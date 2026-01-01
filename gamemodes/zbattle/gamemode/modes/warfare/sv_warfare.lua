MODE.name = "warfare"
MODE.PrintName = "Warfare"
MODE.randomSpawns = true
 

MODE.ForBigMaps = true
MODE.Chance = 0.05

MODE.OverideSpawnPos = true

util.AddNetworkString("warfare_start")
util.AddNetworkString("PlayerSelectTeam")
util.AddNetworkString("warfare_roundend")

local teamModels = {
    [1] = "models/player/Group03/male_01.mdl", 
    [2] = "models/player/Group03/male_02.mdl", 
    [3] = "models/player/Group03/male_03.mdl", 
    [4] = "models/player/Group03/male_04.mdl"  
}

function MODE:CanLaunch()
    return false
end

function MODE:Intermission()
    game.CleanUpMap()

    self.TeamPoints = {
        [1] = zb.GetMapPoints("HMCD_TDM_TEAM_1"),
        [2] = zb.GetMapPoints("HMCD_TDM_TEAM_2"),
        [3] = zb.GetMapPoints("HMCD_TDM_TEAM_3"),
        [4] = zb.GetMapPoints("HMCD_TDM_TEAM_4"),
    }

    for k, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ply:SetupTeam(ply:Team())
    end

    net.Start("warfare_start")
    net.Broadcast()
end

net.Receive("PlayerSelectTeam", function(len, ply)
    local teamID = net.ReadInt(4)
    if not ply.HasChosenTeam and MODE.RoundStarted then
        ply:SetTeam(teamID)
        ply:SetModel(teamModels[teamID])
        ply.HasChosenTeam = true
    end
end)

function MODE:RoundStart()
    self.RoundStarted = true

    for _, ply in ipairs(player.GetAll()) do
        if not ply.HasChosenTeam then
            net.Start("PlayerSelectTeam")
            net.Send(ply)
        end
    end
end

function MODE:GetPlySpawn(ply)
    local plyTeam = ply:Team()
    local spawnPoints = self.TeamPoints[plyTeam]
    if spawnPoints and #spawnPoints > 0 then
        local spawn = table.Random(spawnPoints)
        ply:SetPos(spawn.pos)
    end
end

function MODE:GiveEquipment()
    timer.Simple(0.1, function()
        for _, ply in ipairs(player.GetAll()) do
            if not ply:Alive() then continue end
            ply:SetSuppressPickupNotices(true)


            ply:Give("wep_jack_gmod_eztoolbox.lua")
            ply:Give("weapon_hands_sh")
            ply:SetModel(teamModels[ply:Team()])

            ply:SetSuppressPickupNotices(false)
        end
    end)
end

function MODE:PlayerDeath(victim, inflictor, attacker)
    timer.Simple(10, function()
        if IsValid(victim) then
            victim:Spawn()
            self:GetPlySpawn(victim)
            self:GiveEquipment(victim)
        end
    end)
end

function MODE:EndRound()
end

function MODE:RoundThink()

end

function MODE:GetTeamSpawn()

end

function MODE:CanSpawn()

end
