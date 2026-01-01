--local Organism = hg.organism

local function GetPlayerLang(ply)
	return ply:GetInfo("gmod_language") == "ru" and "ru" or "en"
end

local function isCrush(dmgInfo)
	return (not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST)) or dmgInfo:GetInflictor().RubberBullets
end

local halfValue2 = util.halfValue2
local function damageBone(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet, nodmgchange)
	local crush = isCrush(dmgInfo)
	
	if dmgInfo:IsDamageType(DMG_SLASH) and dmg > 1.5 then
		//crush = false
	end
	
	dmg = dmg * (dmgInfo:GetInflictor().BreakBoneMul or 1)
	
	if crush then
		crush = halfValue2(1 - org[key], 1, 0.5)
		dmg = dmg / math.max(10 * crush * (bone or 1), 1)
		if dmgInfo:GetInflictor().RubberBullets then dmg = dmg * dmgInfo:GetInflictor().Penetration end
	end

	local val = org[key]
	org[key] = math.min(org[key] + dmg, 1)
	local scale = 1 - (org[key] - val)
	
	if !nodmgchange then dmgInfo:ScaleDamage(1 - (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone))) end

	return (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone)), VectorRand(-0.2,0.2) / math.Clamp(dmg,0.4,0.8)
end

local huyasd = {
	en = {
		["spine1"] = "I don't feel anything below my hips.",
		["spine2"] = "I cant't feel or move anything below my torso.",
		["spine3"] = "I can't move at all. I can barely even breathe.",
		["skull"] = "My head is aching.",
	},
	ru = {
		["spine1"] = "Я ничего не чувствую ниже бёдер.",
		["spine2"] = "Я не чувствую и не могу двигать ничем ниже торса.",
		["spine3"] = "Я вообще не могу двигаться. Я едва могу дышать.",
		["skull"] = "Моя голова раскалывается.",
	}
}

local broke_arm = {
	en = {
		"AAAAH—OH GOD, IT'S BROKEN! MY ARM! IT'S BROKEN!",
		"FUCK—MY FUCKING ARM IS BROKEN!",
		"NONONO MY ARM IS BENT ALL WRONG!",
		"IT'S.. MY ARM.. SNAPPED—I HEARD IT SNAP!",
		"MY ARM IS NOT SUPPOSED TO BEND IN HALF!",
	},
	ru = {
		"АААА О БОЖЕ, ОНА СЛОМАНА! МОЯ РУКА! ОНА СЛОМАНА!",
		"ААХ! МОЯ ЁБАНАЯ РУКА!",
		"НЕТНЕТНЕТ МОЯ РУКА ВЫВЕРНУТА СУКА!",
		"ЭТО.. МОЯ РУКА.. ОНА.. ХРУСТНУЛА!!! Я СЛЫШАЛ ХРУСТ!",
		"МОЯ РУКА НЕ ДОЛЖНА СГИБАТЬСЯ ПОПОЛАМ!",
	}
}

local dislocated_arm = {
	en = {
		"MY ARM—GOD, IT'S POPPED OUT OF THE SOCKET!",
		"FUCK—THE SHOULDER'S JUST—HANGING LOOSE!",
		"MY ARM..! IT'S DISLOCATED! I CAN SEE THE BULGE WHERE IT'S WRONG!",
		"THE ARM'S JUST—DEAD WEIGHT—IT'S NOT ATTACHED RIGHT!",
		"SHIT! I CAN FEEL THE BONE OUT OF PLACE!",
	},
	ru = {
		"МОЯ РУКА СУКА!! ОНА ВЫЛЕТЕЛА ИЗ СУСТАВА!",
		"СУКА!! МОЕ ПЛЕЧО ПРОСТО БОЛТАЕТСЯ!",
		"МОЯ РУКА.. ОНА ВЫВИХНУТА! Я ВИЖУ ВЫПУКЛОСТЬ!",
		"МОЯ РУКА!! ОНА НЕПРАВИЛЬНО ПРИСОЕДИНЕНА!",
		"СУКА! Я ЧУВСТВУЮ КОСТЬ НЕ НА МЕСТЕ!",
	}
}

local broke_leg = {
	en = {
		"MY LEG—FUCK, IT'S BROKEN—I HEARD THE SNAP!",
		"FUCK! THE SHIN'S SNAPPED CLEAN THROUGH!",
		"THE KNEE'S WRONG—THE WHOLE LEG'S TWISTED WRONG!",
		"MY LEG..! IT'S JUST—HANGING BY MUSCLE AND SKIN!",
		"THE PAIN'S SHOOTING UP TO MY HIP—FUCK, IT'S BAD!",
		"I CAN'T MOVE MY FOOT—THE ANKLE'S BROKEN TOO!",
	},
	ru = {
		"МОЯ НОГА БЛЯТЬ, ОНА СЛОМАНА! Я СЛЫШАЛ ХРУСТ!",
		"БЛЯТЬ! ГОЛЕНЬ ПЕРЕЛОМАНА НАПРОЧЬ!",
		"МОЕ КОЛЕНО! ВСЯ МОЯ НОГА ВЫВЕРНУТА!",
		"МОЯ НОГА.. ОНА ПРОСТО ДЕРЖИТСЯ НА МЫШЦАХ И КОЖЕ!",
		"БОЛЬ СТРЕЛЯЕТ В БЕДРО! БЛЯТЬ, ЭТО ПЛОХО!",
		"Я НЕ МОГУ ДВИГАТЬ СТУПНЁЙ.. ЛОДЫЖКА ТОЖЕ СЛОМАНА!",
	}
}

local dislocated_leg = {
	en = {
		"MY LEG—FUCK, IT'S DISLOCATED AT THE KNEE!",
		"I CAN SEE THE KNEECAP IN THE WRONG PLACE!",
		"AGHH—THE HIP'S POPPED OUT—IT'S STUCK OUTWARD!",
		"IT'S BENT BACKWARD—THE KNEE SHOULDN'T BEND THIS WAY!",
		"FUCK! THE HIP'S DISLOCATED!",
		"THE ANKLE'S TWISTED—BUT THE KNEE'S THE REAL PROBLEM!",
	},
	ru = {
		"МОЯ НОГА! БЛЯТЬ, ОНА ВЫВИХНУТА В КОЛЕНЕ!",
		"Я ВИЖУ КОЛЕННУЮ ЧАШЕЧКУ НЕ НА МЕСТЕ!",
		"АГГХ! БЕДРО ВЫЛЕТЕЛО! ОНО ТОРЧИТ НАРУЖУ!",
		"ОНО СОГНУТО НАЗАД! КОЛЕНО НЕ ДОЛЖНО ТАК ГНУТЬСЯ!",
		"БЛЯТЬ! БЕДРО ВЫВИХНУТО!",
		"ЛОДЫЖКА ВЫВЕРНУТА... НО КОЛЕНО ЭТО НАСТОЯЩАЯ БЛЯТЬ ПРОБЛЕМА!",
	}
}

local function legs(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.7 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	org.just_damaged_bone = CurTime()
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 40
		org.immobilization = org.immobilization + dmg * 25
		org.fearadd = org.fearadd + 0.5

		if org.isPly then
			local lang = GetPlayerLang(org.owner)
			local msgs = broke_leg[lang]
			org.owner:Notify(msgs[math.random(#msgs)], 1, "broke"..key, 1, nil, nil)
		end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
	else
		org[key.."dislocation"] = true

		org.painadd = org.painadd + 20
		org.immobilization = org.immobilization + dmg * 10
		org.fearadd = org.fearadd + 0.5

		if org.isPly then
			local lang = GetPlayerLang(org.owner)
			local msgs = dislocated_leg[lang]
			org.owner:Notify(msgs[math.random(#msgs)], 1, "dislocated"..key, 1, nil, nil)
		end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 2, "Legs bone damage harm")

	return result, vecrand
end

local function arms(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 4

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.6 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then return 0 end

	org.just_damaged_bone = CurTime()

	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1

		org.painadd = org.painadd + 30
		org.fearadd = org.fearadd + 0.5

		if org.isPly then
			local lang = GetPlayerLang(org.owner)
			local msgs = broke_arm[lang]
			org.owner:Notify(msgs[math.random(#msgs)], 1, "broke"..key, 1, nil, nil)
		end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
	else
		org[key.."dislocation"] = true

		org.painadd = org.painadd + 15
		org.fearadd = org.fearadd + 0.5

		if org.isPly then
			local lang = GetPlayerLang(org.owner)
			local msgs = dislocated_arm[lang]
			org.owner:Notify(msgs[math.random(#msgs)], 1, "dislocated"..key, 1, nil, nil)
		end

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,1) end)
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 1.5, "Arms bone damage harm")

	if org[key] == 1 and key == "rarm" and org.isPly then
		local wep = org.owner.GetActiveWeapon and org.owner:GetActiveWeapon()
	end

	return result, vecrand
end

local function spine(org, bone, dmg, dmgInfo, number, boneindex, dir, hit, ricochet)
	if dmgInfo:IsDamageType(DMG_BLAST) then dmg = dmg / 3 end

	local name = "spine" .. number
	local name2 = "fake_spine" .. number
	if org[name] >= hg.organism[name2] then return 0 end
	local oldDmg = org[name]

	local result, vecrand = damageBone(org, 0.1, isCrush(dmgInfo) and dmg * 2 or dmg * 2, dmgInfo, name, boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 5, "Spine bone damage harm")
	
	if (name == "spine3" || name == "spine2") then
		hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 8, "Broken spine harm")
	end

	if org[name] >= hg.organism[name2] and org.isPly then
		org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		local lang = GetPlayerLang(org.owner)
		org.owner:Notify(huyasd[lang][name], true, name, 2)
		org.painadd = org.painadd + 20
	end
	
	if dmg > 0.2 then
		--org.owner:Notify("Your spinal cord is damaged.",true,"spinalcord",4)
	end

	org.painadd = org.painadd + dmg * 3
	timer.Simple(0, function() hg.LightStunPlayer(org.owner) end)
	org.shock = org.shock + dmg * 15
	return result,vecrand
end

local jaw_broken_msg = {
	en = {
		"I FEEL PIECES OF MY JAW... FUCK-FUCK-FUCK",
		"MY JAW IS FUCKING FLOATING IN MY HEAD",
		"MY JAW... OHH IT HURTS REALLY BAD... I FEEL PIECES OF IT MOVING",
	},
	ru = {
		"Я ЧУВСТВУЮ КУСКИ МОЕЙ ЧЕЛЮСТИ... БЛЯТЬ-БЛЯТЬ-БЛЯТЬ!",
		"ПИЗДЕЦ МОЯ ЧЕЛЮСТЬ СУКА ПЛАВАЕТ В МОЕЙ ГОЛОВЕ",
		"МОЯ ЧЕЛЮСТЬ... ОХХ БЛЯТЬ ЭТО ОЧЕНЬ БОЛЬНО... Я ЧУВСТВУЮ КАК КУСКИ ДВИГАЮТСЯ",
	}
}

local jaw_dislocated_msg = {
	en = {
		"I CAN'T CLOSE MY JAW... IT FUCKING HURTS",
		"MY JAW... ITS JUST STUCK THERE-- OH ITS PAINING",
		"I CANT MOVE MY JAW AT ALL... AND ITS REALLY ACHING",
	},
	ru = {
		"Я НЕ МОГУ ЗАКРЫТЬ ЧЕЛЮСТЬ... ОНО ПИЗДЕЦ КАК БОЛИТ",
		"МОЯ ЧЕЛЮСТЬ... ОНА ПРОСТО ЗАСТРЯЛА ТАМ-- ОХ ЭТО БОЛИТ!",
		"Я ВООБЩЕ НЕ МОГУ ДВИГАТЬ ЧЕЛЮСТЬЮ... ОНА ПИЗДЕЦ КАК НОЕТ!",
	}
}

local input_list = hg.organism.input_list
input_list.jaw = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.jaw

	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "jaw", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.jaw - oldDmg) * 3, "Jaw bone damage harm")

	if org.jaw == 1 and (org.jaw - oldDmg) > 0 and org.isPly then
		local lang = GetPlayerLang(org.owner)
		local msgs = jaw_broken_msg[lang]
		org.owner:Notify(msgs[math.random(#msgs)], true, "jaw", 2)
	end

	local dislocated = (org.jaw - oldDmg) > math.Rand(0.1, 0.3)

	if org.jaw == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	if dislocated then
		org.shock = org.shock + dmg * 20
		org.avgpain = org.avgpain + dmg * 20
		
		if !org.jawdislocation then
			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)
		end

		org.jawdislocation = true

		if org.isPly then
			local lang = GetPlayerLang(org.owner)
			local msgs = jaw_dislocated_msg[lang]
			org.owner:Notify(msgs[math.random(#msgs)], true, "jaw", 2)
		end
	end

	if dmg > 0.2 then
		if org.isPly then timer.Simple(0, function() hg.LightStunPlayer(org.owner,1 + dmg) end) end
	end

	return result,vecrand
end

hook.Add("CanListenOthers", "CantSayWithBrokenJaw", function(output,input,isChat,teamonly,text)
	if IsValid(output) and output.organism.jaw == 1 and output:Alive() and !isChat then
		return false
	end
end)

input_list.skull = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.skull
	
	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "skull", boneindex, dir, hit, ricochet)

	hg.AddHarmToAttacker(dmgInfo, (org.skull - oldDmg) * 4, "Skull bone damage harm")

	if org.skull == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO) end
	end

	org.shock = org.shock + dmg * 3

	org.brain = math.min(org.brain + (math.random(10) == 1 and dmg * 0.05 or 0), 1)
	
	if (org.skull - oldDmg) > 0.6 then
		org.brain = math.min(org.brain + 0.1, 1)
	end

	if dmg > 0.4 then
		if org.isPly then
			timer.Simple(0, function()
				hg.LightStunPlayer(org.owner,1 + dmg)
			end)
		end
	end
	
	org.shock = org.shock + (dmg > 1 and 50 or dmg * 10)

	if org.skull == 1 then
		if dir then
			net.Start("hg_bloodimpact")
			net.WriteVector(dmgInfo:GetDamagePosition())
			net.WriteVector(dir / 10)
			net.WriteFloat(3)
			net.WriteInt(1,8)
			net.Broadcast()
		end
	end

	org.disorientation = org.disorientation + (isCrush(dmgInfo) and dmg * 1 or dmg * 1)

	return result,vecrand
end

local ribs = {
	en = {
		"MY CHEST... SNAPPED",
		"SOMETHING SNAPPED IN MY TORSO",
		"THERE'S SOMETHING SHARP IN MY CHEST...",
		"I FEEL SOMETHING SHARP IN MY TORSO",
	},
	ru = {
		"МОЯ ГРУДЬ... ХРУСТНУЛА...",
		"ЧТО-ТО ХРУСТНУЛО В МОЁМ ТОРСЕ",
		"ЧТО-ТО ОСТРОЕ В МОЕЙ ГРУДИ...",
		"Я ЧУВСТВУЮ ЧТО-ТО ОСТРОЕ В МОЁМ ГРУДАКЕ",
	}
}

input_list.chest = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)	
	local oldDmg = org.chest

	if dmgInfo:IsDamageType(DMG_SLASH+DMG_BULLET+DMG_BUCKSHOT) and math.random(5) == 1 then return 0, vector_origin end

	local result, vecrand = damageBone(org, 0.1, dmg / 4, dmgInfo, "chest", boneindex, dir, hit, ricochet, true)
	
	hg.AddHarmToAttacker(dmgInfo, (org.chest - oldDmg) * 3, "Ribs bone damage harm")

	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	if org.isPly and (not org.brokenribs or (org.brokenribs ~= math.Round(org.chest * 4))) then
		org.brokenribs = math.Round(org.chest * 4)
		
		if org.brokenribs > 0 then
			local lang = GetPlayerLang(org.owner)
			local msgs = ribs[lang]
			org.owner:Notify(msgs[math.random(#msgs)], 5, "ribs", 4)

			org.owner:EmitSound("bones/bone"..math.random(8)..".mp3", 75, 100, 1, CHAN_AUTO)

			return math.min(0, result)
		end
	end

	return result * 0.5, vecrand
end

input_list.pelvis = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.pelvis
	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	local result = damageBone(org, bone, dmg * 0.5, dmgInfo, "pelvis", boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org.pelvis - oldDmg) / 2, "Pelvis bone damage harm")

	return result
end

input_list.rarmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.rarmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "rarm", boneindex, dir, hit, ricochet) end
input_list.larmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone * 1.25, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.larmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "larm", boneindex, dir, hit, ricochet) end
input_list.rlegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.rlegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "rleg", boneindex, dir, hit, ricochet) end
input_list.llegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg * 1.25, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.llegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "lleg", boneindex, dir, hit, ricochet) end
input_list.spine1 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 1, boneindex, dir, hit, ricochet) end
input_list.spine2 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 2, boneindex, dir, hit, ricochet) end
input_list.spine3 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 3, boneindex, dir, hit, ricochet) end