local MODE = MODE

MODE.name = "survival"
MODE.PrintName = "Zombie Survival"
MODE.LootSpawn = true
MODE.GuiltDisabled = true
MODE.randomSpawns = true

MODE.ForBigMaps = true
MODE.Chance = 0.03
MODE.GuiltDisabled = true

local mapsize = 7500
local maxZombies = 45
local zombieSpawnInterval = 30
local zombies = {}

local zombieTypes = {
	{ time = 0, class = "npc_zombie" },
	{ time = 300, class = "npc_fastzombie" },
	{ time = 600, class = "npc_poisonzombie" }
}

util.AddNetworkString("survival_start")
util.AddNetworkString("survival_end")

MODE.LootTable = {
	{50, {
		{15, "weapon_smallconsumable"},
		{12, "weapon_bigconsumable"},
		{8, "weapon_matches"},
		{8, "weapon_tourniquet"},
		{8, "weapon_bandage_sh"},
		{7, "weapon_ducttape"},
		{6, "weapon_painkillers"},
		{5, "weapon_bloodbag"},
		{5, "weapon_hammer"},
		{5, "weapon_walkie_talkie"},
		{4, "hg_flashlight"},
		{4, "weapon_pocketknife"},
		{4, "weapon_leadpipe"},
		{4, "weapon_medkit_sh"},
		{3, "weapon_hg_crowbar"},
		{2, "weapon_tomahawk"},
		{2, "weapon_hatchet"},
		{1, "weapon_hg_axe"},
	}},
	{50, {
		{20, "hg_sling"},
		{15, "weapon_mp-80"},
		{12, "*ammo*"},
		{11, "*sight*"},
		{11, "*barrel*"},
		{10, "weapon_makarov"},
		{9, "weapon_hk_usp"},
		{9, "weapon_glock17"},
		{9, "weapon_cz75"},
		{9, "weapon_px4beretta"},
		{7, "weapon_tec9"},
		{7, "weapon_revolver2"},
		{6, "weapon_revolver357"},
		{6, "weapon_deagle"},
		{6, "weapon_colt9mm"},
		{5, "weapon_doublebarrel_short"},
		{5, "weapon_doublebarrel"},
		{4, "weapon_remington870"},
		{4, "weapon_glock18c"},
		{4, "weapon_skorpion"},
		{4, "weapon_mac11"},
		{4, "weapon_uzi"},
		{4, "weapon_tmp"},
		{3, "weapon_kar98"},
		{3, "weapon_ar_pistol"},
		{3, "weapon_draco"},
		{3, "weapon_mp5"},
		{3, "ent_armor_vest3"},
		{3, "ent_armor_helmet1"},
		{2, "weapon_mp7"},
		{2, "weapon_sks"},
		{2, "weapon_ar15"},
		{2, "ent_armor_vest4"},
		{2, "weapon_hg_molotov_tpik"},
		{2, "weapon_hg_grenade_pipebomb"},
		{1, "weapon_vpo136"},
		{1, "weapon_sr25"},
	}},
}

function MODE:CanLaunch()
    return false
end

function MODE:Intermission()
	game.CleanUpMap()

	for k, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end

	net.Start("survival_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {}
	for _, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#self:CheckAlivePlayers() == 0)
end

function MODE:SpawnZombies()
	if #zombies >= maxZombies then return end

	local nodes = ents.FindByClass("info_node")
	for i = 1, 2 do
		local node = table.Random(nodes)
		local zombieType = self:GetCurrentZombieType()
		local zombie = ents.Create(zombieType)
		zombie:SetPos(node:GetPos())
		zombie:Spawn()
		zombie:SetKeyValue("crabless", "1") 
		table.insert(zombies, zombie)

		zombie:CallOnRemove("RemoveFromTable", function(ent)
			table.RemoveByValue(zombies, ent)
		end)
	end
end

function MODE:SetZombieBodyGroups(zombie)
	if zombie:GetClass() == "npc_zombie" or zombie:GetClass() == "npc_fastzombie" then
		zombie:SetBodygroup(1, 0)
	elseif zombie:GetClass() == "npc_poisonzombie" then
		for i = 1, 5 do
			zombie:SetBodygroup(i, 0)
		end
	end
end

function MODE:GetCurrentZombieType()
	local elapsedTime = CurTime() - (zb.ROUND_START or 0)
	for i = #zombieTypes, 1, -1 do
		if elapsedTime >= zombieTypes[i].time then
			return zombieTypes[i].class
		end
	end
	return "npc_zombie"
end

function MODE:RoundStart()
	for _, ply in ipairs(player.GetAll()) do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		ply:Give("weapon_hands_sh")
		ply:SetSuppressPickupNotices(false)
		zb.GiveRole(ply, "Survivor", Color(0, 255, 0))
	end

	self:SpawnZombies()
	self.NextZombieSpawn = CurTime() + zombieSpawnInterval
end

function MODE:RoundThink()
	local playerCount = #player.GetAll()
	local roundDuration = 120 + math.min(playerCount * 60, 1200)
	if (zb.ROUND_START or 0) + roundDuration < CurTime() then
		self:EndRound()
	end

	if CurTime() >= (self.NextZombieSpawn or 0) then
		self:SpawnZombies()
		self.NextZombieSpawn = CurTime() + zombieSpawnInterval
	end
end

function MODE:PlayerDeath(_, ply)
	if zb.ROUND_STATE == 1 then
		ply:GiveSkill(-0.1)
	end
end

function MODE:EndRound()
	timer.Simple(2, function()
		net.Start("survival_end")
		net.Broadcast()
	end)
end