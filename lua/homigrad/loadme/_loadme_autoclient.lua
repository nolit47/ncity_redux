AUTOCLIENT={}
AUTOCLIENT.Disable = false
AUTOCLIENT.LoadScripts = {}
AUTOCLIENT.ResponseCheckCD = 2
AUTOCLIENT.SendLuaResponseCheckCD = 120

util.AddNetworkString('LoadMe_Response')
util.AddNetworkString('SendLua_Response')

--\\Niggalink Fix
--; J_ = 1 / 0

-- OLD_BroadcastLua = OLD_BroadcastLua or BroadcastLua

-- function BroadcastLua(text, ...)
	-- text = "J_=1;" .. text .. ";J_=0" .. ";if(_J)then _J()end"
	
	-- return OLD_BroadcastLua(text, ...)
-- end

-- local player_meta = FindMetaTable("Player")

-- player_meta.OLD_SendLua = player_meta.OLD_SendLua or player_meta.SendLua

-- function player_meta.SendLua(self, text, ...)
	-- text = "J_=1;" .. text .. ";J_=0" .. ";if(_J)then _J()end"
	
	-- return player_meta.OLD_SendLua(self, text, ...)
-- end
--//

local lua_send_script = "net.Receive('LoadMe',function() func=net.ReadString() J_=1; RunString(func) ;J_=0; end)"
local lua_send_script_ac = [[net.Receive('LoadMe',function()J_=1;RunString(net.ReadString());J_=0;net.Start("LoadMe_Response")net.WriteString(net.ReadString())net.SendToServer()end)]]
lua_send_script = lua_send_script_ac	--; AntiCheat
-- lua_send_script = "J_=1;" .. lua_send_script .. "J_=0"
ZMaxInvalidResponses = 3

BroadcastLua(lua_send_script)

net.Receive('LoadMe_Response',function(len, ply)
	response_name = net.ReadString()
	ply.AUTOCLIENT_AwaitingResponses = ply.AUTOCLIENT_AwaitingResponses or {}
	ply.AUTOCLIENT_AwaitingResponses[response_name] = nil
	
	if(table.Count(ply.AUTOCLIENT_AwaitingResponses) == 0)then
		ply.ZNetInvalidResponses = 0
	end
end)

net.Receive('SendLua_Response',function(len, ply)
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

function AUTOCLIENT.ProcessInvalidResponses(ply)
	if(!AUTOCLIENT_NoKick and !ply:IsAdmin())then
		local total_invalid_responses = (ply.ZSendLuaInvalidResponses or 0) + (ply.ZNetInvalidResponses or 0)
		
		if(total_invalid_responses > ZMaxInvalidResponses)then
			ply:Kick("No response after 4 retries")
		end
	end
end

hook.Add("PlayerPostThink", "AUTOCLIENT_Responses", function(ply)
	if(ply.AUTOCLIENT_AwaitingResponses)then
		if(!ply.AUTOCLIENT_AwaitingResponsesNextCheck or ply.AUTOCLIENT_AwaitingResponsesNextCheck <= CurTime())then
			ply.AUTOCLIENT_AwaitingResponsesNextCheck = CurTime() + AUTOCLIENT.ResponseCheckCD
			
			for response_name, time_expires in pairs(ply.AUTOCLIENT_AwaitingResponses) do
				if(time_expires <= CurTime())then
					if(ply.AUTOCLIENT_AwaitingResponseValid)then
						ply.AUTOCLIENT_AwaitingResponseValid = false
						ply.ZNetInvalidResponses = (ply.ZNetInvalidResponses or 0) + 1
					end
					
					local total_invalid_responses = (ply.ZSendLuaInvalidResponses or 0) + (ply.ZNetInvalidResponses or 0)
				
					if(DOG and DOG.ACheat)then
						DOG.ACheat:NotifyAdmins("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") (D) Игрок " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Не ответил на загрузку кода нетом вовремя (" .. response_name .. ")")
					else
						print("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") ACheat; Player " .. ply:Nick() .. "Haven't responded for net load in time")
					end
					
					if(AUTOCLIENT.LoadScripts[response_name])then
						net.Start('LoadMe')
							net.WriteString(AUTOCLIENT.LoadScripts[response_name])
							net.WriteString(response_name)
						net.Broadcast()
						
						AUTOCLIENT.AddAwaitingResponse(ply, response_name)
					end
					
					AUTOCLIENT.ProcessInvalidResponses(ply)
					
					ply.AUTOCLIENT_AwaitingResponses = nil
					
					break
				end
			end
		end
	end
	
	if(ply.ZFullyLoaded and !ply:IsBot())then
		if(!ply.ZCheckForSendLuaResponseTime or ply.ZCheckForSendLuaResponseTime <= CurTime())then
			ply.ZCheckForSendLuaResponseTime = CurTime() + AUTOCLIENT.SendLuaResponseCheckCD
			ply.ZCheckForSendLuaResponseString = RandomString(3, 7)
			ply.ZCheckForSendLuaResponseExpireTime = CurTime() + 60
			
			ply:SendLua([[net.Start("SendLua_Response")net.WriteString("]] .. ply.ZCheckForSendLuaResponseString .. [[")net.SendToServer()]])
		end
		
		if(ply.ZCheckForSendLuaResponseExpireTime and ply.ZCheckForSendLuaResponseExpireTime <= CurTime())then
			ply.ZCheckForSendLuaResponseExpireTime = nil
			ply.ZSendLuaInvalidResponses = (ply.ZSendLuaInvalidResponses or 0) + 1
			local total_invalid_responses = ply.ZSendLuaInvalidResponses + (ply.ZNetInvalidResponses or 0)
			
			if(DOG and DOG.ACheat)then
				DOG.ACheat:NotifyAdmins("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") (D) Игрок " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Не ответил на SendLua() вовремя")
			else
				print("(" .. total_invalid_responses .. "/" .. ZMaxInvalidResponses .. ") ACheat; Player " .. ply:Nick() .. "Haven't responded for SendLua() in time")
			end
			
			AUTOCLIENT.ProcessInvalidResponses(ply)
		end
	end
end)

function AUTOCLIENT.AddAwaitingResponse(ply, name)
	if(ply:IsBot())then
		--
	else
		ply.AUTOCLIENT_AwaitingResponseValid = true
		ply.AUTOCLIENT_AwaitingResponses = ply.AUTOCLIENT_AwaitingResponses or {}
		ply.AUTOCLIENT_AwaitingResponses[name] = CurTime() + 60
	end
end

function AUTOCLIENT:SetScript(name, script, server_side)
	AUTOCLIENT.LoadScripts[name] = script
	
	for _, ply in player.Iterator() do
		AUTOCLIENT.AddAwaitingResponse(ply, name)
	end
	
	net.Start('LoadMe')
		net.WriteString(script)
		net.WriteString(name)
	net.Broadcast()
end

--[=[
hook.Add("PlayerInitialSpawn","autoclient",function( ply )
	if(AUTOCLIENT.Disable)then return nil end

	timer.Simple(10,function()
		hook.Run( "PlayerFullLoad", ply )
	end)
	--[[
	hook.Add( "SetupMove", ply, function( self, _, cmd )
		h=ply
		if not cmd:IsForced() then
			hook.Run( "PlayerFullLoad", self )
			hook.Remove( "SetupMove", self )
		end
	end )
	]]
end)
]=]

--\\
local load_queue = {}

hook.Add("PlayerInitialSpawn", "autoclient_1", function(ply)
	load_queue[ply] = true
end)

hook.Add("StartCommand", "autoclient_1", function(ply, cmd)
	if(AUTOCLIENT.Disable)then return nil end
	
	if load_queue[ply] and not cmd:IsForced() then
		load_queue[ply] = nil

		hook.Run("PlayerFullLoad", ply)
	end
end)
--//

hook.Add("PlayerFullLoad","autoclient_1",function( ply )
	ply.ZFullyLoaded = true
	
	ply:SendLua(lua_send_script)
	
	for name, script in pairs(AUTOCLIENT.LoadScripts)do
		AUTOCLIENT.AddAwaitingResponse(ply, name)
		net.Start('LoadMe')
			net.WriteString(script)
			net.WriteString(name)
		net.Send(ply)
	end
end)