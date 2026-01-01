
MODE.name = "coop"
MODE.PrintName = "CO-OP"
MODE.randomSpawns = false

MODE.ROUND_TIME = 9000
hg.NextMap = ""

MODE.LootSpawn = false

MODE.Lootables = {
    ["models/items/item_item_crate.mdl"] = true,
    ["models/items/item_item_crate_dynamic.mdl"] = true,
}

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1.5, true--returning true so guilt bans
end

function MODE:GetLootTable()
    local currentMap = game.GetMap()
    local mapData = self.Maps[currentMap]

    return mapData.PlayerEqipment == "rebel" and self.LootTable[2] or self.LootTable[1]
end

MODE.LootTable = {
	[1] = {1, {
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_crowbar"},
		{3,"weapon_tomahawk"},
		{3,"weapon_hatchet"},
		{3,"weapon_hg_axe"},
        {2,"ent_ammo_9x19mmparabellum"},
		{2,"ent_ammo_4.6x30mm"},
        {1,"weapon_hk_usp"},
        {1,"weapon_mp7"},
    }},
	[2] = {1, {
		{9,"ent_ammo_pulse"},
		{9,"ent_ammo_9x19mmparabellum"},
		{9,"ent_ammo_4.6x30mm"},
		{9,"ent_ammo_12/70gauge"},
		{9,"ent_ammo_12/70slug"},
		{9,"ent_ammo_.357magnum"},
        
        {9,"weapon_hk_usp"},
        {8,"weapon_revolver357"},
		{6,"weapon_spas12"},

		{6,"ent_armor_vest3"},
		{5,"ent_armor_helmet1"},

		{5,"weapon_mp7"},
		{5,"weapon_osipr"},

		{5,"ent_armor_vest4"},

		{5,"weapon_hg_molotov_tpik"},
		{5,"weapon_hg_grenade_pipebomb"},
		{5,"weapon_hg_hl2grenade"},
		{5,"weapon_hg_slam"},
	}},
}

hook.Add("EntityTakeDamage","dontfuckingdamagethem",function(ent,dmginfo)
    if CurrentRound().name == "coop" then
        local att = dmginfo:GetAttacker()
        if IsValid(ent) and IsValid(att) and att:IsPlayer() and ent:IsNPC() and ((ent:Disposition(att) == D_LI) or (ent:Disposition(att) == D_NU)) then
			--return true
            --ПОЧЕМУ МЕТРОКОПЫ ДОБРЕНЬКИЕ??
		end
    end
end)

MODE.ForBigMaps = true

MODE.Chance = 1

util.AddNetworkString("coop_start")

function hg.ClearMapsTable()
    sql.Query("DROP TABLE IF EXISTS coop_maps;")
end

COMMANDS.clearmaps = {function(ply)
    ply:ChatPrint("Completed maps cleared!")
    hg.ClearMapsTable()
end, 1}

function hg.AddMapToTable(map)
    map = map or game.GetMap()

    local data = sql.Query("SELECT * FROM coop_maps WHERE map = " .. sql.SQLStr(map) .. ";")

    if not data then
        sql.Query("INSERT INTO coop_maps ( map, completed ) VALUES( " .. sql.SQLStr(map) .. ", TRUE );")
    end
end

function hg.CheckMapCompleted(map, shouldAdd)
    map = map or game.GetMap()
    sql.Query("CREATE TABLE IF NOT EXISTS coop_maps ( map TEXT, completed BOOL );")
    local data = sql.Query("SELECT * FROM coop_maps WHERE map = " .. sql.SQLStr(map) .. ";")

    if data then
        return true
    else
        if shouldAdd then
            hg.AddMapToTable(map)
        end
        return false
    end
end

function MODE:Intermission()
    self.LootTimer = CurTime() + 2
    game.CleanUpMap()

    self.COOPPoints = zb.GetMapPoints("HMCD_COOP_SPAWN")

    for k, ply in ipairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ply:SetupTeam(0)
    end

    net.Start("coop_start")
    net.Broadcast()
end

function MODE:CheckAlivePlayers()
end

function MODE:ZB_OnEntCreated( ent )
end

local mapchange = CreateConVar("zb_coop_autochangelevel", "1", FCVAR_PROTECTED, "", 0, 1)

function MODE:ShouldRoundEnd()
    if (#zb:CheckAlive() <= 0) and (hg.MapCompleted or false) then
        timer.Simple(5, function()
            hg.AddMapToTable(game.GetMap())
            
            RunConsoleCommand("changelevel",hg.NextMap)
        end)
    end
    return (#zb:CheckAlive() <= 0)
end

function MODE:RoundStart()
end

local function getspawnpos(i)
    local tab = {}
    local tbl = ents.FindByClass("info_player_start")

    for k, v in pairs(tbl) do
        if not v:HasSpawnFlags(1) then continue end
        tab[#tab + 1] = v:GetPos()
    end

    return tab[math.Clamp(i % #tab + 1, 1, #tab)]
end

function MODE:GetPlySpawn(ply)
    ply:SetPos(getspawnpos(ply:EntIndex()))
end

function MODE:GetTeamSpawn()
	return {getspawnpos(math.random(50))}, {getspawnpos(math.random(50))}
end

function MODE:GiveEquipment()
    self.COOPPoints = zb.GetMapPoints("HMCD_COOP_SPAWN")
    timer.Simple(0, function()
        local players = player.GetAll()
        local medicCount = 0
        local hasGordon = false

        local currentMap = game.GetMap()
        local mapData = self.Maps[currentMap] or {PlayerEqipment = "rebel"} 
        local playerClass = mapData.PlayerEqipment
        local maxMedics = math.min(3, math.floor(#players / 5))

        for _, ply in RandomPairs(players) do
            self:GetPlySpawn(ply)

            if not ply:Alive() then continue end

            ply:SetSuppressPickupNotices(true)
            ply.noSound = true

            local inv = ply:GetNetVar("Inventory")
            inv["Weapons"]["hg_sling"] = true
            inv["Weapons"]["hg_flashlight"] = true
            ply:SetNetVar("Inventory",inv)

            if not hasGordon and not ply:IsBot() then
                ply:SetPlayerClass("Gordon", playerClass)
                zb.GiveRole(ply, "Freeman", Color(255, 155, 0))
                hasGordon = true
            else
                if medicCount > maxMedics then
                    medicCount = medicCount - 1
                    ply.subClass = "medic"
                end

                if playerClass == "refugee" or playerClass == "citizen" then
                    ply:SetPlayerClass("Refugee", playerClass == "citizen")
                    zb.GiveRole(ply, ply.subClass == "medic" and "Medic" or "Refugee", ply.subClass == "medic" and Color(190,0,0) or Color(255, 155, 0))
                elseif playerClass == "rebel" then
                    ply:SetPlayerClass("Rebel")
                    zb.GiveRole(ply, ply.subClass == "medic" and "Medic" or "Rebel", ply.subClass == "medic" and Color(190,0,0) or Color(255, 155, 0))
                end
            end

            local hands = ply:Give("weapon_hands_sh")
            ply:SelectWeapon("weapon_hands_sh")

            timer.Simple(0.1, function()
                ply.noSound = false
            end)

            ply:SetSuppressPickupNotices(false)
        end
    end)
end

util.AddNetworkString("coop_roundend")
function MODE:EndRound()
    timer.Simple(2, function()
        net.Start("coop_roundend")
        net.Broadcast()
    end)
end

util.AddNetworkString("coop_roundend")
function MODE:EndRound()
    timer.Simple(2, function()
        net.Start("coop_roundend")
        net.Broadcast()
    end)
end

function MODE:RoundThink()
end

function MODE:CanSpawn()
end

function MODE:CanLaunch()
	local triggers = ents.FindByClass( "trigger_changelevel" )
    return #triggers > 0 and IsValid(triggers[1])
end
