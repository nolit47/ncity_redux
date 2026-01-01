local MODE = MODE or {}
MODE.name = "azombie"
MODE.PrintName = "Zombie Invasion"
MODE.LootSpawn = true
MODE.start_time = 5

MODE.name = "azombie"
MODE.LootSpawn = true
MODE.GuiltDisabled = false
MODE.randomSpawns = true

MODE.ForBigMaps = false
MODE.Chance = 0.03

MODE.OverideSpawnPos = true

MODE.ForBigMaps = true

MODE.Chance = 0.05

util.AddNetworkString("azmb_start")
util.AddNetworkString("azmb_end")
util.AddNetworkString("azmb_giverole")

local roles = {
	["citizen"] = {
		objective = "Kill all these bitches, these are my OFFICIAL INSTRUCTIONS.",
		name = "Survivor",
		color = Color(50,150,10),
		color1 = Color(255,255,255)
	},
	["policeman"] = {
		objective = "Find people, help them organize a shelter, if anyone interferes with your goals, you have the right to kill them.",
		name = "policeman",
		color = Color(55,65,165),
		color1 = Color(255,255,255),
		equipment = {
			armor = {"vest2"},
			rndweapons = {"weapon_glock17","weapon_px4beretta"},
			playerclass = "police"
		}
	}
}

--[[
	["policeman"] = {
		objective = "Find people, help them organize a shelter, if anyone interferes with your goals, you have the right to kill them.",
		name = "policeman",
		color = Color(55,65,165),
		color1 = Color(255,255,255),
		equipment = {
			armor = {"vest2"},
			rndweapons = {"weapon_glock17","weapon_px4beretta"},
			playerclass = "police"
		}
	},	
	["marauder"] = {
		objective = "In the midst of the apocalypse, you haven’t found anything better than to rob, kill and do crap in the prince.",
		name = "marauder",
		color = Color(165,55,55),
		color1 = Color(255,255,255),
		equipment = {
			armor = {"vest3"},
			rndweapons = {"weapon_makarov","weapon_revolver2","weapon_revolver357","weapon_tec9"}
		},
	}
--]]

function MODE:Intermission()
	game.CleanUpMap()

	self.Zombuss = {}

	for k, ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ApplyAppearance(ply)
		ply:SetupTeam(0)
		local role = roles.citizen
		ply.role = role
		net.Start("azmb_giverole")
			net.WriteTable(ply.role)
		net.Send(ply)
		ply:Freeze(true)
	end


	net.Start("azmb_start")
	net.Broadcast()

	for k, v in ipairs(zb.Points["RandomSpawns"].Points or {}) do
        local random = math.random(1, math.max(12 - player.GetCount(),2))

        if random == 1 then
            local zombie = ents.Create("npc_zombie")
            zombie:SetPos(v.pos)
            zombie:SetAngles(v.ang)
            zombie:Spawn()
            zombie:Activate()
			self.Zombuss[(#self.Zombuss or 0) + 1] = zombie
			zombie:SetSubMaterial(1,"")
        end
    end
end

function MODE:CheckAlivePlayers()
end

function MODE:ShouldRoundEnd()
	return (#zb:CheckAlive() < 1) or (self.Zombuss and #self.Zombuss < 1)
end

function MODE:RoundStart()
	for k, ply in ipairs(player.GetAll()) do
		ply:Freeze(false)
	end
end

function MODE:GiveWeapons()
	print("huy")
end

function MODE:GiveEquipment()
	local points = zb.GetMapPoints( "AZSpawn" )
	timer.Simple(0.5,function()
		for _, ply in ipairs(player.GetAll()) do
			if not ply:Alive() then continue end
			ply:SetSuppressPickupNotices(true)
				if ply.role.equipment then
					for k,v in pairs(ply.role.equipment) do
						if k == "armor" then
							hg.AddArmor(ply,v)
						elseif k == "rndweapons" then
							ply:Give(table.Random(v))
						elseif k == "playerclass" then
							ply:SetPlayerClass(v)
						end
					end
				end
				if ply.role.customfunc then
					ply.role.customfunc(ply)
				end
				ply:Give("weapon_hands_sh")
			ply:SetSuppressPickupNotices(false)
			local rnd = math.random(1,#points)
			ply:SetPos(points[rnd].pos)
			table.remove(points,rnd)
		end
	end)
end

function MODE:RoundThink()
end

function MODE:PlayerDeath(_,ply)
end

function MODE:GetTeamSpawn()
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("azmb_end")
		local ent = zb:CheckAlive()[1]
		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.Broadcast()
	end)
end

function MODE:CanLaunch()
	--local points = zb.GetMapPoints( "AZSpawn" )
	return false--#points > 1 and #camPoints > 1
end

local headcrabs = {
	npc_headcrab = true,
	npc_headcrab_fast = true,
	npc_headcrab_black = true,
	npc_headcrab_poison = true
}

function MODE:OnEntityCreated( ent )
	--timer.Simple(.1,function()
		--if headcrabs[ent:GetClass()] then
			--ent:Remove()
		--end
	--end)
end

function MODE:OnNPCKilled(npc, attacker, inflictor)   
	table.remove(self.Zombuss, #self.Zombuss)
end