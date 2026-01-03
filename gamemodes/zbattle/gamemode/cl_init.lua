zb = zb or {}
include("shared.lua")
include("loader.lua")

zb.Languages = {
    ["en"] = {
        ["spectating_player"] = "Spectating player: ",
        ["ingame_name"] = "In-game name: ",
        ["players"] = "Players:",
        ["spectators"] = "Spectators:",
        ["server_tick"] = "Server Tick: ",
        ["mute_all"] = "Mute all",
        ["mute_spectators"] = "Mute spectators",
        ["join"] = "Join",
        ["mute"] = "Mute",
        ["account"] = "Account",
        ["medal"] = "Medal",
        ["no_permission"] = "no, you can't",
        ["snake_game"] = "Snake Game",
        ["snake_game_over"] = "Game Over! Press R to restart",
        ["score"] = "Score: ",
        ["he_quit"] = "He quit...",
    },
    ["ru"] = {
        ["spectating_player"] = "Наблюдение за: ",
        ["ingame_name"] = "Игровое имя: ",
        ["players"] = "Игроки:",
        ["spectators"] = "Наблюдатели:",
        ["server_tick"] = "Тикрейт: ",
        ["mute_all"] = "Замьютить всех",
        ["mute_spectators"] = "Замьютить мертвых",
        ["join"] = "Войти",
        ["mute"] = "Замьютить",
        ["account"] = "Аккаунт",
        ["medal"] = "Медаль",
        ["no_permission"] = "Нет, тебе нельзя",
        ["snake_game"] = "Змейка",
        ["snake_game_over"] = "Игра окончена! Нажми R для рестарта",
        ["score"] = "Счет: ",
        ["he_quit"] = "Вышел...",
    }
}

function zb:GetTerm(key)
    local lang = (GetConVar("gmod_language"):GetString() == "russian") and "ru" or "en"
    return (self.Languages[lang] and self.Languages[lang][key]) or self.Languages["en"][key] or key
end
--------------------------------------------------------------------------------

function CurrentRound()
	return zb.modes[zb.CROUND]
end

zb.ROUND_STATE = 0
--0 = players can join, 1 = round is active, 2 = endround
local vecZero = Vector(0.2, 0.2, 0.2)
local vecFull = Vector(1, 1, 1)
spect,prevspect,viewmode = nil,nil,1
local hullscale = Vector(0,0,0)
net.Receive("Player_Spect", function(len)
	spect = net.ReadEntity()
	prevspect = net.ReadEntity()
	viewmode = net.ReadInt(4)

	timer.Simple(0.1,function()
		LocalPlayer():BoneScaleChange()
		LocalPlayer():SetHull(-hullscale,hullscale)
		LocalPlayer():SetHullDuck(-hullscale,hullscale)

		if viewmode == 3 then
			LocalPlayer():SetMoveType(MOVETYPE_NOCLIP)
		end
	end)
end)

zb.ROUND_TIME = zb.ROUND_TIME or 400
zb.ROUND_START = zb.ROUND_START or CurTime()
zb.ROUND_BEGIN = zb.ROUND_BEGIN or CurTime() + 5

net.Receive("updtime",function()
	local time = net.ReadFloat()
	local time2 = net.ReadFloat()
	local time3 = net.ReadFloat()

	zb.ROUND_TIME = time
	zb.ROUND_START = time2
	zb.ROUND_BEGIN = time3
end)

local keydownattack
local keydownattack2
local keydownreload

hook.Add("HUDPaint","FUCKINGSAMENAMEUSEDINHOOKFUCKME",function()
    if LocalPlayer():Alive() then return end
	local spect = LocalPlayer():GetNWEntity("spect")
	if not IsValid(spect) then return end
	if viewmode == 3 then return end
	
	surface.SetFont("HomigradFont")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = zb:GetTerm("spectating_player")..spect:Name()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7)
	surface.DrawText(txt)
	local txt = zb:GetTerm("ingame_name")..spect:GetPlayerName()
	local w, h = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 8 * 7 + h)
	surface.DrawText(txt)
end)

hook.Add("HG_CalcView", "zzzzzzznigger", function(ply, pos, angles, fov)
	if not lply:Alive() then
		if lply:KeyDown(IN_ATTACK) then
			if not keydownattack then
				keydownattack = true
				net.Start("zb_choosehuy_yay")
				net.WriteInt(IN_ATTACK,32)
				net.SendToServer()
			end
		else
			keydownattack = false
		end

		if lply:KeyDown(IN_ATTACK2) then
			if not keydownattack2 then
				keydownattack2 = true
				net.Start("zb_choosehuy_yay")
				net.WriteInt(IN_ATTACK2,32)
				net.SendToServer()
			end
		else
			keydownattack2 = false
		end

		if lply:KeyDown(IN_RELOAD) then
			if not keydownreload then
				keydownreload = true
				net.Start("zb_choosehuy_yay")
				net.WriteInt(IN_RELOAD,32)
				net.SendToServer()
			end
		else
			keydownreload = false
		end

		local spect = lply:GetNWEntity("spect",spect)
		if not IsValid(spect) then return end

		local viewmode = lply:GetNWInt("viewmode",viewmode)
		
		if viewmode == 3 then
			if lply:GetMoveType()!=MOVETYPE_NOCLIP then
				lply:SetMoveType(MOVETYPE_NOCLIP)
			end
			lply:SetObserverMode(OBS_MODE_ROAMING)
		end
		
		local ent = hg.GetCurrentCharacter(spect)
		local bon = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Head1") or 1)
		
		if not bon then return end
		
		local pos,ang = bon:GetTranslation(),bon:GetAngles()

		local eyePos,eyeAng = lply:EyePos(),lply:EyeAngles()
		
		local tr = {}
		tr.start = pos
		tr.endpos = pos + eyeAng:Forward() * -100
		tr.filter = ent
		tr = util.TraceLine(tr)

		pos = (viewmode == 2 and tr.HitPos + eyeAng:Forward() * 5) or (viewmode == 3 and eyePos) or (pos + spect:EyeAngles():Forward() * 5)
		ang  = (viewmode == 1 and (ent~=spect and ent:GetAttachment(ent:LookupAttachment("eyes")).Ang or spect:EyeAngles())) or eyeAng
		
		ang[3] = 0

		local view = {
			origin = pos,
			angles = ang,
			fov = fov,
		}

	else
		lply:SetObserverMode(OBS_MODE_NONE)
	end
end)

zb.ROUND_STATE = 0
net.Receive("RoundInfo", function()
	local rnd = net.ReadString()
	
	if zb.CROUND ~= rnd then
		if hg.DynaMusic then
			hg.DynaMusic:Stop()
		end
	end

	zb.CROUND = rnd

	zb.ROUND_STATE = net.ReadInt(4)

	if zb.CROUND ~= "" then
		if CurrentRound() then
			if CurrentRound().RoundStart then
				CurrentRound():RoundStart()
			end
		end
	end
end)

if IsValid(scoreBoardMenu) then
	scoreBoardMenu:Remove()
	scoreBoardMenu = nil
end

hook.Add("Player Disconnected","retrymenu",function(data)
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
end)

local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function()
    local usefont = "Bahnschrift"
    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end
    return usefont
end

surface.CreateFont("ZB_InterfaceSmall", { font = font(), size = ScreenScale(6), weight = 400, antialias = true })
surface.CreateFont("ZB_InterfaceMedium", { font = font(), size = ScreenScale(10), weight = 400, antialias = true })
surface.CreateFont("ZB_InterfaceMediumLarge", { font = font(), size = 35, weight = 400, antialias = true })
surface.CreateFont("ZB_InterfaceLarge", { font = font(), size = ScreenScale(20), weight = 400, antialias = true })
surface.CreateFont("ZB_InterfaceHumongous", { font = font(), size = 200, weight = 400, antialias = true })

hg.playerInfo = hg.playerInfo or {}

local function addToPlayerInfo(ply, muted, volume)
	hg.playerInfo[ply:SteamID()] = {muted and true or false, volume}
	local json = util.TableToJSON(hg.playerInfo)
	file.Write("zcity_muted.txt", json)
	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")
		if json then hg.playerInfo = util.JSONToTable(json) end
	end
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "zcityhuy", function(data)
	if hg.playerInfo and hg.playerInfo[data.networkid] then
		Player(data.userid):SetMuted(hg.playerInfo[data.networkid][1])
		Player(data.userid):SetVoiceVolumeScale(hg.playerInfo[data.networkid][2])
	end
end)

hook.Add("InitPostEntity", "higgershuy", function()
	if file.Exists("zcity_muted.txt", "DATA") then
		local json = file.Read("zcity_muted.txt", "DATA")
		if json then hg.playerInfo = util.JSONToTable(json) end
		local plrs = player.GetAll()
		if hg.playerInfo then
			for i, ply in ipairs(plrs) do
				if not istable(hg.playerInfo[ply:SteamID()]) then
					local muted = hg.playerInfo[ply:SteamID()]
					hg.playerInfo[ply:SteamID()] = {}
					hg.playerInfo[ply:SteamID()][1] = muted
					hg.playerInfo[ply:SteamID()][2] = 1
				end
				if hg.playerInfo[ply:SteamID()] then
					ply:SetMuted(hg.playerInfo[ply:SteamID()][1])
					ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
				end
			end	
		end
	end
end)

local colGray = Color(122,122,122,255)
local colBlue = Color(130,10,10)
local colBlueUp = Color(160,30,30)
local col = Color(255,255,255,255)
local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(85,85,85,255)

local blur = Material("pp/blurscreen")
local hg_potatopc
hg = hg or {}
function hg.DrawBlur(panel, amount, passes, alpha)
	if is3d2d then return end
	amount = amount or 5
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc
	if(hg_potatopc:GetBool())then
		surface.SetDrawColor(0, 0, 0, alpha or (amount * 20))
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	else
		surface.SetMaterial(blur)
		surface.SetDrawColor(0, 0, 0, alpha or 125)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		local x, y = panel:LocalToScreen(0, 0)
		for i = -(passes or 0.2), 1, 0.2 do
			blur:SetFloat("$blur", i * amount)
			blur:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end
end

BlurBackground = BlurBackground or hg.DrawBlur

hg.muteall = false
hg.mutespect = false

local function OpenPlayerSoundSettings(selfa, ply)
	local Menu = DermaMenu()
	if not hg.playerInfo[ply:SteamID()] or not istable(hg.playerInfo[ply:SteamID()]) then addToPlayerInfo(ply, false, 1) end

	local mute = Menu:AddOption( zb:GetTerm("mute"), function(self)
		if hg.muteall || hg.mutespect then return end
		self:SetChecked(not ply:IsMuted())
		ply:SetMuted( not ply:IsMuted() )
		selfa:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png")
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end )

	mute:SetIsCheckable( true )
	mute:SetChecked( ply:IsMuted() )
	local volumeSlider = vgui.Create("DSlider", Menu)
	volumeSlider:SetLockY( 0.5 )
	volumeSlider:SetTrapInside( true )
	volumeSlider:SetSlideX(hg.playerInfo[ply:SteamID()][2]) 
	volumeSlider.OnValueChanged = function(self, x, y)
		if not IsValid(ply) then return end
		if hg.muteall or (hg.mutespect && !ply:Alive()) then return end
		hg.playerInfo[ply:SteamID()][2] = x
		ply:SetVoiceVolumeScale(hg.playerInfo[ply:SteamID()][2])
		addToPlayerInfo(ply, ply:IsMuted(), hg.playerInfo[ply:SteamID()][2])
	end

	function volumeSlider:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0 ) )
		draw.RoundedBox( 0, 0, 0, w*self:GetSlideX(), h, Color( 255, 0, 0 ) )
		draw.DrawText( ( math.Round( 100*self:GetSlideX(), 0 ) ).."%", "DermaDefault", w/2, h/4, color_white, TEXT_ALIGN_CENTER )
	end
	function volumeSlider.Knob.Paint(self) end

	Menu:AddPanel(volumeSlider)
	Menu:Open()
end

hook.Add("Player Getup", "nomorespect", function(ply)
	if not hg.mutespect then return end
	ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
end)

hook.Add("Player Death", "isspect", function(ply)
	if not hg.mutespect then return end
	ply:SetVoiceVolumeScale(0)
end)

function GM:ScoreboardShow()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Remove()
		scoreBoardMenu = nil
	end
	Dynamic = 0
	scoreBoardMenu = vgui.Create("ZFrame")
	local sizeX,sizeY = ScrW() / 1.3 ,ScrH() / 1.2
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

	scoreBoardMenu:SetPos(posX,posY)
	scoreBoardMenu:SetSize(sizeX,sizeY)
	scoreBoardMenu:MakePopup()
	scoreBoardMenu:SetKeyboardInputEnabled( false )
	scoreBoardMenu:ShowCloseButton( false )

	local muteallbut = vgui.Create("DButton", scoreBoardMenu)
	local w, h = ScreenScale(30),ScreenScale(6)
	muteallbut:SetPos(ScreenScale(60),scoreBoardMenu:GetTall() - h * 1.5)
	muteallbut:SetSize(w, h)
	muteallbut:SetText(zb:GetTerm("mute_all"))
	
	muteallbut.Paint = function(self,w,h)
		surface.SetDrawColor( not hg.muteall and 255 or 0, hg.muteall and 255 or 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	muteallbut.DoClick = function(self,w,h)
		hg.muteall = not hg.muteall
		for i,ply in ipairs(player.GetAll()) do
			if hg.muteall then
				ply:SetVoiceVolumeScale(0)
			else
				ply:SetVoiceVolumeScale((!hg.mutespect or ply:Alive()) and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
			end
		end 
	end

	local mutespectbut = vgui.Create("DButton", scoreBoardMenu)
	local w, h = ScreenScale(30),ScreenScale(6)
	mutespectbut:SetPos(ScreenScale(60 + 35),scoreBoardMenu:GetTall() - h * 1.5)
	mutespectbut:SetSize(w, h)
	mutespectbut:SetText(zb:GetTerm("mute_spectators"))
	
	mutespectbut.Paint = function(self,w,h)
		surface.SetDrawColor( not hg.mutespect and 255 or 0, hg.mutespect and 255 or 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	mutespectbut.DoClick = function(self,w,h)
		hg.mutespect = not hg.mutespect
		for i,ply in ipairs(player.GetAll()) do
			if ply:Alive() then continue end
			if hg.mutespect then
				ply:SetVoiceVolumeScale(0)
			else
				ply:SetVoiceVolumeScale(!hg.muteall and (hg.playerInfo[ply:SteamID()] and hg.playerInfo[ply:SteamID()][2] or 1) or 0)
			end
		end 
	end

	local ServerName = "Z-CITY | СОВЕРШЕННЫЕ СИСЬКИ 18+ | !VIPTEST | ПАУТИНКА"
	local tick
	scoreBoardMenu.PaintOver = function(self,w,h)
		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

		surface.SetFont( "ZB_InterfaceLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(ServerName)
		surface.SetTextPos(w / 2 - lenghtX/2,10)
		surface.DrawText(ServerName)

		surface.SetFont( "ZB_InterfaceSmall" )
		surface.SetTextColor(col.r,col.g,col.b,col.a*0.1)
		local txt = "ZBattle version: "..zb.Version
		local lenghtX, lenghtY = surface.GetTextSize(txt)
		surface.SetTextPos(w*0.01,h - lenghtY - h*0.01)
		surface.DrawText(txt)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(zb:GetTerm("players"))
		surface.SetTextPos(w / 4 - lenghtX/2,ScreenScale(25))
		surface.DrawText(zb:GetTerm("players"))

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(zb:GetTerm("spectators"))
		surface.SetTextPos(w * 0.75 - lenghtX/2,ScreenScale(25))
		surface.DrawText(zb:GetTerm("spectators"))
		tick = math.Round(Lerp(0.025, tick or math.Round(1 / engine.ServerFrameTime(),1), math.Round(1 / engine.ServerFrameTime(),1)),1)
		local txt = zb:GetTerm("server_tick") .. tick
		local lenghtX, lenghtY = surface.GetTextSize(txt)
		surface.SetTextPos(w * 0.5 - lenghtX/2,ScreenScale(25))
		surface.DrawText(txt)
	end

	if LocalPlayer():Team() ~= TEAM_SPECTATOR then
		local SPECTATE = vgui.Create("DButton",scoreBoardMenu)
		SPECTATE:SetPos(sizeX * 0.925,sizeY * 0.095)
		SPECTATE:SetSize(ScrW() / 20,ScrH() / 30)
		SPECTATE:SetText("")
		SPECTATE.DoClick = function()
			net.Start("SpectatorMode")
				net.WriteBool(true)
			net.SendToServer()
			scoreBoardMenu:Remove()
			scoreBoardMenu = nil
		end
		SPECTATE.Paint = function(self,w,h)
			surface.SetDrawColor( 255, 0, 0, 128)
			surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
			surface.SetFont( "ZB_InterfaceMedium" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local txt = zb:GetTerm("join")
			local lx, ly = surface.GetTextSize(txt)
			surface.SetTextPos(w/2 - lx/2, h/2 - ly/2)
			surface.DrawText(txt)
		end
	end

	if LocalPlayer():Team() == TEAM_SPECTATOR then
		local PLAYING = vgui.Create("DButton",scoreBoardMenu)
		PLAYING:SetPos(sizeX * 0.010,sizeY * 0.095)
		PLAYING:SetSize(ScrW() / 20,ScrH() / 30)
		PLAYING:SetText("")
		PLAYING.DoClick = function()
			net.Start("SpectatorMode")
				net.WriteBool(false)
			net.SendToServer()
			scoreBoardMenu:Remove()
			scoreBoardMenu = nil
		end
		PLAYING.Paint = function(self,w,h)
			surface.SetDrawColor( 255, 0, 0, 128)
			surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
			surface.SetFont( "ZB_InterfaceMedium" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local txt = zb:GetTerm("join")
			local lx, ly = surface.GetTextSize(txt)
			surface.SetTextPos(w/2 - lx/2, h/2 - ly/2)
			surface.DrawText(txt)
		end
	end

	local DScrollPanel = vgui.Create("DScrollPanel", scoreBoardMenu)
	DScrollPanel:SetPos(10, ScreenScaleH(58))
	DScrollPanel:SetSize(sizeX/2 - 10, sizeY - ScreenScaleH(72))
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)
		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton", DScrollPanel)
		but:SetSize(100, ScreenScaleH(22))
		but:Dock(TOP)
		but:DockMargin(8, 6, 8, -1)
		but:SetText("")
		local soundButton = vgui.Create("DImageButton", but)
		soundButton:Dock(RIGHT)
		soundButton:SetSize( 30, 0 )
		soundButton:DockMargin(5,10,45,10)
		soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png") 
		soundButton.DoClick = function(self) OpenPlayerSoundSettings(self, ply) end
		ply.soundButton = soundButton
		but.Paint = function(self, w, h)
			if not IsValid(ply) then return end
			surface.SetDrawColor(colBlueUp.r, colBlueUp.g, colBlueUp.b, colBlueUp.a)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(colBlue.r, colBlue.g, colBlue.b, colBlue.a)
			surface.DrawRect(0, h / 2, w, h / 2)
			surface.SetFont("ZB_InterfaceMediumLarge")
			surface.SetTextColor(col.r, col.g, col.b, col.a)
			local name = ply:Name() or zb:GetTerm("he_quit")
			local lx, ly = surface.GetTextSize(name)
			surface.SetTextPos(15, h / 2 - ly / 2)
			surface.DrawText(name)
			local ping = tostring(ply:Ping())
			local lx2, ly2 = surface.GetTextSize(ping)
			surface.SetTextPos(w - lx2 - 15, h / 2 - ly2 / 2)
			surface.DrawText(ping)
		end
		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), zb:GetTerm("no_permission")) return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end
		function but:DoRightClick()
			local Menu = DermaMenu()
			Menu:AddOption( zb:GetTerm("account"), function() zb.Experience.AccountMenu( ply ) end)
			Menu:AddOption( zb:GetTerm("medal"), function() 
				zb.Experience.OpenMenu(ply)
				timer.Simple( .1, function() zb.Experience.Menu(ply) end)
			end) 
			Menu:Open()
		end
		DScrollPanel:AddItem(but)
	end

	local DScrollPanelSpec = vgui.Create("DScrollPanel", scoreBoardMenu)
	DScrollPanelSpec:SetPos(sizeX/2 + 5, ScreenScaleH(58))
	DScrollPanelSpec:SetSize(sizeX/2 - 15, sizeY - ScreenScaleH(72))
	function DScrollPanelSpec:Paint( w, h )
		BlurBackground(self)
		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i,ply in ipairs(player.GetAll()) do
		if ply:Team() ~= TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanelSpec)
		but:SetSize(100,ScreenScaleH(22))
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		local soundButton = vgui.Create("DImageButton", but)
		soundButton:Dock(RIGHT)
		soundButton:SetSize( 30, 0 )
		soundButton:DockMargin(5,10,45,10)
		soundButton:SetImage(not ply:IsMuted() && "icon16/sound.png" || "icon16/sound_mute.png") 
		soundButton.DoClick = function(self) OpenPlayerSoundSettings(self, ply) end
		ply.soundButton = soundButton
		but.Paint = function(self,w,h)
			if not IsValid(ply) then return end
			surface.SetDrawColor(colSpect2.r,colSpect2.g,colSpect2.b,colSpect2.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(colSpect1.r,colSpect1.g,colSpect1.b,colSpect1.a)
			surface.DrawRect(0,h/2,w,h/2)
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local name = ply:Name() or zb:GetTerm("he_quit")
			local lx, ly = surface.GetTextSize(name)
			surface.SetTextPos(15,h/2 - ly/2)
			surface.DrawText(name)
			local ping = tostring(ply:Ping())
			local lx2, ly2 = surface.GetTextSize(ping)
			surface.SetTextPos(w - lx2 -15,h/2 - ly2/2)
			surface.DrawText(ping)
		end
		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), zb:GetTerm("no_permission")) return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end
		function but:DoRightClick()
			local Menu = DermaMenu()
			Menu:AddOption( zb:GetTerm("account"), function() zb.Experience.AccountMenu( ply ) end)
			Menu:AddOption( zb:GetTerm("medal"), function() 
				zb.Experience.OpenMenu(ply)
				timer.Simple( .1, function() zb.Experience.Menu(ply) end)
			end) 
			Menu:Open()
		end
		DScrollPanelSpec:AddItem(but)
	end
	return true
end

function GM:ScoreboardHide()
	if IsValid(scoreBoardMenu) then
		scoreBoardMenu:Close()
		scoreBoardMenu = nil
	end
end

hook.Add("PlayerStartVoice","asd",function(ply)
	if not IsValid(ply) then return end
	return (ply:Alive() and LocalPlayer()!=ply) or nil
end)

if CLIENT then
	net.Receive("PunishLightningEffect", function()
		local target = net.ReadEntity()
		if not IsValid(target) then return end
		local dlight = DynamicLight(target:EntIndex())
		if dlight then
			dlight.pos = target:GetPos()
			dlight.r = 126
			dlight.g = 139
			dlight.b = 212
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 500
			dlight.DieTime = CurTime() + 1
		end
	end)
end

local lightningMaterial = Material("sprites/lgtning")
net.Receive("AnotherLightningEffect", function()
    local target = net.ReadEntity()
	if not IsValid(target) then return end
    local points = {}
    for i = 1, 27 do
        points[i] = target:GetPos() + Vector(0, 0, i * 50) + Vector(math.Rand(-20,20),math.Rand(-20,20),math.Rand(-20,20))
    end
    hook.Add( "PreDrawTranslucentRenderables", "LightningExample", function(isDrawingDepth, isDrawingSkybox)
        if isDrawingDepth or isDrawingSkybox then return end
        local uv = math.Rand(0, 1)
        render.OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD )
        render.SetMaterial(lightningMaterial)
        render.StartBeam(27)
        for i = 1, 27 do
            render.AddBeam(points[i], 20, uv * i, Color(255,255,255,255))
        end
        render.EndBeam()
        render.OverrideBlend( false )
    end )
    timer.Simple(0.1, function()
        hook.Remove("PreDrawTranslucentRenderables", "LightningExample")
    end)
end)

function GM:AddHint( name, delay ) return false end

local snakeGameOpen = false
concommand.Add("zb_snake", function()
    if snakeGameOpen then return end
    local frame = vgui.Create("ZFrame")
    frame:SetTitle(zb:GetTerm("snake_game"))
    frame:SetSize(400, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetDeleteOnClose(true)  
    snakeGameOpen = true  

    local gridSize = 20
    local gridWidth, gridHeight = 19, 19
    local snakePanel = vgui.Create("DPanel", frame)
    snakePanel:SetSize(380, 380)
    snakePanel:SetPos(10, 10)

    local snake = {{x = 10, y = 10}}
    local snakeDirection = "RIGHT"
    local food = nil
    local score = 0
    local gameRunning = true

    local function spawnFood()
        local valid = false
        while not valid do
            food = { x = math.random(0, gridWidth - 1), y = math.random(0, gridHeight - 1) }
            valid = true
            for _, s in ipairs(snake) do if s.x == food.x and s.y == food.y then valid = false break end end
        end
    end

    local function resetGame()
        snake = {{x = 10, y = 10}}
        snakeDirection = "RIGHT"
        score = 0
        gameRunning = true
        spawnFood()  
    end

    function snakePanel:Paint(w, h)
        surface.SetDrawColor(50, 50, 50, 255)
        surface.DrawRect(0, 0, w, h)
        if gameRunning then
            surface.SetDrawColor(0, 255, 0, 255)
            for _, s in ipairs(snake) do surface.DrawRect(s.x * gridSize, s.y * gridSize, gridSize - 1, gridSize - 1) end
            if food then
                surface.SetDrawColor(255, 0, 0, 255)
                surface.DrawRect(food.x * gridSize, food.y * gridSize, gridSize - 1, gridSize - 1)
            end
        else
            draw.SimpleText(zb:GetTerm("snake_game_over"), "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        draw.SimpleText(zb:GetTerm("score") .. score, "DermaDefault", 10, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    function frame:OnKeyCodePressed(key)
        if key == KEY_W and snakeDirection ~= "DOWN" then snakeDirection = "UP"
        elseif key == KEY_S and snakeDirection ~= "UP" then snakeDirection = "DOWN"
        elseif key == KEY_A and snakeDirection ~= "RIGHT" then snakeDirection = "LEFT"
        elseif key == KEY_D and snakeDirection ~= "LEFT" then snakeDirection = "RIGHT"
        elseif key == KEY_R then resetGame() end
    end

    timer.Create("SnakeGameTimer", 0.2, 0, function()
        if not gameRunning then return end
        local head = table.Copy(snake[1])
        if snakeDirection == "UP" then head.y = head.y - 1
        elseif snakeDirection == "DOWN" then head.y = head.y + 1
        elseif snakeDirection == "LEFT" then head.x = head.x - 1
        elseif snakeDirection == "RIGHT" then head.x = head.x + 1 end

        if head.x < 0 or head.x >= gridWidth or head.y < 0 or head.y >= gridHeight then gameRunning = false end
        for _, s in ipairs(snake) do if s.x == head.x and s.y == head.y then gameRunning = false end end

        if gameRunning then
            table.insert(snake, 1, head)
            if food and head.x == food.x and head.y == food.y then score = score + 1 spawnFood()
            else table.remove(snake) end
        end
        if IsValid(snakePanel) then snakePanel:InvalidateLayout(true) end
    end)

    frame.OnClose = function()
        timer.Remove("SnakeGameTimer")
        snakeGameOpen = false  
    end
    resetGame()
end)

hook.Add("Player Spawn", "GuiltKnown", function(ply)
	if ply == LocalPlayer() then system.FlashWindow() end
end)