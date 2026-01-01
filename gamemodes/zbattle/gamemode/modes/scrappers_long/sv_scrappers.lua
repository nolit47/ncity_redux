MODE.name = "scrappers_long"
MODE.PrintName = "Scrappers: Long Game"
MODE.start_time = 0
MODE.end_time = 0
 
MODE.ROUND_TIME = 300
 

MODE.OverrideSpawn = true
MODE.LootSpawn = true
MODE.ForBigMaps = true
MODE.Chance = 0.05

util.AddNetworkString("zb_ScrappersLong_CreateShop")
util.AddNetworkString("zb_ScrappersLong_CloseShop")

local MODE = MODE

function MODE:CanLaunch()
    return false
end

function MODE:CanSpawn(ply)
    if ply:Team() == 0 then return true end

    return false
end

function MODE:EndRound()
    net.Start("zb_ScrappersLong_CloseShop")
    net.Broadcast()
end

function MODE:Intermission()
end

function MODE:RoundStart()
    for _, ply in player.Iterator() do
        ApplyAppearance(ply)
        ply:Spawn()

        ply:Give("weapon_hands_sh")
        ply:SelectWeapon("weapon_hands_sh")
    end

    net.Start("zb_ScrappersLong_CreateShop")
    net.Broadcast()
end

function MODE:GiveEquipment()
end

function MODE:ShouldRoundEnd()
    return false
end

function MODE:PlayerInitialSpawn(ply)
    ply:SetTeam(1001)
end