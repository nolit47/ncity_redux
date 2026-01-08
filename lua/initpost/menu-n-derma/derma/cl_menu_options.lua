local PANEL = {}

-- [Локализация из старой версии]
local L = {
    ["en"] = {
        ["Optimization"] = "Optimization", ["Blood"] = "Blood", ["UI"] = "UI", ["Weapons"] = "Weapons",
        ["View"] = "View", ["Sound"] = "Sound", ["Gameplay"] = "Gameplay", ["ZCity Settings"] = "ZCity Settings",
        ["Potato PC Mode"] = "Potato PC Mode", ["Animations draw distance"] = "Animations draw distance",
        ["Animations FPS"] = "Animations FPS", ["Attachment draw distance"] = "Attachment draw distance",
        ["Maximum smoke trails"] = "Maximum smoke trails", ["TPIK Render distance"] = "TPIK Render distance",
        ["Blood draw distance"] = "Blood draw distance", ["Blood FPS"] = "Blood FPS",
        ["Blood sprites (DISABLED FOR EVERYONE)"] = "Blood sprites (DISABLED FOR EVERYONE)",
        ["Use new blood decals"] = "Use new blood decals", ["Change custom font"] = "Change custom font",
        ["Shotting blur"] = "Shooting blur", ["Dynamic ammo"] = "Dynamic ammo", ["FP death"] = "First person death",
        ["FOV"] = "Field of View", ["Cool gloves"] = "Cool gloves", ["Gloves model"] = "Gloves model",
        ["C'sHS Ragdoll camera"] = "C'sHS Ragdoll camera", ["Gun camera (ADMIN ONLY)"] = "Gun camera (ADMIN ONLY)",
        ["Disable/Enable fov zoom"] = "Disable/Enable FOV zoom", ["Dynamic music"] = "Dynamic music",
        ["New sounds"] = "New sounds", ["Enable/disable quietshoot sounds (FOR PUSSY)"] = "Enable/disable quiet shooting sounds",
        ["Old notificate"] = "Old notifications", ["Enable/Disable random appearance"] = "Enable/Disable random appearance",
        ["Enable/Disable cheats in game"] = "Enable/Disable cheats in game", ["Your cool var "] = "Your cool var ",
        ["Enable/Disable otrub system (ADMIN ONLY)"] = "Enable/Disable unconsciousness system (ADMIN ONLY)",
        ["Enable/Disable fear system (ADMIN ONLY)"] = "Enable/Disable fear system (ADMIN ONLY)",
    },
    ["ru"] = {
        ["Optimization"] = "Оптимизация", ["Blood"] = "Кровь", ["UI"] = "Интерфейс", ["Weapons"] = "Оружие",
        ["View"] = "Вид", ["Sound"] = "Звук", ["Gameplay"] = "Геймплей", ["ZCity Settings"] = "Настройки ZCity",
        ["Potato PC Mode"] = "Режим слабого компукутера", ["Animations draw distance"] = "Дистанция рендера анимаций",
        ["Animations FPS"] = "ФПС анимаций", ["Attachment draw distance"] = "Дистанция рендера атачментов",
        ["Maximum smoke trails"] = "Максимум дымовых партиклов", ["TPIK Render distance"] = "Дистанция рендера TPIK",
        ["Blood draw distance"] = "Дистанция рендера крови", ["Blood FPS"] = "FPS крови",
        ["Blood sprites (DISABLED FOR EVERYONE)"] = "Спрайты крови (ВЫКЛЮЧЕНО ДЛЯ ВСЕХ)",
        ["Use new blood decals"] = "Использовать новые декали крови", ["Change custom font"] = "Изменить пользовательский шрифт",
        ["Shotting blur"] = "Размытие при стрельбе", ["Dynamic ammo"] = "Динамичные патроны", ["FP death"] = "Смерть от первого лица",
        ["FOV"] = "ФОВЧИК 120 КАЛ ОФ ДЮТИ", ["Cool gloves"] = "cool перчатки кsго", ["Gloves model"] = "Модель перчаток",
        ["C'sHS Ragdoll camera"] = "Камера рэгдолла C'sHS", ["Gun camera (ADMIN ONLY)"] = "Камера оружия (ТОЛЬКО АДМИН)",
        ["Disable/Enable fov zoom"] = "Отключить/Включить зум фова", ["Dynamic music"] = "Динамичная музыка",
        ["New sounds"] = "Новые звуки", ["Enable/disable quietshoot sounds (FOR PUSSY)"] = "Включить/выключить тихие звуки стрельбы",
        ["Old notificate"] = "Старые уведомления", ["Enable/Disable random appearance"] = "Включить/Выключить случайную внешность",
        ["Enable/Disable cheats in game"] = "Включить/Выключить читы в игре", ["Your cool var "] = "че",
        ["Enable/Disable otrub system (ADMIN ONLY)"] = "Включить/Выключить систему отруба",
        ["Enable/Disable fear system (ADMIN ONLY)"] = "Включить/Выключить систему страха (ТОЛЬКО АДМИН4ИКОВ)",
    }
}

local function GetLocalizedString(key)
    local lang = GetConVar("gmod_language"):GetString()
    if L[lang] and L[lang][key] then return L[lang][key] end
    return L["en"][key] or key
end

-- [Цвета и Настройки]
if not hg.ColorSettings then include("homigrad/cl_color_settings.lua") end
local colorSettings = hg.ColorSettings
local function copyColor(col) return Color(col.r, col.g, col.b, col.a) end

local panelColor = colorSettings:GetColor("ui_background")
local accentColor = colorSettings:GetColor("ui_accent")
local menuBgColor = colorSettings:GetColor("menu_background")

-- [Опции]
hg.settings = hg.settings or {}
hg.settings.tbl = hg.settings.tbl or {}

function hg.settings:AddOpt( strCategory, strConVar, strTitle, bDecimals, bString )
    self.tbl[strCategory] = self.tbl[strCategory] or {}
    self.tbl[strCategory][strConVar] = { strCategory, strConVar, strTitle, bDecimals or false, bString or false }
end

-- Перенос всех AddOpt из старого файла
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

-- [Синхронизация серверных переменных]
hg.serverConvars = hg.serverConvars or {}
net.Receive("hg_sync_server_convar", function()
    hg.serverConvars[net.ReadString()] = net.ReadBool()
    hook.Run("hg_server_convar_updated")
end)
net.Receive("hg_sync_fear_convar", function()
    hg.serverConvars[net.ReadString()] = net.ReadBool()
    hook.Run("hg_server_convar_updated")
end)

function PANEL:Init()
    self:SetAlpha( 0 )
    self:SetSize( ScrW()*1, ScrH()*1 )
    self:SetY( ScrH() )
    self:SetX( ScrW() / 2 - self:GetWide() / 2 )
    self:SetTitle( "" )
    self:SetBorder( false )
    self:SetColorBG( copyColor(menuBgColor) )
    self:SetBlurStrengh( 2 )
    self:ShowCloseButton( true )
    self.Options = {}

    timer.Simple(0,function() if self.First then self:First() end end)

    self.fDock = vgui.Create("DScrollPanel",self)
    self.fDock:Dock( FILL )

    self:CreateCategory( "ZCity Settings" )

    RunConsoleCommand("hg_request_server_convars")
    RunConsoleCommand("hg_request_fear_convar")
    
    for k,t in SortedPairs(hg.settings.tbl) do
        for _,tbl in SortedPairs(t) do
            local convar = GetConVar(tbl[2])
            if convar then
                self:CreateOption(tbl[1],convar:GetMax() == 1,convar, tbl[4], tbl[3], nil, tbl[5])
            else
                self:CreateServerOption(tbl[1], tbl[2], tbl[3])
            end
        end
    end
end

function PANEL:First()
    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.4, 0, 0.2)
    self:AlphaTo( 255, 0.2, 0.1 )
end

function PANEL:CreateCategory( strCategory )
    if not self.Options[strCategory] then
        local category = vgui.Create("DLabel",self.fDock)
        category:Dock( TOP )
        category:SetSize(0,ScreenScale(20))
        category:SetText(GetLocalizedString(strCategory))
        category:SetFont("ZCity_Small")
        category:DockMargin(15,2,15,5)
    end
    self.Options[strCategory] = self.Options[strCategory] or {}
    return self.Options[strCategory]
end

-- [Функция для серверных настроек (Админских)]
function PANEL:CreateServerOption( strCategory, strConVar, strTitle )
    local Category = self:CreateCategory( strCategory )
    Category[strConVar] = vgui.Create("DPanel",self.fDock)
    local opt = Category[strConVar]
    opt:Dock( TOP )
    opt:SetSize(0,ScreenScale(25))
    opt:DockMargin(10,2,10,2)

    local isAdminOnly = string.find(strTitle, "ADMIN ONLY") ~= nil
    local canModify = not isAdminOnly or LocalPlayer():IsAdmin()
    
    function opt:Paint(w,h)
        draw.RoundedBox( 0, 0, 0, w, h, canModify and panelColor or Color(25,25,25,220) )
        surface.SetDrawColor( accentColor )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end

    opt.NLabel = vgui.Create("DLabel",opt)
    opt.NLabel:SetText( GetLocalizedString(strTitle).."\nServer-side" )
    opt.NLabel:SetFont("ZCity_Tiny")
    opt.NLabel:SizeToContents()
    opt.NLabel:Dock(LEFT)
    opt.NLabel:DockMargin(10,0,0,0)

    opt.Button = vgui.Create("DButton",opt)
    local btn = opt.Button
    btn:SetText( "" )
    btn:DockMargin( 10,ScreenScale(5),10,ScreenScale(5) )
    btn:SetSize( ScreenScale(40),0 )
    btn:Dock( RIGHT )
    btn.On = hg.serverConvars[strConVar] or false

    function btn:Paint(w,h)
        self.Lerp = LerpFT(0.2,self.Lerp or (btn.On and 1 or 0), btn.On and 1 or 0)
        local CLR = accentColor:Lerp(Color(55,175,55),self.Lerp)
        if not canModify then CLR = Color(40,40,40) end
        draw.RoundedBox( 0, 0, 0, w, h, CLR )
        draw.RoundedBox( 0, (w/2)*(self.Lerp), 0, w/2, h, ColorAlpha(panelColor,255) )
        surface.SetDrawColor( accentColor )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end
    
    function btn:DoClick()
        if not canModify then return end
        local commandName = strConVar == "hg_otrub" and "hg_toggle_otrub" or "hg_toggle_fear"
        RunConsoleCommand(commandName, not btn.On and "1" or "0")
        btn.On = not btn.On
    end
    hook.Add("hg_server_convar_updated", opt, function() btn.On = hg.serverConvars[strConVar] or false end)
end

function PANEL:CreateOption( strCategory, bType, cConVar, bDecimals, strTitle, strDesc, bString )
    local Category = self:CreateCategory( strCategory )
    Category[cConVar:GetName()] = vgui.Create("DPanel",self.fDock)
    local opt = Category[cConVar:GetName()]
    opt:Dock( TOP )
    opt:SetSize(0,ScreenScale(25))
    opt:DockMargin(10,2,10,2)

    local isAdminOnly = string.find(strTitle, "ADMIN ONLY") ~= nil
    local canModify = not isAdminOnly or LocalPlayer():IsAdmin()

    function opt:Paint(w,h)
        draw.RoundedBox( 0, 0, 0, w, h, canModify and panelColor or Color(25,25,25,220) )
        surface.SetDrawColor( accentColor )
        surface.DrawOutlinedRect(0,0,w,h,1.5)
    end

    opt.NLabel = vgui.Create("DLabel",opt)
    local localizedTitle = GetLocalizedString(strTitle)
    local localizedDesc = strDesc and GetLocalizedString(strDesc) or string.NiceName( cConVar:GetHelpText() )
    opt.NLabel:SetText( localizedTitle.."\n"..localizedDesc )
    opt.NLabel:SetFont("ZCity_Tiny")
    opt.NLabel:SizeToContents()
    opt.NLabel:Dock(LEFT)
    opt.NLabel:DockMargin(10,0,0,0)

    if bString then
        opt.TextInput = vgui.Create("DTextEntry",opt)
        opt.TextInput:Dock( RIGHT )
        opt.TextInput:SetSize( ScreenScale(90),0 )
        opt.TextInput:DockMargin( 10,5,10,5 )
        opt.TextInput:SetValue(cConVar:GetString())
        opt.TextInput:SetEnabled(canModify)
        function opt.TextInput:OnLoseFocus() if canModify then cConVar:SetString(self:GetValue()) end end
    elseif bType then
        opt.Button = vgui.Create("DButton",opt)
        local btn = opt.Button
        btn:SetText( "" )
        btn:Dock( RIGHT )
        btn:SetSize( ScreenScale(40),0 )
        btn:DockMargin( 10,5,10,5 )
        btn.On = cConVar:GetBool()
        function btn:Paint(w,h)
            self.Lerp = LerpFT(0.2,self.Lerp or (btn.On and 1 or 0), btn.On and 1 or 0)
            local CLR = accentColor:Lerp(Color(55,175,55),self.Lerp)
            if not canModify then CLR = Color(40,40,40) end
            draw.RoundedBox( 0, 0, 0, w, h, CLR )
            draw.RoundedBox( 0, (w/2)*(self.Lerp), 0, w/2, h, ColorAlpha(panelColor,255) )
            surface.SetDrawColor( accentColor )
            surface.DrawOutlinedRect(0,0,w,h,1.5)
        end
        function btn:DoClick()
            if not canModify then return end
            local newValue = cConVar:GetBool() and 0 or 1
            RunConsoleCommand(cConVar:GetName(), tostring(newValue))
            
            btn.On = not cConVar:GetBool()
        end
    else
        local Slid = vgui.Create( "DNumSlider", opt )
        Slid:Dock( RIGHT )
        Slid:SetSize( 500, 0 )
        Slid:SetMinMax( cConVar:GetMin(), cConVar:GetMax() )
        Slid:SetDecimals( bDecimals and 2 or 0)
        Slid:SetConVar( cConVar:GetName() )
        Slid:SetEnabled(canModify)
    end
end

vgui.Register( "ZOptions", PANEL, "ZFrame")

concommand.Add("hg_settings",function()
    if hg_options and IsValid(hg_options) then hg_options:Close() end
    hg_options = vgui.Create("ZOptions") 
    hg_options:MakePopup()
end)