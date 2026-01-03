local LANG = {}

LANG["en"] = {
    ["press_f_forgive"] = "Press F to open forgiveness menu.",
    ["exit"] = "Exit",
    ["forgive_player"] = "Forgive %s? You will forgive him %.1f karma.",

    ["harm_killed"] = "killed you.",
    ["harm_basically_killed"] = "basically killed you.",
    ["harm_seriously_injured"] = "seriously injured you.",
    ["harm_mildly_injured"] = "mildly injured you.",
    ["harm_damaged_bit"] = "damaged you a bit.",

    ["karma_is"] = "Your current karma is %s",
    ["players_karma"] = "\nPlayers karma: \n",
    ["player_karma_line"] = "\t%s's karma is %.2f\n",
}

LANG["ru"] = {
    ["press_f_forgive"] = "Нажмите F, чтобы открыть меню прощения.",
    ["exit"] = "Выход",
    ["forgive_player"] = "Простить %s? Вы простите ему %.1f кармы.",
    
    ["harm_killed"] = "убил вас.",
    ["harm_basically_killed"] = "практически убил вас.",
    ["harm_seriously_injured"] = "серьёзно ранил вас.",
    ["harm_mildly_injured"] = "слегка ранил вас.",
    ["harm_damaged_bit"] = "немного повредил вас.",
    
    ["karma_is"] = "Ваша текущая карма: %s",
    ["players_karma"] = "\nКарма игроков: \n",
    ["player_karma_line"] = "\t%s имеет карму %.2f\n",
}

local function L(key, ...)
    local lang = GetConVar("gmod_language"):GetString() or "en"
    if lang ~= "en" and lang ~= "ru" then lang = "en" end
    
    local text = LANG[lang][key] or LANG["en"][key] or key
    
    if ... then
        return string.format(text, ...)
    end
    
    return text
end

--[[    TO-DO
    -- Добавить менюшку с прощением! |
    -- Добавить нетворкинг |
    -- Ну и все | 
--]]

hook.Add("OnNetVarSet", "Guilt",function(index, key, var)
    if key == "Karma" then
        Entity(index).Karma = var
    end
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
    --if (ply == LocalPlayer()) and ply.Karma then
    --    ply:ChatPrint(L("karma_is", tostring(math.Round(ply.Karma))))
    --end
end)

concommand.Add("hg_getkarma",function(ply)
    if not ply:IsAdmin() then return end

    net.Start("get_karma")
    net.SendToServer()
end)

net.Receive("get_karma",function(len)
    local tbl = net.ReadTable()
    local printTbl = L("players_karma")

    for id,karma in pairs(tbl) do
        printTbl = printTbl .. L("player_karma_line", Player(id):Name(), karma)
    end

    LocalPlayer():PrintMessage(HUD_PRINTCONSOLE, printTbl)
end)

concommand.Add("hg_guilt_menu",function(ply, cmd, args)
    net.Start("open_guilt_menu")
    net.SendToServer()
end)

local OpenMenu

net.Receive("open_guilt_menu", function()
    local tbl = net.ReadTable()
    
    OpenMenu(tbl)
end)

local colGray = Color(122,122,122,255)
local BlurBackground = hg.BlurBackground

local function harmdone(harm)
    if harm >= 9 then
        return L("harm_killed")
    elseif harm >= 5 then
        return L("harm_basically_killed")
    elseif harm >= 2 then
        return L("harm_seriously_injured")
    elseif harm >= 1 then
        return L("harm_mildly_injured")
    else
        return L("harm_damaged_bit")
    end
end

local showstuff = CurTime() + 5
hook.Add("Player Death","karmacheck",function(ply)
    if ply != LocalPlayer() then return end
    
    showstuff = CurTime() + 5
end)

local pressed
hook.Add("HUDPaint","shownotification",function()
    if LocalPlayer():Alive() then return end

    if showstuff > CurTime() then
        local w, h = ScrW(), ScrH()
        local x, y = w / 2, h / 25 * 24
        local txt = L("press_f_forgive")
        surface.SetFont( "HomigradFontBig" )
        surface.SetTextColor(255,255,255,255)
        local w, h = surface.GetTextSize(txt)
        surface.SetTextPos(x - w / 2, y - h / 2)
        surface.DrawText(txt)
    end

    if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) then
        if not pressed then
            showstuff = 0
            RunConsoleCommand("hg_guilt_menu")
            pressed = true
        end
    else
        pressed = nil
    end
end)

OpenMenu = function(tbl)
    if IsValid(guiltMenu) then
		guiltMenu:Remove()
		guiltMenu = nil
	end
    
	local sizeX,sizeY = ScrW() / 2 ,ScrH() / 3
	local posX,posY = ScrW() / 2 - sizeX / 2,ScrH() / 2 - sizeY / 2

	guiltMenu = vgui.Create("DScrollPanel")
	guiltMenu:SetPos(posX, posY)
	guiltMenu:SetSize(sizeX, sizeY)
    guiltMenu:MakePopup()
    guiltMenu:SetKeyboardInputEnabled(false)

    local button = vgui.Create("DButton", guiltMenu)
    button:SetPos(sizeX - ScreenScale(25),ScreenScale(5))
    button:SetSize(ScreenScale(20),ScreenScale(10))
    button:SetText("")

    function button:Paint(w,h)
        BlurBackground(self)

        surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

        local x, y = w / 2, h / 2
        local txt = L("exit")
        surface.SetFont("HomigradFont")
        surface.SetTextColor(255,255,255,255)
        local w, h = surface.GetTextSize(txt)
        surface.SetTextPos(x - w / 2, y - h / 2)
        surface.DrawText(txt)
    end

    function button:DoClick()
        if IsValid(guiltMenu) then
            guiltMenu:Remove()
        end
    end

	function guiltMenu:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

    local first = true
    for ply, harm in pairs(tbl) do
        if not IsValid(ply) then continue end
        if harm <= 0.01 then continue end

        local but = vgui.Create("DButton", guiltMenu)
		but:SetSize(sizeX / 2,ScreenScaleH(22))
		but:Dock(TOP)
        local mg = ScreenScale(5)
		but:DockMargin(mg, first and ScreenScale(20) or mg / 2, mg, mg / 2)
        first = false
		but:SetText("")
        but.ply = ply
        but.name = ply:Name()
        but.harm = harm
        local txt = L("forgive_player", but.name, but.harm)
        local clr = 255
        but.Paint = function(self,w,h)
            BlurBackground(self)
            clr = LerpFT(0.1, clr, self:IsHovered() and 0 or 255)
            surface.SetDrawColor( 255, 0, 0, 128)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )

            local x, y = 0, h / 2
            surface.SetFont("HomigradFont")
            surface.SetTextColor(clr,255,clr,255)
            local w, h = surface.GetTextSize(txt)
            surface.SetTextPos(x + ScreenScale(5), y - h / 2)
            surface.DrawText(txt)
		end

		function but:DoClick()
            net.Start("forgive_player")
            net.WriteEntity(ply)
            net.SendToServer()
            --self:Remove()
            tbl[ply] = nil
            OpenMenu(tbl)
        end

		guiltMenu:AddItem(but)
	end
end