-- "addons\\homigrad\\lua\\homigrad\\sh_phrases.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

-- Локализация
local lang = {
	["en"] = {
		["say_something"] = "Say something"
	},
	["ru"] = {
		["say_something"] = "Сказать что-то"
	}
}

local function GetText(key)
	local playerLang = "en"
	
	if CLIENT then
		playerLang = GetConVar("gmod_language"):GetString()
		if playerLang ~= "en" and playerLang ~= "ru" then
			playerLang = "en"
		end
	end
	
	return lang[playerLang] and lang[playerLang][key] or lang["en"][key]
end

local phrases = {
	[1] = {
		{"vo/npc/male01/question", ".wav", 3, 31},
		{"vo/npc/male01/answer", ".wav", 1, 40},
		{"vo/npc/male01/sorry", ".wav", 1, 3},
		{"vo/npc/male01/squad_affirm", ".wav", 1, 9},
		{"vo/npc/male01/startle", ".wav", 1, 2},
		{"vo/npc/male01/vanswer", ".wav", 1, 14},
		{"vo/npc/male01/wetrustedyou", ".wav", 1, 2},
		{"vo/npc/male01/whoops", ".wav", 1, 1},
		{"vo/npc/male01/yeah", ".wav", 2, 2},
		{"vo/npc/male01/gordead_ans", ".wav", 1, 20},
		{"vo/npc/male01/heretohelp", ".wav", 1, 2},
		//{"vo/npc/male01/holddownspot", ".wav", 1, 2},
		{"vo/npc/male01/imstickinghere01", ".wav", 1, 1},
		{"vo/npc/male01/imstickinghere01", ".wav", 1, 1},
	},
	[2] = {
		{"vo/npc/female01/question", ".wav", 3, 30},
		{"vo/npc/female01/answer", ".wav", 1, 40},
		{"vo/npc/female01/sorry", ".wav", 1, 3},
		{"vo/npc/female01/squad_affirm", ".wav", 1, 9},
		{"vo/npc/female01/startle", ".wav", 1, 2},
		{"vo/npc/female01/vanswer", ".wav", 1, 14},
		{"vo/npc/female01/wetrustedyou", ".wav", 1, 2},
		{"vo/npc/female01/whoops", ".wav", 1, 1},
		{"vo/npc/female01/yeah", ".wav", 2, 2},
		{"vo/npc/female01/gordead_ans", ".wav", 1, 20},
		{"vo/npc/female01/heretohelp", ".wav", 1, 2},
		//{"vo/npc/female01/holddownspot", ".wav", 1, 2}
	}
}

local painPhrases = {
	[1] = {
		{"vo/npc/male01/moan", ".wav", 1, 5},
	},
	[2] = {
		{"vo/npc/female01/moan", ".wav", 1, 5},
	}
}

local cmb_phrases = {
	"npc/combine_soldier/vo/reportingclear.wav",
	"npc/combine_soldier/vo/ripcordripcord.wav",
	"npc/combine_soldier/vo/reportallpositionsclear.wav",
	"npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
	"npc/combine_soldier/vo/overwatchrequestreserveactivation.wav",
	"npc/combine_soldier/vo/overwatchconfirmhvtcontained.wav",
	"npc/combine_soldier/vo/onedown.wav",
	"npc/combine_soldier/vo/heavyresistance.wav",
	"npc/combine_soldier/vo/containmentproceeding.wav",
	"npc/combine_soldier/vo/contactconfirmprosecuting.wav",
	"npc/combine_soldier/vo/movein.wav",
	"npc/combine_soldier/vo/overwatchteamisdown.wav",
	"npc/combine_soldier/vo/prosecuting.wav",
	"npc/combine_soldier/vo/stayalertreportsightlines.wav",
	"npc/combine_soldier/vo/teamdeployedandscanning.wav",
	"npc/combine_soldier/vo/copythat.wav",
	"npc/combine_soldier/vo/engagedincleanup.wav",
	"npc/combine_soldier/vo/executingfullresponse.wav",
	"npc/combine_soldier/vo/goactiveintercept.wav",
	"npc/combine_soldier/vo/necroticsinbound.wav",
	"npc/combine_soldier/vo/standingby].wav",
	"npc/combine_soldier/vo/stayalert.wav",
	"npc/combine_soldier/vo/targetmyradial.wav",
	"npc/combine_soldier/vo/weareinaninfestationzone.wav",
	"npc/combine_soldier/vo/wehavenontaggedviromes.wav"
}

local slugy_phrases = {
	"zcity/voice/slugcat_1/waw_1.mp3",
	"zcity/voice/slugcat_1/waw_2.mp3",
	"zcity/voice/slugcat_1/waw_3.mp3",
	"zcity/voice/slugcat_1/waw_4.mp3"
}

local uwuspeak_phrases = {
	"zbattle/furry/cat_mrrp1.ogg",
	"zbattle/furry/cat_mrrp1.ogg",
	"zbattle/furry/cat_purr1.ogg",
	"zbattle/furry/cat_purr2.ogg",
	"zbattle/furry/mewo.ogg",
	"zbattle/furry/mrrp.ogg",
	"zbattle/furry/prbt.ogg",
	"zbattle/furry/beep1.wav",
	"zbattle/furry/beep2.wav",
}

local fur_pain = {
	"zbattle/furry/exp5.wav",
	"zbattle/furry/exp6.wav",
	"zbattle/furry/exp7.wav",
	"zbattle/furry/exp8.wav",
	"zbattle/furry/exp9.wav",
	"zbattle/furry/exp10.wav",
	"zbattle/furry/exp11.wav",
	"zbattle/furry/exp12.wav",
	"zbattle/furry/exp13.wav",
	"zbattle/furry/exp14.wav",
	"zbattle/furry/exp15.wav",
	"zbattle/furry/exp16.wav",
	"zbattle/furry/exp17.wav",
	"zbattle/furry/death1.wav",
	"zbattle/furry/death3.wav",
	"zbattle/furry/death4.wav",
	"zbattle/furry/death5.wav",
}

local mtcop_phrases = {}
local files,_ = file.Find("sound/npc/metropolice/vo/*.wav","GAME")
for k,v in ipairs(files) do
	mtcop_phrases[k] = "npc/metropolice/vo/" .. v
end

if CLIENT then
	local function randomPhrase()
		RunConsoleCommand("hg_phrase")
	end

	concommand.Add("hg_phrase", function(ply, cmd, args)
		local gender = ThatPlyIsFemale(ply) and 2 or 1
		local i = (#args > 0 and math.Clamp(tonumber(args[1]),1,#phrases[gender])) or math.random(#phrases[gender])
		if (#args < 2 and not #args == 0) then return end
 		local num = (#args > 1 and math.Clamp(tonumber(args[2]),phrases[gender][tonumber(i)][3],phrases[gender][tonumber(i)][4])) or math.random(phrases[gender][tonumber(i)][3], phrases[gender][tonumber(i)][4])
		net.Start("hg_phrase")
		net.WriteInt(i, 8)
		net.WriteInt(num, 8)
		net.SendToServer()
	end)

	hook.Add("radialOptions", "4", function()
		local organism = LocalPlayer().organism or {}

		if LocalPlayer():Alive() and not organism.otrub then
			hg.radialOptions[#hg.radialOptions + 1] = {randomPhrase, (LocalPlayer().PlayerClassName == "Slugcat" and "Wáaaaǎa\nWāaaàaâ") or (LocalPlayer().PlayerClassName == "Gordon" and "...") or GetText("say_something")}
		end
	end)
else
	hook.Add("PlayerSpawn","GiveRandomPitch",function(ply)
		if OverrideSpawn then return end
		
		ply.VoicePitch = math.random(95,105)
	end)

	util.AddNetworkString("hg_phrase")
	net.Receive("hg_phrase", function(len, ply)
		if (ply.phrCld or 0) > CurTime() then return end
		if ply.PlayerClassName == "Gordon" then return end
		if not IsValid(ply) or not ply:Alive() or ply:WaterLevel() >= 3 then return end
		if ply.organism.otrub then return end
		if ply.organism.o2[1] < 15 then return end
		if ply.organism.holdingbreath then return end
		local gender = ThatPlyIsFemale(ply) and 2 or 1
		local i = net.ReadInt(8)
		local num = net.ReadInt(8)
		if ply.organism.brain > 0.1 then
			i = 5
			num = math.random(1,2)
		end

		local phrases2 = phrases

		local inpain = ply.organism.pain > 30
		if inpain then
			phrases2 = painPhrases
		end
		
		local phr = phrases2[math.Round(math.Clamp(gender, 1, 2))]
		phr = phr[math.Round(math.Clamp(i, 1, #phr))]
		
		if not phr then return end

		local random = math.Round(math.Clamp(num, phr[3], phr[4]))

		if inpain then
			random = math.random(phr[3], phr[4])
		end

		local huy = random < 10 and "0" or ""
		local phrase = phr[1] .. huy .. random .. phr[2]
		local ent = hg.GetCurrentCharacter(ply)
		local muffed = ply.armors["face"] == "mask2"
		local pitch = nil

		if ply.PlayerClassName == "Combine" then
			phrase = table.Random( cmb_phrases )
		end

		if ply.PlayerClassName == "Metrocop" then
			phrase = table.Random( mtcop_phrases )
		end

		if ply:GetModel() == "models/distac/player/ghostface.mdl" then
			pitch = true
		end

		local wawer = string.match( ply:GetModel(), "scug" )
		if wawer then
			phrase = table.Random( slugy_phrases )
		end

		if ply.PlayerClassName == "furry" then
			if inpain then
				phrase = table.Random(fur_pain)
			else
				phrase = table.Random(uwuspeak_phrases)
			end
		end
		
		if ply.PlayerClassName == "bloodz" or ply.PlayerClassName == "groove" then
			phrase = table.Random(hg.ghetto_phrases)
			local rf = RecipientFilter()
			rf:AddPAS(ply:GetPos())
			ply.sndplay = CreateSound(ply, phrase, rf)
			ply.sndplay:SetSoundLevel(muffed and 65 or 75)
			ply.sndplay:SetDSP(muffed and 16 or 0)
			ply.sndplay:Play()
			ply.sndplay:ChangeVolume(0.01)
			timer.Simple(0.2, function()
				ply.sndplay:ChangeVolume(1)
			end)
			timer.Simple(hg.precachedsounds[phrase] - 0.5, function()
				ply.sndplay:ChangeVolume(0)
			end)
			ply.phrCld = CurTime() + (hg.precachedsounds[phrase] or 0)
			ply.lastPhr = phrase
			return
		end
				
		if wawer then
			ent:EmitSound(phrase, wawer and 65 or muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, muffed and 14 or 0)
			ent:EmitSound(phrase, wawer and 65 or muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, muffed and 14 or 0)
		else
			ent:EmitSound(phrase, muffed and 65 or 75,ply.VoicePitch or 100,1,CHAN_AUTO,0, pitch and 56 or muffed and 14 or 0)
		end

		if string.match( phrase, ".ogg" ) then // ogg doesn't return the right soundduration
			ply.phrCld = CurTime() + 2
		else
			ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
		end
		ply.lastPhr = phrase
	end)

	hook.Add("PlayerDeath", "StopPhrOnDeath",function(ply)
		local ent = hg.GetCurrentCharacter(ply)
		ent:StopSound(ply.lastPhr or "")
		ply.phrCld = 0
	end)

	hook.Add("HG_OnOtrub", "StopPhrOnOtrub", function( ply )
		local ent = hg.GetCurrentCharacter(ply)
		ent:StopSound(ply.lastPhr or "")
		ply.phrCld = 0
	end)
end

--[[
	ply:Notify("HEV suit has detected a critically low pulse. Epinephrine injected. Auto-pulse enabled. Plasma injected.",60,"pulse_hev",0.5,function(ply)
        net.Start("HEV_DAMAGE")
            net.WriteString("hl1/fvox/automedic_on.wav")
        net.Send(ply)
    end)
	--hook_Run("PreHomigradDamage", org.fakePlayer and ent or ply, dmgInfo,
]]

if SERVER then

	local femaleCount = 10
	local maleCount = 14

	local burn_phrases = {
		"AAAAAAAAAAH AAAAAAAAAAAAAAAAAAAAAH AHHHHH",
		"AAAAAAHHHH",
		"FUCK AAAAAAAAAAAAAAAAAAAAAHHHHHHH FUCK FUCK",
		"FUCK AAAAAAAAGHHHH AAAAAAAAAAAAAAAAAAAH",
		"AAAAAAAAAAAAAAAAH AAAAAAAAAAH",
	}

	hook.Add("PreHomigradDamage","BurnScream", function( ent, dmgInfo )
		local ply = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent

		if dmgInfo:IsDamageType(DMG_BURN) and IsValid(ply) and ply:IsPlayer() and ply.organism and not ply.organism.otrub and ply:Alive() then
			local phrase = "zcitysnd/"..(ThatPlyIsFemale(ply) and "fe" or "").."male/burn/death_burn"..math.random(1,ThatPlyIsFemale(ply) and femaleCount or maleCount)..".mp3"
			ply:Notify(table.Random(hg.sharp_pain),SoundDuration(phrase),"ply_burn",0.5,function(ply)
				if hg.GetCurrentCharacter(ply):IsOnFire() then
					hg.GetCurrentCharacter(ply):EmitSound(phrase)
					ply.phrCld = CurTime() + (SoundDuration(phrase) or 0)
					ply.lastPhr = phrase
				end
			end, Color(204,48,0))
		end
	end)

	hook.Add("Org Think", "ItHurtsfrfr",function(owner, org, timeValue)
		if owner.PlayerClassName != "furry" then return end

		if (owner.lastPainSoundCD or 0) < CurTime() and !org.otrub and org.pain >= 30 and math.random(1, 50) == 1 then
			local phrase = table.Random(fur_pain)

			local muffed = owner.armors["face"] == "mask2"

			owner:EmitSound(phrase, muffed and 65 or 75,owner.VoicePitch or 100,1,CHAN_AUTO,0, pitch and 56 or muffed and 16 or 0)

			owner.lastPainSoundCD = CurTime() + math.Rand(10, 25)
			owner.lastPhr = phrase
		end
	end)

	-- Stop it in water

	hook.Add("OnEntityWaterLevelChanged","StopPhraseInWater",function(ent,old,new)
		if ent:IsPlayer() or ent:IsRagdoll() then
			local ply = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
			local entReal = hg.GetCurrentCharacter(ply)
			if ent == entReal and new == 3 then
				ply.phrCld = 0
				ent:StopSound(ply.lastPhr or "")
			end
		end
	end)
end