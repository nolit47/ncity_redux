
local PANEL = {}

local L = {
    ["en"] = {
        ["Optimization"] = "Optimization",
        ["Blood"] = "Blood",
        ["UI"] = "UI",
        ["Weapons"] = "Weapons",
        ["View"] = "View",
        ["Sound"] = "Sound",
        ["Gameplay"] = "Gameplay",
        ["ZCity Settings"] = "ZCity Settings",
        
        ["Potato PC Mode"] = "Potato PC Mode",
        ["Animations draw distance"] = "Animations draw distance",
        ["Animations FPS"] = "Animations FPS",
        ["Attachment draw distance"] = "Attachment draw distance",
        ["Maximum smoke trails"] = "Maximum smoke trails",
        ["TPIK Render distance"] = "TPIK Render distance",
        ["Blood draw distance"] = "Blood draw distance",
        ["Blood FPS"] = "Blood FPS",
        ["Blood sprites (DISABLED FOR EVERYONE)"] = "Blood sprites (DISABLED FOR EVERYONE)",
        ["Use new blood decals"] = "Use new blood decals",
        ["Change custom font"] = "Change custom font",
        ["Shotting blur"] = "Shooting blur",
        ["Dynamic ammo"] = "Dynamic ammo",
        ["FP death"] = "First person death",
        ["FOV"] = "Field of View",
        ["Cool gloves"] = "Cool gloves",
        ["Gloves model"] = "Gloves model",
        ["C'sHS Ragdoll camera"] = "C'sHS Ragdoll camera",
        ["Gun camera (ADMIN ONLY)"] = "Gun camera (ADMIN ONLY)",
        ["Disable/Enable fov zoom"] = "Disable/Enable FOV zoom",
        ["Dynamic music"] = "Dynamic music",
        ["New sounds"] = "New sounds",
        ["Enable/disable quietshoot sounds (FOR PUSSY)"] = "Enable/disable quiet shooting sounds",
        ["Old notificate"] = "Old notifications",
        ["Enable/Disable random appearance"] = "Enable/Disable random appearance",
        ["Enable/Disable cheats in game"] = "Enable/Disable cheats in game",
        ["Your cool var "] = "Your cool var ",
        ["Enable/Disable otrub system (ADMIN ONLY)"] = "Enable/Disable unconsciousness system (ADMIN ONLY)",
        ["Enable/Disable fear system (ADMIN ONLY)"] = "Enable/Disable fear system (ADMIN ONLY)",
    },
    ["ru"] = {
        ["Optimization"] = "Оптимизация",
        ["Blood"] = "Кровь",
        ["UI"] = "Интерфейс",
        ["Weapons"] = "Оружие",
        ["View"] = "Вид",
        ["Sound"] = "Звук",
        ["Gameplay"] = "Геймплей",
        ["ZCity Settings"] = "Настройки ZCity",
        
        ["Potato PC Mode"] = "Режим слабого компукутера",
        ["Animations draw distance"] = "Дистанция рендера анимаций",
        ["Animations FPS"] = "ФПС анимаций",
        ["Attachment draw distance"] = "Дистанция рендера атачментов",
        ["Maximum smoke trails"] = "Максимум дымовых партиклов",
        ["TPIK Render distance"] = "Дистанция рендера TPIK",
        ["Blood draw distance"] = "Дистанция рендера крови",
        ["Blood FPS"] = "FPS крови",
        ["Blood sprites (DISABLED FOR EVERYONE)"] = "Спрайты крови (ВЫКЛЮЧЕНО ДЛЯ ВСЕХ)",
        ["Use new blood decals"] = "Использовать новые декали крови",
        ["Change custom font"] = "Изменить пользовательский шрифт",
        ["Shotting blur"] = "Размытие при стрельбе",
        ["Dynamic ammo"] = "Динамичные патроны",
        ["FP death"] = "Смерть от первого лица",
        ["FOV"] = "ФОВЧИК 120 КАЛ ОФ ДЮТИ",
        ["Cool gloves"] = "cool перчатки кsго",
        ["Gloves model"] = "Модель перчаток",
        ["C'sHS Ragdoll camera"] = "Камера рэгдолла C'sHS",
        ["Gun camera (ADMIN ONLY)"] = "Камера оружия (ТОЛЬКО АДМИН)",
        ["Disable/Enable fov zoom"] = "Отключить/Включить зум фова",
        ["Dynamic music"] = "Динамичная музыка",
        ["New sounds"] = "Новые звуки",
        ["Enable/disable quietshoot sounds (FOR PUSSY)"] = "Включить/выключить тихие звуки стрельбы",
        ["Old notificate"] = "Старые уведомления",
        ["Enable/Disable random appearance"] = "Включить/Выключить случайную внешность",
        ["Enable/Disable cheats in game"] = "Включить/Выключить читы в игре",
        ["Your cool var "] = "че",
        ["Enable/Disable otrub system (ADMIN ONLY)"] = "Включить/Выключить систему отруба",
        ["Enable/Disable fear system (ADMIN ONLY)"] = "Включить/Выключить систему страха (ТОЛЬКО АДМИН4ИКОВ)",
    }
}

local function GetLocalizedString(key)
    local lang = GetConVar("gmod_language"):GetString()
    if L[lang] and L[lang][key] then
        return L[lang][key]
    elseif L["en"][key] then
        return L["en"][key]
    end
    
    return key
end

hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}
function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false }
end

hg.settings:AddOpt("Optimization","hg_potatopc", "Potato PC Mode")
hg.settings:AddOpt("Optimization","hg_anims_draw_distance", "Animations draw distance")
hg.settings:AddOpt("Optimization","hg_anim_fps", "Animations FPS")
hg.settings:AddOpt("Optimization","hg_attachment_draw_distance", "Attachment draw distance")
hg.settings:AddOpt("Optimization","hg_maxsmoketrails", "Maximum smoke trails")
hg.settings:AddOpt("Optimization","hg_tpik_distance", "TPIK Render distance")

hg.settings:AddOpt("Blood","hg_blood_draw_distance", "Blood draw distance")
hg.settings:AddOpt("Blood","hg_blood_fps", "Blood FPS")
hg.settings:AddOpt("Blood","hg_blood_sprites", "Blood sprites (DISABLED FOR EVERYONE)")
hg.settings:AddOpt("Blood","hg_new_blood", "Use new blood decals")

hg.settings:AddOpt("UI","hg_font", "Change custom font", false, true)

hg.settings:AddOpt("Weapons","hg_weaponshotblur_enable", "Shotting blur")
hg.settings:AddOpt("Weapons","hg_dynamic_mags", "Dynamic ammo")

hg.settings:AddOpt("View","hg_firstperson_death", "FP death")
hg.settings:AddOpt("View","hg_fov", "FOV")
hg.settings:AddOpt("View","hg_coolgloves", "Cool gloves")
hg.settings:AddOpt("View","hg_change_gloves", "Gloves model")
hg.settings:AddOpt("View","hg_cshs_fake", "C'sHS Ragdoll camera")
hg.settings:AddOpt("View","hg_gun_cam", "Gun camera (ADMIN ONLY)")
hg.settings:AddOpt("View","hg_nofovzoom", "Disable/Enable fov zoom")
 
hg.settings:AddOpt("Sound","hg_dmusic", "Dynamic music")
hg.settings:AddOpt("Sound","hg_newsounds", "New sounds")
hg.settings:AddOpt("Sound","hg_quietshots", "Enable/disable quietshoot sounds (FOR PUSSY)")

hg.settings:AddOpt("Gameplay","hg_old_notificate", "Old notificate")
hg.settings:AddOpt("Gameplay","hg_random_appearance", "Enable/Disable random appearance")
hg.settings:AddOpt("Gameplay","hg_cheats", "Enable/Disable cheats in game")
hg.settings:AddOpt("Gameplay","hg_otrub", "Enable/Disable otrub system (ADMIN ONLY)")
hg.settings:AddOpt("Gameplay","hg_fear", "Enable/Disable fear system (ADMIN ONLY)")

hg.serverConvars = hg.serverConvars or {}

net.Receive("hg_sync_server_convar", function()
    local convarName = net.ReadString()
    local value = net.ReadBool()
    hg.serverConvars[convarName] = value
    hook.Run("hg_server_convar_updated_" .. convarName)
end)

net.Receive("hg_sync_fear_convar", function()
    local convarName = net.ReadString()
    local value = net.ReadBool()
    hg.serverConvars[convarName] = value
    hook.Run("hg_server_convar_updated_" .. convarName)
end)

function PANEL:Init()
    self:SetAlpha( 0 )
    self:SetSize( ScrW()*1, ScrH()*1 )
    self:SetY( ScrH() )
    self:SetX( ScrW() / 2 - self:GetWide() / 2 )
    self:SetTitle( "" )
    self:SetBorder( false )
    self:SetColorBG( Color(10,10,25,245) )
    self:SetBlurStrengh( 2 )
    self:SetDraggable( false )
    self:ShowCloseButton( true )
    self.Options = {}

    timer.Simple(0,function()
        self:First()
    end)

    self.fDock = vgui.Create("DScrollPanel",self)
    local fDock = self.fDock
    fDock:Dock( FILL )

    self:CreateCategory( "ZCity Settings" )

    RunConsoleCommand("hg_request_server_convars")
    RunConsoleCommand("hg_request_fear_convar")
    
    for k,t in SortedPairs(hg.settings.tbl) do
        for _,tbl in SortedPairs(t) do
            local convar = GetConVar(tbl[2])
            if convar then
                self:CreateOption(tbl[1],convar:GetMax() == 1,convar, tbl[4], tbl[3] or convar:GetName(), nil, tbl[5])
            else
                self:CreateServerOption(tbl[1], tbl[2], tbl[3])
            end
        end
    end
end

function PANEL:First( ply )
    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )
end

function PANEL:CreateCategory( strCategory )
    local fDock = self.fDock
    if not self.Options[strCategory] then
        local category = vgui.Create("DLabel",fDock)
        category:Dock( TOP )
        category:SetSize(0,ScreenScale(20))
        category:SetText(GetLocalizedString(strCategory)) -- localized
        category:SetFont("ZCity_Small")
        category:DockMargin(15,2,15,5)
    end
    self.Options[strCategory] = self.Options[strCategory] or {}
    return self.Options[strCategory]
end

local color_blacky = Color(39,39,39,220)
local color_reddy = Color(105,0,0,220)

function PANEL:CreateServerOption( strCategory, strConVar, strTitle )
    local fDock = self.fDock
    local Category = self:CreateCategory( strCategory )
    Category[strConVar] = vgui.Create("DPanel",fDock)
    local opt = Category[strConVar]
    opt:Dock( TOP )
    opt:SetSize(0,ScreenScale(25))
    opt:DockMargin(10,2,10,2)

    local isAdminOnly = string.find(strTitle, "ADMIN ONLY") ~= nil
    local canModify = not isAdminOnly or LocalPlayer():IsAdmin()
    
    function opt:Paint(w,h)
        local bgColor = canModify and color_blacky or Color(25,25,25,220)
        draw.RoundedBox( 0, 0, 0, w, h, bgColor )
        surface.SetDrawColor( canModify and color_reddy or Color(60,0,0,220) )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end

    opt.NLabel = vgui.Create("DLabel",opt)
    local NLbl = opt.NLabel
    local localizedTitle = GetLocalizedString(strTitle)
    NLbl:SetText( localizedTitle.."\n".."Server-side setting" )
    NLbl:SetFont("ZCity_Tiny")
    NLbl:SizeToContents()
    NLbl:Dock(LEFT)
    NLbl:DockMargin(10,0,0,0)
    NLbl:SetTextColor(canModify and Color(255,255,255) or Color(120,120,120))

    opt.Button = vgui.Create("DButton",opt)
    local btn = opt.Button
    btn:SetText( "" )
    btn:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
    btn:SetSize( ScreenScale(40),0 )
    btn:Dock( RIGHT )
    btn:SetEnabled(canModify)

    btn.On = hg.serverConvars[strConVar] or false

    function btn:Paint(w,h)
        self.Lerp = LerpFT(0.2,self.Lerp or (btn.On and 1 or 0), btn.On and 1 or 0)
        local CLR = color_reddy:Lerp(Color(55,175,55),self.Lerp)
        if not canModify then
            CLR = Color(40,40,40)
        end
        draw.RoundedBox( 0, 0, 0, w, h, CLR )
        
        draw.RoundedBox( 0, (w/2)*(self.Lerp), 0, w/2, h, ColorAlpha(color_blacky,255) )
        surface.SetDrawColor( canModify and color_reddy or Color(60,0,0,220) )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end
    
    function btn:DoClick()
        if not canModify then
            chat.AddText(Color(255,100,100), "[ZCity] ", Color(255,255,255), "Only admins can modify this setting!")
            surface.PlaySound("buttons/button10.wav")
            return
        end
        
        local commandName = strConVar == "hg_otrub" and "hg_toggle_otrub" or "hg_toggle_fear"
        RunConsoleCommand(commandName, not btn.On and "1" or "0")
        btn.On = not btn.On
    end
    hook.Add("hg_server_convar_updated_" .. strConVar, opt, function()
        btn.On = hg.serverConvars[strConVar] or false
    end)
end

function PANEL:CreateOption( strCategory, bType, cConVar, bDecimals, strTitle, strDesc, bString )
    local fDock = self.fDock
    local Category = self:CreateCategory( strCategory )
    Category[cConVar:GetName()] = vgui.Create("DPanel",fDock)
    local opt = Category[cConVar:GetName()]
    opt:Dock( TOP )
    opt:SetSize(0,ScreenScale(25))
    opt:DockMargin(10,2,10,2)

    local isAdminOnly = string.find(strTitle, "ADMIN ONLY") ~= nil
    local canModify = not isAdminOnly or LocalPlayer():IsAdmin()
    
    function opt:Paint(w,h)
        local bgColor = canModify and color_blacky or Color(25,25,25,220)
        draw.RoundedBox( 0, 0, 0, w, h, bgColor )
        surface.SetDrawColor( canModify and color_reddy or Color(60,0,0,220) )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end

    opt.NLabel = vgui.Create("DLabel",opt)
    local NLbl = opt.NLabel
    local localizedTitle = GetLocalizedString(strTitle)
    local localizedDesc = strDesc and GetLocalizedString(strDesc) or string.NiceName( cConVar:GetHelpText() )
    NLbl:SetText( localizedTitle.."\n"..localizedDesc )
    NLbl:SetFont("ZCity_Tiny")
    NLbl:SizeToContents()
    NLbl:Dock(LEFT)
    NLbl:DockMargin(10,0,0,0)
    NLbl:SetTextColor(canModify and Color(255,255,255) or Color(120,120,120))

    if bString then
        opt.TextInput = vgui.Create("DTextEntry",opt)
        local TextInput = opt.TextInput
        TextInput:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
        TextInput:DockPadding(ScreenScale(5),ScreenScale(5),ScreenScale(5),ScreenScale(5))
        TextInput:SetSize( ScreenScale(90),0 )
        TextInput:Dock( RIGHT )
        TextInput:SetEnabled(canModify)

        TextInput:SetValue(cConVar:GetString())
        TextInput:SetPlaceholderText(GetLocalizedString("Your cool var ")..cConVar:GetName())
        TextInput:SetFont("ZCity_Tiny")
        function TextInput:OnLoseFocus()
            if canModify then
                RunConsoleCommand(cConVar:GetName(), self:GetValue())
            end
        end
    elseif bType then
        opt.Button = vgui.Create("DButton",opt)
        local btn = opt.Button
        btn:SetText( "" )
        btn:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
        btn:SetSize( ScreenScale(40),0 )
        btn:Dock( RIGHT )
        btn:SetEnabled(canModify)

        btn.On = cConVar:GetBool()

        function btn:Paint(w,h)
            self.Lerp = LerpFT(0.2,self.Lerp or (btn.On and 1 or 0), btn.On and 1 or 0)
            local CLR = color_reddy:Lerp(Color(55,175,55),self.Lerp)
            if not canModify then
                CLR = Color(40,40,40)
            end
            draw.RoundedBox( 0, 0, 0, w, h, CLR )
            
            draw.RoundedBox( 0, (w/2)*(self.Lerp), 0, w/2, h, ColorAlpha(color_blacky,255) )
            surface.SetDrawColor( canModify and color_reddy or Color(60,0,0,220) )
            surface.DrawOutlinedRect(0,0,w,h,1.5)
        end
        
        function btn:DoClick()
            if not canModify then
                chat.AddText(Color(255,100,100), "[ZCity] ", Color(255,255,255), "Only admins can modify this setting!")
                surface.PlaySound("buttons/button10.wav")
                return
            end
            
            local newValue = not cConVar:GetBool()
            RunConsoleCommand(cConVar:GetName(), newValue and "1" or "0")
            btn.On = newValue
        end
    else
        local Slid = vgui.Create( "DNumSlider", opt )
        Slid:DockMargin( 10,15,10,15 )
        Slid:SetSize( 500, 0 )
        Slid:Dock( RIGHT )
        Slid:SetMin( cConVar:GetMin() )
        Slid:SetMax( cConVar:GetMax() )
        Slid:SetDecimals( bDecimals and 2 or 0)
        Slid:SetConVar( cConVar:GetName() )
        Slid.TextArea:SetFont("ZCity_Tiny")
        Slid:SetEnabled(canModify)
    end
end

vgui.Register( "ZOptions", PANEL, "ZFrame")
 
concommand.Add("hg_settings",function()
    if hg_options and IsValid(hg_options) then
        hg_options:Close()
        hg_options = nil
    end
    local s = vgui.Create("ZOptions") 
    s:MakePopup()
    hg_options = s
end)

--https://vk.com/audio-2001212316_123212316