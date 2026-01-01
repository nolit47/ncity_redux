MODE.name = "streetsweep"
MODE.PrintName = "Street Sweep"
MODE.randomSpawns = false
 

MODE.OverideSpawnPos = true
MODE.ROUND_TIME = 9000

MODE.start_time = 0
MODE.end_time = 0
 
MODE.ForBigMaps = true
MODE.Chance = 0.05

util.AddNetworkString("SS_ChangePhase")
util.AddNetworkString("SS_ResearchVote")
util.AddNetworkString("SS_CreateMap")
util.AddNetworkString("SS_TechPriority")
util.AddNetworkString("SS_UpdateResearch")

local MODE = MODE

function MODE:CanLaunch()
    return false
end

net.Receive("SS_ResearchVote", function(len, ply) --голосование за исследование (КТО КРУЧЕ, АУКЦИОН В СКРАППЕРАХ ИЛИ!?!?!?)
    if ply:Team() > 1 then return end

    local lane = net.ReadString()
    local k = net.ReadUInt(6)

    MODE.ResearchVotedPlayers[ply] = true

    MODE.ResearchVotes[lane][k].Votes = MODE.ResearchVotes[lane][k].Votes or {}

    MODE.ResearchVotes[lane][k]["Votes"][ply:Team()] = (MODE.ResearchVotes[lane][k]["Votes"][ply:Team()] and MODE.ResearchVotes[lane][k]["Votes"][ply:Team()] + 1) or 1

    if MODE.ResearchPlayerVotes[ply] then
        MODE.ResearchVotes[MODE.ResearchPlayerVotes[ply].lane][MODE.ResearchPlayerVotes[ply].k]["Votes"][ply:Team()] = MODE.ResearchVotes[MODE.ResearchPlayerVotes[ply].lane][MODE.ResearchPlayerVotes[ply].k]["Votes"][ply:Team()] - 1

        net.Start("SS_ResearchVote")
            net.WriteString(MODE.ResearchPlayerVotes[ply].lane)
            net.WriteUInt(MODE.ResearchPlayerVotes[ply].k, 6)

            net.WriteUInt(MODE.ResearchVotes[MODE.ResearchPlayerVotes[ply].lane][MODE.ResearchPlayerVotes[ply].k]["Votes"][ply:Team()], 32)
        net.Send(team.GetPlayers(ply:Team()))
    end

    MODE.ResearchPlayerVotes[ply] = {
        lane = lane,
        k = k
    }

    if table.Count(MODE.ResearchVotedPlayers) > (#team.GetPlayers(ply:Team()) * 0.66) then
        timer.Adjust("SS_PhaseTimer_" .. ply:Team(), 0)
    end

    net.Start("SS_ResearchVote")
        net.WriteString(lane)
        net.WriteUInt(k, 6)

        net.WriteUInt(MODE.ResearchVotes[lane][k]["Votes"][ply:Team()], 32)
    net.Send(team.GetPlayers(ply:Team()))
end)

MODE.PhaseDelays = { --задержка в таймере для каждой фазы
    [1] = 300
}

MODE.PhaseFuncs = { --функция которая вызывается для каждой фазы
    [1] = function(self, Team)
        MODE.ResearchVotedPlayers = {}

        timer.Create("SS_PhaseTimer_" .. Team, self.PhaseDelays[1], 1, function()
            local votes = MODE.ResearchVotes

            local Best = 0

            local Winner

            for k, v in pairs(votes) do
                for k2, v2 in ipairs(v) do
                    local votes2 = v2.Votes

                    if !votes2 then continue end

                    if votes2[Team] and (votes2[Team] > Best) then
                        Winner = {k, k2}
                        Best = votes2[Team]
                    end
                end
            end

            if Winner then
                self:ResearchTech(Winner, Team)
            end

            self:ChangePhase(2, Team)
        end)
    end
}

function MODE:ResearchTech(winner, Team) --начать исследование
    local lane = winner[1]
    local slot = winner[2]

    self.Teams[Team].CurrentResearch = {
        lane = lane,
        slot = slot,
        Invested = 0
    }

    self:UpdateResearch(Team)
end

function MODE:UpdateResearch(Team) --прислать команде текущий фокус исследования
    if !self.Teams[Team].CurrentResearch then return end

    net.Start("SS_UpdateResearch")
        net.WriteTable(self.Teams[Team].CurrentResearch)
    net.Send(team.GetPlayers(Team))
end

function MODE:ChangePhase(phase, Team) --поменять фазу карты либо всем, либо определённой команде (асинхронные фазы)
    net.Start("SS_ChangePhase")
        net.WriteUInt(phase, 5)
    if Team then
        net.Send(team.GetPlayers(Team))
    else
        net.Broadcast()
    end

    if self.PhaseFuncs[phase] then
        self.PhaseFuncs[phase](self, Team)
    end
end

function MODE:ShouldRoundEnd()
    return false
end

function MODE:Intermission()
end

function MODE:RoundStart()
    self:ResetValues()

    net.Start("SS_CreateMap")
    net.Broadcast()

    self:UpdateResearch(0)
    self:UpdateResearch(1)

    timer.Simple(5, function() --плыв
        self:ChangePhase(1, 0)
        self:ChangePhase(1, 1)
    end)
end

function MODE:EndRound()
end

function MODE:GiveEquipment()
end