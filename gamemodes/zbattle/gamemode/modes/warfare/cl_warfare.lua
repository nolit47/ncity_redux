MODE.name = "warfare"

local MODE = MODE

net.Receive("warfare_start", function()
    surface.PlaySound("csgo_round.wav")
    zb.RemoveFade()
end)

local function CreateTeamSelectionMenu()
    local frame = vgui.Create("ZFrame")
    frame:SetTitle("Выбор команды")
    frame:SetSize(300, 400)
    frame:Center()
    frame:MakePopup()

    local teams = {
        { name = "Оливковая", color = Color(107, 142, 35), teamID = 1 },
        { name = "Песочная", color = Color(244, 164, 96), teamID = 2 },
        { name = "Черная", color = Color(0, 0, 0), teamID = 3 },
        { name = "Коричневая", color = Color(139, 69, 19), teamID = 4 }
    }

    for _, teamData in ipairs(teams) do
        local button = vgui.Create("DButton", frame)
        button:Dock(TOP)
        button:SetText(teamData.name)
        button:SetTextColor(teamData.color)
        button:DockMargin(10, 10, 10, 0)
        button.DoClick = function()
            net.Start("PlayerSelectTeam")
            net.WriteInt(teamData.teamID, 4)
            net.SendToServer()
            frame:Close()
        end
    end
end

function MODE:RoundStart()
    timer.Simple(1, function()
        CreateTeamSelectionMenu()
    end)
end

function MODE:RenderScreenspaceEffects()
    if zb.ROUND_START + 7.5 < CurTime() then return end
    local fade = math.Clamp(zb.ROUND_START + 7.5 - CurTime(), 0, 1)

    surface.SetDrawColor(0, 0, 0, 255 * fade)
    surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
    if zb.ROUND_START + 8.5 < CurTime() then return end
     
    if not lply:Alive() then return end
    zb.RemoveFade()
    local fade = math.Clamp(zb.ROUND_START + 8 - CurTime(), 0, 1)
    local team_ = lply:Team()

    local teamNames = {
        [1] = "Оливковая команда",
        [2] = "Песочная команда",
        [3] = "Черная команда",
        [4] = "Коричневая команда"
    }

    local teamColors = {
        [1] = Color(107, 142, 35),
        [2] = Color(244, 164, 96),
        [3] = Color(0, 0, 0),
        [4] = Color(139, 69, 19)
    }

    draw.SimpleText("Warfare | Free For All", "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.1, Color(0, 162, 255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Вы в команде: " .. (teamNames[team_] or ""), "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.5, teamColors[team_] or Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

net.Receive("warfare_roundend", function()
end)
