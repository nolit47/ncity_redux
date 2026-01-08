if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "M99 Etorphine"
SWEP.Instructions = "The M99 Etorphine is a compact syringe-injector for quick, silent immobilization of targets. Unlike firearms, it delivers etorphine—a potent opioid analgesic originally for large animals—directly into spinal nerves, paralyzing respiratory muscles and causing unconsciousness in 10 seconds.."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/weapons/w_models/w_jyringe_proj.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_poisonneedle")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_poisonneedle"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.WorkWithFake = false
SWEP.offsetVec = Vector(5, -1.5, -0.6)
SWEP.offsetAng = Angle(0, 0, 0)
SWEP.ModelScale = 0.5

function SWEP:Initialize()
    if SERVER then
        self.Uses = 5
    end
end

if SERVER then
    function SWEP:OnRemove() end
end

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.Model)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
	self:SetHold(self.HoldType)
end

SWEP.traceLen = 5

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner())
end

local caninjectbone = {
    ["ValveBiped.Bip01_Spine"] = true,
    ["ValveBiped.Bip01_Spine1"] = true,
    ["ValveBiped.Bip01_Spine2"] = true
}

function SWEP:CanInject(ent,bone) 

    local matrix = ent:GetBoneMatrix(ent:TranslatePhysBoneToBone(bone))
    local pos = matrix:GetTranslation()
    local ang = matrix:GetAngles()

    local TrueVec = ( self.Owner:GetPos() - ent:GetPos() ):GetNormalized()
	local LookVec = ent:GetAngles():Forward() * 1
	local DotProduct = LookVec:DotProduct( TrueVec )
	local ApproachAngle=( -math.deg( math.asin(DotProduct) )+90 )

    return ApproachAngle>=120
end

if CLIENT then
    local MarkedTargets = {}
    
    net.Receive("EtorphineMarker", function()
        local target = net.ReadEntity()
        local addMarker = net.ReadBool()
        
        if addMarker then
            local knockoutTime = net.ReadFloat() -- Time when target will be knocked out
            MarkedTargets[target] = {
                knockoutTime = knockoutTime,
                expireTime = CurTime() + 300 -- 5 minutes
            }
        else
            MarkedTargets[target] = nil
        end
    end)
    
    hook.Add("HUDPaint", "EtorphineMarkerHUD", function()
        for target, data in pairs(MarkedTargets) do
            if not IsValid(target) or CurTime() > data.expireTime then
                MarkedTargets[target] = nil
                continue
            end
            
            local timeLeft = data.knockoutTime - CurTime()
            
            -- Only show marker if countdown is still active
            if timeLeft > 0 then
                local pos = target:EyePos() + Vector(0, 0, 10)
                local screenPos = pos:ToScreen()
                
                if screenPos.visible then
                    local text = string.format("Вырубится через %.1fs", timeLeft)
                    local color = Color(255, 200, 0, 255) -- Orange for countdown
                    
                    draw.SimpleTextOutlined(text, "DermaDefault", screenPos.x, screenPos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.4, Color(0, 0, 0, 200))
                end
            end
        end
    end)
    
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
        local tr = self:GetEyeTrace()
        local toScreen = tr.HitPos:ToScreen()

        if IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsRagdoll())and caninjectbone[tr.Entity:GetBoneName(tr.PhysicsBone)] and self:CanInject(tr.Entity,tr.PhysicsBone) then
            draw.SimpleText( "inject", "DermaLarge", toScreen.x, toScreen.y+25, Color(255,0,0,255), TEXT_ALIGN_CENTER )
            surface.SetDrawColor(195,0,0,155)
            surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
        else
            surface.SetDrawColor(255,255,255,155)
            surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
        end
	end
end

if SERVER then
    util.AddNetworkString("EtorphineMarker")
    
    -- Track who marked whom
    local EtorphineMarkers = {}
    
    -- Remove marker when target dies
    hook.Add("PlayerDeath", "EtorphineMarkerRemove", function(victim)
        if EtorphineMarkers[victim] then
            for owner, _ in pairs(EtorphineMarkers[victim]) do
                if IsValid(owner) then
                    net.Start("EtorphineMarker")
                        net.WriteEntity(victim)
                        net.WriteBool(false) -- Remove marker
                    net.Send(owner)
                end
            end
            EtorphineMarkers[victim] = nil
        end
    end)
    
    -- Clean up on disconnect
    hook.Add("PlayerDisconnected", "EtorphineMarkerCleanup", function(ply)
        EtorphineMarkers[ply] = nil
        for victim, owners in pairs(EtorphineMarkers) do
            if owners[ply] then
                owners[ply] = nil
            end
        end
    end)
    
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Wait )
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if self.Uses <= 0 then return end
    local tr = self:GetEyeTrace()
    if not IsValid(tr.Entity) then return end
    local ent = tr.Entity
    if not (ent:IsPlayer() or ent:IsRagdoll()) then return end
    local bone = tr.PhysicsBone
    local bonename = ent:GetBoneName(bone)
    if not bonename or not caninjectbone[bonename] then return end
    if not self:CanInject(ent, bone) then return end
    self:EmitSound("weapons/knife/knife_deploy1.wav")
    local target
    if ent:IsPlayer() then
        target = ent
    elseif ent:IsRagdoll() then
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetNWEntity("RagdollDeath") == ent then
                target = ply
                break
            elseif ply.FakeRagdoll == ent then
                target = ply
                break
            end
        end
    end
    if not IsValid(target) or not target:IsPlayer() then return end
    local targorg = target.organism
    if not targorg then return end
    self.Uses = self.Uses - 1
    owner:Notify("Uses left: " .. self.Uses, 3)
    
    -- Mark target for owner
    EtorphineMarkers[target] = EtorphineMarkers[target] or {}
    EtorphineMarkers[target][owner] = true
    
    owner.EtorphineTarget = target
    owner.EtorphineMarkTime = CurTime() + 300 -- Mark for 5 minutes
    
    local knockoutTime = CurTime() + 10 -- Will be knocked out in 10 seconds
    net.Start("EtorphineMarker")
        net.WriteEntity(target)
        net.WriteBool(true) -- Add marker
        net.WriteFloat(knockoutTime) -- Send knockout time
    net.Send(owner)
    
    -- Auto-remove marker after 5 minutes
    timer.Simple(300, function()
        if IsValid(owner) and EtorphineMarkers[target] and EtorphineMarkers[target][owner] then
            EtorphineMarkers[target][owner] = nil
            net.Start("EtorphineMarker")
                net.WriteEntity(target)
                net.WriteBool(false) -- Remove marker
            net.Send(owner)
        end
    end)
    
    timer.Simple(10, function()
        if not IsValid(target) or not target:Alive() then return end
        targorg.tranquilizer = 5
        targorg.consciousness = 0
        target:Notify("You feel a strange numbness spreading...", 3)
    end)
end
end