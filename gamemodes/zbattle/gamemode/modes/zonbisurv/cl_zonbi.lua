MODE.name = "survival"

local MODE = MODE

local mapsize = 7500

local roundend = false

local LANG = {}

LANG.en = {
	mode_title = "Homicide | Zombie Survival",
	you_are = "You are a Survivor",
	objective = "Survive the zombie apocalypse.",
	won = " won!",
	nobody = "Nobody",
	close = "Close",
	died = " - died",
	no_bots = "no, you can't",
	he_quited = "He quited..."
}

LANG.ru = {
	mode_title = "Homicide | ЗОМБЕ ВЫЖИВАНИЕ",
	you_are = "Вы выживший",
	objective = "Переживите зомдбэ-апокалипсис.",
	won = " победил!",
	nobody = "Никто не",
	close = "Закрыть",
	died = " - погиб",
	no_bots = "нет нельзя",
	he_quited = "Он вышел..."
}

local function GetLang()
	local gmodLang = GetConVar("gmod_language"):GetString()
	if gmodLang == "ru" then
		return LANG.ru
	end
	return LANG.en
end

local function L(key)
	local lang = GetLang()
	return lang[key] or LANG.en[key] or key
end

net.Receive("survival_start", function()
	roundend = false
	zb.RemoveFade()
	surface.PlaySound("snd_jack_hmcd_survival.mp3")
end)

function MODE:RenderScreenspaceEffects()
	if zb.ROUND_START + 7.5 < CurTime() then return end
	local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)
	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
	if zb.ROUND_START + 20 > CurTime() then
		draw.SimpleText(string.FormattedTime(zb.ROUND_START + 20 - CurTime(), "%02i:%02i:%02i"), "ZB_HomicideMedium", sw * 0.5, sh * 0.75, Color(255, 55, 55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local ply = LocalPlayer()
		if not ply:Alive() then return end
		if zb.ROUND_START + 8.5 < CurTime() then return end
		zb.RemoveFade()
		local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
		draw.SimpleText(L("mode_title"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(L("you_are"), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, Color(0, 255, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(L("objective"), "ZB_HomicideMedium", sw * 0.5, sh * 0.9, Color(0, 255, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

net.Receive("survival_end", function()
	roundend = CurTime()
	hook.Remove("Think", "ZoneSoundThink")
	if MODE.SoundStation and MODE.SoundStation:IsValid() then
		MODE.SoundStation:Stop()
		MODE.SoundStation = nil
	end
	CreateEndMenu()
end)

function MODE:RoundStart()
	for i, ply in ipairs(player.GetAll()) do
		ply.won = nil
	end
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
end

local CreateEndMenu = nil
local wonply = nil

local colGray = Color(85,85,85,255)
local colRed = Color(217,201,99)
local colRedUp = Color(207,181,59)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
    hmcdEndMenu:Remove()
    hmcdEndMenu = nil
end

CreateEndMenu = function()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

    surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")
	
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(L("close"))
		surface.SetTextPos( lenghtX - lenghtX/1.1, 4)
		surface.DrawText(L("close"))
	end

    hmcdEndMenu.Paint = function(self,w,h)
		BlurBackground(self)
		local txt = (wonply and wonply:GetPlayerName() or L("nobody"))..L("won")
		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(txt)
		surface.SetTextPos(w / 2 - lenghtX/2,20)
		surface.DrawText(txt)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i,ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			local col1 = (ply.won and colRed) or (ply:Alive() and colBlue) or colGray
            local col2 = (ply.won and colRedUp) or (ply:Alive() and colBlueUp) or colSpect1
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

            local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lenghtX, lenghtY = surface.GetTextSize( ply:GetPlayerName() or L("he_quited") )
			
			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lenghtY/2 + 1)
			surface.DrawText(ply:GetPlayerName() or L("he_quited"))

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lenghtY/2)
			surface.DrawText(ply:GetPlayerName() or L("he_quited"))

            
			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lenghtX, lenghtY = surface.GetTextSize( ply:GetPlayerName() or L("he_quited") )
			surface.SetTextPos(15,h/2 - lenghtY/2)
			surface.DrawText((ply:Name() .. (not ply:Alive() and L("died") or "")) or L("he_quited"))

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lenghtX, lenghtY = surface.GetTextSize( ply:Frags() or L("he_quited") )
			surface.SetTextPos(w - lenghtX -15,h/2 - lenghtY/2)
			surface.DrawText(ply:Frags() or L("he_quited"))
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), L("no_bots")) return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	return true
end