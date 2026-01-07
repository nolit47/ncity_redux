local player_GetAll = player.GetAll
zb.modes = zb.modes or {}


local forcemodeconvar = CreateConVar("zb_forcemode", "", FCVAR_ARCHIVE)

function zb:GetMode(round)
	if zb.modes[round] then return round end
	
	for name,mode in pairs(zb.modes) do
		if mode.Types and mode.Types[round] then
			return name
		end
	end
end

function CurrentRound()
	if IsValid(ents.FindByClass( "trigger_changelevel" )[1]) then
		zb.nextround = "coop"
		zb.CROUND = zb.CROUND or "coop"
		return zb.modes["coop"]
	end

	zb.CROUND = zb.CROUND or "hmcd"
	if not zb.CROUND_SUBTYPE or (zb.LASTCROUND != zb.CROUND) then
		zb.CROUND_SUBTYPE = zb:GetMode(zb.CROUND)
		zb.LASTCROUND = zb.CROUND
	end
	local round = zb.CROUND_SUBTYPE
	--print(zb.CROUND,round)
	
	return zb.modes[round], zb.CROUND
end

function NextRound(round)
	if IsValid(ents.FindByClass( "trigger_changelevel" )[1]) then
		zb.nextround = "coop"
	else
		-- Validate the round before setting it
		if round and round ~= "random" and not zb:GetMode(round) then
			ErrorNoHalt("[ZBattle] Warning: Invalid mode '" .. tostring(round) .. "' - falling back to hmcd\n")
			zb.nextround = "hmcd"
		else
			zb.nextround = round
		end
	end
end

function zb:PreRound()
	local currentMode = CurrentRound()
	if not currentMode then
		ErrorNoHalt("[ZBattle] PreRound: CurrentRound() returned nil, resetting to hmcd\n")
		zb.CROUND = "hmcd"
		zb.CROUND_SUBTYPE = nil
		currentMode = CurrentRound()
		if not currentMode then return end -- Safety check
	end
	
	if ((((zb.Roundscount or 0) > 15) and !GetConVar("zb_dev"):GetBool()) or ( (player.GetCount() > 1) and zb.ROUND_STATE == 0 and zb.CheckRTVVotes() )) and !(zb.RoundsLeft and zb.CROUND == "cstrike") then
		zb.StartRTV(20)
		zb.ROUND_STATE = 0
		return
	end
	
	if zb.ROUND_STATE == 0 and #player_GetAll() > 1 then
		zb.END_TIME = nil

		zb.START_TIME = zb.START_TIME or CurTime() + (currentMode.start_time or 5)
		if zb.START_TIME < CurTime() then zb:RoundStart() end
	end
end

function zb:RoundThink()
	if zb.ROUND_STATE == 1 then
		local currentMode = CurrentRound()
		if currentMode and currentMode.RoundThink then 
			currentMode:RoundThink(currentMode) 
		end
	end
end

hook.Add("CanListenOthers","RoundStartChat",function(output,input,isChat,teamonly,text)
	if zb.ROUND_STATE == 0 or zb.ROUND_STATE == 3 then return true, false end
end)

function zb:EndRound()
	zb.ROUND_STATE = 3
	zb.Roundscount = (zb.Roundscount or 0) + 1

	local mode, round = CurrentRound()
	
	if not mode then
		ErrorNoHalt("[ZBattle] EndRound: CurrentRound() returned nil\n")
		-- Send a fallback network message
		net.Start("RoundInfo")
			net.WriteString("hmcd")
			net.WriteInt(zb.ROUND_STATE, 4)
		net.Broadcast()
		return
	end

	net.Start("RoundInfo")
		net.WriteString(mode.name or "hmcd")
		net.WriteInt(zb.ROUND_STATE, 4)
	net.Broadcast()

	--PrintMessage(HUD_PRINTTALK, "Раунд закончен.")
	mode:EndRound()
	hook.Run("ZB_EndRound")
	zb.AddFade()

	hg.achievements.SavePlayerAchievements()
end

function zb:CheckWinner(tbl)
	local playerTable = table.Copy(tbl)
	for i, players in pairs(playerTable) do
		if table.Count(players) == 0 then
			playerTable[i] = nil
			continue
		end

		playerTable[i] = i
	end

	local winner = (table.Count(playerTable) == 1 and table.Random(playerTable)) or (table.Count(playerTable) == 0 and 3) or false
	local shouldendround = winner and true or nil
	return shouldendround, winner
end

zb.ROUND_TIME = zb.ROUND_TIME or 300

function zb:ShouldRoundEnd()
	local currentMode = CurrentRound()
	if not currentMode then return false end
	
	local time = zb.ROUND_TIME
	local shouldroundend = currentMode:ShouldRoundEnd()
	if shouldroundend ~= false then
		local boringround = (zb.ROUND_START + time) < CurTime()
		
		if boringround and currentMode.BoringRoundFunction then
			PrintMessage(HUD_PRINTTALK, "Stopping round because it was TOO boring.")
			
			currentMode:BoringRoundFunction()
		end

		return (shouldroundend and true) or (boringround)
	else
		return false
	end
end

function zb:EndRoundThink()
	if zb.ROUND_STATE == 1 and zb:ShouldRoundEnd() then zb:EndRound() end
	if zb.ROUND_STATE == 3 then
		local currentMode = CurrentRound()
		if not currentMode then
			ErrorNoHalt("[ZBattle] EndRoundThink: CurrentRound() returned nil, forcing to hmcd\n")
			zb.CROUND = "hmcd"
			zb.CROUND_SUBTYPE = nil
			return
		end
		
		zb.END_TIME = zb.END_TIME or (CurTime() + (currentMode.end_time or 5))
		if zb.END_TIME < CurTime() then
			zb.ROUND_STATE = 0

			hook.Run("ZB_PreRoundStart")

			zb.CROUND = zb.nextround or "hmcd"
			
			-- Validate the new round
			local newMode = CurrentRound()
			if not newMode then
				ErrorNoHalt("[ZBattle] EndRoundThink: Invalid next round '" .. tostring(zb.CROUND) .. "', falling back to hmcd\n")
				zb.CROUND = "hmcd"
				zb.CROUND_SUBTYPE = nil
				newMode = CurrentRound()
				if not newMode then return end
			end
			
			if newMode.shouldfreeze then zb:Freeze() end

			--PrintMessage(HUD_PRINTTALK, "Gamemode: " .. CurrentRound().PrintName or "None")

			local mode, round = CurrentRound()
			net.Start("RoundInfo")
				net.WriteString(mode.name or "hmcd")
				net.WriteInt(zb.ROUND_STATE, 4)
			net.Broadcast()

			hg.UpdateRoundTime(mode.ROUND_TIME, CurTime(), CurTime() + (mode.start_time or 5))

			self:KillPlayers()
			self:AutoBalance()

			if hg.PluvTown.Active then
				for _, ply in player.Iterator() do
					ply:SetNetVar("CurPluv", "pluv")
				end
			end

			mode:Intermission()
			mode:GiveEquipment()
		end
	end
end

hook.Add("PlayerInitialSpawn", "zb_SendRoundInfo", function(ply)
	if zb.CROUND then
		local mode,round = CurrentRound()
		if mode then
			net.Start("RoundInfo")
				net.WriteString(mode.name or "hmcd")
				net.WriteInt(zb.ROUND_STATE, 4)
			net.Send(ply)
		end
	end

	if ply.SyncVars then ply:SyncVars() end
end)

util.AddNetworkString("RoundInfo")
function zb:Think(time)
	if (zb.thinkTime or CurTime()) > time then return end
	zb.thinkTime = time + 1
	zb:PreRound()
	zb:RoundThink()
	zb:EndRoundThink()
end

hook.Add("Think", "zb-think", function() zb:Think(CurTime()) end)

function zb:KillPlayers()
	local mode = CurrentRound()
	if not mode then return end
	
	for i, ply in ipairs(player_GetAll()) do
		if ply:Team() == TEAM_SPECTATOR then continue end

		ply:GiveExp(math.random(4,15))

		if ply:Alive() and mode.DontKillPlayer and mode:DontKillPlayer(ply) then
			hg.organism.Clear(ply.organism)
			hg.FakeUp(ply,true,true)

			continue
		end
		
		ply:KillSilent()
		ply:Spawn()
		ply:SetPlayerClass()
	end
end

local forcemode = "random"

function zb.GetModes()
	local newtbl = {}
	for name,tbl in pairs(zb.modes) do
		table.insert(newtbl,name)
	end
	return newtbl
end

ZBATTLE_BIGMAP = 5700

COMMANDS.bigmap = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end
		local set = tonumber(args[1]) != 0
		ZBATTLE_BIGMAP = set and 0 or 6969
		ply:ChatPrint("Big map - "..tostring(set))
		zb.RerollChances()
	end,
	0
}


zb.BigMaps = {
	["mu_smallotown_v2_snow"] = true,
	["mu_smallotown_v2_13"] = true,
	["mu_smallotown_v2_13_night"] = true,
}

function zb.GetAvailableModes()
	zb.tdm_checkpoints()

	local newtbl = {}

	for i,name in pairs(zb.GetModes()) do
		
		local tbl = zb.modes[name]
		if (tbl.CanLaunch and tbl:CanLaunch()) and 
		( 
			( not tbl.ForBigMaps ) or 
			( zb.GetWorldSize() > ZBATTLE_BIGMAP )
		) then			
			if tbl.SubModes then
				for i, name in pairs(tbl:SubModes()) do
					table.insert(newtbl, name)
				end
			else
				table.insert(newtbl, name)
			end
		end
	end

	return newtbl
end

zb.ModesPlaytime = zb.ModesPlaytime or {}

function zb.GetModesPlaytime()
	local tbl = zb.GetAvailableModes()
	local newtbl = {}
	local count = 0

	for i,name in ipairs(tbl) do
		local amt = zb.ModesPlaytime[name] or 0
		newtbl[name] = amt
		count = count + amt
	end

	return newtbl, count
end

function zb.GetModePlaytime(name)
	return zb.ModesPlaytime[name] or 0
end

function zb.SetModePlaytime(name, set)
	zb.ModesPlaytime[name] = set
end

function zb.AddModePlaytime(name, add)
	zb.ModesPlaytime[name] = (zb.ModesPlaytime[name] or 0) + add
end

function zb.AddCurrentModePlayed()
	local mode = CurrentRound()
	if not mode then return end
	local name = mode.name

	if mode.SubModes then
		name = mode.Type or "hmcd"
	end
	
	zb.AddModePlaytime(name, 1)
end

zb.ModesChances = zb.ModesChances or {}

function zb.GetChance(name, modes, amtplayed)
	local mode = zb:GetMode(name)
	if not mode then return 0.1 end
	
	local tbl = zb.modes[mode]
	if not tbl then return 0.1 end
	
	local frequency_played = modes and amtplayed and modes[name] and modes[name] / amtplayed

	local newtbl = tbl.Types and tbl.Types[name] or tbl

	return newtbl.ChanceFunction and newtbl:ChanceFunction() or newtbl.Chance or 0.1
end

function zb.GetModesChances()
	local tbl = zb.GetAvailableModes()
	local newtbl = {}

	local modes, amtplayed = zb.GetModesPlaytime()
	
	for i,name in pairs(tbl) do
		newtbl[name] = zb.GetChance(name, modes, amtplayed)
	end

	return newtbl
end

function zb.WeightedChanceMode()
	local modes_chances = zb.GetModesChances()
	local weight = 0

	for name, chance in pairs(modes_chances) do
		local played = modes_chances[name]
		weight = weight + chance * 100
	end

	if weight == 0 then return "hmcd" end -- Safety check

	local random = math.random(weight)
	
	local count = 0
	for name, chance in RandomPairs(modes_chances) do
		count = count + chance * 100

		if count >= random then
			return name
		end
	end

	return "hmcd"
end

function zb.GetWorldSize()
	local world = game.GetWorld()
	local worldMin = world:GetInternalVariable("m_WorldMins")
	local worldMax = world:GetInternalVariable("m_WorldMaxs")
	local size = worldMin:Distance(worldMax)

	return size + (zb.BigMaps[ game.GetMap() ] and 5000 or 0)
end

function zb.GetRoundName(name)
	local mode = zb:GetMode(name)
	if not mode or not zb.modes[mode] then return "Unknown Mode" end
	return zb.modes[mode].PrintName or name
end

zb.RoundList = zb.RoundList or {}
zb.QueuedModes = zb.QueuedModes or {} 

function zb.CheckChances()
	if #zb.RoundList == 0 then
		zb.RerollChances()
	end

	local nextrnd = zb.nextround or zb.RoundList[1]
	print("Next round is: "..zb.GetRoundName(nextrnd).." ("..nextrnd..")")
	
	if #zb.QueuedModes > 0 then
		print("Queued game modes:")
		for i=1, #zb.QueuedModes do
			print("  "..i..": "..zb.GetRoundName(zb.QueuedModes[i]).." ("..zb.QueuedModes[i]..")")
		end
	else
		for i=1,#zb.RoundList do
			print("Round "..(i+1).." will be "..zb.GetRoundName(zb.RoundList[i]).." ("..zb.RoundList[i]..")")
		end
	end
end

function zb.RerollChances()
	zb.RoundList = {}
	
	for i=1,20 do
		zb.RoundList[i] = zb.WeightedChanceMode()
	end

	zb.nextround = table.remove(zb.RoundList, 1)
end


function zb.GetModesInfo()
    local modesInfo = {}
    for name, mode in pairs(zb.modes) do
        table.insert(modesInfo, {
            key = name,
            name = mode.PrintName or mode.name or name,
            description = mode.Description or "",
            forBigMaps = mode.ForBigMaps or false,
			canlaunch = (mode.CanLaunch and mode:CanLaunch() and 1 or 0)
        })
    end
    return modesInfo
end


function zb.SetRoundList(newList)
	local newLista = table.Copy(newList)
    if #newLista > 0 then
		zb.nextround = table.remove(newLista, 1)
		zb.RoundList = newLista
	else
		zb.RerollChances()
		
		zb.nextround = table.remove(zb.RoundList, 1)
	end
end


util.AddNetworkString("ZB_SendModesInfo")
util.AddNetworkString("ZB_SendRoundList") 
util.AddNetworkString("ZB_RequestRoundList")
util.AddNetworkString("ZB_UpdateRoundList")
util.AddNetworkString("ZB_NotifyRoundListChange")


function zb.SendModesInfoToClient(ply)
    net.Start("ZB_SendModesInfo")
        net.WriteTable(zb.GetModesInfo())
    net.Send(ply)
end


function zb.SendRoundListToClient(ply)
    net.Start("ZB_SendRoundList")
        net.WriteTable(zb.RoundList)
        net.WriteString(zb.nextround or "")
    net.Send(ply)
end


hook.Add("PlayerInitialSpawn", "ZB_SendModesOnSpawn", function(ply)
    if ply:IsAdmin() then
        timer.Simple(1, function()
            if IsValid(ply) then
                zb.SendModesInfoToClient(ply)
                zb.SendRoundListToClient(ply)
            end
        end)
    end
end)


net.Receive("ZB_RequestRoundList", function(len, ply)
    if IsValid(ply) and ply:IsAdmin() then
		zb.SendModesInfoToClient(ply)
        zb.SendRoundListToClient(ply)
    end
end)

net.Receive("ZB_UpdateRoundList", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    
    local newList = net.ReadTable()
    local forceUpdate = net.ReadBool()
    
    zb.SetRoundList(newList)

    net.Start("ZB_NotifyRoundListChange")
        net.WriteString(ply:Nick())
    net.Send(zb.GetAllAdmins())
    
    for _, admin in ipairs(zb.GetAllAdmins()) do
        zb.SendRoundListToClient(admin)
    end
end)

function zb:RoundStart()
	local currentMode = CurrentRound()
	if not currentMode then
		ErrorNoHalt("[ZBattle] RoundStart: CurrentRound() returned nil\n")
		return
	end
	
	if currentMode.shouldfreeze then zb:Unfreeze() end

	zb.ROUND_STATE = 1
	zb.START_TIME = nil

	local mode, round = CurrentRound()
	
	zb.ROUND_BEGIN = CurTime()
	hg.UpdateRoundTime()
	
	net.Start("RoundInfo")
		net.WriteString(mode.name or "hmcd")
		net.WriteInt(zb.ROUND_STATE, 4)
	net.Broadcast()

	if forcemodeconvar:GetString() != "" then
		forcemode = forcemodeconvar:GetString()
	end

	zb.AddCurrentModePlayed()
	
	mode:RoundStart()
	
	local nextMode

	if #zb.RoundList == 0 then
		zb.RerollChances()
	end

	nextMode = table.remove(zb.RoundList, 1)
	
	local currentMode = mode.Type or round
	
	print("Next game mode is " .. nextMode)
	
	NextRound(forcemode ~= "random" and forcemode or (nextMode or "hmcd"))
	
	if mode.RoundStartPost then
		mode:RoundStartPost()
	end

	hook.Run("ZB_StartRound")
	
	//zb.GetAllPoints(true)

    for _, admin in ipairs(zb.GetAllAdmins()) do
        zb.SendRoundListToClient(admin)
    end
end

concommand.Add("zb_setnextmode", function(ply,cmd,args)
	local mode = args and args[1]
	if not mode then
		if IsValid(ply) then ply:ChatPrint("Usage: zb_setnextmode <mode> [now]") else print("Usage: zb_setnextmode <mode> [now]") end
		return
	end

	if IsValid(ply) and not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end

	if not zb:GetMode(mode) and mode ~= "random" then
		if IsValid(ply) then ply:ChatPrint("Unknown mode: " .. mode) else print("Unknown mode: " .. mode) end
		return
	end

	NextRound(mode)

	if args and args[2] and (args[2] == "now" or args[2] == "1") then
		if IsValid(ply) then ply:ChatPrint("Ending round to switch to: " .. mode) else print("Ending round to switch to: " .. mode) end
		zb:EndRound()
	else
		if IsValid(ply) then ply:ChatPrint("Next mode set to: " .. mode) else print("Next mode set to: " .. mode) end
	end
end)

concommand.Add("zb_endmode", function(ply,cmd,args)
	if IsValid(ply) and not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end

	if IsValid(ply) then ply:ChatPrint("Round ended by admin") else print("Round ended by console") end
	zb:EndRound()
end)

concommand.Add("zb_checkchances",function(ply) if ply:IsAdmin() then zb.CheckChances() end end)
concommand.Add("zb_rerollchances",function(ply) if ply:IsAdmin() then zb.RerollChances() zb.CheckChances() end end)

function zb.NotifyQueueEmptied()
	net.Start("QueueEmptiedNotification")
	net.Send(zb.GetAllAdmins())
end

hook.Add("PlayerInitialSpawn", "SendGameModesToClient", function(ply)
	if ply:IsAdmin() then
		local modesToSend = {}
		for key, mode in pairs(zb.modes) do
			table.insert(modesToSend, {key = key, name = mode.PrintName or mode.name})
		end

		net.Start("SendAvailableModes")
			net.WriteTable(modesToSend)
		net.Send(ply)
	end
end)

net.Receive("AdminSetGameMode", function(len, ply)
	if not ply:IsAdmin() then return end 

	local command = net.ReadString()
	local modeKey = net.ReadString()
	local addToQueue = net.ReadBool() or false 

	if command == "setmode" then
		NextRound(modeKey)
		ply:ChatPrint("Game mode set to: " .. modeKey)
		
		if addToQueue then
			table.insert(zb.QueuedModes, modeKey)
			zb.NotifyQueueModified(ply, "added " .. modeKey .. " to")
			
			zb.SyncQueueToAdmins()
		end
	elseif command == "setforcemode" then
		forcemode = modeKey
		NextRound(forcemode)
		ply:ChatPrint("Force mode set to: " .. modeKey)
		
		if addToQueue then
			table.insert(zb.QueuedModes, modeKey)
			zb.NotifyQueueModified(ply, "added " .. modeKey .. " to")
			
			zb.SyncQueueToAdmins()
		end
	end
end)

net.Receive("AdminEndRound", function(len, ply)
	if not ply:IsAdmin() then return end

	ply:ChatPrint("Round ended!")
	zb:EndRound()
end)

function zb.SyncQueueToAdmins()
	timer.Simple(0.1, function()
		net.Start("SendGameQueue")
		net.WriteTable(zb.QueuedModes)
		net.Send(zb.GetAllAdmins())
	end)
end

net.Receive("AdminSetGameQueue", function(len, ply)
	if not ply:IsAdmin() then return end
	
	local modeQueue = net.ReadTable()
	zb.QueuedModes = modeQueue
	
	if #modeQueue == 0 then
		ply:ChatPrint("Game mode queue has been cleared")
		zb.NotifyQueueModified(ply, "cleared")
		
		
		timer.Simple(0.2, function()
			net.Start("QueueEmptiedNotification")
			net.Send(zb.GetAllAdmins())
		end)
	else
		ply:ChatPrint("Game mode queue set with " .. #modeQueue .. " modes")
		zb.NotifyQueueModified(ply, "updated")
	end
	
	zb.SyncQueueToAdmins()
end)

function zb.NotifyQueueModified(ply, action)
    local admins = zb.GetAllAdmins()
    
    local recipients = {}
    for _, admin in ipairs(admins) do
        if admin ~= ply then 
            table.insert(recipients, admin)
        end
    end
    

    if #recipients > 0 then
        net.Start("QueueModifiedNotification")
        net.WriteString(IsValid(ply) and ply:Nick() or "Server")
        net.WriteString(action)
        net.Send(recipients)
    end
end

function zb:Unfreeze()
    for i, ply in ipairs(player_GetAll()) do
        if ply:Alive() then ply:Freeze(false) end
    end
end


function zb:Freeze()
    for i, ply in ipairs(player_GetAll()) do
        if ply:Alive() then ply:Freeze(true) end
    end
end

function zb.GetAllAdmins()
	local admins = {}
	for _, ply in ipairs(player_GetAll()) do
		if ply:IsAdmin() then
			table.insert(admins, ply)
		end
	end
	return admins
end

COMMANDS.setmode = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end
		if not args[1] or (not zb:GetMode(args[1]) and args[1]~="random") then return end
		ply:ChatPrint(args[1])
		NextRound(args[1])
	end,
	0
}

COMMANDS.setforcemode = {
	function(ply, args)
		if not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end
		if not args[1] or (not zb:GetMode(args[1]) and args[1]~="random") then return end
		ply:ChatPrint(args[1])
		forcemode = args[1]
		if args[1] ~= "random" then
			NextRound(args[1])
		end
	end,
	0
}

COMMANDS.endround = {function(ply, args)
	if not ply:IsAdmin() then ply:ChatPrint("You don't have access") return end
	 	zb:EndRound()
	end,
	0}

if SERVER then
    util.AddNetworkString("SendAvailableModes")
    util.AddNetworkString("AdminSetGameMode")
	util.AddNetworkString("AdminEndRound")
    util.AddNetworkString("AdminSetGameQueue")
    util.AddNetworkString("RequestGameQueue")
    util.AddNetworkString("SendGameQueue")
    util.AddNetworkString("QueueEmptiedNotification")
    util.AddNetworkString("QueueModifiedNotification")

    hook.Add("PlayerInitialSpawn", "SendGameModesToClient", function(ply)
        if ply:IsAdmin() then
            local modesToSend = {}
            for key, mode in pairs(zb.modes) do
                table.insert(modesToSend, {key = key, name = mode.PrintName or mode.name})
            end

            net.Start("SendAvailableModes")
                net.WriteTable(modesToSend)
            net.Send(ply)
        end
    end)

    net.Receive("AdminSetGameMode", function(len, ply)
        if not ply:IsAdmin() then return end 

        local command = net.ReadString()
        local modeKey = net.ReadString()
        local addToQueue = net.ReadBool() or false 

		if not zb:GetMode(modeKey) and modeKey ~= "random" then
			ply:ChatPrint("Invalid mode: " .. modeKey)
			return
		end

		if not (ply:IsSuperAdmin() or ply:IsAdmin()) and zb.modes[modeKey] and not zb.modes[modeKey]:CanLaunch() then
			ply:ChatPrint("This mode can't launch (No points or Is blocked): " .. modeKey)
			return 
		end

        if command == "setmode" then
            NextRound(modeKey)
            ply:ChatPrint("Game mode set to: " .. modeKey)
            
            if addToQueue then
                table.insert(zb.QueuedModes, modeKey)
                zb.NotifyQueueModified(ply, "added " .. modeKey .. " to")
                
                zb.SyncQueueToAdmins()
            end
        elseif command == "setforcemode" then
            forcemode = modeKey
            NextRound(forcemode)
            ply:ChatPrint("Force mode set to: " .. modeKey)
            
            if addToQueue then
                table.insert(zb.QueuedModes, modeKey)
                zb.NotifyQueueModified(ply, "added " .. modeKey .. " to")
                
                zb.SyncQueueToAdmins()
            end
        end
    end)
    
    function zb.SyncQueueToAdmins()
        timer.Simple(0.1, function()
            net.Start("SendGameQueue")
            net.WriteTable(zb.QueuedModes)
            net.Send(zb.GetAllAdmins())
        end)
    end
    
    net.Receive("AdminSetGameQueue", function(len, ply)
        if not ply:IsAdmin() then return end
        
        local modeQueue = net.ReadTable()
        zb.QueuedModes = modeQueue
        
        if #modeQueue == 0 then
            ply:ChatPrint("Game mode queue has been cleared")
            zb.NotifyQueueModified(ply, "cleared")
            
            
            timer.Simple(0.2, function()
                net.Start("QueueEmptiedNotification")
                net.Send(zb.GetAllAdmins())
            end)
        else
            ply:ChatPrint("Game mode queue set with " .. #modeQueue .. " modes")
            zb.NotifyQueueModified(ply, "updated")
        end
        
        zb.SyncQueueToAdmins()
    end)

end
