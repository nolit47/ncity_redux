--
local CurTime = CurTime
util.AddNetworkString("hgwep reload")
function SWEP:Reload(time)
	if not self:CanUse() or not self:CanReload() then return end
	self.LastReload = CurTime()
	self:ReloadStart()
	self:ReloadStartPost()
	local org = self:GetOwner().organism
	self.StaminaReloadMul = (org and ((2 - (self:GetOwner().organism.stamina[1] / 180)) + ((org.pain / 40) + (org.larm / 3) + (org.rarm / 5)) - (1 - math.Clamp(org.recoilmul or 1,0.45,1.4))) or 1)
	self.StaminaReloadMul = math.Clamp(self.StaminaReloadMul,0.65,1.5)
	self.StaminaReloadTime = self.ReloadTime * self.StaminaReloadMul
	self.StaminaReloadTime = (self.StaminaReloadTime + (self:Clip1() > 0 and -self.StaminaReloadTime/3 or 0 ))
	self.reload = self.LastReload + self.StaminaReloadTime
	self.dwr_reverbDisable = true
	net.Start("hgwep reload")
		net.WriteEntity(self)
		net.WriteFloat(self.LastReload)
		net.WriteInt(self:Clip1(),10)
		net.WriteFloat(self.StaminaReloadTime)
		net.WriteFloat(self.StaminaReloadMul)
	net.Broadcast()
end

function SWEP:OnCantReload()

end

function SWEP:ReloadStart()
	self:SetHold(self.ReloadHold or self.HoldType)
	hook.Run("HGReloading", self)
	--if self.ReloadSound then self:GetOwner():EmitSound(self.ReloadSound, 60, 100, 0.8, CHAN_AUTO) end
end

if SERVER then return end

-- Create font for caliber display
surface.CreateFont("CaliberFont", {
    font = "Bahnschrift",
    size = ScreenScale(8),
    weight = 600,
    outline = false,
    shadow = true
})

-- Variable to store when caliber should be shown
local caliberShowTime = 0
local caliberShowDuration = 2 -- Show for 2 seconds
local caliberText = ""
local caliberAlpha = 0

-- Hook into the reload key press
hook.Add("PlayerBindPress", "ShowCaliberOnReload", function(ply, bind, pressed)
    if not pressed then return end
    if not string.find(bind, "+reload") then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.ishgwep then return end
    
    -- Get the weapon's caliber from Primary.Ammo
    local caliber = wep.Primary.Ammo or "Unknown"
    
    -- Get current ammo type if weapon has multiple types
    if wep.RealAmmoType then
        caliber = wep.RealAmmoType
    end
    
    -- Format the caliber text
    caliberText = "Caliber: " .. caliber
    caliberShowTime = CurTime() + caliberShowDuration
    caliberAlpha = 0
end)

-- Draw the caliber on HUD
hook.Add("HUDPaint", "DrawCaliberDisplay", function()
    if CurTime() > caliberShowTime then 
        -- Fade out
        caliberAlpha = Lerp(FrameTime() * 5, caliberAlpha, 0)
        if caliberAlpha < 0.01 then return end
    else
        -- Fade in
        caliberAlpha = Lerp(FrameTime() * 10, caliberAlpha, 255)
    end
    
    local scrW, scrH = ScrW(), ScrH()
    local x = scrW * 0.75
    local y = scrH * 0.85
    
    -- Background
    local bgColor = Color(0, 0, 0, 150 * (caliberAlpha / 255))
    local textColor = Color(255, 255, 255, caliberAlpha)
    
    -- Get text dimensions
    surface.SetFont("CaliberFont")
    local textW, textH = surface.GetTextSize(caliberText)
    
    -- Draw background box
    draw.RoundedBox(4, x - textW / 2 - 10, y - textH / 2 - 5, 
                    textW + 20, textH + 10, bgColor)
    
    -- Draw caliber text
    draw.SimpleText(caliberText, "CaliberFont", x, y, 
                   textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Optional: Show current magazine ammo info
    local wep = LocalPlayer():GetActiveWeapon()
    if IsValid(wep) and wep.ishgwep then
        local ammoText = string.format("%d / %d", wep:Clip1(), wep:GetMaxClip1())
        local ammoColor = Color(200, 200, 200, caliberAlpha * 0.8)
        
        draw.SimpleText(ammoText, "CaliberFont", x, y + textH + 5, 
                       ammoColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)