-- SERVER-SIDE GUILT SYSTEM
-- Localization
local LANG = {}

LANG["en"] = {
    ["karma_kick"] = "Your karma is %d",
    ["karma_ban"] = "Player %s has been banned for %d minutes for having too low karma.",
    ["rdm_ban"] = "Player %s has been banned for 30 minutes for RDMing in a team based gamemode.",
    ["kicked_banned"] = "Kicked and banned.",

    ["epileptic_seizure"] = "You are experiencing an epileptic seizure.",

    ["karma_is"] = "Your current karma is %s",

    ["harm_done"] = "This harm done is: %.3f",
    ["overall_amt"] = "Overall amt done is: %.3f",
    ["overall_harm"] = "Overall harm done is: %.3f",
    ["guilt_done"] = "Guilt done is: %.3f",
}

LANG["ru"] = {
    ["karma_kick"] = "Ваша карма: %d",
    ["karma_ban"] = "Игрок %s был забанен на %d минут за слишком низкую карму.",
    ["rdm_ban"] = "Игрок %s был забанен на 30 минут за RDM в командном режиме.",
    ["kicked_banned"] = "Кикнут и забанен.",
    
    ["epileptic_seizure"] = "У тебя эпилептический припадок.",
    
    ["karma_is"] = "Ваша текущая карма: %s",

    ["harm_done"] = "Нанесённый урон: %.3f",
    ["overall_amt"] = "Общее количество: %.3f",
    ["overall_harm"] = "Общий урон: %.3f",
    ["guilt_done"] = "Вина: %.3f",
}

local function L(ply, key, ...)
    local lang = "en"
    
    if IsValid(ply) and ply:IsPlayer() then
        lang = ply:GetInfo("gmod_language") or "en"
    end
    
    if lang ~= "en" and lang ~= "ru" then lang = "en" end
    
    local text = LANG[lang][key] or LANG["en"][key] or key
    
    if ... then
        return string.format(text, ...)
    end
    
    return text
end

-- СДЕЛАЙТЕ СИНХРУ С СКУЭЛЬ УЖЕ // ЛАДНО Я САМ СДЕЛАЮ
zb = zb or {}

zb.GuiltTable = zb.GuiltTable or {}
zb.HarmDone = zb.HarmDone or {}
zb.HarmDoneKarma = zb.HarmDoneKarma or {}
zb.GuiltSQL = zb.GuiltSQL or {}
zb.GuiltSQL.PlayerInstances = zb.GuiltSQL.PlayerInstances or {}

local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer",0,FCVAR_SERVER_CAN_EXECUTE,"enable developer mode (enables damage traces)",0,1)


hook.Add("DatabaseConnected", "GuiltCreateData", function()
	local query

	query = mysql:Create("zb_guilt")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:Create("value", "FLOAT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    zb.GuiltSQL.Active = true
end)

hook.Add( "PlayerInitialSpawn","ZB_GuiltSQL", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    --if not zb.GuiltSQL.Active then
    --    zb.GuiltSQL.PlayerInstances[steamID64] = {}
    --    return
    --end 

	local query = mysql:Select("zb_guilt")
		query:Select("value")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].value) then
				local updateQuery = mysql:Update("zb_guilt")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

				zb.GuiltSQL.PlayerInstances[steamID64] = {}

                zb.GuiltSQL.PlayerInstances[steamID64].value = tonumber(result[1].value)

                ply.Karma = ply:guilt_GetValue()
                ply:SetNetVar("Karma",ply.Karma)

                if zb.GuiltSQL.PlayerInstances[steamID64].value < 0 then
                    ply:Ban(5,false)
                    ply:guilt_SetValue( zb.GuiltSQL.PlayerInstances[steamID64].value + 10 )
                    ply:Kick(L(ply, "karma_kick", math.Round( zb.GuiltSQL.PlayerInstances[steamID64].value, 0 )))
                end
			else
				local insertQuery = mysql:Insert("zb_guilt")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("value", 100)
				insertQuery:Execute()

				zb.GuiltSQL.PlayerInstances[steamID64] = {}

				zb.GuiltSQL.PlayerInstances[steamID64].value = 100

                ply.Karma = ply:guilt_GetValue()
                ply:SetNetVar("Karma",ply.Karma)
			end
		end)
	query:Execute()

end)

local plyMeta = FindMetaTable("Player")

function plyMeta:guilt_GetValue()

    return zb.GuiltSQL.PlayerInstances[self:SteamID64()] and zb.GuiltSQL.PlayerInstances[self:SteamID64()].value or 100

end

function plyMeta:guilt_SetValue( zb_guilt )

    local steamID64 = self:SteamID64()
	
	zb.GuiltSQL.PlayerInstances[self:SteamID64()] = zb.GuiltSQL.PlayerInstances[self:SteamID64()] or {}
	zb.GuiltSQL.PlayerInstances[self:SteamID64()].value = zb.GuiltSQL.PlayerInstances[self:SteamID64()].value or 100
	
    zb.GuiltSQL.PlayerInstances[self:SteamID64()].value = zb_guilt

	local updateQuery = mysql:Update("zb_guilt")
		updateQuery:Update("value", zb_guilt)
		updateQuery:Where("steamid", steamID64)
	updateQuery:Execute()
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8 
end

hook.Add("HomigradDamage", "GuiltReg", function(ply, dmgInfo, hitgroup, ent, harm)
    local Attacker, Victim = dmgInfo:GetAttacker(), ply
    
    if not IsValid(Attacker) or not Attacker:IsPlayer() then return end
    if not IsValid(Victim) or not (Victim:IsPlayer() or Victim.organism.fakePlayer) then return end

    local maxharm = zb.MaximumHarm
    zb.HarmDone[Victim] = zb.HarmDone[Victim] or {}
    zb.HarmDoneKarma[Victim] = zb.HarmDoneKarma[Victim] or {}
    zb.HarmDoneKarma[Victim][Attacker] = zb.HarmDoneKarma[Victim][Attacker] or 0
    
    local oldharmdone = zb.HarmDone[Victim][Attacker] or 0
    zb.HarmDone[Victim][Attacker] = math.Clamp((zb.HarmDone[Victim][Attacker] or 0) + harm, 0, maxharm)

    local newharm = math.min(harm + oldharmdone, maxharm)
    local harm = newharm - oldharmdone
    local amt = harm / maxharm
    
    if amt > 0.2 or newharm / maxharm > 0.8 then
        --print("Player "..Attacker:Name().." harmed player "..(Victim:IsPlayer() and Victim:Name() or (tostring(Victim))).." with "..harm.." points.")
        --print("They contributed a total of "..math.Round(newharm / maxharm * 100, 0).."% of "..(Victim:IsPlayer() and Victim:Name() or (tostring(Victim))).."'s death")
    end

    if hg_developer:GetBool() then
        Attacker:ChatPrint(L(Attacker, "harm_done", harm))
        Attacker:ChatPrint(L(Attacker, "overall_amt", amt))
        Attacker:ChatPrint(L(Attacker, "overall_harm", newharm))
        Attacker:ChatPrint(L(Attacker, "guilt_done", amt * 60))
        Attacker:ChatPrint(" ")
    end

    hook.Run("HarmDone", Attacker, Victim, amt)

    Victim = hg.GetCurrentCharacter(Victim) or Victim
    Victim = hg.RagdollOwner(Victim) or Victim

    local rnd, cround = CurrentRound()

    if rnd.GuiltDisabled or GetConVar("zb_dev"):GetBool() then return end
    
    zb.GuiltTable[Attacker] = zb.GuiltTable[Attacker] or {}
    zb.GuiltTable[Victim] = zb.GuiltTable[Victim] or {}
    
    if Attacker == Victim then return end
    
    if Victim.isTraitor and !Attacker.isTraitor and rnd.name == "hmcd" and !zb.IsForce(Attacker) then return end
    if Attacker.isTraitor and !Victim.isTraitor and rnd.name == "hmcd" then return end
    if rnd.name != "hmcd" and (Attacker.Team and Victim.Team and Attacker:Team() ~= Victim:Team()) then return end
    if zb.ROUND_STATE != 1 and (rnd.name != "cstrike" or !zb.RoundsLeft) then return end
    if Victim.Guilt and Victim.Guilt > 1 then return end

    local victimWep = Victim:IsPlayer() and IsValid(Victim:GetActiveWeapon()) and Victim:GetActiveWeapon()
    
    amt = amt * 1
        * (Victim:IsPlayer() and math.Clamp(((Victim.Karma or 100) / 100), 1, 1.2) or 1)
        * (Victim:IsPlayer() and ((IsLookingAt(Victim, Attacker:EyePos()) and (victimWep and (ishgweapon(victimWep) or ((victimWep:GetClass() == "weapon_hands_sh" and victimWep:GetFists() or victimWep.ismelee2) and Victim:EyePos():Distance(Attacker:EyePos()) <= 90)))) and 0.5 or 1) or 1)

    local add = amt * maxharm

    add = add * (Victim:IsPlayer() and Attacker:PlayerClassEvent("Guilt", Victim) or 1)
    add = add * 1.2 * 1.5

    local mul, shouldBanGuilt
    
    if rnd.GuiltCheck then
        mul, shouldBanGuilt = rnd.GuiltCheck(Attacker, Victim, add, harm, amt)

        add = add * (mul or 1)
    end
 
    local guiltadd = amt * 60
    Attacker.Guilt = (Attacker.Guilt or 0) + guiltadd
    Attacker.Karma = math.Clamp((Attacker.Karma or 100) - add * math.max(((1 - (zb.GuiltTable[Victim][Attacker] or 0)) / 1),0), -50, zb.MaxKarma)
    Attacker.LastAttacked = CurTime()

    zb.HarmDoneKarma[Victim][Attacker] = zb.HarmDoneKarma[Victim][Attacker] + add

    if shouldBanGuilt and Attacker.Guilt >= 100 then
        Attacker:Ban(30,false)
        Attacker:Kick(L(Attacker, "kicked_banned"))
        PrintMessage(HUD_PRINTTALK, L(nil, "rdm_ban", Attacker:Name()))
    end

    Attacker:SetNetVar("Karma", Attacker.Karma)
    
    zb.GuiltTable[Attacker][Victim] = math.Clamp((zb.GuiltTable[Attacker][Victim] or 0) + guiltadd, 0, 200)

    if Attacker.Karma <= 0 then
        local time = math.Round(60 - Attacker.Karma * 4, 0)
        Attacker.Karma = 0
        Attacker:Ban(time, false)
        Attacker:Kick(L(Attacker, "kicked_banned"))
        PrintMessage(HUD_PRINTTALK, L(nil, "karma_ban", Attacker:Name(), time))
    end
end)

function zb.IsForce(Attacker)
    return Attacker.PlayerClassName == "police" and Attacker.PlayerClassName == "nationalguard" and Attacker.PlayerClassName == "swat"
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8 
end

function zb.ForcesAttackedInnocent(self, Victim)
    local victimWep = Victim:IsPlayer() and IsValid(Victim:GetActiveWeapon()) and Victim:GetActiveWeapon()

    return 3 * (Victim.LastAttacked and ((Victim.LastAttacked + 10) > CurTime()) and 0.33 or 1) * (Victim:IsPlayer() and ((IsLookingAt(Victim, self:EyePos()) and (victimWep and (ishgweapon(victimWep) or ((victimWep:GetClass() == "weapon_hands_sh" and victimWep:GetFists() or victimWep.ismelee2) and Victim:EyePos():Distance(self:EyePos()) <= 72)))) and 0 or 1) or 1)
end

hook.Add("PlayerDisconnected","GuiltSaveOnDisconect",function(ply)
    ply:guilt_SetValue( ply.Karma or 100 )
end)

hook.Add("PlayerInitialSpawn","GuiltGiveOnConnect",function(ply)
    
end)

hook.Add("Player Spawn","SlowlyRestoreKarma",function(ply)
    if OverrideSpawn then return end

    ply.lastwarning = nil
    //ply.firstwarning = nil
    ply.Karma = ply.Karma or 100
    ply:SetNetVar("Karma",ply.Karma)
    //ply:guilt_SetValue( ply.Karma or 100 )
    
    ply.Guilt = 0
end)

hook.Add("Player Think", "karmagain", function(ply)
    if (ply.KarmaGainThink or 0) > CurTime() then return end
    ply.KarmaGainThink = CurTime() + 120

    ply.Karma = math.Clamp(ply.Karma + (ply.Karma > 100 and 0.5 or (ply.KarmaGain or 1)), 0, zb.MaxKarma)// * (1 + ply:HasPurchase("zpremium")), 0, zb.MaxKarma)
    
    ply:SetNetVar("Karma", ply.Karma)
    //ply:guilt_SetValue( ply.Karma or 100 )
end)

hook.Add("Org Clear","removekarmashaking",function(org)
    org.start_shaking = nil
end)

hook.Add("Should Fake Up", "karma", function(ply)
    if ply.organism and ply.organism.start_shaking then return false end
end)

hook.Add("Org Think", "Its_Karma_Bro",function(owner, org, timeValue)
    if not owner or not owner:IsPlayer() or org.otrub or not org.isPly then return end
    if not owner:IsPlayer() or not owner:Alive() then return end
    
    local ply = owner
    
    if (ply.Karma or 100) < 50 then
        if ((math.random(math.Clamp((ply.Karma or 100),20,zb.MaxKarma) * 300) == 1 or org.start_shaking)) then
            hg.StunPlayer(ply)
            local time = 15
            ply:Notify(L(ply, "epileptic_seizure"), 16, "seizure", 0.5)
            org.start_shaking = org.start_shaking or (CurTime() + time)
            local ent = hg.GetCurrentCharacter(owner)
            local mul = ((org.start_shaking) - CurTime()) / time
            
            if mul > 0 then
                ent:GetPhysicsObjectNum(math.random(ent:GetPhysicsObjectCount()) - 1):ApplyForceCenter(VectorRand(-750 * mul,750 * mul))
            else
                org.start_shaking = nil
            end
        else
            org.start_shaking = nil
        end
	end

    if (ply.Karma or 100) < 35 then
        if math.random(2000) == 1 then
            hg.organism.Vomit(owner)
        end
    end
end)

hook.Add("ZB_EndRound","savevalues",function()
    for i,ply in ipairs(player.GetAll()) do
        ply:guilt_SetValue( ply.Karma or 100 )
    end
end)

hook.Add("ZB_StartRound","NO_HARM",function()
    for i,ply in ipairs(player.GetAll()) do
        if (ply.Guilt or 0) < 1 then
            ply.KarmaGain = math.Clamp((ply.KarmaGain or 1) + 0.25, 1, 2)
        else
            ply.KarmaGain = 1
        end

        //ply:guilt_SetValue( ply.Karma or 100 )
    end
    
    zb.HarmDone = {}
    zb.HarmDoneKarma = {}
end)

util.AddNetworkString("get_karma")
net.Receive("get_karma",function(len, ply)
    if not ply:IsAdmin() then return end

    local tbl = {}

    for i,pl in ipairs(player.GetAll()) do
        tbl[pl:UserID()] = pl.Karma
    end

    net.Start("get_karma")
    net.WriteTable(tbl)
    net.Send(ply)
end)

concommand.Add("hg_setkarma",function(ply,cmd,args)
    if not ply:IsAdmin() then return end
    
    local lenargs = #args
    local newply = player.GetListByName(lenargs > 1 and args[1] or ply:Name())[1]

    newply.Karma = tonumber(lenargs > 1 and args[2] or args[1])
    newply:SetNetVar("Karma",ply.Karma)
    //newply:guilt_SetValue( ply.Karma or 100 )
end)

util.AddNetworkString("open_guilt_menu")
util.AddNetworkString("forgive_player")

net.Receive("open_guilt_menu",function(len, ply)
    if ply:Alive() then return end
    local tbl = zb.HarmDoneKarma[ply] or {}
    net.Start("open_guilt_menu")
    net.WriteTable(tbl)
    net.Send(ply)
    //current round guilt
end)

net.Receive("forgive_player", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not zb.HarmDoneKarma[ply] then return end
    local harm = zb.HarmDoneKarma[ply][ent]
    if not harm then return end

    ent.Karma = math.Clamp(ent.Karma + harm, 0, zb.MaxKarma)
    ent:SetNetVar("Karma",ent.Karma)
    //ent:guilt_SetValue((ent.Karma or 100))

    zb.HarmDone[ply][ent] = 0
    zb.HarmDoneKarma[ply][ent] = 0
    net.Start("open_guilt_menu")
    net.WriteTable(zb.HarmDoneKarma[ply])
    net.Send(ply)
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
    if ply.Karma then
        ply:ChatPrint(L(ply, "karma_is", tostring(math.Round(ply.Karma))))
    end
end)