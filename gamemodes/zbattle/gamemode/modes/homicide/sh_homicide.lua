local MODE = MODE
MODE.name = "hmcd"
MODE.PrintName = "Homicide"

zb = zb or {}
zb.Languages = zb.Languages or {}

local translations = {
    ["en"] = {
        ["role_defoko_name"] = "Defoko",
        ["role_defoko_desc"] = "Default.\nYou've prepared for a long time.\nYou are equipped with various weapons, poisons and explosives, grenades and your favourite heavy duty knife and a zoraki signal pistol to help you kill.",
        ["role_defoko_desc_soe"] = "Default.\nYou've prepared a long time for this moment.\nYou are equipped with various weapons, poisons and explosives, grenades and your favourite heavy duty knife and silenced pistol with an additional mag to help you kill.",
        ["role_defoko_obj"] = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
        
        ["role_infiltrator_name"] = "Infiltrator",
        ["role_infiltrator_desc"] = "Can break people's necks from behind.\nCan completely disguise as other players if they're in ragdoll.\nHas no weapons or tools except knife, epipen and smoke grenade.\nFor people who like to play chess.",
        ["role_infiltrator_desc_soe"] = "Can break people's necks from behind.\nCan completely disguise as other players if they're in ragdoll.\nHas smoke grenade, walkie-talkie, knife, taser with 2 additional shooting heads and epipen.\nFor people who like to play chess.",
        ["role_infiltrator_obj"] = "You're an expert in diversion. Be discreet and kill one by one",
        
        ["role_assasin_name"] = "Assasin",
        ["role_assasin_desc"] = "Can quickly disarm people from any angle.\nDisarms faster from behind.\nDisarms faster from front if the victim is in ragdoll.\nProficient in shooting from guns.\nHas additional stamina (+ 80 units compared to other traitors).\nEquipped with walkie-talkie.\nFor people who like to play checkers.",
        ["role_assasin_desc_soe"] = "Can quickly disarm people from any angle.\nDisarms faster from behind.\nDisarms faster from front if the victim is in ragdoll.\nProficient in shooting from guns.\nHas additional stamina (+ 80 units compared to other traitors).\nEquipped with walkie-talkie, knife, epipen and flashlight.\nFor people who like to play checkers.",
        ["role_assasin_obj"] = "You're an expert in guns and in disarmament. Disarm gunman and use his weapon against others",
        
        ["role_chemist_name"] = "Chemist",
        ["role_chemist_desc"] = "Has multiple chemical agents and epipen and knife.\nResistant to a certain degree to all chemical agents mentioned.\nCan detect presence and potency of chemical agents in the air.",
        ["role_chemist_obj"] = "You're a chemist who decided to use his knowledge to hurt others. Poison everything.",
        
        ["role_zombie_name"] = "Zombie",
        ["role_zombie_desc"] = "Can infect other players silently.\nInfected players can be cured by a doctor.\nIf all players are cured zombie will lose.\nInstead of dying will be randomly transported to another infected player's body.\nHas no weapons or any tools.\nDespite being zombie, still bears appearance of a normal human.",
        ["role_zombie_obj"] = "You're the zombie. Infect everyone to win. Avoid doctor.",
        
        ["prof_doctor"] = "Doctor",
        ["prof_huntsman"] = "Huntsman",
        ["prof_engineer"] = "Engineer",
        ["prof_cook"] = "Cook",
        
        ["traitor"] = "Traitor",
        ["murderer"] = "Murderer",
        ["innocent"] = "Innocent",
        ["bystander"] = "Bystander",
        ["traitor_mario"] = "Traitor Mario",
        ["hero_mario"] = "Hero Mario",
        ["innocent_mario"] = "Innocent Mario",
        
        ["obj_kill_all"] = "You've been preparing for this for a long time. Kill everyone.",
        ["obj_mario_traitor"] = "You're the evil Mario! Jump around and take down everyone.",
        ["obj_mario_hero"] = "You're the hero Mario! Use your jumping ability to stop the traitor.",
        ["obj_mario_innocent"] = "You're a bystander Mario, survive and avoid the traitor's traps!",
    },
    ["ru"] = {
        ["role_defoko_name"] = "Дефолт",
        ["role_defoko_desc"] = "Классика.\nВы готовились к этому долгое время.\nВы снаряжены различным оружием, ядами, взрывчаткой и вашим любимым ножом, а также сигнальным пистолетом Zoraki.",
        ["role_defoko_desc_soe"] = "Классика.\nВы долго ждали этого момента.\nВы снаряжены оружием, ядами и взрывчаткой, а также бесшумным пистолетом с запасным магазином.",
        ["role_defoko_obj"] = "У вас есть всё: от ядов до взрывчатки. Убейте всех.",
        
        ["role_infiltrator_name"] = "Диверсант",
        ["role_infiltrator_desc"] = "Может ломать шеи со спины.\nМожет полностью маскироваться под других игроков, если они в состоянии регдолла.\nНет оружия, кроме ножа, эпинефрина и дымовой шашки.\nДля любителей шахмат.",
        ["role_infiltrator_desc_soe"] = "Может ломать шеи со спины.\nМожет маскироваться под других. Есть дымовуха, рация, нож, тайзер с зарядами и эпинефрин.\nДля стратегов.",
        ["role_infiltrator_obj"] = "Вы эксперт в скрытности. Будьте осторожны и убивайте по одному.",
        
        ["role_assasin_name"] = "Ассасин",
        ["role_assasin_desc"] = "Быстро обезоруживает людей под любым углом.\nСо спины — еще быстрее. Если жертва без сознания — мгновенно.\nМастер стрельбы. Имеет повышенную выносливость (+80 единиц).\nЕсть рация.\nДля любителей шашек.",
        ["role_assasin_desc_soe"] = "Мастер обезоруживания и стрельбы.\nПовышенная выносливость. Снаряжен рацией, ножом, эпинефрином и фонариком.\nДля активных игроков.",
        ["role_assasin_obj"] = "Вы эксперт по оружию. Обезоруживайте врагов и используйте их пушки против них самих.",
        
        ["role_chemist_name"] = "Химик",
        ["role_chemist_desc"] = "Имеет при себе набор химикатов, эпинефрин и нож.\nУстойчив к воздействию своих газов.\nВидит концентрацию и тип химикатов в воздухе.",
        ["role_chemist_obj"] = "Вы химик, решивший использовать знания во вред. Отравите всё вокруг.",
        
        ["role_zombie_name"] = "Зомби",
        ["role_zombie_desc"] = "Может незаметно заражать игроков.\nЗараженных может вылечить доктор. Если всех вылечат — зомби проиграет.\nВместо смерти переселяется в тело другого зараженного.\nОружия нет, выглядит как человек.",
        ["role_zombie_obj"] = "Вы зомби. Заразите всех, чтобы победить. Избегайте доктора.",
        
        ["prof_doctor"] = "Доктор",
        ["prof_huntsman"] = "Егерь",
        ["prof_engineer"] = "Инженер",
        ["prof_cook"] = "Повар",
        
        ["traitor"] = "Предатель",
        ["murderer"] = "Убийца",
        ["innocent"] = "Невиновный",
        ["bystander"] = "Прохожий",
        ["traitor_mario"] = "Злой Марио",
        ["hero_mario"] = "Герой Марио",
        ["innocent_mario"] = "Обычный Марио",
        
        ["obj_kill_all"] = "Вы долго к этому готовились. Убейте всех.",
        ["obj_mario_traitor"] = "Вы злой Марио! Прыгайте по головам и уничтожьте всех.",
        ["obj_mario_hero"] = "Вы герой Марио! Используйте прыжки, чтобы остановить предателя.",
        ["obj_mario_innocent"] = "Вы обычный Марио, выживайте и избегайте ловушек!",
    }
}

for lang, keys in pairs(translations) do
    zb.Languages[lang] = zb.Languages[lang] or {}
    for k, v in pairs(keys) do
        zb.Languages[lang][k] = v
    end
end

function zb:GetTerm(key)
    local lang = (GetConVar("gmod_language"):GetString() == "russian") and "ru" or "en"
    return (self.Languages[lang] and self.Languages[lang][key]) or (self.Languages["en"] and self.Languages["en"][key]) or key
end
--------------------------------------------------------------------------------

--\\
MODE.TraitorExpectedAmtBits = 13
--//

--\\Sub Roles
MODE.ConVarName_SubRole_Traitor = "hmcd_subrole_traitor"

if(CLIENT)then
	MODE.ConVar_SubRole_Traitor = CreateClientConVar(MODE.ConVarName_SubRole_Traitor, "traitor_default", true, true, "Выбор под роли в хомисайде")
end

--; TODO
--; Инженер - шахид бомба + иеды

MODE.SubRoles = {
	--=\\Traitor
	--==\\
	["traitor_default"] = {
		Name = zb:GetTerm("role_defoko_name"),
		Description = zb:GetTerm("role_defoko_desc"),
		Objective = zb:GetTerm("role_defoko_obj"),
		SpawnFunction = function(ply)
			local wep = ply:Give("weapon_zoraki")
			
			timer.Simple(1, function()
				wep:ApplyAmmoChanges(2)
			end)
		
			ply:Give("weapon_buck200knife")	
			ply:Give("weapon_hg_rgd_tpik")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_shuriken")
			ply:Give("weapon_hg_smokenade")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_suit")
			ply:Give("weapon_hg_jam")
			-- ply:Give("weapon_traitor_poison2")
			-- ply:Give("weapon_traitor_poison3")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_default_soe"] = {
		Name = zb:GetTerm("role_defoko_name"),
		Description = zb:GetTerm("role_defoko_desc_soe"),
		Objective = zb:GetTerm("role_defoko_obj"),
		SpawnFunction = function(ply)
			if not IsValid(ply) then return end
			local p22 = ply:Give("weapon_p22")
			if not IsValid(p22) then return end
			ply:GiveAmmo(p22:GetMaxClip1() * 1, p22:GetPrimaryAmmoType(), true)
			
			hg.AddAttachmentForce(ply, p22, "supressor4")
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade")
			ply:Give("weapon_traitor_ied")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory",inv)
		end,
	},
	--==//
	
	--==\\
	["traitor_infiltrator"] = {
		Name = zb:GetTerm("role_infiltrator_name"),
		Description = zb:GetTerm("role_infiltrator_desc"),
		Objective = zb:GetTerm("role_infiltrator_obj"),
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_infiltrator_soe"] = {
		Name = zb:GetTerm("role_infiltrator_name"),
		Description = zb:GetTerm("role_infiltrator_desc_soe"),
		Objective = zb:GetTerm("role_infiltrator_obj"),
		SpawnFunction = function(ply)
			local taser = ply:Give("weapon_taser")
			
			ply:GiveAmmo(taser:GetMaxClip1() * 2, taser:GetPrimaryAmmoType(), true)
			ply:Give("weapon_sogknife")
			-- ply:Give("weapon_hg_rgd_tpik")
			-- ply:Give("weapon_walkie_talkie")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_hg_smokenade")
			
			ply.organism.recoilmul = 1
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	--; СДЕЛАТЬ ЕМУ ЛУТ ДРУГИХ ИГРОКОВ ДАЖЕ ПОКА У НИХ НЕТ ПУШКИ В РУКАХ
	--; Сделать ему вырубание по вагус нерву
	["traitor_assasin"] = {
		Name = zb:GetTerm("role_assasin_name"),
		Description = zb:GetTerm("role_assasin_desc"),
		Objective = zb:GetTerm("role_assasin_obj"),
		SpawnFunction = function(ply)
			-- ply:Give("weapon_sogknife")	
			-- ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_hg_smokenade")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.8
			ply.organism.stamina.max = 300
			-- local inv = ply:GetNetVar("Inventory", {})
			-- inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	["traitor_assasin_soe"] = {
		Name = zb:GetTerm("role_assasin_name"),
		Description = zb:GetTerm("role_assasin_desc_soe"),
		Objective = zb:GetTerm("role_assasin_obj"),
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")	
			ply:Give("weapon_adrenaline")
			-- ply:Give("weapon_walkie_talkie")
			-- ply:Give("weapon_hg_smokenade")
			-- ply:Give("weapon_hg_shuriken")
			
			ply.organism.recoilmul = 0.4
			ply.organism.stamina.max = 300
			--local inv = ply:GetNetVar("Inventory", {})
			--inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
		end,
	},
	--==//
	
	--==\\
	["traitor_chemist"] = {
		Name = zb:GetTerm("role_chemist_name"),
		Description = zb:GetTerm("role_chemist_desc"),
		Objective = zb:GetTerm("role_chemist_obj"),
		SpawnFunction = function(ply)
			ply:Give("weapon_sogknife")
			ply:Give("weapon_adrenaline")
			ply:Give("weapon_traitor_poison1")
			ply:Give("weapon_traitor_poison2")
			ply:Give("weapon_traitor_poison3")
			ply:Give("weapon_traitor_poison4")
			ply:Give("weapon_traitor_poison_consumable")
			
			ply.organism.stamina.max = 220
			local inv = ply:GetNetVar("Inventory", {})
			inv["Weapons"]["hg_flashlight"] = true
			
			ply:SetNetVar("Inventory", inv)
			MODE.CleanChemicalsOfPlayer(ply)
		end,
	},
	--==//
	["traitor_zombie"] = {
		Name = zb:GetTerm("role_zombie_name"),
		Description = zb:GetTerm("role_zombie_desc"),
		Objective = zb:GetTerm("role_zombie_obj"),
		SpawnFunction = function(ply)
			-- Специфика зомби
		end,
	},
	--=//
}
--//

--\\Professions
MODE.ProfessionsRoundTypes = {
	["standard"] = true,
	["soe"] = true,
}

MODE.Professions = {
	["doctor"] = {
		Name = zb:GetTerm("prof_doctor"),
		SpawnFunction = function(ply) end,
	},
	["huntsman"] = {
		Name = zb:GetTerm("prof_huntsman"),
		SpawnFunction = function(ply) end,
	},
	["engineer"] = {
		Name = zb:GetTerm("prof_engineer"),
		SpawnFunction = function(ply) end,
	},
	["cook"] = {
		Name = zb:GetTerm("prof_cook"),
		SpawnFunction = function(ply) end,
	},
}
--//

--\\
MODE.FadeScreenTime = 1.5
MODE.DefaultRoundStartTime = 6
MODE.RoleChooseRoundStartTime = 10

MODE.RoleChooseRoundTypes = {
	["standard"] = {
		TraitorDefaultRole = "traitor_default",
		Traitor = {
			["traitor_default"] = true,
			["traitor_infiltrator"] = true,
			["traitor_chemist"] = true,
			["traitor_assasin"] = true,
		},
		Professions = {
			["doctor"] = { Chance = 1 },
			["huntsman"] = { Chance = 1 },
			["engineer"] = { Chance = 1 },
			["cook"] = { Chance = 1 },
		},
	},
	["soe"] = {
		TraitorDefaultRole = "traitor_default_soe",
		Traitor = {
			["traitor_default_soe"] = true,
			["traitor_infiltrator_soe"] = true,
			["traitor_assasin_soe"] = true,
		},
		Professions = {
			["doctor"] = { Chance = 1 },
			["huntsman"] = { Chance = 1 },
			["engineer"] = { Chance = 1 },
			["cook"] = { Chance = 1 },
		},
	},
}
--//

MODE.Roles = {}
MODE.Roles.soe = {
	traitor = {
		name = zb:GetTerm("traitor"),
		color = Color(190,0,0)
	},
	gunner = {
		name = zb:GetTerm("innocent"),
		color = Color(158,0,190)
	},
	innocent = {
		name = zb:GetTerm("innocent"),
		color = Color(0,120,190)
	},
}

MODE.Roles.standard = {
	traitor = {
		objective = zb:GetTerm("obj_kill_all"),
		name = zb:GetTerm("murderer"),
		color = Color(190,0,0)
	},
	gunner = {
		name = zb:GetTerm("bystander"),
		color = Color(158,0,190)
	},
	innocent = {
		name = zb:GetTerm("bystander"),
		color = Color(0,120,190)
	},
}

MODE.Roles.wildwest = {
	traitor = {
		objective = zb:GetTerm("obj_kill_all"),
		name = zb:GetTerm("murderer"),
		color = Color(190,0,0)
	},
	gunner = {
		name = zb:GetTerm("bystander"),
		color = Color(159,85,0)
	},
	innocent = {
		name = zb:GetTerm("bystander"),
		color = Color(159,85,0)
	},
}

MODE.Roles.gunfreezone = {
	traitor = {
		name = zb:GetTerm("murderer"),
		color = Color(190,0,0)
	},
	gunner = {
		name = zb:GetTerm("innocent"),
		color = Color(0,120,190)
	},
	innocent = {
		name = zb:GetTerm("innocent"),
		color = Color(0,120,190)
	},
}

MODE.Roles.supermario = {
	traitor = {
		objective = zb:GetTerm("obj_mario_traitor"),
		name = zb:GetTerm("traitor_mario"),
		color = Color(190,0,0)
	},
	gunner = {
		objective = zb:GetTerm("obj_mario_hero"),
		name = zb:GetTerm("hero_mario"),
		color = Color(158,0,190)
	},
	innocent = {
		objective = zb:GetTerm("obj_mario_innocent"),
		name = zb:GetTerm("innocent_mario"),
		color = Color(0,120,190)
	},
}

function MODE.GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)
	
	if(trace)then
		local aim_ent = trace.Entity
		local other_ply = nil
		
		if(IsValid(aim_ent))then
			if(aim_ent:IsPlayer())then
				other_ply = aim_ent
			elseif(aim_ent:IsRagdoll())then
				if(IsValid(aim_ent.ply))then
					other_ply = aim_ent.ply
				end
			end
		end
		
		return aim_ent, other_ply, trace
	else
		return nil
	end
end