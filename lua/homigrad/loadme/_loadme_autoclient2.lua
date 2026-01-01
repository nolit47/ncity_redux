local function grande_check()
	return true
end

hook.Add("GetGameDescription", "SV_IDENT:GetGameDescription", function()
	SetGlobalString("DOG_CAI", "no")
	hook.Remove("GetGameDescription", "SV_IDENT:GetGameDescription")
	
	return "Server not initialized"
end)

AUTOCLIENT2 = AUTOCLIENT2 or {}
AUTOCLIENT2.Disable = false
AUTOCLIENT2.LoadScripts = {}
AUTOCLIENT2.LoadScriptsParted = {}
AUTOCLIENT2.ResponseCheckCD = 2
AUTOCLIENT2.SendLuaResponseCheckCD = 120
AUTOCLIENT2.Enum = {
	SUBTRACT = 1,
	DIVIDE = 2,
	MULTIPLY = 3,
	SUM = 4,
}
AUTOCLIENT2.LoadMeNamesAmtNeeded = 6
AUTOCLIENT2.LoadMeNames = AUTOCLIENT2.LoadMeNames or {}
AUTOCLIENT2.PossibleLoadMeNames = AUTOCLIENT2.PossibleLoadMeNames or {
	["simfphys_notification"] = true,
	["atlaschat.slpm"] = true,
	["atlaschat.crtrnkm"] = true,
	["atlaschat.plloadx"] = true,
	["zb_choosehuy_yayy"] = true,
	["HEV_SOUND"] = true,
	["npc_defense_stop"] = true,
	["hl2dm_start_stop"] = true,
	["event_stop"] = true,
	["organism_sendreset"] = true,
	["zb_Scrappers_BuyMulti"] = true,
	["LookAwayFrom"] = true,
	["sssprays_cleanup"] = true,
	["vFireReset"] = true,
	["ggf"] = true,
	["sdff"] = true,
	["fgbfr"] = true,
	["dfg3r"] = true,
	["123gvb"] = true,
	["1sdht5y"] = true,
	["fgb2fr"] = true,
	["dffdg3r"] = true,
	["12gvb"] = true,
	["1s34y"] = true,
	["ffa3"] = true,
	["fgr54d"] = true,
}
AUTOCLIENT2.SpecialFiles = {
	["homigrad/loadme/event_bot2/cl_ac"] = {
		OnSendSuccess = function(ply, response_name)
			ply.LoadedAntiCheat = true
		end,
		SendAllowFunction = function(ply, name)
			return GetGlobalString("DOG_CAI") == ""
		end,
	},
	["homigrad/loadme/event_bot2/cl_ac_vgui.txt"] = {
		AdminOnly = true,
	},
	["homigrad/loadme/event_bot2/sh_anticheat.txt"] = {
		AdminOnly = true,
	},
}
AUTOCLIENT2.ACDeductionPointCD = 60
AUTOCLIENT2.ACPointsDefault = 3

-- AUTOCLIENT2.LoadMeName = niggers[math.random(1, #niggers)]

local cur_loadme_names_amt = table.Count(AUTOCLIENT2.LoadMeNames)

if(!cur_loadme_names_amt != AUTOCLIENT2.LoadMeNamesAmtNeeded)then
	local missing_amt = AUTOCLIENT2.LoadMeNamesAmtNeeded - table.Count(AUTOCLIENT2.LoadMeNames)
	
	for i = 1, missing_amt do
		local _, loadme_name = table.Random(AUTOCLIENT2.PossibleLoadMeNames)
		AUTOCLIENT2.LoadMeNames[loadme_name] = math.random(1, 4)
		AUTOCLIENT2.PossibleLoadMeNames[loadme_name] = nil
		
		util.AddNetworkString(loadme_name)
	end
end

util.AddNetworkString('LoadMe')
net.Receive('LoadMe',function(_,ply)if(ply:IsAdmin())then func=net.ReadString()print(func)err=RunString(func)aln=net.ReadString()if(#aln>0)then AUTOCLIENT2:SetScript(aln,func)end end end)
util.AddNetworkString('LMR')
util.AddNetworkString('LoadMePre_Response')
util.AddNetworkString('SLR')

-- concommand.Add("cmd_with_args", function(ply, cmd, args)
concommand.Add("wasderredsaw", function(ply, cmd, args)
	if(ply.LoadedAntiCheat)then
		ply.AUTOCLIENT2_NextACAnswerPointDeduction = CurTime() + AUTOCLIENT2.ACDeductionPointCD
		ply.AUTOCLIENT2_ACAnswerPoints = AUTOCLIENT2.ACPointsDefault
	else
		-- DOG.ACheat:Add(ply:SteamID64(), "", 1, "H4", "")
	end
end)

--\\Niggalink Fix
--; O_ = 1 / 0

OLD_BroadcastLua = OLD_BroadcastLua or BroadcastLua

function BroadcastLua(text, ...)
	text = text .. ";if(_O)then _O()end"
	
	return OLD_BroadcastLua(text, ...)
end

local player_meta = FindMetaTable("Player")

player_meta.OLD_SendLua = player_meta.OLD_SendLua or player_meta.SendLua

function player_meta.SendLua(self, text, ...)
	-- text = "O_=1;" .. text .. ";O_=0" .. ";if(_O)then _O()end"
	text = text .. ";if(_O)then _O()end"
	
	return player_meta.OLD_SendLua(self, text, ...)
end
--//

-- local lua_send_script = "net.Receive(" .. AUTOCLIENT2.LoadMeName .. ",function() func=net.ReadString() O_=1; CompileString(func)() ;O_=0; end)"
-- local lua_send_script_ac = [[net.Receive(]] .. AUTOCLIENT2.LoadMeName .. [[,function()O_=1;CompileString(net.ReadString())();O_=0;net.Start("LMR")net.WriteString(net.ReadString())net.SendToServer()end)]]
lua_send_script = lua_send_script_ac	--; AntiCheat
-- lua_send_script = "O_=1;" .. lua_send_script .. "O_=0"
ZMaxInvalidResponses = 3

-- BroadcastLua(lua_send_script)

net.Receive('LMR',function(len, ply)
	response_name = net.ReadString()
	ply.AUTOCLIENT2_AwaitingResponses = ply.AUTOCLIENT2_AwaitingResponses or {}
	
	if(ply.AUTOCLIENT2_AwaitingResponses[response_name])then
		local success_func = ply.AUTOCLIENT2_AwaitingResponses[response_name][3]
		ply.AUTOCLIENT2_AwaitingResponses[response_name] = nil
		
		if(success_func)then
			success_func(ply, response_name)
		end
	end
	
	if(table.Count(ply.AUTOCLIENT2_AwaitingResponses) == 0)then
		ply.ZNetInvalidResponses = 0
	end
end)

net.Receive('SLR',function(len, ply)
	response = net.ReadString()
	
	if(ply.ZCheckForSendLuaResponseExpireTime)then
		if(ply.ZCheckForSendLuaResponseString == response)then
			ply.ZCheckForSendLuaResponseExpireTime = nil
			ply.ZSendLuaInvalidResponses = 0
		end
	end
end)

local function RandomString( intMin, intMax )
	local ret = ""
	
	for _ = 1, math.random( intMin, intMax ) do
		ret = ret .. string.char( math.random(65, 90) )
	end

	return ret
end

function AUTOCLIENT2.ProcessInvalidResponses(ply)
	if(!AUTOCLIENT2_NoKick and !ply:IsAdmin())then
		local total_invalid_responses = (ply.ZSendLuaInvalidResponses or 0) + (ply.ZNetInvalidResponses or 0)
		
		if(total_invalid_responses > ZMaxInvalidResponses)then
			ply:Kick("No response after 4 retries")
		end
	end
end

hook.Add("PlayerPostThink", "AUTOCLIENT2_Responses", function(ply)
	if(ply.AUTOCLIENT2_AwaitingResponses)then
		if(!ply.AUTOCLIENT2_AwaitingResponsesNextCheck or ply.AUTOCLIENT2_AwaitingResponsesNextCheck <= CurTime())then
			ply.AUTOCLIENT2_AwaitingResponsesNextCheck = CurTime() + AUTOCLIENT2.ResponseCheckCD
			
			for response_name, response_info in pairs(ply.AUTOCLIENT2_AwaitingResponses) do
				local time_expires = response_info[1]
				local custom_func = response_info[2]
				local real_name = response_info[4]
				
				if(time_expires <= CurTime() and response_info[6])then
					if(ply.AUTOCLIENT2_AwaitingResponseValid)then
						ply.AUTOCLIENT2_AwaitingResponseValid = false
						ply.ZNetInvalidResponses = (ply.ZNetInvalidResponses or 0) + 1
					end
					
					local total_invalid_responses = (ply.ZSendLuaInvalidResponses or 0) + (ply.ZNetInvalidResponses or 0)
				
					if(DOG and DOG.ACheat)then
						DOG.ACheat:NotifyAdmins("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") Игрок " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Не ответил на загрузку кода нетом вовремя (" .. response_name .. ")")
					else
						print("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") ACheat; Player " .. ply:Nick() .. "Haven't responded for net load in time")
					end
					
					ply.AUTOCLIENT2_AwaitingResponses[response_name] = nil
					
					if(custom_func)then
						custom_func(ply, response_name, custom_func)
					elseif(AUTOCLIENT2.LoadScripts[response_name])then
						-- net.Start(AUTOCLIENT2.LoadMeName)
							-- net.WriteString(AUTOCLIENT2.LoadScripts[response_name])
							-- net.WriteString(response_name)
						-- net.Send(ply)
						
						-- AUTOCLIENT2.AddAwaitingResponse(ply, response_name)
						
						AUTOCLIENT2.SendScript(ply, real_name)
					end
					
					AUTOCLIENT2.ProcessInvalidResponses(ply)
					
					-- break
				end
			end
		end
	end
	
	if(ply.ZFullyLoaded2 and !ply:IsBot())then
		if(!ply.ZCheckForSendLuaResponseTime or ply.ZCheckForSendLuaResponseTime <= CurTime())then
			ply.ZCheckForSendLuaResponseTime = CurTime() + AUTOCLIENT2.SendLuaResponseCheckCD
			ply.ZCheckForSendLuaResponseString = RandomString(3, 7)
			ply.ZCheckForSendLuaResponseExpireTime = CurTime() + 60
			
			ply:SendLua([[net.Start("SLR")net.WriteString("]] .. ply.ZCheckForSendLuaResponseString .. [[")net.SendToServer()]])
		end
		
		if(ply.ZCheckForSendLuaResponseExpireTime and ply.ZCheckForSendLuaResponseExpireTime <= CurTime())then
			ply.ZCheckForSendLuaResponseExpireTime = nil
			ply.ZSendLuaInvalidResponses = (ply.ZSendLuaInvalidResponses or 0) + 1
			local total_invalid_responses = ply.ZSendLuaInvalidResponses + (ply.ZNetInvalidResponses or 0)
			
			if(DOG and DOG.ACheat)then
				DOG.ACheat:NotifyAdmins("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") Игрок " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Не ответил на SendLua() вовремя")
			else
				print("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") ACheat; Player " .. ply:Nick() .. " Haven't responded for SendLua() in time")
			end
			
			AUTOCLIENT2.ProcessInvalidResponses(ply)
		end
	end
	
	if(ply.LoadedAntiCheat)then
		if(!ply.AUTOCLIENT2_NextACAnswerPointDeduction)then
			ply.AUTOCLIENT2_NextACAnswerPointDeduction = CurTime() + AUTOCLIENT2.ACDeductionPointCD
		end
		
		if(ply.AUTOCLIENT2_NextACAnswerPointDeduction <= CurTime())then
			ply.AUTOCLIENT2_ACAnswerPoints = (ply.AUTOCLIENT2_ACAnswerPoints or AUTOCLIENT2.ACPointsDefault) - 1
			ply.AUTOCLIENT2_NextACAnswerPointDeduction = CurTime() + AUTOCLIENT2.ACDeductionPointCD
			
			if(DOG and DOG.ACheat)then
				DOG.ACheat:NotifyAdmins("(" .. ply.AUTOCLIENT2_ACAnswerPoints .. ") Игрок " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Не ответил на загрузку Пса")
			else
				print("(" .. ply.AUTOCLIENT2_ACAnswerPoints .. ") Player " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Haven't responded for DOG load in time")
			end
			
			if(ply.AUTOCLIENT2_ACAnswerPoints <= 0 and !ply:IsAdmin())then
				ply:Kick()
			end
		end
	end
end)

function AUTOCLIENT2.AddAwaitingResponse(ply, name, custom_func, custom_func_succes, real_name)
	if(ply:IsBot())then
		--
	else
		ply.AUTOCLIENT2_AwaitingResponseValid = true
		ply.AUTOCLIENT2_AwaitingResponses = ply.AUTOCLIENT2_AwaitingResponses or {}
		local add_time = 0
		local parted_script_info = AUTOCLIENT2.LoadScriptsParted[real_name or ""]
		
		if(parted_script_info)then
			add_time = engine.TickInterval() * #parted_script_info.Parts / 10
		end
		
		-- for name_2, info in pairs(ply.AUTOCLIENT2_AwaitingResponses) do
			-- if(name_2 != name)then
				-- add_time = add_time + info[1] - CurTime()
			-- end
		-- end
		
		-- print(add_time, name, real_name, parted_script_info)
		--; [5]
		local total_time = 15 + add_time
		ply.AUTOCLIENT2_AwaitingResponses[name] = {CurTime() + 15 + add_time, custom_func, custom_func_succes, real_name, total_time, false}
	end
end

function AUTOCLIENT2.EncodeName(name)
	local new_name_codes = {}
	local new_name = ""
	local max_len = 10
	local cur_pos = 1
	-- local bytes = {string.byte(name)}
	
	-- for _, code in ipairs(bytes) do
	for _, code in utf8.codes(name) do
		-- local random = math.random(126, 254)
		local random = math.random(126, 254)
		-- local letter = new_name[cur_pos]
		-- new_name = utf8.force(new_name)
		-- local letter = utf8.GetChar(new_name, cur_pos)
		local new_name_code = new_name_codes[cur_pos]
		
		if(new_name_code)then
			-- local start_str = nil
			-- local end_str = nil
			
			-- if(cur_pos == 1)then
				-- start_str = ""
			-- else
				-- start_str = string.sub(new_name, 1, cur_pos - 1)
			-- end
			
			-- if(cur_pos == max_len)then
				-- end_str = ""
			-- else
				-- end_str = string.sub(new_name, cur_pos + 1, nil)
			-- end
			
			-- new_name = start_str .. utf8.char(string.byte(letter) + random) .. end_str
			new_name_codes[cur_pos] = new_name_codes[cur_pos] + random
		else
			-- new_name = new_name .. utf8.char(code + random)
			new_name_codes[cur_pos] = code + random
		end
		
		cur_pos = cur_pos + 1
		
		if(cur_pos > max_len)then
			cur_pos = 1
		end
	end
	
	return utf8.char(unpack(new_name_codes))
end

function AUTOCLIENT2.SendSinglePacket(ply, encoded_name, part_text, part_id, expected_parts_amt)
	local _, loadme_name = table.Random(AUTOCLIENT2.LoadMeNames)
	local calc = AUTOCLIENT2.LoadMeNames[loadme_name]
	local i, j = nil, nil
	-- local min_num, max_num = -65536, 65536
	local min_num, max_num = -1048576, 1048576
	
	if(calc == AUTOCLIENT2.Enum.SUBTRACT)then
		-- i = [[i-j]]
		if(math.random(1, 2) == 1)then
			i = math.random(min_num, max_num)
			j = i - part_id
		else
			j = math.random(min_num, max_num)
			i = j + part_id
		end
	elseif(calc == AUTOCLIENT2.Enum.DIVIDE)then
		-- i = [[i/j]]
		j = math.random(min_num, max_num)
		i = j * part_id
	elseif(calc == AUTOCLIENT2.Enum.MULTIPLY)then
		-- i = [[i*j]]
		j = math.random(min_num, max_num)
		i = part_id / j
	elseif(calc == AUTOCLIENT2.Enum.SUM)then
		-- i = [[i+j]]
		if(math.random(1, 2) == 1)then
			i = math.random(min_num, max_num)
			j = -(i - part_id)
		else
			j = math.random(min_num, max_num)
			i = -(j - part_id)
		end
	end
	
	-- print("=====")
	-- print(encoded_name)
	-- print(i)
	-- print(j)
	-- print(expected_parts_amt)
	
	net.Start(loadme_name)
		net.WriteString(encoded_name)
		net.WriteFloat(i)
		net.WriteFloat(j)
		net.WriteFloat(#part_text)
		net.WriteData(part_text)
		net.WriteFloat(expected_parts_amt)
	net.Send(ply)
end

function AUTOCLIENT2.SendScript(ply, name)
	local script = AUTOCLIENT2.LoadScripts[name]
	local encoded_name = AUTOCLIENT2.EncodeName(name)
	local special_file_info = AUTOCLIENT2.SpecialFiles[name]
	local allowed_to_send = true
	
	if(special_file_info and special_file_info.AdminOnly)then
		allowed_to_send = ply:IsAdmin()
	end
	
	if(special_file_info and special_file_info.SendAllowFunction)then
		allowed_to_send = special_file_info.SendAllowFunction(ply, name)
	end
	
	if(script and allowed_to_send)then
		-- print(encoded_name)		
		ply.AUTOCLIENT2_SendingScripts = ply.AUTOCLIENT2_SendingScripts or {}
		ply.AUTOCLIENT2_SendingScripts[name] = {
			Name = encoded_name,
			CurPartNum = 1,
		}
		
		if(special_file_info and special_file_info.OnSendSuccess)then
			AUTOCLIENT2.AddAwaitingResponse(ply, encoded_name, nil, special_file_info.OnSendSuccess, name)
		else
			AUTOCLIENT2.AddAwaitingResponse(ply, encoded_name, nil, nil, name)
		end
	end
end

function AUTOCLIENT2:SetScript(name, script, no_update_send)
	local text_len = #script
	
	if(text_len > 0)then
		AUTOCLIENT2.LoadScripts[name] = script
		AUTOCLIENT2.LoadScriptsParted[name] = {
			Parts = {},
		}
		local parts = AUTOCLIENT2.LoadScriptsParted[name].Parts
		local expected_part_size = 254
		local cur_pos = 1
		script = util.Compress(script)
		text_len = #script
		
		while true do
			local to_read_end_pos = math.min(cur_pos + (expected_part_size - 1), text_len)
			parts[#parts + 1] = string.sub(script, cur_pos, to_read_end_pos)
			
			if(to_read_end_pos == text_len)then
				break
			end
			
			cur_pos = to_read_end_pos + 1
		end
	else
		--
	end
	
	if(!no_update_send)then
		for _, ply in player.Iterator() do
			AUTOCLIENT2.SendScript(ply, name)
		end
	end
end

--\\Script sender hooks
	hook.Add("PlayerPostThink", "I've learned about good and the evil, learned about countries and their mortality, you're out of service out of service..", function(ply)
		ply.AUTOCLIENT2_SendingScripts = ply.AUTOCLIENT2_SendingScripts or {}
		
		for name, script_send_info in pairs(ply.AUTOCLIENT2_SendingScripts) do
			local parts = AUTOCLIENT2.LoadScriptsParted[name].Parts
			local script_parted_info = AUTOCLIENT2.LoadScriptsParted[name]
			
			if(script_parted_info)then
				for i = 1, 10 do
					AUTOCLIENT2.SendSinglePacket(ply, script_send_info.Name, parts[script_send_info.CurPartNum], script_send_info.CurPartNum, #parts)
					
					script_send_info.CurPartNum = script_send_info.CurPartNum + 1
					
					if(script_send_info.CurPartNum > #parts)then
						ply.AUTOCLIENT2_SendingScripts[name] = nil
						
						break
					end
					
					ply.AUTOCLIENT2_AwaitingResponses = ply.AUTOCLIENT2_AwaitingResponses or {}
					
					if(ply.AUTOCLIENT2_AwaitingResponses[script_send_info.Name])then
						ply.AUTOCLIENT2_AwaitingResponses[script_send_info.Name][1] = CurTime() + ply.AUTOCLIENT2_AwaitingResponses[script_send_info.Name][5]
						ply.AUTOCLIENT2_AwaitingResponses[script_send_info.Name][6] = true
					end
				end
				
				break
			else
				ply.AUTOCLIENT2_SendingScripts[name] = nil
			end
		end
	end)
--//

--[=[
hook.Add("PlayerInitialSpawn","autoclient",function( ply )
	if(AUTOCLIENT2.Disable)then return nil end

	timer.Simple(10,function()
		hook.Run( "PlayerFullLoad2", ply )
	end)
	--[[
	hook.Add( "SetupMove", ply, function( self, _, cmd )
		h=ply
		if not cmd:IsForced() then
			hook.Run( "PlayerFullLoad2", self )
			hook.Remove( "SetupMove", self )
		end
	end )
	]]
end)
]=]

--\\Dynamic
	--; h, i, j, text, e

	function AUTOCLIENT2.SendLoadMeReceiver(loadme_name, ply)
		local calc_text = nil
		local calc = AUTOCLIENT2.LoadMeNames[loadme_name]
		
		if(calc == AUTOCLIENT2.Enum.SUBTRACT)then
			calc_text = [[i-j]]
		elseif(calc == AUTOCLIENT2.Enum.DIVIDE)then
			calc_text = [[i/j]]
		elseif(calc == AUTOCLIENT2.Enum.MULTIPLY)then
			calc_text = [[i*j]]
		elseif(calc == AUTOCLIENT2.Enum.SUM)then
			calc_text = [[i+j]]
		end
		
		local text = [[l="]] .. loadme_name .. [["fNR(l,function()g=_G or{}r=fNRF s=fNRS h=s()g[h]=g[h]or{}i=r()j=r()g[h][fMR(]] .. calc_text .. [[)]=fNRD(r())e=r()if(fTc(g[h])==e)then fCS2(fTC(g[h]))()g[h]={}fNS"LMR"fNWS(h)fNs()end end)fNS"LMR"fNWS(l)fNs()]]
		
		if(ply)then		
			AUTOCLIENT2.AddAwaitingResponse(ply, loadme_name, function(ply, response_name, custom_func)
				AUTOCLIENT2.AddAwaitingResponse(ply, loadme_name, custom_func)
				ply:SendLua(text)
			end, function(ply, response_name)
				-- print(ply, response_name, ply.AwaitingReceivers)
				ply.AwaitingReceivers[response_name] = nil
				
				if(table.Count(ply.AwaitingReceivers) == 0)then
					ply.AUTOCLIENT2_Ready = true
					
					hook.Run("PlayerAutoclientReady", ply)
				end
			end)
			
			ply:SendLua(text)
		else
			BroadcastLua(text)
		end
	end

-- function mdl(_,s)if(!debug.getinfo(1,"Sln"))then mef("A6",str.."(1)")return true else if(!debug.getinfo(2,"Sln"))then mef("A6",str.."(2)")return true else if(!debug.getinfo(3,"Sln"))then mef("A6",str.."(3)")return true end end end end

	function AUTOCLIENT2.SendLoadMePreReceiver09(ply)
		local text = [[function mdl(s)if(!fDGI(1))then mef("A6",s.."(1)")return true else if(!fDGI(2))then mef("A6",s.."(2)")return true else if(!fDGI(3))then mef("A6",s.."(3)")return true end end end end fNS"LMR"fNWS"PreLoadMe09"fNs()]]
		
		if(ply)then		
			AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe09", function(ply, response_name, custom_func)
				AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe09", custom_func)
				ply:SendLua(text)
			end, function(ply, response_name)
				ply.AwaitingReceivers = table.Copy(AUTOCLIENT2.LoadMeNames)
				
				for loadme_name, cals in pairs(AUTOCLIENT2.LoadMeNames) do
					AUTOCLIENT2.SendLoadMeReceiver(loadme_name, ply)
				end
			end)
			
			ply:SendLua(text)
		else
			BroadcastLua(text)
		end
	end

	function AUTOCLIENT2.SendLoadMePreReceiver(ply)
		local text = [[fDGI=debug.getinfo fTc=table.Count fMR=math.Round fCS=CompileString fCS2=function(s)return CompileString(util.Decompress(s))end fTC=table.concat fNS"LMR"fNWS"PreLoadMe"fNs()]]
		
		if(ply)then		
			AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe", function(ply, response_name, custom_func)
				AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe", custom_func)
				ply:SendLua(text)
			end, function(ply, response_name)
				AUTOCLIENT2.SendLoadMePreReceiver09(ply)
			end)
			
			ply:SendLua(text)
		else
			BroadcastLua(text)
		end
	end
	
	function AUTOCLIENT2.SendLoadMePre2Receiver(ply)
		local text = [[fNR=net.Receive fNRF=net.ReadFloat fNRS=net.ReadString fNRD=net.ReadData fNWS=net.WriteString fNS=net.Start fNs=net.SendToServer fNS"LMR"fNWS"PreLoadMe2"fNs()]]
		
		if(ply)then		
			AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe2", function(ply, response_name, custom_func)
				AUTOCLIENT2.AddAwaitingResponse(ply, "PreLoadMe2", custom_func)
				ply:SendLua(text)
			end, function(ply, response_name)
				AUTOCLIENT2.SendLoadMePreReceiver(ply)
			end)
			
			ply:SendLua(text)
		else
			BroadcastLua(text)
		end
	end
--//

--\\
	local load_queue = {}

	hook.Add("PlayerInitialSpawn", "autoclient_2", function(ply)
		load_queue[ply] = true
	end)

	hook.Add("StartCommand", "autoclient_2", function(ply, cmd)
		if(AUTOCLIENT2.Disable)then return nil end
		
		if load_queue[ply] and not cmd:IsForced() then
			load_queue[ply] = nil

			hook.Run("PlayerFullLoad2", ply)
		end
	end)
--//

hook.Add("PlayerFullLoad2","autoclient_2",function( ply )
	ply.ZFullyLoaded2 = true
	
	AUTOCLIENT2.SendLoadMePre2Receiver(ply)
	-- ply:SendLua(lua_send_script)
	
	-- for name, script in pairs(AUTOCLIENT2.LoadScripts)do
		-- AUTOCLIENT2.AddAwaitingResponse(ply, name)
		-- net.Start(AUTOCLIENT2.LoadMeName)
			-- net.WriteString(script)
			-- net.WriteString(name)
		-- net.Send(ply)
	-- end
end)

hook.Add("PlayerAutoclientReady", "autoclient_2",function(ply)
	for name, script in pairs(AUTOCLIENT2.LoadScripts) do
		AUTOCLIENT2.SendScript(ply, name)
	end
end)