hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}


function hg.achievements.Init()
    if not file.Exists("zcity", "DATA") then 
        file.CreateDir("zcity")
    end
end

hg.achievements.Init()


function hg.achievements.LoadAchievements()
    local ach = file.Read("zcity/achievements.json", "DATA")
    if ach then
        hg.achievements.achievements_data.created_achevements = util.JSONToTable(ach)
    end

    --local ach_ply = file.Read("zcity/players_achevements.json", "DATA")
    --if ach_ply then
    --    hg.achievements.achievements_data.player_achievements = util.JSONToTable(ach_ply)
    --end
end

hook.Add("DatabaseConnected", "AchievementsCreateData", function()
	local query

	query = mysql:Create("hg_achievements")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
        query:Create("achievements", "TEXT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    hg.achievements.SqlActive = true
end)

hook.Add( "PlayerInitialSpawn","hg_Exp_OnInitSpawn", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not hg.achievements.SqlActive then
        hg.achievements.achievements_data.player_achievements[steamID64] = {}
        return
    end 

	local query = mysql:Select("hg_achievements")
		query:Select("achievements")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
            --print(result)
            --PrintTable(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].achievements) then
				local updateQuery = mysql:Update("hg_achievements")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

                hg.achievements.achievements_data.player_achievements[steamID64] = util.JSONToTable(result[1].achievements)

                --PrintTable(hg.achievements.achievements_data.player_achievements[steamID64])
			else
				local insertQuery = mysql:Insert("hg_achievements")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("achievements", util.TableToJSON({}))
				insertQuery:Execute()

				hg.achievements.achievements_data.player_achievements[steamID64] = {}
			end
		end)
	query:Execute()

end)


function hg.achievements.SaveToFile(fileName, data)
    file.Write("zcity/" .. fileName .. ".json", util.TableToJSON(data, true))
end

function hg.achievements.SaveToSQL(ply, data)
    if not hg.achievements.SqlActive then return end
    local name = ply:Name()
	local steamID64 = ply:SteamID64()
    --print(util.TableToJSON(hg.achievements.achievements_data.player_achievements[steamID64] or {}))
    local updateQuery = mysql:Update("hg_achievements")
        --updateQuery:Update("steam_name", name)
        --print(util.TableToJSON(data or hg.achievements.GetPlayerAchievements(ply) or {}))
        updateQuery:Update("achievements", util.TableToJSON(data or hg.achievements.GetPlayerAchievements(ply) or {}) )
        updateQuery:Where("steamid", steamID64)
    updateQuery:Execute()

    --file.Write("zcity/" .. fileName .. ".json", util.TableToJSON(data, true))
end

function hg.achievements.SaveAchievements()
    hg.achievements.SaveToFile("achievements", hg.achievements.achievements_data.created_achevements)
end

function hg.achievements.SavePlayerAchievements()
    for k, ply in player.Iterator() do
        hg.achievements.SaveToSQL(ply)
    end
    --hg.achievements.SaveToFile("players_achevements", hg.achievements.achievements_data.player_achievements)
end

--hg.achievements.SavePlayerAchievements()

hg.achievements.LoadAchievements()

local replacement_img = "homigrad/vgui/models/star.png"


function hg.achievements.CreateAchievementType(key, needed_value, start_value, description, name, img, showpercent)
    img = img or replacement_img
    hg.achievements.achievements_data.created_achevements[key] = {
        start_value = start_value,
        needed_value = needed_value,
        description = description,
        name = name,
        img = img,
        key = key,
        showpercent = showpercent,
    }
    hg.achievements.SaveAchievements()
end


function hg.achievements.GetCreatedAchievements()
    return hg.achievements.achievements_data.created_achevements
end


function hg.achievements.GetAchievementInfo(key)
    return hg.achievements.achievements_data.created_achevements[key]
end


function hg.achievements.GetPlayerAchievements(ply)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID]
end


function hg.achievements.GetPlayerAchievement(ply, key)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID][key] or {}
end


local function isAchievementCompleted(ply, key, val)
    local ach = hg.achievements.achievements_data.created_achevements[key]
    return val >= ach.needed_value and (hg.achievements.achievements_data.player_achievements[ply:SteamID64()][key].value or 0) < val
end

util.AddNetworkString("hg_NewAchievement")


function hg.achievements.SetPlayerAchievement(ply, key, val)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    local playerAchievements = hg.achievements.achievements_data.player_achievements[steamID]
    playerAchievements[key] = playerAchievements[key] or {}

    if isAchievementCompleted(ply, key, val) then
        local ach = hg.achievements.achievements_data.created_achevements[key]
        net.Start("hg_NewAchievement")
            net.WriteString(ach.name)
            net.WriteString(ach.img)
        net.Send(ply)
    end

    playerAchievements[key].value = val

    hg.achievements.SaveToSQL(ply,playerAchievements)
end


function hg.achievements.ApproachPlayerAchievement(ply, key, val)
    local ach = hg.achievements.GetPlayerAchievement(ply, key)
    local ach_info = hg.achievements.GetAchievementInfo(key)

    hg.achievements.SetPlayerAchievement(ply, key, math.Approach(ach.value or ach_info.start_value, ach_info.needed_value, val))
end

util.AddNetworkString("req_ach")


net.Receive("req_ach", function(len, ply)
    if (ply.ach_cooldown or 0) > CurTime() then return end
    ply.ach_cooldown = CurTime() + 2
    net.Start("req_ach")
        net.WriteTable(hg.achievements.GetCreatedAchievements())
        net.WriteTable(hg.achievements.GetPlayerAchievements(ply))
    net.Send(ply)
end)


hook.Add("PlayerDeath","huy",function(ply)
    --if gmod.GetGamemode() ~= "zbattle" then return end
    hg.achievements.ApproachPlayerAchievement(ply,"die",1)
end)

if !hg.init_ach then
    -- death
    hg.achievements.CreateAchievementType("die",1,0,"Die.","Once and for all",nil,false)
    -- braindeath
    hg.achievements.CreateAchievementType("brain",1,0,"Die from hypoxia.","I will definitely survive...",nil,false)
    -- death from drugs
    hg.achievements.CreateAchievementType("drugs",1,0,"Die from opioids overdose.","Overstimulated",nil,false)
    -- FirstTime Unconscious
    hg.achievements.CreateAchievementType("firsttime",1,0,"Getting unconscious for the first time.","First time?",nil,false)
    -- Hey guys!
    hg.achievements.CreateAchievementType("heyguys",1,0,"Commit suicide with a firearm","I guess that's it.",nil,false)
    -- 41%
    hg.achievements.CreateAchievementType("41", 1, 0, "41%", "Say it out loud.", nil, true)
    -- TERMINATOR
    hg.achievements.CreateAchievementType("illbeback",3,0,"Get shot in the head and get up alive.","I'll be back",nil,true)
    -- Killemall by traitor
    hg.achievements.CreateAchievementType("killemall",1,0,"Kill everyone being a traitor and win the round, players on the server should be more than 9.","Kill Em All",nil,false)
    -- traitor win
    hg.achievements.CreateAchievementType("killedall",1,0,"Win a round as a killer.","Too easy?",nil,false)

    hg.init_ach = true
end

hook.Add("HG_OnOtrub","hg_firsttime_Acchivment",function(ply)
    --if gmod.GetGamemode() ~= "zbattle" then return end
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    hg.achievements.ApproachPlayerAchievement(ply,"firsttime",1)
end)

hook.Add("ZB_TraitorWinOrNot","hg_killedall_Acchivment",function(ply,winner)
    --if gmod.GetGamemode() ~= "zbattle" then return end
    if winner == 1 then
        hg.achievements.ApproachPlayerAchievement(ply,"killedall",1)
    end
end)

local roundply = 0

hook.Add("ZB_StartRound","hg_killemall_Acchivment",function()
    roundply = 0
    for k,v in player.Iterator() do
        roundply = roundply + 1
    end
end)

hook.Add("ZB_TraitorWinOrNot","hg_killemall_Acchivment",function(ply,winner)
    --if gmod.GetGamemode() ~= "zbattle" then return end
    --hg.achievements.SetPlayerAchievement(ply,"killemall",0)
    if winner == 1 and (ply.TraitorKills or 0 >= roundply - 1) and roundply >= 10 then
        hg.achievements.SetPlayerAchievement(ply,"killemall",1)
    end
end)

hook.Add("PlayerDeath","hg_killemall_Acchivment",function(ply)
    if ply.isTraitor then ply.TraitorKills = 0 return end
    if IsValid(ply.ZBestAttacker) and ply.ZBestAttacker.isTraitor then
        ply.ZBestAttacker.TraitorKills = (ply.ZBestAttacker.TraitorKills or 0) + 1
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if ply.isTraitor then ply.TraitorKills = 0 return end
end)

hook.Add("HomigradDamage","hg_illbeback_Acchivment",function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs)
    --if gmod.GetGamemode() ~= "zbattle" then return end
    if not ply:IsPlayer() then return end
    if dmgInfo:IsDamageType(DMG_BULLET) and hitgroup == HITGROUP_HEAD and hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",1)
        ply.illbeback = CurTime() + 10
    end
end)

hook.Add("HG_OnOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 1 and ply.illbeback > CurTime() then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",2)
    end
end)

hook.Add("PlayerDeath","hg_illbeback_Acchivment",function(ply)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",0)
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",0)
    end
end)

hook.Add("HG_OnWakeOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 2 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",3)
    end
end)

local tblToFind = {
    {"trans","trans"},
    {"транс","trans"},
    {"suicide","suicide"},
    {"суицид","suicide"},
    {"41","41"},
}
hook.Add("PlayerSay","41%",function(ply,txt) 
    local lowerTxt = txt:lower()
    local huy = {
        ["trans"] = false,
        ["41"] = false,
        ["suicide"] = false
    }
    for _, v in ipairs(tblToFind) do
        local found = string.find( txt:lower(), v[1] )
        --print(found)
        if found then
            huy[v[2]] = true
        end
    end
    --PrintTable(huy)
    if huy["trans"] and huy["41"] and huy["suicide"] then
        hg.achievements.SetPlayerAchievement(ply,"41",1)
    end
end)


hook.Add("PlayerDeath", "hg_heyguys_Acchivment", function(ply, inf, att)
	local wep = ply:GetActiveWeapon()
	if wep == NULL or wep == nil or wep.Base ~= "homigrad_base" then return end
	if IsValid(att and ply) and att:IsPlayer() and ply:IsPlayer() and ply == att then
		hg.achievements.ApproachPlayerAchievement(ply, "heyguys", 1)
	end
end)