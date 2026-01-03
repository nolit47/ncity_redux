local MODE = MODE
MODE.name = "hmcd"

--\\Local Functions
local function screen_scale_2(num)
	return ScreenScale(num) / (ScrW() / ScrH())
end

-- Localization system
local LANG = {}

-- English
LANG["en"] = {
	-- Chat messages
	["alone_mission"] = "You are alone on your mission.",
	["accomplice_one"] = "You have 1 accomplice",
	["traitors_besides"] = "There are(is) %d traitor(s) besides you",
	["secret_words"] = "Traitor secret words are: \"%s\" and \"%s\".",
	["traitor_names"] = "Traitor names (only you, as a main traitor can see them):",
	
	-- Round types
	["type_standard"] = "Standard",
	["type_soe"] = "State of Emergency",
	["type_gunfreezone"] = "Gun Free Zone",
	["type_suicidelunatic"] = "Suicide Lunatic",
	["type_wildwest"] = "Wild west",
	["type_supermario"] = "Super Mario",
	
	-- Handicaps
	["handicap_leg"] = "You are handicapped: your right leg is broken.",
	["handicap_obesity"] = "You are handicapped: you are suffering from severe obesity.",
	["handicap_hemophilia"] = "You are handicapped: you are suffering from hemophilia.",
	["handicap_incapacitated"] = "You are handicapped: you are physically incapacitated.",
	
	-- HUD
	["homicide"] = "Homicide",
	["unknown"] = "Unknown",
	["you_are"] = "You are %s",
	["assistant"] = "Assistant",
	["traitors_list"] = "Traitors list:",
	["traitor_secret_words"] = "Traitor secret words:",
	["occupation"] = "Occupation: %s",
	["round_starting"] = "Round is starting...",
	
	-- Roles - Standard
	["standard_traitor_name"] = "a Murderer",
	["standard_traitor_obj"] = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
	["standard_gunner_name"] = "a Bystander",
	["standard_gunner_obj"] = "You are a bystander with a concealed firearm. You've tasked yourself to help police find the criminal faster.",
	["standard_innocent_name"] = "a Bystander",
	["standard_innocent_obj"] = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
	
	-- Roles - SOE
	["soe_traitor_name"] = "a Traitor",
	["soe_traitor_obj"] = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
	["soe_gunner_name"] = "an Innocent",
	["soe_gunner_obj"] = "You are an innocent with a hunting weapon. Find and neutralize the traitor before it's too late.",
	["soe_innocent_name"] = "an Innocent",
	["soe_innocent_obj"] = "You are an innocent, rely only on yourself, but stick around with crowds to make traitor's job harder.",
	
	-- Roles - Wild West
	["wildwest_traitor_name"] = "The Killer",
	["wildwest_traitor_obj"] = "This town ain't that big for all of us.",
	["wildwest_gunner_name"] = "The Sheriff",
	["wildwest_gunner_obj"] = "You're the sheriff of this town. You gotta find and kill the lawless bastard.",
	["wildwest_innocent_name"] = "a Fellow Cowboy",
	["wildwest_innocent_obj"] = "We gotta get justice served over here, there's a lawless prick murdering men.",
	
	-- Roles - Gun Free Zone
	["gunfreezone_traitor_name"] = "a Murderer",
	["gunfreezone_traitor_obj"] = "You're geared up with items, poisons, explosives and weapons hidden in your pockets. Murder everyone here.",
	["gunfreezone_gunner_name"] = "a Bystander",
	["gunfreezone_gunner_obj"] = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
	["gunfreezone_innocent_name"] = "a Bystander",
	["gunfreezone_innocent_obj"] = "You are a bystander of a murder scene, although it didn't happen to you, you better be cautious.",
	
	-- Roles - Suicide Lunatic
	["suicidelunatic_traitor_name"] = "a Shahid",
	["suicidelunatic_traitor_obj"] = "My brother insha'Allah, don't let him down.",
	["suicidelunatic_gunner_name"] = "an Innocent",
	["suicidelunatic_gunner_obj"] = "Sheep fucker's gone crazy, now you need to survive.",
	["suicidelunatic_innocent_name"] = "an Innocent",
	["suicidelunatic_innocent_obj"] = "Sheep fucker's gone crazy, now you need to survive.",
	
	-- Roles - Super Mario
	["supermario_traitor_name"] = "Traitor Mario",
	["supermario_traitor_obj"] = "You're the evil Mario! Jump around and take down everyone.",
	["supermario_gunner_name"] = "Hero Mario",
	["supermario_gunner_obj"] = "You're the hero Mario! Use your jumping ability to stop the traitor.",
	["supermario_innocent_name"] = "Innocent Mario",
	["supermario_innocent_obj"] = "You're a bystander Mario, survive and avoid the traitor's traps!",
	
	-- Assistant traitor
	["assistant_traitor_obj"] = "You are equipped with nothing. Help other traitors win.",
	
	-- End screen
	["was_traitor"] = " was a traitor",
	["close"] = "Close",
	["died"] = " - died",
	["incapacitated"] = " - incapacitated",
	["traitor_lose_arrested"] = "Traitor %s was arrested.",
	["traitor_lose_killed"] = "Traitor %s was killed.",
	["somewhere_pluvtown"] = "SOMEWHERE IN PLUVTOWN",
}

-- Russian
LANG["ru"] = {
	-- Chat messages
	["alone_mission"] = "Ты один на этом задании.",
	["accomplice_one"] = "У тебя есть 1 сообщник",
	["traitors_besides"] = "Помимо тебя есть %d предатель(ей)",
	["secret_words"] = "Секретные слова предателей: \"%s\" и \"%s\".",
	["traitor_names"] = "Имена предателей (только ты, как главный предатель, можешь их видеть):",
	
	-- Round types
	["type_standard"] = "Стандарт",
	["type_soe"] = "Чрезвычайное положение",
	["type_gunfreezone"] = "Зона без оружия",
	["type_suicidelunatic"] = "Террорист-смертник",
	["type_wildwest"] = "Дикий запад",
	["type_supermario"] = "Супер Марио",
	
	-- Handicaps
	["handicap_leg"] = "У тебя инвалидность: твоя правая нога сломана.",
	["handicap_obesity"] = "У тебя инвалидность: ты страдаешь от ожирения.",
	["handicap_hemophilia"] = "У тебя инвалидность: ты страдаешь от гемофилии.",
	["handicap_incapacitated"] = "У тебя инвалидность: ты физически недееспособен.",
	
	-- HUD
	["homicide"] = "Убийство",
	["unknown"] = "Неизвестно",
	["you_are"] = "Ты %s",
	["assistant"] = "Помощник",
	["traitors_list"] = "Список предателей:",
	["traitor_secret_words"] = "Секретные слова предателей:",
	["occupation"] = "Профессия: %s",
	["round_starting"] = "Раунд начинается...",
	
	-- Roles - Standard
	["standard_traitor_name"] = "Убийца",
	["standard_traitor_obj"] = "Ты экипирован предметами, ядами, взрывчаткой и оружием, спрятанным в карманах. Убей всех здесь.",
	["standard_gunner_name"] = "Невиновный",
	["standard_gunner_obj"] = "Ты Невиновный со скрытым огнестрельным оружием. Ты взял на себя задачу помочь полиции быстрее найти преступника.",
	["standard_innocent_name"] = "Невиновный",
	["standard_innocent_obj"] = "Ты Невиновный на месте убийства, хотя с тобой ничего не случилось, но тебе лучше быть осторожным.",
	
	-- Roles - SOE
	["soe_traitor_name"] = "Предатель",
	["soe_traitor_obj"] = "Ты экипирован предметами, ядами, взрывчаткой и оружием, спрятанным в карманах. Убей всех здесь.",
	["soe_gunner_name"] = "Невиновный",
	["soe_gunner_obj"] = "Ты невиновный с охотничьим оружием. Найди и нейтрализуй предателя, пока не поздно.",
	["soe_innocent_name"] = "Невиновный",
	["soe_innocent_obj"] = "Ты невиновный, полагайся только на себя, но держись рядом с толпой, чтобы усложнить работу предателю.",
	
	-- Roles - Wild West
	["wildwest_traitor_name"] = "Убийца",
	["wildwest_traitor_obj"] = "Этот город недостаточно большой для всех нас.",
	["wildwest_gunner_name"] = "Шериф",
	["wildwest_gunner_obj"] = "Ты шериф этого города. Тебе нужно найти и убить беззаконника.",
	["wildwest_innocent_name"] = "Ковбой",
	["wildwest_innocent_obj"] = "Нам нужно восстановить справедливость, здесь беззаконный ублюдок убивает людей.",
	
	-- Roles - Gun Free Zone
	["gunfreezone_traitor_name"] = "Убийца",
	["gunfreezone_traitor_obj"] = "Ты экипирован предметами, ядами, взрывчаткой и оружием, спрятанным в карманах. Убей всех здесь.",
	["gunfreezone_gunner_name"] = "Невиновный",
	["gunfreezone_gunner_obj"] = "Ты Невиновный на месте убийства, хотя с тобой ничего не случилось, но тебе лучше быть осторожным.",
	["gunfreezone_innocent_name"] = "Невиновный",
	["gunfreezone_innocent_obj"] = "Ты Невиновный на месте убийства, хотя с тобой ничего не случилось, но тебе лучше быть осторожным.",
	
	-- Roles - Suicide Lunatic
	["suicidelunatic_traitor_name"] = "Шахид",
	["suicidelunatic_traitor_obj"] = "Мой брат иншааллах, не подведи его.",
	["suicidelunatic_gunner_name"] = "Невиновный",
	["suicidelunatic_gunner_obj"] = "Ебатель овец сошёл с ума, теперь тебе нужно выжить.",
	["suicidelunatic_innocent_name"] = "Невиновный",
	["suicidelunatic_innocent_obj"] = "Ебатель овец сошёл с ума, теперь тебе нужно выжить.",
	
	-- Roles - Super Mario
	["supermario_traitor_name"] = "Злой Марио",
	["supermario_traitor_obj"] = "Ты злой Марио! Прыгай и убивай всех.",
	["supermario_gunner_name"] = "Герой Марио",
	["supermario_gunner_obj"] = "Ты герой Марио! Используй свою способность прыгать, чтобы остановить предателя.",
	["supermario_innocent_name"] = "Невиновный Марио",
	["supermario_innocent_obj"] = "Ты невиновный Марио, выживай и избегай ловушек предателя!",
	
	-- Assistant traitor
	["assistant_traitor_obj"] = "Ты ничем не экипирован. Помоги другим предателям победить.",
	
	-- End screen
	["was_traitor"] = " был предателем",
	["close"] = "Закрыть",
	["died"] = " - умер",
	["incapacitated"] = " - недееспособен",
	["traitor_lose_arrested"] = "Предатель %s был арестован.",
	["traitor_lose_killed"] = "Предатель %s был убит.",
	["somewhere_pluvtown"] = "ГДЕ-ТО В ПЛАВТАУНЕ",
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

MODE.L = L
--//

MODE.TypeSounds = {
	["standard"] = {"snd_jack_hmcd_psycho.mp3","snd_jack_hmcd_shining.mp3"},
	["soe"] = "snd_jack_hmcd_disaster.mp3",
	["gunfreezone"] = "snd_jack_hmcd_panic.mp3" ,
	["suicidelunatic"] = "zbattle/jihadmode.mp3",
	["wildwest"] = "snd_jack_hmcd_wildwest.mp3",
	["supermario"] = "snd_jack_hmcd_psycho.mp3"
}
local fade = 0
net.Receive("homicide_start",function()
	for i,ply in ipairs(player.GetAll()) do
		ply.isTraitor = false
		ply.isGunner = false
	end

	--\\
	lply.isTraitor = net.ReadBool()
	lply.isGunner = net.ReadBool()
	MODE.Type = net.ReadString()
	local screen_time_is_default = net.ReadBool()
	lply.SubRole = net.ReadString()
	lply.MainTraitor = net.ReadBool()
	MODE.TraitorWord = net.ReadString()
	MODE.TraitorWordSecond = net.ReadString()
	MODE.TraitorExpectedAmt = net.ReadUInt(MODE.TraitorExpectedAmtBits)
	StartTime = CurTime()
	MODE.TraitorsLocal = {}

	if(lply.isTraitor and screen_time_is_default)then
		if(MODE.TraitorExpectedAmt == 1)then
			chat.AddText(L("alone_mission"))
		else
			if(MODE.TraitorExpectedAmt == 2)then
				chat.AddText(L("accomplice_one"))
			else
				chat.AddText(L("traitors_besides", MODE.TraitorExpectedAmt - 1))
			end

			chat.AddText(L("secret_words", MODE.TraitorWord, MODE.TraitorWordSecond))
		end

		if(lply.MainTraitor)then
			if(MODE.TraitorExpectedAmt > 1)then
				chat.AddText(L("traitor_names"))
			end

			for key = 1, MODE.TraitorExpectedAmt do
				local traitor_info = {net.ReadColor(false), net.ReadString()}

				if(MODE.TraitorExpectedAmt > 1)then
					MODE.TraitorsLocal[#MODE.TraitorsLocal + 1] = traitor_info

					chat.AddText(traitor_info[1], "\t" .. traitor_info[2])
				end
			end
		end
	end

	lply.Profession = net.ReadString()
	--//

	if(MODE.RoleChooseRoundTypes[MODE.Type] and !screen_time_is_default)then
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.RoleChooseRoundStartTime
	else
		MODE.DynamicFadeScreenEndTime = CurTime() + MODE.DefaultRoundStartTime
	end

	MODE.RoleEndedChosingState = screen_time_is_default

	if(screen_time_is_default)then
		if istable(MODE.TypeSounds[MODE.Type]) then
			surface.PlaySound(table.Random(MODE.TypeSounds[MODE.Type]))
		else
			surface.PlaySound(MODE.TypeSounds[MODE.Type])
		end
	end

	fade = 0
end)

MODE.TypeNames = {
	["standard"] = function() return L("type_standard") end,
	["soe"] = function() return L("type_soe") end,
	["gunfreezone"] = function() return L("type_gunfreezone") end,
	["suicidelunatic"] = function() return L("type_suicidelunatic") end,
	["wildwest"] = function() return L("type_wildwest") end,
	["supermario"] = function() return L("type_supermario") end
}

local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", "Bahnschrift", true, false, "change every text font to selected because ui customization is cool")
local font = function()
    local usefont = "Bahnschrift"

    if hg_font:GetString() != "" then
        usefont = hg_font:GetString()
    end

    return usefont
end

surface.CreateFont("ZB_HomicideSmall", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMedium", {
	font = font(),
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideMediumLarge", {
	font = font(),
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideLarge", {
	font = font(),
	size = ScreenScale(30),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_HomicideHumongous", {
	font = font(),
	size = 255,
	weight = 400,
	antialias = true
})

MODE.TypeObjectives = {}
MODE.TypeObjectives.soe = {
	traitor = {
		objective = function() return L("soe_traitor_obj") end,
		name = function() return L("soe_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("soe_gunner_obj") end,
		name = function() return L("soe_gunner_name") end,
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = function() return L("soe_innocent_obj") end,
		name = function() return L("soe_innocent_name") end,
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.standard = {
	traitor = {
		objective = function() return L("standard_traitor_obj") end,
		name = function() return L("standard_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("standard_gunner_obj") end,
		name = function() return L("standard_gunner_name") end,
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = function() return L("standard_innocent_obj") end,
		name = function() return L("standard_innocent_name") end,
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.wildwest = {
	traitor = {
		objective = function() return L("wildwest_traitor_obj") end,
		name = function() return L("wildwest_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("wildwest_gunner_obj") end,
		name = function() return L("wildwest_gunner_name") end,
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = function() return L("wildwest_innocent_obj") end,
		name = function() return L("wildwest_innocent_name") end,
		color1 = Color(0,120,190),
		color2 = Color(158,0,190)
	},
}

MODE.TypeObjectives.gunfreezone = {
	traitor = {
		objective = function() return L("gunfreezone_traitor_obj") end,
		name = function() return L("gunfreezone_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("gunfreezone_gunner_obj") end,
		name = function() return L("gunfreezone_gunner_name") end,
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = function() return L("gunfreezone_innocent_obj") end,
		name = function() return L("gunfreezone_innocent_name") end,
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.suicidelunatic = {
	traitor = {
		objective = function() return L("suicidelunatic_traitor_obj") end,
		name = function() return L("suicidelunatic_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("suicidelunatic_gunner_obj") end,
		name = function() return L("suicidelunatic_gunner_name") end,
		color1 = Color(0,120,190)
	},

	innocent = {
		objective = function() return L("suicidelunatic_innocent_obj") end,
		name = function() return L("suicidelunatic_innocent_name") end,
		color1 = Color(0,120,190)
	},
}

MODE.TypeObjectives.supermario = {
	traitor = {
		objective = function() return L("supermario_traitor_obj") end,
		name = function() return L("supermario_traitor_name") end,
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},

	gunner = {
		objective = function() return L("supermario_gunner_obj") end,
		name = function() return L("supermario_gunner_name") end,
		color1 = Color(158,0,190),
		color2 = Color(158,0,190)
	},

	innocent = {
		objective = function() return L("supermario_innocent_obj") end,
		name = function() return L("supermario_innocent_name") end,
		color1 = Color(0,120,190)
	},
}

function MODE:RenderScreenspaceEffects()
	fade_end_time = MODE.DynamicFadeScreenEndTime or 0
	local time_diff = fade_end_time - CurTime()

	if(time_diff > 0)then
		zb.RemoveFade()

		local fade = math.min(time_diff / MODE.FadeScreenTime, 1)

		surface.SetDrawColor(0, 0, 0, 255 * fade)
		surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1 )
	end
end

local handicap = {
	[1] = function() return L("handicap_leg") end,
	[2] = function() return L("handicap_obesity") end,
	[3] = function() return L("handicap_hemophilia") end,
	[4] = function() return L("handicap_incapacitated") end
}

function MODE:HUDPaint()
	if not MODE.Type or not MODE.TypeObjectives[MODE.Type] then return end
	if lply:Team() == TEAM_SPECTATOR then return end
	if StartTime + 12 < CurTime() then return end
	
	fade = Lerp(FrameTime()*1, fade, math.Clamp(StartTime + 5 - CurTime(),-2,2))

	local typeNameFunc = MODE.TypeNames[MODE.Type]
	local typeName = typeNameFunc and typeNameFunc() or L("unknown")
	draw.SimpleText(L("homicide") .. " | " .. typeName, "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.1, Color(0,162,255, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local roleData = (lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor) or (lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner) or MODE.TypeObjectives[MODE.Type].innocent
	local Rolename = type(roleData.name) == "function" and roleData.name() or roleData.name
	local ColorRole = roleData.color1
	ColorRole.a = 255 * fade

	local color_role_innocent = MODE.TypeObjectives[MODE.Type].innocent.color1
	color_role_innocent.a = 255 * fade

	local color_white_faded = Color(255, 255, 255, 255 * fade)
	color_white_faded.a = 255 * fade

	draw.SimpleText(L("you_are", Rolename), "ZB_HomicideMediumLarge", sw * 0.5, sh * 0.5, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local cur_y = sh * 0.5

	if(lply.SubRole and lply.SubRole != "")then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText("" .. ((MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Name or lply.SubRole) or lply.SubRole), "ZB_HomicideMediumLarge", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		draw.SimpleText(L("assistant"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if(lply.isTraitor)then
		cur_y = cur_y + ScreenScale(20)

		if(lply.MainTraitor)then
			MODE.TraitorsLocal = MODE.TraitorsLocal or {}

			if(#MODE.TraitorsLocal > 1)then
				draw.SimpleText(L("traitors_list"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				for _, traitor_info in ipairs(MODE.TraitorsLocal) do
					local traitor_color = Color(traitor_info[1].r, traitor_info[1].g, traitor_info[1].b, 255 * fade)
					cur_y = cur_y + ScreenScale(15)

					draw.SimpleText(traitor_info[2], "ZB_HomicideMedium", sw * 0.5, cur_y, traitor_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
		else
			draw.SimpleText(L("traitor_secret_words"), "ZB_HomicideMedium", sw * 0.5, cur_y, ColorRole, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWord .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			cur_y = cur_y + ScreenScale(15)

			draw.SimpleText("\"" .. MODE.TraitorWordSecond .. "\"", "ZB_HomicideMedium", sw * 0.5, cur_y, color_white_faded, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if(lply.Profession and lply.Profession != "")then
		cur_y = cur_y + ScreenScale(20)

		local profName = (MODE.Professions[lply.Profession] and MODE.Professions[lply.Profession].Name or lply.Profession) or lply.Profession
		draw.SimpleText(L("occupation", profName), "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	
	if(handicap[lply:GetLocalVar("karma_sickness", 0)])then
		cur_y = cur_y + ScreenScale(20)

		local handicapText = type(handicap[lply:GetLocalVar("karma_sickness", 0)]) == "function" and handicap[lply:GetLocalVar("karma_sickness", 0)]() or handicap[lply:GetLocalVar("karma_sickness", 0)]
		draw.SimpleText(handicapText, "ZB_HomicideMedium", sw * 0.5, cur_y, color_role_innocent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local objData = (lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor) or (lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner) or MODE.TypeObjectives[MODE.Type].innocent
	local Objective = type(objData.objective) == "function" and objData.objective() or objData.objective

	if(lply.SubRole and lply.SubRole != "")then
		if(MODE.SubRoles[lply.SubRole] and MODE.SubRoles[lply.SubRole].Objective)then
			Objective = MODE.SubRoles[lply.SubRole].Objective
		end
	end

	if(!lply.MainTraitor and lply.isTraitor)then
		Objective = L("assistant_traitor_obj")
	end

	if(!MODE.RoleEndedChosingState)then
		Objective = L("round_starting")
	end

	local ColorObj = (lply.isTraitor and MODE.TypeObjectives[MODE.Type].traitor.color2) or (lply.isGunner and MODE.TypeObjectives[MODE.Type].gunner.color2) or MODE.TypeObjectives[MODE.Type].innocent.color2 or Color(255,255,255)
	ColorObj.a = 255 * fade
	draw.SimpleText(Objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.9, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText(L("somewhere_pluvtown"), "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local CreateEndMenu

net.Receive("hmcd_roundend", function()
	local traitors, gunners = {}, {}

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local traitor = net.ReadEntity()
		traitors[key] = traitor
		traitor.isTraitor = true
	end

	for key = 1, net.ReadUInt(MODE.TraitorExpectedAmtBits) do
		local gunner = net.ReadEntity()
		gunners[key] = gunner
		gunner.isGunner = true
	end

	timer.Simple(2.5, function()
		lply.isPolice = false
		lply.isTraitor = false
		lply.isGunner = false
		lply.MainTraitor = false
		lply.SubRole = nil
		lply.Profession = nil
	end)

	traitor = traitors[1] or Entity(0)

	CreateEndMenu(traitor)
end)

net.Receive("hmcd_announce_traitor_lose", function()
	local traitor = net.ReadEntity()
	local traitor_alive = net.ReadBool()

	if(IsValid(traitor))then
		local playerColor = traitor:GetPlayerColor():ToColor()
		local playerNick = traitor:GetPlayerName() .. ", " .. traitor:Nick()
		
		if traitor_alive then
			chat.AddText(color_white, L("traitor_lose_arrested", playerNick))
		else
			chat.AddText(color_white, L("traitor_lose_killed", playerNick))
		end
	end
end)

local colGray = Color(85,85,85)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
	hmcdEndMenu:Remove()
	hmcdEndMenu = nil
end

CreateEndMenu = function(traitor)
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

	surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")

	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
		surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize(L("close"))
		surface.SetTextPos( lenghtX - lenghtX/1.1, 4)
		surface.DrawText(L("close"))
	end

	hmcdEndMenu.PaintOver = function(self,w,h)
		if not IsValid(traitor) then return end

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lenghtX, lenghtY = surface.GetTextSize((traitor:GetPlayerName() or "He quited...") .. L("was_traitor"))
		surface.SetTextPos(w / 2 - lenghtX/2,20)
		surface.DrawText( (traitor:GetPlayerName() or "He quited...") .. L("was_traitor"))
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)

	for i,ply in ipairs(player.GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
			if not IsValid(ply) then return end
			local col1 = (ply.isTraitor and colRed) or (ply:Alive() and colBlue) or colGray
			local col2 = IsValid(ply) and ply.isTraitor and (ply:Alive() and colRedUp or colSpect1) or ((ply:Alive() and ((not ply.organism) or (not ply.organism.otrub))) and colBlueUp) or colSpect1
			local name = (ply:Nick() or "He quited...")
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

			local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lenghtX, lenghtY = surface.GetTextSize( name )

			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lenghtY/2 + 1)
			surface.DrawText( name )

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lenghtY/2)
			surface.DrawText( name )

			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			
			local statusText = ply:GetPlayerName() or "He quited..."
			if not ply:Alive() then
				statusText = statusText .. L("died")
			elseif ply.organism and ply.organism.otrub then
				statusText = statusText .. L("incapacitated")
			end
			
			local lenghtX, lenghtY = surface.GetTextSize( statusText )
			surface.SetTextPos(15,h/2 - lenghtY/2)
			surface.DrawText(statusText)

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lenghtX, lenghtY = surface.GetTextSize( ply:Frags() or "" )
			surface.SetTextPos(w - lenghtX -15,h/2 - lenghtY/2)
			surface.DrawText(ply:Frags() or "")
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
end

--\\
net.Receive("HMCD(StartPlayersRoleSelection)", function()
	local role = net.ReadString()

	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end

	if(MODE.RoleChooseRoundTypes[MODE.Type])then
		VGUI_HMCD_RolePanelList = vgui.Create("HMCD_RolePanelList")
		VGUI_HMCD_RolePanelList.RolesIDsList = MODE.RoleChooseRoundTypes[MODE.Type][role]
		VGUI_HMCD_RolePanelList:SetSize(screen_scale_2(1000), screen_scale_2(600))
		VGUI_HMCD_RolePanelList:Center()
		VGUI_HMCD_RolePanelList:InvalidateParent(false)
		VGUI_HMCD_RolePanelList:Construct()
		VGUI_HMCD_RolePanelList:MakePopup()
	end
end)

net.Receive("HMCD(EndPlayersRoleSelection)", function()
	if(IsValid(VGUI_HMCD_RolePanelList))then
		VGUI_HMCD_RolePanelList:Remove()
	end
end)

net.Receive("HMCD(SetSubRole)", function(len, ply)
	lply.SubRole = net.ReadString()
end)
--//