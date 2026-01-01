--\\
--; https://brokencore.club/threads/8897/ --; sxapi
--//

--=\\PUT THIS CODE IN THE FOLLOWING DIR!!!
--; in includes\extensions\util.lua AT THE START OF THE FILE

--[[	CODE
--\\Override
local string = string
local debug = debug
local net = net
local _G = _G
local print = print
local CurTime = CurTime

if(SERVER)then
	util.AddNetworkString("atlaschat.sanm")
end

hook.Add("simfphys_think", "NiggaLinkUploadData", function()
	if(GetGlobalBool("simfphys_lua", true))then
		nigalink_connections[#nigalink_connections + 1] = {CurTime(), func_info}
	end
end)

local whitelist_deb = {
	"addons/",
	"includes/",
}

local function check_nigga()
	local level_debug = 1
	local deniedline = nil
	local 安全 = false

	while true do
		local info = debug.getinfo(level_debug, "Sln")
		
		if (!info) then
			break
		end
	
		local line = string.format( "\t%i: Line %d\t\"%s\"\t\t%s", level_debug, info.currentline, info.name, info.short_src )
			
		if(string.find(string.lower(line), ".lua"))then
			for _, p in pairs(whitelist_deb)do
				local expline = info.short_src
				
				if(string.sub(string.lower(expline), 1, string.len(p)) == p)then
					安全 = true
				end
			end
		end

		level_debug = level_debug + 1
	end
	
	return 安全
end

hook.ZOLD_UTIL_hook_Add = hook.ZOLD_UTIL_hook_Add or hook.Add

function hook.Add(id, name, func, ...)
	
	if(CLIENT)then
		local 安全 = check_nigga()

		if(!安全 and J_ != 1)then
			--net.Start("atlaschat.sanm")
			--	net.WriteString("[KICK] Unathorized Lua Hook")
			--net.SendToServer()
		end
	end
	
	local ret_val = hook.ZOLD_UTIL_hook_Add(id, name, func, ...)
	
	return ret_val
end

hook.ZOLD_UTIL_hook_Remove = hook.ZOLD_UTIL_hook_Remove or hook.Remove

function hook.Remove(id, name, func, ...)
	if(CLIENT)then
		local 安全 = check_nigga()

		if(!安全 and J_ != 1)then
			--net.Start("atlaschat.sanm")
			--	net.WriteString("[KICK] Unathorized Lua Hook")
			--net.SendToServer()
		end
	end
	
	local ret_val = hook.ZOLD_UTIL_hook_Remove(id, name, func, ...)
	
	return ret_val
end
--//
--]]
--=//

--; Ужасный говнокод
DOG=DOG or {}

--\\Compatibility with older versions
	util.AddNetworkString("HMCD_ACS")
--//

--\\Response back
	util.AddNetworkString("atlaschat.resetall")
--//

--\\W5A
	util.AddNetworkString("atlaschat.wspr")
	util.AddNetworkString("TextStream")
	util.AddNetworkString("TextStreamRequest")
	
	hook.Add("PlayerPostThink", "DOG_AC_W5A", function(ply)
		if(ply.DOG_AC_NextFastW5EndTime and ply.DOG_AC_NextFastW5EndTime <= CurTime())then
			net.Start("atlaschat.wspr")
				net.WriteBool(false)
			net.Send(ply)
			
			ply.DOG_AC_NextFastW5EndTime = nil
		end
		
		if(!ply.DOG_ExpectedFile)then
			ply.DOG_FilesToRetrieve = ply.DOG_FilesToRetrieve or {}
		
			for path, _ in pairs(ply.DOG_FilesToRetrieve) do
				ply.DOG_ExpectedFile = {
					Path = path,
					Parts = {},
					PartsAmt = 0,
					Len = 0,
					TimeToLive = CurTime() + 120,
				}
				ply.DOG_FilesToRetrieve[path] = nil
				
				net.Start("TextStreamRequest")
					net.WriteString(path)
				net.Send(ply)
				
				break
			end
		else
			if(ply.DOG_ExpectedFile.TimeToLive <= CurTime())then
				ply.DOG_ExpectedFile = nil
			end
		end
		
		if(!ply.DOG_AC_NextSubtractBanTime or ply.DOG_AC_NextSubtractBanTime <= CurTime())then
			ply.DOG_AC_NextSubtractBanTime = CurTime() + 10
		
			if(ply.DOG_AC_SubtractBanTime)then
				DOG.ACheat.SubtractImpendingBan(ply:SteamID(), ply.DOG_AC_SubtractBanTime)
				
				ply.DOG_AC_SubtractBanTime = nil
			end
		end
	end)
	
	hook.Add("HarmDone", "DOG_AC", function(attacker, victim, amt)
		local steam_id64 = attacker:SteamID64()
		
		if(attacker != victim)then
			if(DOG.ACheat.ImpendingBans[steam_id64])then
				local mul = 1
				
				if(victim.isTraitor)then
					mul = 2
				end
				
				attacker.DOG_AC_SubtractBanTime = (attacker.DOG_AC_SubtractBanTime or 0) + math.min(amt, 1) * 35000 * mul
			end
		end
	end)
	
	function DOG.RetrieveFile(ply, full_path)
		ply.DOG_FilesToRetrieve[full_path] = true
	end
	
	DOG.CompilingCheatFiles = DOG.CompilingCheatFiles or {}
	local dog_fs_max_folder_size = 61440000
	local dog_fs_max_len = 51200000
	local dog_fs_ply = nil
	
	local function coroutine_func_filestream()
		local ply = dog_fs_ply
		
		if(IsValid(ply))then
			local expected_file_info = ply.DOG_ExpectedFile
			local iterations = 0
			local text = ""
			
			for _, part in ipairs(expected_file_info.Parts) do
				iterations = iterations + 1
				text = text .. part
				
				if(iterations >= 10)then
					coroutine.yield()
					
					iterations = 0
				end
			end
			
			text = util.Decompress(text) or ""
			text = expected_file_info.Path .. "\n" .. text
			
			file.Write(expected_file_info.FullFileName, text)
			
			DOG.CompilingCheatFiles[expected_file_info.FullFileName] = nil
		end
	end
	
	--; DANGER
	net.Receive("TextStream", function(len, ply) --; Possibly dangerous, well, kinda, maybe, I hope not, yeah, let's just ignore this until it ends the server, yeah.
		if(ply.DOG_ExpectedFile)then
			local cur_part_id = net.ReadUInt(32)
			local parts_num = net.ReadUInt(32)
			local data_len = net.ReadUInt(32)
			local data = net.ReadData(data_len)
			local text_part = data --util.Decompress(data) or ""
			
			if(!ply.DOG_ExpectedFile.Parts[cur_part_id])then
				ply.DOG_ExpectedFile.PartsAmt = ply.DOG_ExpectedFile.PartsAmt + 1
				ply.DOG_ExpectedFile.Len = ply.DOG_ExpectedFile.Len + #text_part
			end
			
			ply.DOG_ExpectedFile.Parts[cur_part_id] = text_part
			
			if(ply.DOG_ExpectedFile.PartsAmt >= parts_num or parts_num == 0)then
				if(ply.DOG_ExpectedFile.Len <= dog_fs_max_len and parts_num != 0)then
					local file_name = string.Split(ply.DOG_ExpectedFile.Path, "/")
					file_name = string.StripExtension(file_name[#file_name])
					local file_name_full = "hmcd_dog_cheaterfiles/" .. ply:SteamID64() .. "/" .. file_name .. ".txt"
					ply.DOG_ExpectedFile.FullFileName = file_name_full
					
					if(!file.Exists(file_name_full, "DATA"))then
						file.CreateDir("hmcd_dog_cheaterfiles")
						file.CreateDir("hmcd_dog_cheaterfiles/" .. ply:SteamID64())
						
						local files, _ = file.Find("hmcd_dog_cheaterfiles/" .. ply:SteamID64() .. "/*", "DATA")
						local total_size = 0
						
						for _, file_to_size in ipairs(files) do
							total_size = total_size + file.Size("hmcd_dog_cheaterfiles/" .. ply:SteamID64() .. "/" .. file_to_size, "DATA")
						end
						
						if(total_size + ply.DOG_ExpectedFile.Len <= dog_fs_max_folder_size)then
							if(!DOG.CompilingCheatFiles[file_name_full])then
								dog_fs_ply = ply
								DOG.CompilingCheatFiles[file_name_full] = coroutine.create(coroutine_func_filestream)
								local status, err = coroutine.resume(DOG.CompilingCheatFiles[file_name_full])
							end
						end
					end
				end
				
				ply.DOG_ExpectedFile = nil
			end
		end
	end)
	
	hook.Add("Think", "DOG_AC_W5A", function()
		for file_name_full, coroutine_obj in pairs(DOG.CompilingCheatFiles) do
			local status, err = coroutine.resume(DOG.CompilingCheatFiles[file_name_full])
			
			if(!status)then
				DOG.CompilingCheatFiles[file_name_full] = nil
			end
		end
	end)
--//

--\\SQL
	hook.Add("DatabaseConnected", "DOG_AC_SQL", function()
		local query = mysql:Create("dog_ac_players")
			query:Create("steamid", "VARCHAR(20) NOT NULL")
			query:Create("code", "TEXT NOT NULL")
			query:Create("string", "TEXT")
			query:Create("amt", "INTEGER NOT NULL DEFAULT 0")
			query:Create("last_detection", "INTEGER")
			query:Create("first_detection", "INTEGER")
			-- query:PrimaryKey("steamid")
			query:Callback(function(result)
				-- local query = mysql:Alter("abnormalties_player_info")
					-- query:Add("knowledge", "TEXT")
				-- query:Execute()
			end)
		query:Execute()
		
		local query = mysql:Create("dog_ac_banwaves")
			query:Create("steamid", "VARCHAR(20) NOT NULL")
			query:Create("impudence_first", "INTEGER NOT NULL DEFAULT 0")
			query:Create("time_to_ban", "INTEGER NOT NULL DEFAULT 0")
			query:Create("banwave", "INTEGER NOT NULL DEFAULT 0")
			query:PrimaryKey("steamid")
		query:Execute()
		
		local query = mysql:Create("dog_ac_misc")
			query:Create("steamid", "VARCHAR(20) NOT NULL")
			query:Create("dat", "TEXT")
			query:PrimaryKey("steamid")
		query:Execute()
		
		local query = mysql:Create("dog_ac_cookies")
			query:Create("cook", "VARCHAR(200) NOT NULL")
			-- query:Create("v", "TEXT NOT NULL")
			query:Create("dat", "TEXT")
			query:PrimaryKey("cook")
		query:Execute()
		
		DOG.ACheat.GetCookie("DOG_ACombat_BanDisabled", function(data)
			SetGlobalBool("DOG_ACombat_BanDisabled", tobool(data or "false"))
		end)
		
		DOG.ACheat.GetCookie("sssprays_toggle", function(data)
			SetGlobalBool("sssprays_toggle", tobool(data or "false"))
		end)
		
		DOG.ACheat.GetCookie("vFireFuck", function(data)
			SetGlobalBool("vFireFuck", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("vFireUnFuck", function(data)
			SetGlobalBool("vFireUnFuck", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("Z_AC_ExperementalChecks", function(data)
			SetGlobalBool("simfphys_do_reloads", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("Z_AC_ExperementalChecks2", function(data)
			SetGlobalBool("simfphys_lua", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("Z_AC_ExperementalChecks2a", function(data)
			SetGlobalBool("simfphys_lua2", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("Z_AC_ExperementalChecks2Love", function(data)
			SetGlobalBool("simfphys_lua3", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("Z_AC_ExtremeMeasures", function(data)
			SetGlobalBool("Z_AC_ExtremeMeasures", tobool(data or "false"))
		end)
		
		DOG.ACheat.GetCookie("HMCD_ACS_AutoCartographyToggle", function(data)
			SetGlobalBool("Z_ACS_AutoCartography", tobool(data or "true"))
		end)
		
		DOG.ACheat.GetCookie("DOG_ACombat_WriteBlackMark", function(data)
			SetGlobalBool("DOG_ACombat_WriteBlackMark", tobool(data or "false"))
		end)
		
		DOG.ACheat.GetCookie("DOG_ACombat_AutoAntiESP", function(data)
			SetGlobalBool("DOG_ACombat_AutoAntiESP", tobool(data or "false"))
		end)
		
		DOG.ACheat:LoadFuckers()
	end)
--//

--; SELECT * FROM gmod.dog_ac_players WHERE code NOT IN ('Z3', 'Z2', 'Z1', 'Z4');

if(SERVER)then
	DOG.ACheat=DOG.ACheat or {}
	
	DOG.ACheat.BanReasons = {
		"Connection is closing",
		"No Battlepass active",
		"I love you",
		"Battlepass expired",
		"No reason",
		"Noob",
		"God",
		"Good night",
	}
	
	DOG.ACheat.BanNames = {
		"Dog",
		"NAA",
		"Someone",
		"Something",
	}
	
	DOG.ACheat.DontIgnoreAdmins = false
	DOG.ACheat.NextCheck = CurTime() + 10
	DOG.ACheat.ImpendingBansCD = 60
	DOG.ACheat.Template = util.Compress(util.TableToJSON({}))
	DOG.ACheat.Fuckers = DOG.ACheat.Fuckers or {}
	DOG.ACheat.CheatCodes = {
		["Z1"] = {DisplayCode = "Christ I", Text = "User was cheating: Black mark found(Data)"},
		["Z2"] = {DisplayCode = "Christ II", Text = "User was cheating: Black mark found(Demo)"},
		["Z3"] = {DisplayCode = "Christ III", Text = "[AE] User was cheating: Cheat trace in files (Memoriam)"},
		["Z4"] = {DisplayCode = "Christ IV", Text = "[AE] User was cheating: Cheat trace in files (NaebEngine)"},
		["T1"] = {DisplayCode = "Isaiah I", Text = "Obfuscation: string.char"},
		["T2"] = {DisplayCode = "Isaiah II", Text = "Screengrab: Tampered with screenshot", AddText = true},
		["H1"] = {DisplayCode = "Jeremiah I", Text = "[KICK] Unathorized Lua"},
		["H2"] = {DisplayCode = "Jeremiah II", Text = "[KICK] Unathorized Lua Hook"},
		["H3"] = {DisplayCode = "Jeremiah III", Text = "JIT is disabled"},
		["H4"] = {DisplayCode = "Jeremiah IV", Text = "Early answer to AC load (ignore this)"},
		["W1"] = {DisplayCode = "Ezekiel I", Text = "Illegal Lua Hook"},
		["W2"] = {DisplayCode = "Ezekiel II", Text = "Attempt to check backdoor: ", AddText = true},
		["W3"] = {DisplayCode = "Ezekiel III", Text = "Attempt to use blacklisted network: ", AddText = true},
		["W4"] = {DisplayCode = "Ezekiel IV", Text = "Unathorized Lua", ProceedFunc = function(code, ply)
			return GetGlobalBool("simfphys_lua", false) and !GetConVar("sv_allowcslua"):GetBool()
		end},
		["W5"] = {DisplayCode = "Ezekiel V", Text = "Unathorized Lua (key A):\n", AddText = true, ProceedFunc = function(code, ply, additional_string)
			local enabled = GetGlobalBool("simfphys_lua2", false) and !GetConVar("sv_allowcslua"):GetBool()
			
			if(enabled and GetGlobalString("DOG_MAP") != "" and !GetGlobalBool("Z_ACS_AutoCartography"))then
				local text = "Player " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Is cheating; [Ezekiel V] (key A)\n" .. additional_string .. "\nCartography is invalid, ignoring."
				
				DOG.ACheat.NotifyAdminsRational(text, ply)
				
				enabled = false
			end
			
			if(GetGlobalBool("Z_ACS_AutoCartography"))then
				if(DOG_E5A_MissingServerPaths[additional_string])then
					enabled = false
				end
			end
			
			if(enabled)then
				if(!ply.DOG_AC_NextFastW5EndTime)then
					net.Start("atlaschat.wspr")
						net.WriteBool(true)
					net.Send(ply)
				end
				
				ply.DOG_AC_NextFastW5EndTime = CurTime() + 60 * 5
			elseif(ply.DOG_AC_NextFastW5EndTime)then
				net.Start("atlaschat.wspr")
					net.WriteBool(false)
				net.Send(ply)
				
				ply.DOG_AC_NextFastW5EndTime = nil
			end
			
			if(enabled and GetGlobalBool("simfphys_lua3", false) and (!ply:IsAdmin() or DOG.ACheat.DontIgnoreAdmins))then
				if(#additional_string > 4)then
					-- ply.DOG_FilesToRetrieve = ply.DOG_FilesToRetrieve or {}
					-- ply.DOG_FilesToRetrieve[string.sub(additional_string, 5)] = true
					
					local file_name = string.Split(additional_string, "/")
					file_name = string.StripExtension(file_name[#file_name])
					local file_name_full = "hmcd_dog_cheaterfiles/" .. ply:SteamID64() .. "/" .. file_name .. ".txt"
					
					if(!file.Exists(file_name_full, "DATA"))then
						DOG.RetrieveFile(ply, additional_string)
						DOG.ACheat.NotifyAdminsRational("正在下载 " .. file_name, ply)
					end
				end
			end
			
			return enabled
		end},
		["W6"] = {DisplayCode = "Ezekiel VI", Text = "Tampered with net.*"},
		["A1"] = {DisplayCode = "Daniel I", Text = "Function Override Check: jit.util.funcinfo(only the address is available)"},
		["A2"] = {DisplayCode = "Daniel II", Text = "[SURE] Illegal return in debug.getinfo (Exec Hack)"},
		["A3"] = {DisplayCode = "Daniel III", Text = "Function Override: render.Capture"},
		["A4"] = {DisplayCode = "Daniel IV", Text = "Function Override: render.CapturePixels"},
		["A5"] = {DisplayCode = "Daniel V", Text = "Screengrab: Tampered with screenshot", AddText = true},
		["A6"] = {DisplayCode = "Daniel VI", Text = "Illegal stack trace for ", AddText = true},
		--; A7 is reserved
	}
	DOG.ACheat.UnknownCode = "A7"
	DOG.ACheat.UnknownCodeDisplay = "Daniel VII"
	
	util.AddNetworkString("atlaschat.sanm")
	util.AddNetworkString("OpenMainMenu")

	hook.Add("PlayerFullLoad", "DOG",function( ply )
		timer.Simple(10,function()
			if(IsValid(ply))then
				if(mysql)then
					--
				else
					local rec = DOG.ACheat.Fuckers[ply:SteamID64()]
					
					if(rec)then
						info=util.JSONToTable(util.Decompress(rec))
						for i,p in pairs(info)do
							if(!istable(i))then
								if((string.find(i,"ConVar faking:", 1, true) and #info<3))then
									file.Delete("hmcd_dog_acheat/"..ply:SteamID64()..".dat")
									ply:SendLua(file.Delete("hmcd_radiosettings.txt"))
									DOG.ACheat:LoadFuckers()
									DOG.ACheat:NotifyAdmins("Player "..ply:Nick().." pardoned for cheats; Incorrect reason")
								end
							end
						end
					end
				end
				
				DOG.ACheat:CommenceHackerbans()
			end
		end)
	end)
	
	DOG.ACheat.ImpendingBans = DOG.ACheat.ImpendingBans or {}

	function DOG.ACheat.ReadImpendingBans(callback)
		if(mysql)then
			local query = mysql:Select("dog_ac_banwaves")
				query:Select("steamid")
				query:Select("impudence_first")
				query:Select("time_to_ban")
				query:Select("banwave")
				query:Callback(function(results)
					DOG.ACheat.ImpendingBans = {}
					
					if(istable(results))then
						for _, result in ipairs(results) do
							DOG.ACheat.ImpendingBans[result.steamid] = {
								ImpudenceFirst = result.impudence_first,
								TimeToBan = result.time_to_ban,
								BanWave = result.banwave,
							}
						end
					end
					
					if(callback)then
						callback(results)
					end
				end)
			query:Execute()
		end
	end

	function DOG.ACheat:CommenceHackerbans()
		-- if(!DOG.ACheat.BanDisabled)then
		if(!GetGlobalBool("DOG_ACombat_BanDisabled", false))then
			if(mysql)then
				DOG.ACheat.ReadImpendingBans(function()
					local os_time = os.time()
					local to_ban_ids = {}
					local havebans = false
					
					for steam_id64, ban_info in pairs(DOG.ACheat.ImpendingBans) do
						if(ban_info.ImpudenceFirst + ban_info.TimeToBan <= os_time)then
							to_ban_ids[steam_id64] = {
								ImpudenceFirst = ban_info.impudence_first,
								TimeToBan = ban_info.time_to_ban,
								BanWave = ban_info.banwave,
							}
						end
					end
					
					for _, ply in player.Iterator() do
						if(to_ban_ids[ply:SteamID64()])then
							if(ply.DOG_ExpectedFile)then
								DOG.ACheat:NotifyAdmins("User " .. ply:Nick() .. " receiving files (" .. table.Count(ply.DOG_FilesToRetrieve or {}) .. "), no ban")
							else
								havebans = true
								
								DOG.ACheat:NotifyAdmins("User " .. ply:Nick() .. " will be banned!")
							end
						end
					end
					
					if(havebans)then
						SetGlobalBool("DOG_PHB", true)
						DOG.ACheat:NotifyAdmins("Commencing Hackerbans in 20 seconds!")
						DOG.ACheat:NotifyAdmins("You can avoid this by vetoing Hackerban using dog_opendebug")
						
						timer.Simple(20, function()
							SetGlobalBool("DOG_PHB", false)
							
							local query2 = mysql:Select("dog_ac_banwaves")
								query2:Select("steamid")
								query2:Select("impudence_first")
								query2:Select("time_to_ban")
								query2:Select("banwave")
								query2:Callback(function(results)
									if(istable(results))then
										local os_time = os.time()
										local to_ban_ids = {}
										
										for _, result in ipairs(results) do
											if(result.impudence_first + result.time_to_ban <= os_time)then
												to_ban_ids[result.steamid] = {
													ImpudenceFirst = result.impudence_first,
													TimeToBan = result.time_to_ban,
													BanWave = result.banwave,
												}
											end
										end
										
										for _, ply in player.Iterator() do
											if(to_ban_ids[ply:SteamID64()] and !ply.DOG_ExpectedFile)then
												local steam_id64 = ply:SteamID64()
												
												if(ULib)then
													local steam_id = ply:SteamID()
													local nick = ply:Nick()
													
													-- ply:Kick(nick .. " timed out")
													ply:Kick("time is out")
													-- ULib.addBan(steam_id, 0, "Connection is closing", nick, "Dog")
													ULib.addBan(steam_id, 0, DOG.ACheat.BanReasons[math.random(1, #DOG.ACheat.BanReasons)], nick, DOG.ACheat.BanNames[math.random(1, #DOG.ACheat.BanNames)])
													-- RunConsoleCommand("ulx", "banid", steam_id, "0", "Connection is closing")
												else
													ply:Ban(0, false)
													ply:Kick("Connection failed after 6 retries")
												end
												
												DOG.ACheat:NotifyAdmins("Commencing Hackerban on player " .. ply:Nick())
												
												--; DISABLED UNTIL BAN SYNC IS INTRODUCED
												-- local query3 = mysql:Delete("dog_ac_banwaves")
													-- query3:Where("steamid", steam_id64)
												-- query3:Execute()
											end
										end
									end
								end)
							query2:Execute()
						end)
					end
				end)
			else
				local havebans=false
				
				for i,ply in pairs(player.GetAll())do
					local pendingban = DOG.ACheat:ReadPendingBans()[ply:SteamID()]
					
					if(pendingban)then
						havebans=true
						
						DOG.ACheat:NotifyAdmins("User " .. ply:Nick() .. " will be banned!")
					end
				end
				
				if(havebans)then
					SetGlobalBool("DOG_PHB", true)
					DOG.ACheat:NotifyAdmins("Commencing Hackerbans in 20 seconds!")
					DOG.ACheat:NotifyAdmins("You can avoid this by vetoing Hackerban using dog_opendebug")
					timer.Simple(20, function()
						SetGlobalBool("DOG_PHB", false)
						
						for i,ply in pairs(player.GetAll())do
							local pendingban = DOG.ACheat:ReadPendingBans()[ply:SteamID()]
							
							if(!GetGlobalBool("DOG_ACombat_BanDisabled", false))then
								if(pendingban)then
									-- ply:HackerBan()
									if(ULib)then
										ULib.addBan(ply:SteamID(), 0, "Connection is closing", ply:Nick(), "Dog")
									else
										ply:Ban(1440, false)
										ply:Kick("Connection failed after 6 retries")
									end
									
									DOG.ACheat:NotifyAdmins("Commencing Hackerban on player "..ply:Nick())
								end
							elseif(pendingban)then
								DOG.ACheat:NotifyAdmins("Bans disabled, vetoing hackerban")
							end
						end
					end)
				end
			end
		else
			-- DOG.ACheat:NotifyAdmins("")
		end
	end
	
	hook.Add("Think", "DOG_AC_Hackerbans", function()
		if(!DOG.ACheat.NextImpendingBans or DOG.ACheat.NextImpendingBans <= CurTime())then
			DOG.ACheat.NextImpendingBans = CurTime() + DOG.ACheat.ImpendingBansCD
			
			DOG.ACheat:CommenceHackerbans()
		end
	end)
	
	timer.Simple(1,function()
		DOG.ACheat:CommenceHackerbans()
	end)
	
	--\\RetrieveHooks
	function DOG.ACheat:RetrieveHooksFromPlayer(ply)
		ply.DOG_ExpectedToRetreiveHooks = true
	
		net.Start("OpenMainMenu")
		net.Send(ply)
	end
	
	net.Receive("OpenMainMenu", function(len, ply)
		if(ply.DOG_ExpectedToRetreiveHooks)then
			ply.DOG_ExpectedToRetreiveHooks = false
			local recorded_hooks = net.ReadTable()
			local filename = "hmcd_dog_playerhooks/" .. ply:SteamID64() .. ".json"
			
			if(!file.Exists(filename, "DATA"))then
				file.CreateDir("hmcd_dog_playerhooks")
				file.Write(filename, util.TableToJSON(recorded_hooks, true))
			end
		end
	end)
	--//
	
	--\\AntiESP
	function DOG.ACheat.ReadAntiESPList(no_decompress)
		local filename = "hmcd_dog_impendingbans/anti_esp_list.dat"
		
		if(!file.Exists(filename, "DATA"))then
			file.CreateDir("hmcd_dog_impendingbans")
			file.Write(filename, DOG.ACheat.Template)
		end
		
		local data = file.Read(filename)
		
		if(!no_decompress)then
			data = util.JSONToTable(util.Decompress(data))
		end
		
		return data
	end
	
	function DOG.ACheat.SetAntiESPList(SID, value)
		if(value == false)then
			value = nil
		end
		
		local info = DOG.ACheat.ReadAntiESPList()
		info[SID] = value
		local filename = "hmcd_dog_impendingbans/anti_esp_list.dat"
		local data = util.Compress(util.TableToJSON(info))
		
		file.Write(filename,data)
	end
	--//
	
	--\\
	function DOG.ACheat:ReadPendingBans()
		local filename = "hmcd_dog_impendingbans/bans.dat"
		if(!file.Exists(filename,"DATA"))then
			file.CreateDir("hmcd_dog_impendingbans")
			file.Write(filename,DOG.ACheat.Template)
		end
		local data = file.Read(filename)
		data = util.JSONToTable(util.Decompress(data))
		return data
	end
	
	function DOG.ACheat.GetRandomBanWaveTime()
		if(math.random(1, 5) == 1)then
			return math.random(86400 * 1, 86400 * 5)
		else
			return math.random(86400 / 2, 86400 * 3)
		end
	end
	
	function DOG.ACheat:SetImpendingBan(SID, value, callback, time_to_ban)
		local ply = player.GetBySteamID(SID)
		
		if(IsValid(ply))then
			ply.DOG_BanScheduled = value
		end
	
		if(mysql)then
			local steamid_64 = util.SteamIDTo64(SID)
			
			local query = mysql:Select("dog_ac_banwaves")
				query:Select("time_to_ban")
				query:Where("steamid", steamid_64)
				query:Callback(function(results)
					results = results or {}
					
					if(results[1])then
						if(!value)then
							local query2 = mysql:Delete("dog_ac_banwaves")
								query2:Where("steamid", steamid_64)
								query2:Callback(function()
									if(callback)then
										callback()
									end
								end)
							query2:Execute()
						end
					else
						local query2 = mysql:Insert("dog_ac_banwaves")
							query2:Insert("banwave", 0)
							query2:Insert("impudence_first", os.time())
							query2:Insert("time_to_ban", time_to_ban or DOG.ACheat.GetRandomBanWaveTime())
							query2:Insert("steamid", steamid_64)
							query2:Callback(function()
								if(callback)then
									callback()
								end
							end)
						query2:Execute()
					end
				end)
			query:Execute()
		else
			if(value==false)then value = nil end
			local info = DOG.ACheat:ReadPendingBans()
			info[SID] = value
			local filename = "hmcd_dog_impendingbans/bans.dat"
			local data = util.Compress(util.TableToJSON(info))
			file.Write(filename,data)
		end
	end
	
	function DOG.ACheat.SubtractImpendingBan(SID, value, callback)
		value = math.Round(value)
		
		if(mysql)then
			local steamid_64 = util.SteamIDTo64(SID)
			
			local query = mysql:Select("dog_ac_banwaves")
				query:Select("time_to_ban")
				query:Where("steamid", steamid_64)
				query:Callback(function(results)
					results = results or {}
					
					if(results[1])then
						local query2 = mysql:Update("dog_ac_banwaves")
							query2:Update("time_to_ban", (results[1].time_to_ban or 0) - value)
							query2:Where("steamid", steamid_64)
							query2:Callback(function()
								if(callback)then
									callback()
								end
							end)
						query2:Execute()
					end
				end)
			query:Execute()
		end
	end
	--//
	
	--\\
	function DOG.ACheat:SetField(SID64, Field, Arg, code, additional_string)
		if(mysql)then
			additional_string = additional_string or ""
			
			if(Field == "Note")then
				local query = mysql:Select("dog_ac_misc")
					query:Select("dat")
					query:Where("steamid", SID64)
					query:Callback(function(results)
						if(istable(results) and results[1])then
							local data = results[1].dat
							data = util.JSONToTable(data) or {}
							data.Note = Arg
							
							local query2 = mysql:Update("dog_ac_misc")
								query2:Update("dat", util.TableToJSON(data))
								query2:Where("steamid", SID64)
							query2:Execute()
						else
							local data = {}
							data.Note = Arg
							
							local query2 = mysql:Insert("dog_ac_misc")
								query2:Insert("dat", util.TableToJSON(data))
								query2:Insert("steamid", SID64)
							query2:Execute()
						end
					end)
				query:Execute()
			else
				local query = mysql:Select("dog_ac_players")
					query:Select("amt")
					query:Where("steamid", SID64)
					query:Where("code", code)
					query:Where("additional_string", additional_string)
					query:Callback(function(results)
						if(istable(results) and results[1])then
							local query2 = mysql:Update("dog_ac_players")
								query2:Update("amt", Arg)
								query2:Where("steamid", SID64)
								query2:Where("code", code)
								query2:Where("additional_string", additional_string)
							query2:Execute()
						else
							DOG.ACheat:Add(SID64,Field,Arg, code, additional_string)
						end
					end)
				query:Execute()
			end
		else
			local info = DOG.ACheat:ReadFile(SID64, true)
			info[Field] = Arg
			local filename = "hmcd_dog_acheat/" .. SID64 .. ".dat"
			local data = util.Compress(util.TableToJSON(info))
			
			file.Write(filename, data)
		end
	end
	--//
	
	function DOG.ACheat:ReadFile(SID64,ShouldUnPack,NoWrite)
		local filename = "hmcd_dog_acheat/"..SID64..".dat"
		if(!file.Exists(filename,"DATA") and !NoWrite)then
			file.CreateDir("hmcd_dog_acheat")
			file.Write(filename,DOG.ACheat.Template)
		end
		local data = file.Read(filename)
		if(ShouldUnPack)then
			data = util.JSONToTable(util.Decompress(data))
		end
		return data
	end

	function DOG.ACheat.SetCookie(var, data)
		if(mysql)then
			data = tostring(data)
			
			local query = mysql:Select("dog_ac_cookies")
				query:Select("dat")
				query:Where("cook", var)
				query:Callback(function(results)
					if(istable(results) and results[1])then
						local query2 = mysql:Update("dog_ac_cookies")
							query2:Update("dat", data)
							query2:Where("cook", var)
						query2:Execute()
					else
						local query2 = mysql:Insert("dog_ac_cookies")
							query2:Insert("dat", data)
							query2:Insert("cook", var)
						query2:Execute()
					end
				end)
			query:Execute()
		else
			cookie.Set(var, data)
		end
	end
	
	function DOG.ACheat.GetCookie(var, callback)
		if(mysql)then
			local query = mysql:Select("dog_ac_cookies")
				query:Select("dat")
				query:Where("cook", var)
				query:Callback(function(results)
					if(istable(results) and results[1])then
						callback(results[1].dat)
					else
						callback(nil)
					end
				end)
			query:Execute()
		else
			callback(cookie.GetString(var))
		end
	end
	
	function DOG.ACheat:Add(SID64,Field,Arg, code, additional_string)
		additional_string = additional_string or ""
		local code_info = DOG.ACheat.CheatCodes[code or ""]
		
		if(code_info and !code_info.AddText)then
			additional_string = ""
		end
		
		if(Field != "KnownIPs")then
			if(mysql)then
				local query = mysql:Select("dog_ac_players")
					mysql:Select("amt")
					query:Where("steamid", SID64)
					query:Where("code", code)
					query:Where("string", additional_string)
					query:Callback(function(result)
						local amt = 0
						local os_time = os.time()
					
						if(istable(result) and result[1] and result[1].amt)then
							amt = result[1].amt
							amt = amt + Arg
							
							local query2 = mysql:Update("dog_ac_players")
								query2:Update("amt", amt)
								query2:Update("last_detection", os_time)
								query2:Where("steamid", SID64)
								query2:Where("code", code)
								query2:Where("string", additional_string)
							query2:Execute()
						else
							amt = amt + Arg
							
							local query2 = mysql:Insert("dog_ac_players")
								query2:Insert("amt", amt)
								query2:Insert("steamid", SID64)
								query2:Insert("code", code)
								query2:Insert("string", additional_string)
								query2:Insert("first_detection", os_time)
								query2:Insert("last_detection", os_time)
							query2:Execute()
						end
					end)
				query:Execute()
			else
				local info = DOG.ACheat:ReadFile(SID64, true)
				
				if(isnumber(info[Field]))then
					info[Field] = {Value = info[Field], FirstTime = os.time()}
				end
				
				info[Field] = info[Field] or {Value = 0, FirstTime = os.time()}
				info[Field].Value = info[Field].Value + Arg
				info[Field].LastTime = os.time()
				local filename = "hmcd_dog_acheat/"..SID64..".dat"
				local data = util.Compress(util.TableToJSON(info))
				file.Write(filename,data)
			end
		else
			ErrorNoHalt("field == KnownIPs!\n")
		end
	end
	
	-- DOG.ACheat:Add(Entity(1):SteamID64(), "nigger", 1)
	
	function DOG.ACheat:RemoveFile(SID64)
		local filename = "hmcd_dog_acheat/" .. SID64 .. ".dat"
		
		file.Delete(filename)
	end
	
	function DOG.ACheat:AddIP(SID64,IP)
		if(mysql)then
			local query = mysql:Select("dog_ac_misc")
				query:Select("dat")
				query:Where("steamid", SID64)
				query:Callback(function(results)
					if(istable(results) and results[1])then
						local data = results[1].dat
						data = util.JSONToTable(data) or {}
						data.KnownIPs = data.KnownIPs or {}
						data.KnownIPs[IP] = (data.KnownIPs[IP] or 0) + 1
						
						local query2 = mysql:Update("dog_ac_misc")
							query2:Update("dat", util.TableToJSON(data))
							query2:Where("steamid", SID64)
						query2:Execute()
					else
						local data = {}
						data.KnownIPs = {}
						data.KnownIPs[IP] = 1
						
						local query2 = mysql:Insert("dog_ac_misc")
							query2:Insert("dat", util.TableToJSON(data))
							query2:Insert("steamid", SID64)
						query2:Execute()
					end
				end)
			query:Execute()
		else
			local info = DOG.ACheat:ReadFile(SID64,true)
			info.KnownIPs = info.KnownIPs or {}
			info.KnownIPs[IP] = info.KnownIPs[IP] or 0
			info.KnownIPs[IP]= info.KnownIPs[IP] + 1
			local filename = "hmcd_dog_acheat/"..SID64..".dat"
			local data = util.Compress(util.TableToJSON(info))
			file.Write(filename,data)
		end
	end

	function DOG.ACheat:LoadFuckers()
		if(mysql)then
			local query = mysql:Select("dog_ac_players")
				query:Select("amt")
				query:Select("steamid")
				query:Select("code")
				query:Select("string")
				query:Callback(function(results)
					if(istable(results))then
						for _, result in ipairs(results)do
							DOG.ACheat.Fuckers[result.steamid] = DOG.ACheat.Fuckers[result.steamid] or {}
							DOG.ACheat.Fuckers[result.steamid][result.code] = {
								String = result.string,
								Amt = result.amt,
							}
						end
					end
				end)
			query:Execute()
		else
			local files = file.Find("hmcd_dog_acheat/*","DATA")
			local ids = {}
			for i=1,#files do
				local p = files[i]
				if(!p)then break end
				local apath = string.Explode("/",p)
				local SID64=apath[#apath]
				SID64=string.StripExtension(SID64)
				DOG.ACheat.Fuckers[SID64]=DOG.ACheat:ReadFile(SID64,false)
			end
		end
	end
	
	function DOG.ACheat:NotifyAdmins(text, is_ban_scheduled)
		for i,p in pairs(player.GetAll())do
			if(p:IsAdmin())then
				local notify = true
				local silence_level = p:GetInfoNum("dog_debug_silence_level", 0)
				
				if(silence_level == -1)then
					notify = true
				elseif(silence_level == 0)then
					if(is_ban_scheduled)then
						notify = false
					end
				elseif(silence_level > 0)then
					if(is_ban_scheduled)then
						notify = false
					end
					
					if(string.find(text, "User was cheating", 1, true))then
						notify = false
					end
					
					if(silence_level > 1)then
						notify = false
					end
				end
				
				if(notify)then
					p:ChatPrint("[ADMINS]"..DOG.Name..": "..text)
				end
			end
		end
		
		MsgC(Color(0, 0, 255), DOG.Name .. ": " .. text .. "\n")
	end

	function DOG.ACheat:UpdateImpudence(ply,text)
		local score = 6
		
		if(string.find(text, "ConVar faking: ", 1, true))then
			score = 2
		end
		
		if(string.find(text, "User was cheating", 1, true))then
			score = 0
		end
		
		if(string.find(text, "[SURE]", 1, true))then
			score = 6
		end
	
		if(string.find(text, "[CONF_90]", 1, true))then
			score = 5
		end
	
		-- if(string.find(text, "[UNSURE]", 1, true))then
			-- score = 0
		-- end
		
		if(string.find(text, "[EXPEREMENTAL]", 1, true))then
			score = 0
		end
		
		if(string.find(text, "[Isaiah II]", 1, true))then
			score = 0 --; ERROR
		end
		
		-- if(string.find(text, "[KICK]", 1, true))then
			-- score = 0
		-- end
		
		ply.DOG_AC_Score = (ply.DOG_AC_Score or 0) + score
		
		if(ply.DOG_AC_Score > 5)then
			ply.DOG_AC_Score = 0
			
			DOG.ACheat:NotifyAdmins("Too much impudence of player " .. ply:Nick() .. "\nBan scheduled. Do not intervene", ply.DOG_BanScheduled)
			DOG.ACheat:SetImpendingBan(ply:SteamID(), true, function()
				DOG.ACheat:CommenceHackerbans()
			end)
		end
	end
	
	function DOG.ACheat.ApplyExtraSanctions(ply, text)
		_,send = string.find(text, "[AE]", 1, true)
		if(send)then
			if(ZScreenGrab and GetGlobalBool("DOG_ACombat_AutoAntiESP", false))then
				ZScreenGrab.ToggleAntiESPForPlayer(ply, true)
				DOG.ACheat:NotifyAdmins("АнтиESP включено для игрока " .. ply:Nick())
			end
		end
		
		-- if(string.find(text, "[UNSURE]", 1, true))then
			-- ply.Z_AC_UnsureDetections = (ply.Z_AC_UnsureDetections or 0) + 1
			
			-- if(ply.Z_AC_UnsureDetections > 2)then
				-- DOG.ACheat.DetectPlayer(ply, "[CONF_90] Player is using ESP or cheat menu")
			-- end
		-- end
		
		-- if(string.find(text, "[KICK]", 1, true))then
			-- timer.Simple(0, function()
				-- ply:Kick("Connection is closing")
			-- end)
		-- end
	end
	
	function DOG.ACheat.NotifyAdminsRational(text, ply)
		ply.Z_AC_CheatMessagesTimes = ply.Z_AC_CheatMessagesTimes or {}
		
		if(!ply.Z_AC_CheatMessagesTimes[text] or ply.Z_AC_CheatMessagesTimes[text] <= CurTime())then
			ply.Z_AC_CheatMessagesTimes[text] = CurTime() + 10
		
			DOG.ACheat:NotifyAdmins(text, ply.DOG_BanScheduled)
			
			return true
		end
	end
	
	function DOG.ACheat.DetectPlayer(ply, code, additional_string)
		local code_info = DOG.ACheat.CheatCodes[code]
		local text = "[" .. code .. "]"
		local allowed_to_proceed = true
		
		if(code_info)then
			text = "[" .. (code_info.DisplayCode or code) .. "]"
			text = text .. "\n" .. code_info.Text
			
			if(code_info.AddText)then
				text = text .. additional_string
			else
				additional_string = ""
			end
			
			if(code_info.ProceedFunc)then
				allowed_to_proceed = code_info.ProceedFunc(code, ply, additional_string)
			end
		else
			text = "Unknown code (" .. code .. "),\ntreating as ALEPH [" .. (DOG.ACheat.UnknownCodeDisplay or DOG.ACheat.UnknownCode) .. "]"
			code = DOG.ACheat.UnknownCode
			additional_string = ""
		end
		
		if(allowed_to_proceed)then
			if(ply:IsAdmin() and !DOG.ACheat.DontIgnoreAdmins)then
				local text = "Admin " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Is cheating; " .. text .. "\nNo sanctions applied."
				
				DOG.ACheat.NotifyAdminsRational(text, ply)
				-- DOG.ACheat:NotifyAdmins(text)
			else
				local _,send = string.find(text, "ConVar faking: ", 1, true)
				
				if(send)then
					local convar = string.Explode(" ", string.Right(text,-send-1))[1]
					local value = string.Explode(" ", text)
					value = value[#value]
					
					if (!ConVarExists(convar)) or (tostring(GetConVarNumber(convar)) == string.Trim(value)) then
						return
					end
				end
				
				local notify_text = "Player " .. ply:Nick() .. "[" .. ply:EntIndex() .. "]" .. " Is cheating; " .. text
				local write = DOG.ACheat.NotifyAdminsRational(notify_text, ply)
				
				if(write)then
					if(GetGlobalBool("DOG_ACombat_WriteBlackMark", false))then
						ply:SendLua("HMCD_ACombatSystem_Write()")
					end
					
					DOG.ACheat:UpdateImpudence(ply, text)
					DOG.ACheat:Add(ply:SteamID64(), text, 1, code, additional_string)
					DOG.ACheat:AddIP(ply:SteamID64(), ply:IPAddress())
					DOG.ACheat:LoadFuckers()
				end
				
				DOG.ACheat.ApplyExtraSanctions(ply, text)
			end
		end
	end
	
	net.Receive("atlaschat.sanm", function(len, ply)
		-- DOG.ACheat.CheatCodes
		local code = net.ReadString()
		local additional_string = net.ReadString()
		
		DOG.ACheat.DetectPlayer(ply, code, additional_string)
		
		net.Start("atlaschat.resetall")
			net.WriteString("whisper")
		net.Send(ply)
	end)
	
	--[[
	hook.Add("Think","DOG_CH",function()
		if(DOG.ACheat.NextCheck<CurTime())then
			DOG.ACheat.NextCheck=CurTime()+150
			BroadcastLua("HMCD_ACombatSystem_OnFireWeapon()")
		end
	end)]]

	local function checkBan( steamid64, ip, password, clpassword, name )
		local steamid = util.SteamIDFrom64( steamid64 )
		local banData = ULib.bans[ steamid ]
		if not banData then return end -- Not banned

		-- Nothing useful to show them, go to default message
		if not banData.admin and not banData.reason and not banData.unban and not banData.time then return end

		local message = ULib.getBanMessage( steamid )
		Msg(string.format("%s (%s)<%s> was kicked by ULib because they are on the ban list\n", name, steamid, ip))
		return false, message
	end
	
	hook.Add("IsFullyAuthenticated","BanNigger",function(ply)
		if checkBan(ply:OwnerSteamID64()) ~= nil then
			ply:Kick("ИДИ К ЧЕРТУ!")
		end
	end)
end

--\\
--[[
--; x5o!p%@ap[4\pzx54(p^)7cc)7}$eicar-standard-antivirus-test-file!
-- local class = "!"
-- local class = (">"):rep(511)
-- local class = ("\13"):rep(511)
-- local class = ("хуй"):rep(12)
-- local class = "\1 я тупой читер"
-- local class = "huy\13 fg\13\24\21"
-- local class = "\9\27\16"

ENT = {}
ENT.Spawnable = true
ENT.Category = "DarkRP: Еда"
-- ENT.PrintName = NULL
ENT.PrintName = math.huge
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

scripted_ents.Register(ENT, class)
-- RunConsoleCommand("spawnmenu_reload")
--//

-- PrintTable(scripted_ents.Get(math.huge))

-- local funny = ents.Create("player")
local funny = ents.Create(class)
print(funny)
funny:SetPos(vector_origin)
funny:Spawn()
funny:Activate()
]]

--\\Картография
local srv = {
["addons/FProfiler/lua/autorun/fprofiler.lua"]=true,
["addons/atlaschat/lua/atlaschat/cl_expression.lua"]=true,
["addons/atlaschat/lua/atlaschat/cl_init.lua"]=true,
["addons/atlaschat/lua/atlaschat/cl_panel.lua"]=true,
["addons/atlaschat/lua/atlaschat/cl_theme.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/chatroom.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/config.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/editor.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/expression_list.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/form.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/frame.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/mysql.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/rank_list.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/restrictions.lua"]=true,
["addons/atlaschat/lua/atlaschat/gui/slider.lua"]=true,
["addons/atlaschat/lua/atlaschat/sh_config.lua"]=true,
["addons/atlaschat/lua/atlaschat/sh_utilities.lua"]=true,
["addons/atlaschat/lua/atlaschat/themes/black.lua"]=true,
["addons/atlaschat/lua/atlaschat/themes/blur.lua"]=true,
["addons/atlaschat/lua/atlaschat/themes/default.lua"]=true,
["addons/atlaschat/lua/atlaschat/themes/source_engine.lua"]=true,
["addons/atlaschat/lua/autorun/atlaschat_load.lua"]=true,
["addons/fprofiler/lua/autorun/fprofiler.lua"]=true,
["addons/fprofiler/lua/fprofiler/cami.lua"]=true,
["addons/fprofiler/lua/fprofiler/gather.lua"]=true,
["addons/fprofiler/lua/fprofiler/prettyprint.lua"]=true,
["addons/fprofiler/lua/fprofiler/report.lua"]=true,
["addons/fprofiler/lua/fprofiler/ui/clientcontrol.lua"]=true,
["addons/fprofiler/lua/fprofiler/ui/frame.lua"]=true,
["addons/fprofiler/lua/fprofiler/ui/model.lua"]=true,
["addons/fprofiler/lua/fprofiler/ui/servercontrol.lua"]=true,
["addons/fprofiler/lua/fprofiler/util.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/base_gmodentity.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/ent_scrappers_money.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/ent_scrappers_scrap.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/func_bomb_target.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/func_hostage_rescue.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/info_bomb_target_hint_a.lua"]=true,
["addons/homig2/gamemodes/zbattle/entities/entities/info_bomb_target_hint_b.lua"]=true,
["addons/homig2/gamemodes/zbattle/gamemode/cl_init.lua"]=true,
["addons/homig2/gamemodes/zbattle/gamemode/loader.lua"]=true,
["addons/homig2/gamemodes/zbattle/gamemode/shared.lua"]=true,
["addons/homig2/lua/autorun/yachin.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_claymore.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_grapplinghook.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_breachcharge.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_cyanide_canister.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_cyanide_plotnypih.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_emptymag.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_flashbang.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_hl2grenade.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_impact.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_m67.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_pipebomb.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_rgd5.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_grenade_shg.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_hmcd_radio.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_jam.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_molotov.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_motiontracker.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_slam.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_smokenade.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_hg_snowball.lua"]=true,
["addons/homigrad-otherweapons/lua/entities/ent_throwable.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_adrenaline.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_bandage_sh.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_base/ai_translations.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_base/cl_init.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_base/sh_anim.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_base/shared.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_bat.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_betablock.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_bigbandage_sh.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_bigconsumable.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_bloodbag.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_breachcharge.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_brick.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_buck200knife.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_chair_leg.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_claymore.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_ducttape.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_fentanyl.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_grapplinghook.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_gymnasticstick.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hammer.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_handcuffs.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_handcuffs_key.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hands_sh.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hatchet.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_axe.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_banka.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_bottle.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_bottlebroken.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_crowbar.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_emptymag.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_extinguisher.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_f1_tpik.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_flashbang_tpik.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_flashbang.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_hl2grenade.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_impact.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_m67.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_pipebomb.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_rgd5.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_shg.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_grenade_tpik.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_jam.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_machete.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_molotov.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_molotov_tpik.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_motiontracker.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_mug.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_shovel.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_shuriken.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_slam.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_sledgehammer.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_smokenade.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_snowball.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_spear.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_spear_knife.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_spear_pro.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_stunstick.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hg_tonfa.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_hidebox.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_leadpipe.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_mannitol.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_matches.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_medkit_sh.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_melee.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_morphine.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_naloxone.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_needle.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_painkillers.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_painkillers_tpik.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_pan.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_pluviska.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_pocketknife.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_ram.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_shield.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_smallconsumable.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_sogknife.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_spawnmenu_pda.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_table_leg.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_tomahawk.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_tourniquet.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_tpik1_base.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_tpik_base.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_ied.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_poison1.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_poison2.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_poison3.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_poison4.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_poison_consumable.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_traitor_suit.lua"]=true,
["addons/homigrad-otherweapons/lua/weapons/weapon_walkie_talkie.lua"]=true,
["addons/homigrad-weapons/lua/entities/crossbow_projectile.lua"]=true,
["addons/homigrad-weapons/lua/entities/homigrad_gun.lua"]=true,
["addons/homigrad-weapons/lua/entities/projectile_base.lua"]=true,
["addons/homigrad-weapons/lua/entities/projectile_nonexplosive_base.lua"]=true,
["addons/homigrad-weapons/lua/entities/rpg26_projectile.lua"]=true,
["addons/homigrad-weapons/lua/entities/rpg_projectile.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/cl_camera.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/cl_optics.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/cl_shells.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_ammo.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_anim.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_attachment.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_bullet.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_fake.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_holster_deploy.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_reload.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_replicate.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_spray.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_weaponsinv.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/sh_worldmodel.lua"]=true,
["addons/homigrad-weapons/lua/weapons/homigrad_base/shared.lua"]=true,
["addons/homigrad/lua/autorun/loader.lua"]=true,
["addons/homigrad/lua/autorun/rpchatcommands.lua"]=true,
["addons/homigrad/lua/autorun/shitdecals.lua"]=true,
["addons/homigrad/lua/entities/ammo_base/cl_init.lua"]=true,
["addons/homigrad/lua/entities/ammo_base/shared.lua"]=true,
["addons/homigrad/lua/entities/armor_base/cl_init.lua"]=true,
["addons/homigrad/lua/entities/armor_base/shared.lua"]=true,
["addons/homigrad/lua/entities/attachment_base/cl_init.lua"]=true,
["addons/homigrad/lua/entities/attachment_base/shared.lua"]=true,
["addons/homigrad/lua/entities/bomb/cl_init.lua"]=true,
["addons/homigrad/lua/entities/bomb/shared.lua"]=true,
["addons/homigrad/lua/entities/ent_airdrop.lua"]=true,
["addons/homigrad/lua/entities/ent_hg_fire.lua"]=true,
["addons/homigrad/lua/entities/ent_hg_firesmall.lua"]=true,
["addons/homigrad/lua/entities/firework_base.lua"]=true,
["addons/homigrad/lua/entities/hg_brassknuckles/cl_init.lua"]=true,
["addons/homigrad/lua/entities/hg_brassknuckles/shared.lua"]=true,
["addons/homigrad/lua/entities/hg_flashlight/cl_init.lua"]=true,
["addons/homigrad/lua/entities/hg_flashlight/shared.lua"]=true,
["addons/homigrad/lua/entities/hg_sling/cl_init.lua"]=true,
["addons/homigrad/lua/entities/hg_sling/shared.lua"]=true,
["addons/homigrad/lua/entities/zbox_lootbox/cl_init.lua"]=true,
["addons/homigrad/lua/entities/zbox_lootbox/shared.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/cl_help.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/cl_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/langs/sh_words.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/sh_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/cl_swarm.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/ent_swm_projectile.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm_bullseye.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm_mother.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm_sentinel.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm_sentry.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/npc_swarm_thumper.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/swarm/swarm_ai_base.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/weapons/sh_weapon_bleeding_musket.lua"]=true,
["addons/homigrad/lua/homigrad/abnormalty_detection/weapons/sh_weapon_thaumaturgic_arm.lua"]=true,
["addons/homigrad/lua/homigrad/achievements/cl_achievement.lua"]=true,
["addons/homigrad/lua/homigrad/admin_tools/cl_init.lua"]=true,
["addons/homigrad/lua/homigrad/admin_tools/derma/cl_mainbar.lua"]=true,
["addons/homigrad/lua/homigrad/admin_tools/sh_init.lua"]=true,
["addons/homigrad/lua/homigrad/admin_tools/sh_player_properties.lua"]=true,
["addons/homigrad/lua/homigrad/appearance/cl_appearance.lua"]=true,
["addons/homigrad/lua/homigrad/appearance/derma/cl_apperance.lua"]=true,
["addons/homigrad/lua/homigrad/appearance/derma/cl_plymodel_preview.lua"]=true,
["addons/homigrad/lua/homigrad/appearance/sh_accessories.lua"]=true,
["addons/homigrad/lua/homigrad/appearance/sh_appearance.lua"]=true,
["addons/homigrad/lua/homigrad/cl_bulletholes.lua"]=true,
["addons/homigrad/lua/homigrad/cl_camera.lua"]=true,
["addons/homigrad/lua/homigrad/cl_comunication.lua"]=true,
["addons/homigrad/lua/homigrad/cl_hud.lua"]=true,
["addons/homigrad/lua/homigrad/cl_postprocess.lua"]=true,
["addons/homigrad/lua/homigrad/cl_tpik.lua"]=true,
["addons/homigrad/lua/homigrad/dynamic_music/cl_init.lua"]=true,
["addons/homigrad/lua/homigrad/dynamic_music/sh_packs.lua"]=true,
["addons/homigrad/lua/homigrad/explosives/cl_explosives.lua"]=true,
["addons/homigrad/lua/homigrad/fake/cl_fake.lua"]=true,
["addons/homigrad/lua/homigrad/gunposmenu/cl_menu.lua"]=true,
["addons/homigrad/lua/homigrad/gunposmenu/sh_positioning.lua"]=true,
["addons/homigrad/lua/homigrad/hud/cl_weapon_selector.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/cl_3d2dvgui.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/core/sh_netsream2.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/core/sh_networking.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/outline.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/pointshop/derma/cl_playerview.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/pointshop/derma/cl_pointshop.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/pointshop/sh_pointshop.lua"]=true,
["addons/homigrad/lua/homigrad/libraries/pon.lua"]=true,
["addons/homigrad/lua/homigrad/liquid_drum/particles/cl_gasoline.lua"]=true,
["addons/homigrad/lua/homigrad/liquid_drum/particles/cl_main.lua"]=true,
["addons/homigrad/lua/homigrad/liquid_drum/particles/input/input_cl.lua"]=true,
["addons/homigrad/lua/homigrad/liquid_drum/sh_liquid_drum.lua"]=true,
["addons/homigrad/lua/homigrad/loadme/cl_anticheat_uncompressed.lua"]=true,
["addons/homigrad/lua/homigrad/loadme/cl_nuclear_bomb_DONOTSEND.lua"]=true,
["addons/homigrad/lua/homigrad/minstd.lua"]=true,
["addons/homigrad/lua/homigrad/new_appearance/cl_init.lua"]=true,
["addons/homigrad/lua/homigrad/new_appearance/sh_accessories.lua"]=true,
["addons/homigrad/lua/homigrad/new_appearance/sh_shared.lua"]=true,
["addons/homigrad/lua/homigrad/optionsmenu/cl_menu.lua"]=true,
["addons/homigrad/lua/homigrad/organism/cl_headcrab.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_0/cl_tier_0.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_0/sh_hitboxorgans.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/cl_main.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/cl_statistics.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/modules/cl_virus.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/modules/particles/cl_blood.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/modules/particles/cl_blood2.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/modules/particles/cl_main.lua"]=true,
["addons/homigrad/lua/homigrad/organism/tier_1/modules/particles/input/cl_input.lua"]=true,
["addons/homigrad/lua/homigrad/phys_bullets/cl_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/phys_bullets/sh_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/phys_silk/cl_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/phys_silk/sh_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/pluvtown/pluvworks/cl_pluv.lua"]=true,
["addons/homigrad/lua/homigrad/pluvtown/sh_pluvload.lua"]=true,
["addons/homigrad/lua/homigrad/richpresence/cl_richpresence.lua"]=true,
["addons/homigrad/lua/homigrad/roleplus/cl_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/roleplus/sh_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/sh_bone_layers.lua"]=true,
["addons/homigrad/lua/homigrad/sh_debug.lua"]=true,
["addons/homigrad/lua/homigrad/sh_effects.lua"]=true,
["addons/homigrad/lua/homigrad/sh_equipment.lua"]=true,
["addons/homigrad/lua/homigrad/sh_hg_ammo.lua"]=true,
["addons/homigrad/lua/homigrad/sh_hg_armor.lua"]=true,
["addons/homigrad/lua/homigrad/sh_hg_attachments.lua"]=true,
["addons/homigrad/lua/homigrad/sh_inventory.lua"]=true,
["addons/homigrad/lua/homigrad/sh_luabullets.lua"]=true,
["addons/homigrad/lua/homigrad/sh_notification.lua"]=true,
["addons/homigrad/lua/homigrad/sh_phrases.lua"]=true,
["addons/homigrad/lua/homigrad/sh_quaternions.lua"]=true,
["addons/homigrad/lua/homigrad/sh_screengrab.lua"]=true,
["addons/homigrad/lua/homigrad/sh_status_messages.lua"]=true,
["addons/homigrad/lua/homigrad/sh_util.lua"]=true,
["addons/homigrad/lua/homigrad/sh_zmeyka.lua"]=true,
["addons/homigrad/lua/homigrad/synthesizer/cl_plugin.lua"]=true,
["addons/homigrad/lua/homigrad/synthesizer/sh_plugin.lua"]=true,
["addons/homigrad/lua/initpost/cl_atlases.lua"]=true,
["addons/homigrad/lua/initpost/cl_derma_skin.lua"]=true,
["addons/homigrad/lua/initpost/menu-N-derma/cl_init.lua"]=true,
["addons/homigrad/lua/initpost/menu-N-derma/derma/cl_frame.lua"]=true,
["addons/homigrad/lua/initpost/menu-N-derma/derma/cl_menu_options.lua"]=true,
["addons/homigrad/lua/initpost/menu-N-derma/derma/cl_menu_panel.lua"]=true,
["addons/igs-modification/lua/autorun/l_ingameshopmod.lua"]=true,
["addons/lua-misc/lua/autorun/_loadme_znovenkey.lua"]=true,
["addons/simfphys/lua/autorun/simfphys_extra.lua"]=true,
["addons/simfphys/lua/autorun/simfphys_init.lua"]=true,
["addons/simfphys/lua/autorun/simfphys_prewar.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_attachment.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_attachment_translucent.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_base/cl_init.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_base/shared.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_gaspump.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_gaspump_diesel.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_gaspump_electric.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_gib.lua"]=true,
["addons/simfphys/lua/entities/gmod_sent_vehicle_fphysics_wheel.lua"]=true,
["addons/simfphys/lua/simfphys/anim.lua"]=true,
["addons/simfphys/lua/simfphys/base_functions.lua"]=true,
["addons/simfphys/lua/simfphys/base_lights.lua"]=true,
["addons/simfphys/lua/simfphys/base_vehicles.lua"]=true,
["addons/simfphys/lua/simfphys/client/damage.lua"]=true,
["addons/simfphys/lua/simfphys/client/fonts.lua"]=true,
["addons/simfphys/lua/simfphys/client/hud.lua"]=true,
["addons/simfphys/lua/simfphys/client/lighting.lua"]=true,
["addons/simfphys/lua/simfphys/client/poseparameter.lua"]=true,
["addons/simfphys/lua/simfphys/client/seatcontrols.lua"]=true,
["addons/simfphys/lua/simfphys/client/tab.lua"]=true,
["addons/simfphys/lua/simfphys/init.lua"]=true,
["addons/simfphys/lua/simfphys/view.lua"]=true,
["addons/simfphys/lua/weapons/weapon_simfillerpistol.lua"]=true,
["addons/simfphys/lua/weapons/weapon_simremote.lua"]=true,
["addons/simfphys/lua/weapons/weapon_simrepair.lua"]=true,
["addons/simfphys_extra_functions/lua/autorun/__simfphys_randys_extra_functions.lua"]=true,
["addons/simfphys_extra_functions/lua/autorun/_simfphys_plates_generic.lua"]=true,
["addons/simfphys_extra_functions/lua/autorun/_simfphys_polradio_base.lua"]=true,
["addons/simfphys_extra_functions/lua/simfphysextra/cl_init.lua"]=true,
["addons/simfphys_extra_functions/lua/simfphysextra/hooks.lua"]=true,
["addons/simfphys_extra_functions/lua/simfphysextra/init.lua"]=true,
["addons/simfphys_extra_functions/lua/simfphysextra/shared.lua"]=true,
["addons/simfphys_extra_functions/lua/simfphysextra/tab.lua"]=true,
["addons/vfire-master/lua/autorun/fire_creation.lua"]=true,
["addons/vfire-master/lua/autorun/fire_game_modifications.lua"]=true,
["addons/vfire-master/lua/autorun/fire_misc.lua"]=true,
["addons/vfire-master/lua/entities/entityflame/shared.lua"]=true,
["addons/vfire-master/lua/entities/vfire/shared.lua"]=true,
["addons/vfire-master/lua/entities/vfire_ball/shared.lua"]=true,
["addons/vfire-master/lua/entities/vfire_cluster/shared.lua"]=true,
["addons/zbase/lua/autorun/zbase.lua"]=true,
["addons/zbase/lua/entities/npc_zbase_snpc/shared.lua"]=true,
["addons/zbase/lua/entities/zb_mortar.lua"]=true,
["addons/zbase/lua/entities/zb_projectile.lua"]=true,
["addons/zbase/lua/entities/zb_rock.lua"]=true,
["addons/zbase/lua/entities/zb_rocket.lua"]=true,
["addons/zbase/lua/entities/zb_spawner/cl_init.lua"]=true,
["addons/zbase/lua/entities/zb_spawner/shared.lua"]=true,
["addons/zbase/lua/entities/zb_spit.lua"]=true,
["addons/zbase/lua/entities/zb_temporary_ent.lua"]=true,
["addons/zbase/lua/entities/zbase_navigator/cl_init.lua"]=true,
["addons/zbase/lua/entities/zbase_navigator/shared.lua"]=true,
["addons/zbase/lua/weapons/weapon_elitepolice_mp5k.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_357.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_357_hl1.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_alyxgun.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_annabelle.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_ar2.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_controller.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_crossbow.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_crowbar.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_glock_hl1.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_pistol.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_rpg.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_shotgun.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_shotgun_hl1.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_smg1.lua"]=true,
["addons/zbase/lua/weapons/weapon_zb_stunstick.lua"]=true,
["addons/zbase/lua/weapons/weapon_zbase/sh_internal.lua"]=true,
["addons/zbase/lua/weapons/weapon_zbase/shared.lua"]=true,
["addons/zbase/lua/zbase/cl_spawnmenu.lua"]=true,
["addons/zbase/lua/zbase/cl_toolmenu.lua"]=true,
["addons/zbase/lua/zbase/controller/cl.lua"]=true,
["addons/zbase/lua/zbase/controller/sh.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_antlion/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_antlion_spitter/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_combine_elite/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_combine_nova_prospekt/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_combine_soldier/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_crab_synth/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_dog/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_fastzombie/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_friendly_hunter/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_civilian/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_civilian_f/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_medic/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_medic_f/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_rebel/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_rebel_f/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_refugee/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_human_refugee_f/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_hunter/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_kleiner/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_magnusson/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_manhack/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_metropolice/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_metropolice_elite/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_mortar_synth/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_odessa/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_poisonzombie/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_stalker/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_test/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_uriah/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_vortigaunt/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_zombie/shared.lua"]=true,
["addons/zbase/lua/zbase/entities/zb_zombine/shared.lua"]=true,
["addons/zbase/lua/zbase/npc_base_sentence.lua"]=true,
["addons/zbase/lua/zbase/npc_base_shared.lua"]=true,
["addons/zbase/lua/zbase/sh_cvars.lua"]=true,
["addons/zbase/lua/zbase/sh_globals_pri.lua"]=true,
["addons/zbase/lua/zbase/sh_globals_pub.lua"]=true,
["addons/zbase/lua/zbase/sh_hooks.lua"]=true,
["addons/zbase/lua/zbase/sh_override_functions.lua"]=true,
["addons/zbase/lua/zbase/sh_properties.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/entities/entities/ent_zrp_item.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/cl_init.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/cl_characters.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/cl_vgui.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/cl_vgui_character_creation_menu.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/cl_vgui_character_select_menu.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/sh_character.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/characters/sh_characters.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/cl_plugin.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/inventories/cl_inventories.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/inventories/sh_inventories.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/inventories/sh_inventory.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/items/cl_items.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/items/sh_item.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/items/sh_items.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/items/sh_items_loader.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/sh_player.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/main/sh_plugin.lua"]=true,
["addons/zbox_rp/gamemodes/zbox_rp/gamemode/shared.lua"]=true,
["addons/zippy_library/lua/autorun/conv.lua"]=true,
["addons/zippy_library/lua/conv/cl.lua"]=true,
["addons/zippy_library/lua/conv/internals/sh_hooks.lua"]=true,
["addons/zippy_library/lua/conv/internals/sh_miscnet.lua"]=true,
["addons/zippy_library/lua/conv/sh.lua"]=true,
["addons/zippy_library/lua/convenience/adam.lua"]=true,
["addons/zippy_library/lua/convenience/deprecated/cl_adam.lua"]=true,
["addons/zippy_library/lua/convenience/deprecated/sh_ent.lua"]=true,
["addons/zippy_library/lua/convenience/deprecated/sh_misc.lua"]=true,
["addons/zippy_library/lua/entities/conv_text/cl_init.lua"]=true,
["addons/zippy_library/lua/entities/conv_text/shared.lua"]=true,
["gamemodes/base/entities/entities/base_ai/cl_init.lua"]=true,
["gamemodes/base/entities/entities/base_ai/shared.lua"]=true,
["gamemodes/base/entities/entities/base_anim.lua"]=true,
["gamemodes/base/entities/entities/base_entity/cl_init.lua"]=true,
["gamemodes/base/entities/entities/base_entity/shared.lua"]=true,
["gamemodes/base/entities/entities/base_nextbot/shared.lua"]=true,
["gamemodes/base/entities/entities/env_skypaint.lua"]=true,
["gamemodes/base/entities/entities/gmod_hands.lua"]=true,
["gamemodes/base/entities/entities/npc_tf2_ghost.lua"]=true,
["gamemodes/base/entities/entities/prop_effect.lua"]=true,
["gamemodes/base/entities/entities/ragdoll_motion.lua"]=true,
["gamemodes/base/gamemode/animations.lua"]=true,
["gamemodes/base/gamemode/cl_deathnotice.lua"]=true,
["gamemodes/base/gamemode/cl_hudpickup.lua"]=true,
["gamemodes/base/gamemode/cl_pickteam.lua"]=true,
["gamemodes/base/gamemode/cl_scoreboard.lua"]=true,
["gamemodes/base/gamemode/cl_spawnmenu.lua"]=true,
["gamemodes/base/gamemode/cl_targetid.lua"]=true,
["gamemodes/base/gamemode/cl_voice.lua"]=true,
["gamemodes/base/gamemode/gravitygun.lua"]=true,
["gamemodes/base/gamemode/obj_player_extend.lua"]=true,
["gamemodes/base/gamemode/player_class/player_default.lua"]=true,
["gamemodes/base/gamemode/player_class/taunt_camera.lua"]=true,
["gamemodes/base/gamemode/player_shd.lua"]=true,
["gamemodes/base/gamemode/shared.lua"]=true,
["gamemodes/sandbox/entities/entities/base_edit.lua"]=true,
["gamemodes/sandbox/entities/entities/base_gmodentity.lua"]=true,
["gamemodes/sandbox/entities/entities/edit_fog.lua"]=true,
["gamemodes/sandbox/entities/entities/edit_sky.lua"]=true,
["gamemodes/sandbox/entities/entities/edit_sun.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_anchor.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_balloon.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_button.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_cameraprop.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_dynamite.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_emitter.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_ghost.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_hoverball.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_lamp.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_light.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_thruster.lua"]=true,
["gamemodes/sandbox/entities/entities/gmod_wheel.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_camera.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/cl_init.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/cl_viewscreen.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/ghostentity.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/object.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/shared.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stool.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stool_cl.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/axis.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/balloon.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/ballsocket.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/button.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/camera.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/colour.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/creator.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/duplicator.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/duplicator/arming.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/duplicator/icon.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/duplicator/transport.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/dynamite.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/editentity.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/elastic.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/emitter.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/example.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/eyeposer.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/faceposer.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/finger.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/hoverball.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/hydraulic.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/inflator.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/lamp.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/leafblower.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/light.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/material.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/motor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/muscle.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/nocollide.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/paint.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/physprop.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/pulley.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/remover.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/rope.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphysduplicator.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphyseditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphysgeareditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphysmiscsoundeditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphyssoundeditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphyssuspensioneditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/simfphyswheeleditor.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/slider.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/thruster.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/trails.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/weld.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/wheel.lua"]=true,
["gamemodes/sandbox/entities/weapons/gmod_tool/stools/winch.lua"]=true,
["gamemodes/sandbox/gamemode/cl_hints.lua"]=true,
["gamemodes/sandbox/gamemode/cl_init.lua"]=true,
["gamemodes/sandbox/gamemode/cl_notice.lua"]=true,
["gamemodes/sandbox/gamemode/cl_search_models.lua"]=true,
["gamemodes/sandbox/gamemode/cl_spawnmenu.lua"]=true,
["gamemodes/sandbox/gamemode/cl_worldtips.lua"]=true,
["gamemodes/sandbox/gamemode/editor_player.lua"]=true,
["gamemodes/sandbox/gamemode/gui/IconEditor.lua"]=true,
["gamemodes/sandbox/gamemode/persistence.lua"]=true,
["gamemodes/sandbox/gamemode/player_class/player_sandbox.lua"]=true,
["gamemodes/sandbox/gamemode/player_extension.lua"]=true,
["gamemodes/sandbox/gamemode/save_load.lua"]=true,
["gamemodes/sandbox/gamemode/shared.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/contextmenu.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controlpanel.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/control_presets.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/ctrlcolor.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/ctrllistbox.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/ctrlnumpad.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/manifest.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/preset_editor.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/controls/ropematerial.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/content.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contentcontainer.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contentheader.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenticon.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contentsearch.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contentsidebar.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contentsidebartoolbox.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/addonprops.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/custom.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/dupes.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/entities.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/gameprops.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/npcs.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/postprocess.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/saves.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/vehicles.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/weapons.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/postprocessicon.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/creationmenu/manifest.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/spawnmenu.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/toolmenu.lua"]=true,
["gamemodes/sandbox/gamemode/spawnmenu/toolpanel.lua"]=true,
["lua/ZBattle/gamemode/libraries/!core/cl_bullshit.lua"]=true,
["lua/ZBattle/gamemode/libraries/!core/sh_pointshandystuff.lua"]=true,
["lua/ZBattle/gamemode/libraries/!core/sh_tween.lua"]=true,
["lua/ZBattle/gamemode/libraries/cl_modeselect_menu.lua"]=true,
["lua/ZBattle/gamemode/libraries/experience/cl_menu.lua"]=true,
["lua/ZBattle/gamemode/libraries/experience/derma/cl_account_panel.lua"]=true,
["lua/ZBattle/gamemode/libraries/experience/derma/cl_exp_panel.lua"]=true,
["lua/ZBattle/gamemode/libraries/experience/sh_util.lua"]=true,
["lua/ZBattle/gamemode/libraries/guilt/cl_guilt.lua"]=true,
["lua/ZBattle/gamemode/libraries/guilt/sh_guilt.lua"]=true,
["lua/ZBattle/gamemode/libraries/mappoints/sh_points.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/core/sh_anim.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/core/sh_tier_0.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_bloodz.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_combine.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_gordon.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_groove.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_hohol.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_nationalguard.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_police.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_rebel.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_refuge.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_slugcat.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_swat.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_terrorist.lua"]=true,
["lua/ZBattle/gamemode/libraries/playerclass/sh_wagner.lua"]=true,
["lua/ZBattle/gamemode/libraries/rtv/cl_rtv.lua"]=true,
["lua/ZBattle/gamemode/libraries/rtv/derma/cl_derma_menu.lua"]=true,
["lua/ZBattle/gamemode/libraries/rtv/derma/cl_derma_rtvbutton.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_animation.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_giverole.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_lootspawn.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_pluvis.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_simplex.lua"]=true,
["lua/ZBattle/gamemode/libraries/sh_ulxcommands.lua"]=true,
["lua/ZBattle/gamemode/modes/coop/cl_coop.lua"]=true,
["lua/ZBattle/gamemode/modes/coop/sh_coop.lua"]=true,
["lua/ZBattle/gamemode/modes/criresp/cl_criresp.lua"]=true,
["lua/ZBattle/gamemode/modes/criresp/sh_criresp.lua"]=true,
["lua/ZBattle/gamemode/modes/defense/cl_defense.lua"]=true,
["lua/ZBattle/gamemode/modes/defense/sh_defense.lua"]=true,
["lua/ZBattle/gamemode/modes/dm/cl_dm.lua"]=true,
["lua/ZBattle/gamemode/modes/dm/sh_dm.lua"]=true,
["lua/ZBattle/gamemode/modes/eventhandler/cl_event.lua"]=true,
["lua/ZBattle/gamemode/modes/eventhandler/sh_event.lua"]=true,
["lua/ZBattle/gamemode/modes/gwars/cl_gwars.lua"]=true,
["lua/ZBattle/gamemode/modes/gwars/sh_gwars.lua"]=true,
["lua/ZBattle/gamemode/modes/hl2dm/cl_hl2dm.lua"]=true,
["lua/ZBattle/gamemode/modes/hl2dm/sh_hl2dm.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/cl_derma.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/cl_homicide.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/cl_hud.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/cl_professions_abilities.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/cl_subrole_abilities.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/sh_homicide.lua"]=true,
["lua/ZBattle/gamemode/modes/homicide/sh_subrole_abilities.lua"]=true,
["lua/ZBattle/gamemode/modes/riot/cl_riot.lua"]=true,
["lua/ZBattle/gamemode/modes/riot/sh_riot.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/cl_scrappers.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/derma/cl_clouds.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/derma/cl_mainslot.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/derma/cl_scrappersbutton.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/derma/cl_shop.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers/sh_scrappers.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/cl_scrappers.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_clouds.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_framebase.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_gridsweep.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_mainslot.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_scrappersbutton.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/derma/cl_shop.lua"]=true,
["lua/ZBattle/gamemode/modes/scrappers_long/sh_scrappers.lua"]=true,
["lua/ZBattle/gamemode/modes/scugarena/cl_arena.lua"]=true,
["lua/ZBattle/gamemode/modes/scugarena/sh_arena.lua"]=true,
["lua/ZBattle/gamemode/modes/sfd/cl_sfd.lua"]=true,
["lua/ZBattle/gamemode/modes/sfd/sh_sfd.lua"]=true,
["lua/ZBattle/gamemode/modes/smo/cl_smo.lua"]=true,
["lua/ZBattle/gamemode/modes/smo/sh_smo.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/cl_ss.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_gridsweep.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_map.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_mapslot.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_players.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_researchslot.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/derma/cl_tooltip.lua"]=true,
["lua/ZBattle/gamemode/modes/streetsweep/sh_ss.lua"]=true,
["lua/ZBattle/gamemode/modes/tdm/cl_tdm.lua"]=true,
["lua/ZBattle/gamemode/modes/tdm/sh_tdm.lua"]=true,
["lua/ZBattle/gamemode/modes/tdm_cstrike/cl_cstrike.lua"]=true,
["lua/ZBattle/gamemode/modes/tdm_cstrike/sh_cstrike.lua"]=true,
["lua/ZBattle/gamemode/modes/warfare/cl_warfare.lua"]=true,
["lua/ZBattle/gamemode/modes/warfare/sh_warfare.lua"]=true,
["lua/ZBattle/gamemode/modes/zombie/cl_adv_zomibe.lua"]=true,
["lua/ZBattle/gamemode/modes/zombie/sh_adv_zomibe.lua"]=true,
["lua/ZBattle/gamemode/modes/zonbisurv/cl_zonbi.lua"]=true,
["lua/ZBattle/gamemode/modes/zonbisurv/sh_zonbi.lua"]=true,
["lua/ai_translations.lua"]=true,
["lua/arcticvr/attachments/default.lua"]=true,
["lua/arcticvr/magazines/12gshell_1.lua"]=true,
["lua/arcticvr/magazines/deagle_7.lua"]=true,
["lua/arcticvr/magazines/glock_17.lua"]=true,
["lua/arcticvr/magazines/m9_15.lua"]=true,
["lua/arcticvr/magazines/mac10_32.lua"]=true,
["lua/arcticvr/magazines/tmp_30.lua"]=true,
["lua/atlaschat/cl_init.lua"]=true,
["lua/autorun/__simfphys_randys_extra_functions.lua"]=true,
["lua/autorun/_loadme_znovenkey.lua"]=true,
["lua/autorun/_simfphys_l4d_extra_functions.lua"]=true,
["lua/autorun/_simfphys_plates_generic.lua"]=true,
["lua/autorun/_simfphys_plates_l4d.lua"]=true,
["lua/autorun/_simfphys_polradio_base.lua"]=true,
["lua/autorun/addons.code-workspace"]=true,
["lua/autorun/anticitizen_one.lua"]=true,
["lua/autorun/anticitizen_one_player.lua"]=true,
["lua/autorun/atlaschat_load.lua"]=true,
["lua/autorun/austria_particles.lua"]=true,
["lua/autorun/autorun.lua"]=true,
["lua/autorun/ba2_precache.lua"]=true,
["lua/autorun/ba2_shared.lua"]=true,
["lua/autorun/ballas_gangs.lua"]=true,
["lua/autorun/base_npcs.lua"]=true,
["lua/autorun/base_vehicles.lua"]=true,
["lua/autorun/beta_units_glowlib.lua"]=true,
["lua/autorun/c_arms_rebel.lua"]=true,
["lua/autorun/cl_arcticvr.lua"]=true,
["lua/autorun/cl_arcticvr_attachments.lua"]=true,
["lua/autorun/cl_arcticvr_cases.lua"]=true,
["lua/autorun/cl_arcticvr_misc.lua"]=true,
["lua/autorun/client/ba2_client_init.lua"]=true,
["lua/autorun/client/cl_playerflinch.lua"]=true,
["lua/autorun/client/cl_simplest_subtitles.lua"]=true,
["lua/autorun/client/demo_recording.lua"]=true,
["lua/autorun/client/gm_demo.lua"]=true,
["lua/autorun/client/roundalert.lua"]=true,
["lua/autorun/client/terminator_cl_events.lua"]=true,
["lua/autorun/client/vj_menu_main_client.lua"]=true,
["lua/autorun/client/vj_menu_plugins.lua"]=true,
["lua/autorun/client/vj_menu_snpc.lua"]=true,
["lua/autorun/client/vj_menu_weapon.lua"]=true,
["lua/autorun/conv.lua"]=true,
["lua/autorun/custombloodimpact.lua"]=true,
["lua/autorun/dejs_actually_enhanced_natguard.lua"]=true,
["lua/autorun/dejs_ukrainian_ground_forces_playermodel.lua"]=true,
["lua/autorun/dejs_zuper_zoldati_playermodel.lua"]=true,
["lua/autorun/developer_functions.lua"]=true,
["lua/autorun/ej_combinesniper.lua"]=true,
["lua/autorun/ej_combinesniper_pm.lua"]=true,
["lua/autorun/fire_creation.lua"]=true,
["lua/autorun/fire_game_modifications.lua"]=true,
["lua/autorun/fire_misc.lua"]=true,
["lua/autorun/fprofiler.lua"]=true,
["lua/autorun/game_hl2.lua"]=true,
["lua/autorun/gm_sosnovka_slon_script_banya_super_klass.lua"]=true,
["lua/autorun/groove_gangs.lua"]=true,
["lua/autorun/headshot_script.lua"]=true,
["lua/autorun/init.lua"]=true,
["lua/autorun/it_goes_in_the_dark.lua"]=true,
["lua/autorun/jesus.lua"]=true,
["lua/autorun/l_ingameshopmod.lua"]=true,
["lua/autorun/loader.lua"]=true,
["lua/autorun/menubar.lua"]=true,
["lua/autorun/npccodes.lua"]=true,
["lua/autorun/patient_2.lua"]=true,
["lua/autorun/playermodelcodes.lua"]=true,
["lua/autorun/prigozhin_playermodel.lua"]=true,
["lua/autorun/properties.lua"]=true,
["lua/autorun/properties/bodygroups.lua"]=true,
["lua/autorun/properties/bone_manipulate.lua"]=true,
["lua/autorun/properties/collisions.lua"]=true,
["lua/autorun/properties/drive.lua"]=true,
["lua/autorun/properties/editentity.lua"]=true,
["lua/autorun/properties/gravity.lua"]=true,
["lua/autorun/properties/ignite.lua"]=true,
["lua/autorun/properties/keep_upright.lua"]=true,
["lua/autorun/properties/kinect_controller.lua"]=true,
["lua/autorun/properties/npc_scale.lua"]=true,
["lua/autorun/properties/persist.lua"]=true,
["lua/autorun/properties/remove.lua"]=true,
["lua/autorun/properties/skin.lua"]=true,
["lua/autorun/properties/statue.lua"]=true,
["lua/autorun/rb655_extended_spawnmenu.lua"]=true,
["lua/autorun/rb655_legacy_addon_props.lua"]=true,
["lua/autorun/rpchatcommands.lua"]=true,
["lua/autorun/rpg7particles.lua"]=true,
["lua/autorun/scug.lua"]=true,
["lua/autorun/seb.lua"]=true,
["lua/autorun/sh_arcticvr_attloader.lua"]=true,
["lua/autorun/sh_arcticvr_bullets.lua"]=true,
["lua/autorun/sh_arcticvr_magloader.lua"]=true,
["lua/autorun/sh_arcticvr_passthrough.lua"]=true,
["lua/autorun/sh_formattime.lua"]=true,
["lua/autorun/sh_mansion.lua"]=true,
["lua/autorun/sh_playerflinch.lua"]=true,
["lua/autorun/sh_terminator_funcs.lua"]=true,
["lua/autorun/shitdecals.lua"]=true,
["lua/autorun/simfphys_extra.lua"]=true,
["lua/autorun/simfphys_init.lua"]=true,
["lua/autorun/simfphys_prewar.lua"]=true,
["lua/autorun/spawnlist_69charger.lua"]=true,
["lua/autorun/spawnlist_69sedan.lua"]=true,
["lua/autorun/spawnlist_82hatchback.lua"]=true,
["lua/autorun/spawnlist_84sedan.lua"]=true,
["lua/autorun/spawnlist_95sedan.lua"]=true,
["lua/autorun/spawnlist_ambulance.lua"]=true,
["lua/autorun/spawnlist_apbag.lua"]=true,
["lua/autorun/spawnlist_apc.lua"]=true,
["lua/autorun/spawnlist_apcart.lua"]=true,
["lua/autorun/spawnlist_apcat.lua"]=true,
["lua/autorun/spawnlist_apcat2.lua"]=true,
["lua/autorun/spawnlist_apfuel.lua"]=true,
["lua/autorun/spawnlist_army_truck.lua"]=true,
["lua/autorun/spawnlist_boat_trailer_20ft.lua"]=true,
["lua/autorun/spawnlist_boat_trailer_35ft.lua"]=true,
["lua/autorun/spawnlist_bus.lua"]=true,
["lua/autorun/spawnlist_bus2.lua"]=true,
["lua/autorun/spawnlist_bus3.lua"]=true,
["lua/autorun/spawnlist_cement_truck.lua"]=true,
["lua/autorun/spawnlist_church_bus.lua"]=true,
["lua/autorun/spawnlist_church_bus_armored.lua"]=true,
["lua/autorun/spawnlist_crownvic.lua"]=true,
["lua/autorun/spawnlist_deliveryvan.lua"]=true,
["lua/autorun/spawnlist_deliveryvan_a.lua"]=true,
["lua/autorun/spawnlist_fire_truck.lua"]=true,
["lua/autorun/spawnlist_flatnose_truck.lua"]=true,
["lua/autorun/spawnlist_generator.lua"]=true,
["lua/autorun/spawnlist_hmmwv.lua"]=true,
["lua/autorun/spawnlist_howitzer.lua"]=true,
["lua/autorun/spawnlist_longnose_truck.lua"]=true,
["lua/autorun/spawnlist_motorhome.lua"]=true,
["lua/autorun/spawnlist_news_van.lua"]=true,
["lua/autorun/spawnlist_nuke_car.lua"]=true,
["lua/autorun/spawnlist_pickup_2004.lua"]=true,
["lua/autorun/spawnlist_pickup_4x4.lua"]=true,
["lua/autorun/spawnlist_pickup_78.lua"]=true,
["lua/autorun/spawnlist_pickup_b_78.lua"]=true,
["lua/autorun/spawnlist_pickup_dually.lua"]=true,
["lua/autorun/spawnlist_pickup_regcab.lua"]=true,
["lua/autorun/spawnlist_police_car_city.lua"]=true,
["lua/autorun/spawnlist_police_car_city2.lua"]=true,
["lua/autorun/spawnlist_police_car_rural.lua"]=true,
["lua/autorun/spawnlist_police_pickup_truck.lua"]=true,
["lua/autorun/spawnlist_police_pickup_truck2.lua"]=true,
["lua/autorun/spawnlist_racecar.lua"]=true,
["lua/autorun/spawnlist_racecar_d.lua"]=true,
["lua/autorun/spawnlist_semi_trailer.lua"]=true,
["lua/autorun/spawnlist_semi_truck.lua"]=true,
["lua/autorun/spawnlist_suv_2001.lua"]=true,
["lua/autorun/spawnlist_swat.lua"]=true,
["lua/autorun/spawnlist_tanker_trailer.lua"]=true,
["lua/autorun/spawnlist_tankerdestruction_trailer.lua"]=true,
["lua/autorun/spawnlist_taxi_city.lua"]=true,
["lua/autorun/spawnlist_taxi_old.lua"]=true,
["lua/autorun/spawnlist_taxi_rural.lua"]=true,
["lua/autorun/spawnlist_tractor.lua"]=true,
["lua/autorun/spawnlist_tractor01.lua"]=true,
["lua/autorun/spawnlist_truck_nuke.lua"]=true,
["lua/autorun/spawnlist_utility_truck.lua"]=true,
["lua/autorun/spawnlist_utility_truck_m.lua"]=true,
["lua/autorun/spawnlist_van.lua"]=true,
["lua/autorun/spawnlist_van_m.lua"]=true,
["lua/autorun/sv_arcticvr.lua"]=true,
["lua/autorun/sv_arcticvr_attachments.lua"]=true,
["lua/autorun/sv_arcticvr_penetration.lua"]=true,
["lua/autorun/swat.lua"]=true,
["lua/autorun/terminator_thetable.lua"]=true,
["lua/autorun/terminator_weapanalog_weightsystem.lua"]=true,
["lua/autorun/ulib_init.lua"]=true,
["lua/autorun/utilities_menu.lua"]=true,
["lua/autorun/vj_base_autorun.lua"]=true,
["lua/autorun/vj_base_check.lua"]=true,
["lua/autorun/vj_cof_autorun.lua"]=true,
["lua/autorun/vj_controls.lua"]=true,
["lua/autorun/vj_convars.lua"]=true,
["lua/autorun/vj_files.lua"]=true,
["lua/autorun/vj_files_language.lua"]=true,
["lua/autorun/vj_files_particles.lua"]=true,
["lua/autorun/vj_garn47car_autorun.lua"]=true,
["lua/autorun/vj_globals.lua"]=true,
["lua/autorun/vj_menu_main.lua"]=true,
["lua/autorun/vj_menu_properties.lua"]=true,
["lua/autorun/vj_menu_spawn.lua"]=true,
["lua/autorun/vj_menu_spawninfo.lua"]=true,
["lua/autorun/vrmod_init.lua"]=true,
["lua/autorun/yachin.lua"]=true,
["lua/autorun/yahet_funeral.lua"]=true,
["lua/autorun/zbase.lua"]=true,
["lua/autorun/zcity_models.lua"]=true,
["lua/cl_camera.lua"]=true,
["lua/cl_expression.lua"]=true,
["lua/cl_optics.lua"]=true,
["lua/cl_panel.lua"]=true,
["lua/cl_shells.lua"]=true,
["lua/cl_theme.lua"]=true,
["lua/contentsearch.lua"]=true,
["lua/derma/derma.lua"]=true,
["lua/derma/derma_animation.lua"]=true,
["lua/derma/derma_example.lua"]=true,
["lua/derma/derma_gwen.lua"]=true,
["lua/derma/derma_menus.lua"]=true,
["lua/derma/derma_utils.lua"]=true,
["lua/derma/init.lua"]=true,
["lua/drive/drive_base.lua"]=true,
["lua/drive/drive_noclip.lua"]=true,
["lua/drive/drive_sandbox.lua"]=true,
["lua/entities/arc9_eft_40mm_m381_bang.lua"]=true,
["lua/entities/arc9_eft_40mm_m386_bang.lua"]=true,
["lua/entities/arc9_eft_40mm_m406_bang.lua"]=true,
["lua/entities/arc9_eft_40mm_m433_bang.lua"]=true,
["lua/entities/arc9_eft_40mm_m441_bang.lua"]=true,
["lua/entities/arc9_eft_grenade_base.lua"]=true,
["lua/entities/arcticvr_att.lua"]=true,
["lua/entities/arcticvr_mag.lua"]=true,
["lua/entities/ba2_airwaste.lua"]=true,
["lua/entities/ba2_barrel.lua"]=true,
["lua/entities/ba2_gasmask.lua"]=true,
["lua/entities/ba2_gasmask_filter.lua"]=true,
["lua/entities/ba2_gib.lua"]=true,
["lua/entities/ba2_hordespawner.lua"]=true,
["lua/entities/ba2_infbody.lua"]=true,
["lua/entities/ba2_infection_manager.lua"]=true,
["lua/entities/ba2_maskcitizen.lua"]=true,
["lua/entities/ba2_maskcitizen_medic.lua"]=true,
["lua/entities/ba2_maskcitizen_rebel.lua"]=true,
["lua/entities/ba2_pointspawner.lua"]=true,
["lua/entities/ba2_radiobaby.lua"]=true,
["lua/entities/ba2_virus_cloud.lua"]=true,
["lua/entities/ba2_virus_sample.lua"]=true,
["lua/entities/ent_hmcd_mansion_cuestick.lua"]=true,
["lua/entities/ent_hmcd_mansion_cup.lua"]=true,
["lua/entities/ent_hmcd_mansion_knife.lua"]=true,
["lua/entities/ent_hmcd_mansion_pencils.lua"]=true,
["lua/entities/ent_hmcd_mansion_poker.lua"]=true,
["lua/entities/ent_hmcd_mansion_sheet.lua"]=true,
["lua/entities/it_goes_in_the_dark.lua"]=true,
["lua/entities/nb_ba2_infected.lua"]=true,
["lua/entities/nb_ba2_infected_citizen.lua"]=true,
["lua/entities/nb_ba2_infected_combine.lua"]=true,
["lua/entities/nb_ba2_infected_custom.lua"]=true,
["lua/entities/nb_ba2_infected_custom_armored.lua"]=true,
["lua/entities/nb_ba2_infected_police.lua"]=true,
["lua/entities/nb_ba2_infected_rebel.lua"]=true,
["lua/entities/npc_scug_f/shared.lua"]=true,
["lua/entities/npc_scug_h/shared.lua"]=true,
["lua/entities/npc_vj_cof_baby/shared.lua"]=true,
["lua/entities/npc_vj_cof_child/shared.lua"]=true,
["lua/entities/npc_vj_cof_citalopram/shared.lua"]=true,
["lua/entities/npc_vj_cof_crawler/shared.lua"]=true,
["lua/entities/npc_vj_cof_crazyrunner/shared.lua"]=true,
["lua/entities/npc_vj_cof_croucher/shared.lua"]=true,
["lua/entities/npc_vj_cof_faceless2/shared.lua"]=true,
["lua/entities/npc_vj_cof_faster/shared.lua"]=true,
["lua/entities/npc_vj_cof_krypandenej/shared.lua"]=true,
["lua/entities/npc_vj_cof_mace/shared.lua"]=true,
["lua/entities/npc_vj_cof_phsycho/shared.lua"]=true,
["lua/entities/npc_vj_cof_sawcrazy/shared.lua"]=true,
["lua/entities/npc_vj_cof_sawer/shared.lua"]=true,
["lua/entities/npc_vj_cof_sawrunner/shared.lua"]=true,
["lua/entities/npc_vj_cof_sewmo/shared.lua"]=true,
["lua/entities/npc_vj_cof_slower1/shared.lua"]=true,
["lua/entities/npc_vj_cof_slower3/shared.lua"]=true,
["lua/entities/npc_vj_cof_slowerno/shared.lua"]=true,
["lua/entities/npc_vj_cof_slowerstuck/shared.lua"]=true,
["lua/entities/npc_vj_cof_stranger/shared.lua"]=true,
["lua/entities/npc_vj_cof_suicider/shared.lua"]=true,
["lua/entities/npc_vj_cof_taller/shared.lua"]=true,
["lua/entities/npc_vj_cof_upper/shared.lua"]=true,
["lua/entities/npc_vj_cof_watro/shared.lua"]=true,
["lua/entities/npc_vj_creature_base/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_ally/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_ally_creature/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_frnd/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_hstl/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_hstl_creature/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_hstl_creaturebackup/shared.lua"]=true,
["lua/entities/npc_vj_garn47_car_lowpoly_frnd/shared.lua"]=true,
["lua/entities/npc_vj_human_base/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_f_nurse/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_female/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_airport/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_ceda/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_clown/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_fallsur/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_hospital/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_jimmy/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_mudmen/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_police/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_riot/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_soldier/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_m_worker/shared.lua"]=true,
["lua/entities/npc_vj_l4d_com_male/shared.lua"]=true,
["lua/entities/npc_vj_tank_base/shared.lua"]=true,
["lua/entities/npc_vj_tankg_base/shared.lua"]=true,
["lua/entities/npc_vj_test_aerial/shared.lua"]=true,
["lua/entities/npc_vj_test_humanply/shared.lua"]=true,
["lua/entities/npc_vj_test_interactive/shared.lua"]=true,
["lua/entities/npc_vj_test_player/shared.lua"]=true,
["lua/entities/obj_vj_blasterrod.lua"]=true,
["lua/entities/obj_vj_bonefollower.lua"]=true,
["lua/entities/obj_vj_bullseye.lua"]=true,
["lua/entities/obj_vj_combineball.lua"]=true,
["lua/entities/obj_vj_controller/shared.lua"]=true,
["lua/entities/obj_vj_crossbowbolt.lua"]=true,
["lua/entities/obj_vj_flareround.lua"]=true,
["lua/entities/obj_vj_gib/shared.lua"]=true,
["lua/entities/obj_vj_grenade.lua"]=true,
["lua/entities/obj_vj_grenade_rifle.lua"]=true,
["lua/entities/obj_vj_l4d_pipebomb.lua"]=true,
["lua/entities/obj_vj_npccontroller/shared.lua"]=true,
["lua/entities/obj_vj_projectile_base/shared.lua"]=true,
["lua/entities/obj_vj_rocket.lua"]=true,
["lua/entities/obj_vj_spawner_base/shared.lua"]=true,
["lua/entities/obj_vj_tank_shell.lua"]=true,
["lua/entities/prop_vj_animatable/shared.lua"]=true,
["lua/entities/prop_vj_board.lua"]=true,
["lua/entities/prop_vj_flag.lua"]=true,
["lua/entities/sent_ball.lua"]=true,
["lua/entities/sent_vj_adminhealthkit.lua"]=true,
["lua/entities/sent_vj_board.lua"]=true,
["lua/entities/sent_vj_campfire.lua"]=true,
["lua/entities/sent_vj_cof_allrand/shared.lua"]=true,
["lua/entities/sent_vj_cof_allrand_spawner/shared.lua"]=true,
["lua/entities/sent_vj_fireplace.lua"]=true,
["lua/entities/sent_vj_l4d_cominf.lua"]=true,
["lua/entities/sent_vj_l4d_cominf_sp.lua"]=true,
["lua/entities/sent_vj_l4d_director/shared.lua"]=true,
["lua/entities/sent_vj_ply_healthkit.lua"]=true,
["lua/entities/sent_vj_ply_spawn.lua"]=true,
["lua/entities/sent_vj_ply_spawnpoint.lua"]=true,
["lua/entities/sent_vj_test/shared.lua"]=true,
["lua/entities/synth_soldier_pulsenade.lua"]=true,
["lua/entities/terminator_nextbot/compatibilityhacks.lua"]=true,
["lua/entities/terminator_nextbot/shared.lua"]=true,
["lua/entities/terminator_nextbot/sharedextras.lua"]=true,
["lua/entities/terminator_nextbot_base/cl_init.lua"]=true,
["lua/entities/terminator_nextbot_base/cl_playercontrol.lua"]=true,
["lua/entities/terminator_nextbot_base/drive.lua"]=true,
["lua/entities/terminator_nextbot_base/shared.lua"]=true,
["lua/entities/terminator_nextbot_base/tasks.lua"]=true,
["lua/entities/terminator_nextbot_fakeply.lua"]=true,
["lua/entities/terminator_nextbot_slower.lua"]=true,
["lua/entities/terminator_nextbot_snail.lua"]=true,
["lua/entities/terminator_nextbot_snail_disguised.lua"]=true,
["lua/entities/terminator_nextbot_soldier_base.lua"]=true,
["lua/entities/terminator_nextbot_wraith.lua"]=true,
["lua/entities/terminator_nextbot_zambie/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambie_slow/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambieacid/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambieacidfast/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambieberserk/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiebiggerheadcrab/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiebigheadcrab/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiecop/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiecrabbaby/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiefast/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiefastgrunt/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambieflame/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiegrunt/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiegruntelite/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambienecro/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambietank/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambietorso/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambietorsofast/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambietorsowraith/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiewraith/shared.lua"]=true,
["lua/entities/terminator_nextbot_zambiewraithelite/shared.lua"]=true,
["lua/entities/tombstone.lua"]=true,
["lua/entities/true_sign.lua"]=true,
["lua/entities/widget_arrow.lua"]=true,
["lua/entities/widget_axis.lua"]=true,
["lua/entities/widget_base.lua"]=true,
["lua/entities/widget_bones.lua"]=true,
["lua/entities/widget_disc.lua"]=true,
["lua/entities/zambie_easy_nextbot_spawnpoint/shared.lua"]=true,
["lua/entities/zambie_nextbot_spawnpoint/shared.lua"]=true,
["lua/entities/zb_betau_throwing_knife.lua"]=true,
["lua/entities/zb_proj_myt_cmb_nade.lua"]=true,
["lua/fprofiler/cami.lua"]=true,
["lua/fprofiler/gather.lua"]=true,
["lua/fprofiler/prettyprint.lua"]=true,
["lua/fprofiler/report.lua"]=true,
["lua/fprofiler/ui/clientcontrol.lua"]=true,
["lua/fprofiler/ui/frame.lua"]=true,
["lua/fprofiler/ui/model.lua"]=true,
["lua/fprofiler/ui/servercontrol.lua"]=true,
["lua/fprofiler/util.lua"]=true,
["lua/gui/chatroom.lua"]=true,
["lua/gui/config.lua"]=true,
["lua/gui/editor.lua"]=true,
["lua/gui/expression_list.lua"]=true,
["lua/gui/form.lua"]=true,
["lua/gui/frame.lua"]=true,
["lua/gui/mysql.lua"]=true,
["lua/gui/rank_list.lua"]=true,
["lua/gui/restrictions.lua"]=true,
["lua/gui/slider.lua"]=true,
["lua/homigrad/abnormalty_detection/cl_help.lua"]=true,
["lua/homigrad/abnormalty_detection/cl_plugin.lua"]=true,
["lua/homigrad/abnormalty_detection/langs/sh_words.lua"]=true,
["lua/homigrad/abnormalty_detection/sh_plugin.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/cl_swarm.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/ent_swm_projectile.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm_bullseye.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm_mother.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm_sentinel.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm_sentry.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/npc_swarm_thumper.lua"]=true,
["lua/homigrad/abnormalty_detection/swarm/swarm_ai_base.lua"]=true,
["lua/homigrad/abnormalty_detection/weapons/sh_weapon_bleeding_musket.lua"]=true,
["lua/homigrad/abnormalty_detection/weapons/sh_weapon_thaumaturgic_arm.lua"]=true,
["lua/homigrad/achievements/cl_achievement.lua"]=true,
["lua/homigrad/admin_tools/cl_init.lua"]=true,
["lua/homigrad/admin_tools/derma/cl_mainbar.lua"]=true,
["lua/homigrad/admin_tools/sh_init.lua"]=true,
["lua/homigrad/admin_tools/sh_player_properties.lua"]=true,
["lua/homigrad/appearance/cl_appearance.lua"]=true,
["lua/homigrad/appearance/derma/cl_apperance.lua"]=true,
["lua/homigrad/appearance/derma/cl_plymodel_preview.lua"]=true,
["lua/homigrad/appearance/sh_accessories.lua"]=true,
["lua/homigrad/appearance/sh_appearance.lua"]=true,
["lua/homigrad/cl_bulletholes.lua"]=true,
["lua/homigrad/cl_camera.lua"]=true,
["lua/homigrad/cl_comunication.lua"]=true,
["lua/homigrad/cl_hud.lua"]=true,
["lua/homigrad/cl_postprocess.lua"]=true,
["lua/homigrad/cl_tpik.lua"]=true,
["lua/homigrad/dynamic_music/cl_init.lua"]=true,
["lua/homigrad/dynamic_music/sh_packs.lua"]=true,
["lua/homigrad/explosives/cl_explosives.lua"]=true,
["lua/homigrad/fake/cl_fake.lua"]=true,
["lua/homigrad/gunposmenu/cl_menu.lua"]=true,
["lua/homigrad/gunposmenu/sh_positioning.lua"]=true,
["lua/homigrad/hud/cl_weapon_selector.lua"]=true,
["lua/homigrad/libraries/cl_3d2dvgui.lua"]=true,
["lua/homigrad/libraries/core/sh_netsream2.lua"]=true,
["lua/homigrad/libraries/core/sh_networking.lua"]=true,
["lua/homigrad/libraries/outline.lua"]=true,
["lua/homigrad/libraries/pointshop/derma/cl_playerview.lua"]=true,
["lua/homigrad/libraries/pointshop/derma/cl_pointshop.lua"]=true,
["lua/homigrad/libraries/pointshop/sh_pointshop.lua"]=true,
["lua/homigrad/libraries/pon.lua"]=true,
["lua/homigrad/liquid_drum/particles/cl_gasoline.lua"]=true,
["lua/homigrad/liquid_drum/particles/cl_main.lua"]=true,
["lua/homigrad/liquid_drum/particles/input/input_cl.lua"]=true,
["lua/homigrad/liquid_drum/sh_liquid_drum.lua"]=true,
["lua/homigrad/loadme/cl_anticheat_uncompressed.lua"]=true,
["lua/homigrad/minstd.lua"]=true,
["lua/homigrad/new_appearance/cl_init.lua"]=true,
["lua/homigrad/new_appearance/sh_accessories.lua"]=true,
["lua/homigrad/new_appearance/sh_shared.lua"]=true,
["lua/homigrad/optionsmenu/cl_menu.lua"]=true,
["lua/homigrad/organism/cl_headcrab.lua"]=true,
["lua/homigrad/organism/tier_0/cl_tier_0.lua"]=true,
["lua/homigrad/organism/tier_0/sh_hitboxorgans.lua"]=true,
["lua/homigrad/organism/tier_1/cl_main.lua"]=true,
["lua/homigrad/organism/tier_1/cl_statistics.lua"]=true,
["lua/homigrad/organism/tier_1/modules/cl_virus.lua"]=true,
["lua/homigrad/organism/tier_1/modules/particles/cl_blood.lua"]=true,
["lua/homigrad/organism/tier_1/modules/particles/cl_blood2.lua"]=true,
["lua/homigrad/organism/tier_1/modules/particles/cl_main.lua"]=true,
["lua/homigrad/organism/tier_1/modules/particles/input/cl_input.lua"]=true,
["lua/homigrad/phys_bullets/cl_plugin.lua"]=true,
["lua/homigrad/phys_bullets/sh_plugin.lua"]=true,
["lua/homigrad/phys_silk/cl_plugin.lua"]=true,
["lua/homigrad/phys_silk/sh_plugin.lua"]=true,
["lua/homigrad/roleplus/cl_plugin.lua"]=true,
["lua/homigrad/roleplus/sh_plugin.lua"]=true,
["lua/homigrad/sh_bone_layers.lua"]=true,
["lua/homigrad/sh_debug.lua"]=true,
["lua/homigrad/sh_effects.lua"]=true,
["lua/homigrad/sh_equipment.lua"]=true,
["lua/homigrad/sh_hg_ammo.lua"]=true,
["lua/homigrad/sh_hg_armor.lua"]=true,
["lua/homigrad/sh_hg_attachments.lua"]=true,
["lua/homigrad/sh_inventory.lua"]=true,
["lua/homigrad/sh_luabullets.lua"]=true,
["lua/homigrad/sh_notification.lua"]=true,
["lua/homigrad/sh_phrases.lua"]=true,
["lua/homigrad/sh_quaternions.lua"]=true,
["lua/homigrad/sh_screengrab.lua"]=true,
["lua/homigrad/sh_util.lua"]=true,
["lua/homigrad/sh_zmeyka.lua"]=true,
["lua/homigrad/synthesizer/cl_plugin.lua"]=true,
["lua/homigrad/synthesizer/sh_plugin.lua"]=true,
["lua/igs/settings/config_sh.lua"]=true,
["lua/igs/settings/sh_additems.lua"]=true,
["lua/igs/settings/sh_addlevels.lua"]=true,
["lua/includes/extensions/angle.lua"]=true,
["lua/includes/extensions/client/entity.lua"]=true,
["lua/includes/extensions/client/globals.lua"]=true,
["lua/includes/extensions/client/panel.lua"]=true,
["lua/includes/extensions/client/panel/animation.lua"]=true,
["lua/includes/extensions/client/panel/dragdrop.lua"]=true,
["lua/includes/extensions/client/panel/scriptedpanels.lua"]=true,
["lua/includes/extensions/client/panel/selections.lua"]=true,
["lua/includes/extensions/client/player.lua"]=true,
["lua/includes/extensions/client/render.lua"]=true,
["lua/includes/extensions/coroutine.lua"]=true,
["lua/includes/extensions/debug.lua"]=true,
["lua/includes/extensions/entity.lua"]=true,
["lua/includes/extensions/ents.lua"]=true,
["lua/includes/extensions/file.lua"]=true,
["lua/includes/extensions/game.lua"]=true,
["lua/includes/extensions/math.lua"]=true,
["lua/includes/extensions/math/ease.lua"]=true,
["lua/includes/extensions/motionsensor.lua"]=true,
["lua/includes/extensions/net.lua"]=true,
["lua/includes/extensions/player.lua"]=true,
["lua/includes/extensions/player_auth.lua"]=true,
["lua/includes/extensions/string.lua"]=true,
["lua/includes/extensions/table.lua"]=true,
["lua/includes/extensions/util.lua"]=true,
["lua/includes/extensions/util/worldpicker.lua"]=true,
["lua/includes/extensions/vector.lua"]=true,
["lua/includes/extensions/weapon.lua"]=true,
["lua/includes/gmsave.lua"]=true,
["lua/includes/gui/icon_progress.lua"]=true,
["lua/includes/init.lua"]=true,
["lua/includes/modules/ai_vj_schedule.lua"]=true,
["lua/includes/modules/ai_vj_task.lua"]=true,
["lua/includes/modules/vj_ai_nodegraph.lua"]=true,
["lua/includes/modules/vj_ai_schedule.lua"]=true,
["lua/includes/modules/vj_ai_task.lua"]=true,
["lua/includes/util.lua"]=true,
["lua/includes/util/client.lua"]=true,
["lua/includes/util/color.lua"]=true,
["lua/includes/util/javascript_util.lua"]=true,
["lua/includes/util/model_database.lua"]=true,
["lua/includes/util/sql.lua"]=true,
["lua/includes/util/tooltips.lua"]=true,
["lua/includes/util/vgui_showlayout.lua"]=true,
["lua/includes/util/workshop_files.lua"]=true,
["lua/initpost/cl_derma_skin.lua"]=true,
["lua/initpost/menu-n-derma/cl_init.lua"]=true,
["lua/initpost/menu-n-derma/derma/cl_frame.lua"]=true,
["lua/initpost/menu-n-derma/derma/cl_menu_options.lua"]=true,
["lua/initpost/menu-n-derma/derma/cl_menu_panel.lua"]=true,
["lua/loader.lua"]=true,
["lua/minstd.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/contextmenu.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controlpanel.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/control_presets.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/ctrlcolor.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/ctrllistbox.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/ctrlnumpad.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/manifest.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/preset_editor.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/controls/ropematerial.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/content.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contentcontainer.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contentheader.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenticon.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contentsearch.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contentsidebar.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contentsidebartoolbox.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/addonprops.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/custom.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/dupes.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/entities.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/gameprops.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/npcs.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/postprocess.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/saves.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/vehicles.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/weapons.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/content/postprocessicon.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/creationmenu/manifest.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/spawnmenu.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/toolmenu.lua"]=true,
["lua/sandbox/gamemode/spawnmenu/toolpanel.lua"]=true,
["lua/sh_ammo.lua"]=true,
["lua/sh_anim.lua"]=true,
["lua/sh_attachment.lua"]=true,
["lua/sh_bullet.lua"]=true,
["lua/sh_config.lua"]=true,
["lua/sh_fake.lua"]=true,
["lua/sh_holster_deploy.lua"]=true,
["lua/sh_reload.lua"]=true,
["lua/sh_replicate.lua"]=true,
["lua/sh_spray.lua"]=true,
["lua/sh_utilities.lua"]=true,
["lua/sh_weaponsinv.lua"]=true,
["lua/sh_worldmodel.lua"]=true,
["lua/shared.lua"]=true,
["lua/simfphys/anim.lua"]=true,
["lua/simfphys/base_functions.lua"]=true,
["lua/simfphys/base_lights.lua"]=true,
["lua/simfphys/base_vehicles.lua"]=true,
["lua/simfphys/client/damage.lua"]=true,
["lua/simfphys/client/fonts.lua"]=true,
["lua/simfphys/client/hud.lua"]=true,
["lua/simfphys/client/lighting.lua"]=true,
["lua/simfphys/client/poseparameter.lua"]=true,
["lua/simfphys/client/seatcontrols.lua"]=true,
["lua/simfphys/client/tab.lua"]=true,
["lua/simfphys/init.lua"]=true,
["lua/simfphys/view.lua"]=true,
["lua/simfphysextra/cl_init.lua"]=true,
["lua/simfphysextra/hooks.lua"]=true,
["lua/simfphysextra/init.lua"]=true,
["lua/simfphysextra/shared.lua"]=true,
["lua/simfphysextra/tab.lua"]=true,
["lua/skins/default.lua"]=true,
["lua/stools/loot_editor.lua"]=true,
["lua/stools/point_editor.lua"]=true,
["lua/stools/simfphysfueleditor.lua"]=true,
["lua/stools/submaterial.lua"]=true,
["lua/stools/vj_tool_bullseye.lua"]=true,
["lua/stools/vj_tool_equipment.lua"]=true,
["lua/stools/vj_tool_follower.lua"]=true,
["lua/stools/vj_tool_health.lua"]=true,
["lua/stools/vj_tool_mover.lua"]=true,
["lua/stools/vj_tool_notarget.lua"]=true,
["lua/stools/vj_tool_relationship.lua"]=true,
["lua/stools/vj_tool_scanner.lua"]=true,
["lua/stools/vj_tool_spawner.lua"]=true,
["lua/stools/vjstool_bullseye.lua"]=true,
["lua/stools/vjstool_entityscanner.lua"]=true,
["lua/stools/vjstool_healthmodifier.lua"]=true,
["lua/stools/vjstool_notarget.lua"]=true,
["lua/stools/vjstool_npcequipment.lua"]=true,
["lua/stools/vjstool_npcfollower.lua"]=true,
["lua/stools/vjstool_npcmover.lua"]=true,
["lua/stools/vjstool_npcrelationship.lua"]=true,
["lua/stools/vjstool_npcspawner.lua"]=true,
["lua/stools/zbase_guard.lua"]=true,
["lua/stools/zbase_mover.lua"]=true,
["lua/subtitles/subtitle_test.lua"]=true,
["lua/subtitles/vj_garn47_car_subs.lua"]=true,
["lua/themes/black.lua"]=true,
["lua/themes/blur.lua"]=true,
["lua/themes/default.lua"]=true,
["lua/themes/source_engine.lua"]=true,
["lua/ulib/cl_init.lua"]=true,
["lua/ulib/client/cl_util.lua"]=true,
["lua/ulib/client/commands.lua"]=true,
["lua/ulib/client/draw.lua"]=true,
["lua/ulib/modules/ulx_init.lua"]=true,
["lua/ulib/shared/cami_global.lua"]=true,
["lua/ulib/shared/cami_ulib.lua"]=true,
["lua/ulib/shared/commands.lua"]=true,
["lua/ulib/shared/defines.lua"]=true,
["lua/ulib/shared/hook.lua"]=true,
["lua/ulib/shared/messages.lua"]=true,
["lua/ulib/shared/misc.lua"]=true,
["lua/ulib/shared/player.lua"]=true,
["lua/ulib/shared/plugin.lua"]=true,
["lua/ulib/shared/sh_ucl.lua"]=true,
["lua/ulib/shared/tables.lua"]=true,
["lua/ulib/shared/util.lua"]=true,
["lua/ulx/cl_init.lua"]=true,
["lua/ulx/cl_lib.lua"]=true,
["lua/ulx/modules/cl/motdmenu.lua"]=true,
["lua/ulx/modules/cl/uteam.lua"]=true,
["lua/ulx/modules/cl/xgui_client.lua"]=true,
["lua/ulx/modules/cl/xgui_helpers.lua"]=true,
["lua/ulx/modules/cl/xlib.lua"]=true,
["lua/ulx/modules/sh/chat.lua"]=true,
["lua/ulx/modules/sh/fun.lua"]=true,
["lua/ulx/modules/sh/menus.lua"]=true,
["lua/ulx/modules/sh/rcon.lua"]=true,
["lua/ulx/modules/sh/teleport.lua"]=true,
["lua/ulx/modules/sh/user.lua"]=true,
["lua/ulx/modules/sh/userhelp.lua"]=true,
["lua/ulx/modules/sh/util.lua"]=true,
["lua/ulx/modules/sh/vote.lua"]=true,
["lua/ulx/sh_base.lua"]=true,
["lua/ulx/sh_defines.lua"]=true,
["lua/ulx/xgui/bans.lua"]=true,
["lua/ulx/xgui/commands.lua"]=true,
["lua/ulx/xgui/gamemodes/sandbox.lua"]=true,
["lua/ulx/xgui/groups.lua"]=true,
["lua/ulx/xgui/maps.lua"]=true,
["lua/ulx/xgui/settings.lua"]=true,
["lua/ulx/xgui/settings/client.lua"]=true,
["lua/ulx/xgui/settings/server.lua"]=true,
["lua/vj_base/convars.lua"]=true,
["lua/vj_base/debug.lua"]=true,
["lua/vj_base/enums.lua"]=true,
["lua/vj_base/extensions/corpse.lua"]=true,
["lua/vj_base/extensions/music.lua"]=true,
["lua/vj_base/funcs.lua"]=true,
["lua/vj_base/hooks.lua"]=true,
["lua/vj_base/menu/entity_configures.lua"]=true,
["lua/vj_base/menu/entity_properties.lua"]=true,
["lua/vj_base/menu/main.lua"]=true,
["lua/vj_base/menu/spawn.lua"]=true,
["lua/vj_base/plugins/garn47_car.lua"]=true,
["lua/vj_base/plugins/official_cryoffear.lua"]=true,
["lua/vj_base/plugins/official_l4d_cominf.lua"]=true,
["lua/vj_base/resources/localization.lua"]=true,
["lua/vj_base/resources/main.lua"]=true,
["lua/vj_base/resources/particles.lua"]=true,
["lua/vj_base/resources/sounds.lua"]=true,
["lua/vrmod/0/vrmod_api.lua"]=true,
["lua/vrmod/1/vrmod_doors.lua"]=true,
["lua/vrmod/cardboardmod.lua"]=true,
["lua/vrmod/vrmod.lua"]=true,
["lua/vrmod/vrmod_actioneditor.lua"]=true,
["lua/vrmod/vrmod_changelog.lua"]=true,
["lua/vrmod/vrmod_character.lua"]=true,
["lua/vrmod/vrmod_character_fbt.lua"]=true,
["lua/vrmod/vrmod_character_hands.lua"]=true,
["lua/vrmod/vrmod_climbing.lua"]=true,
["lua/vrmod/vrmod_dermapopups.lua"]=true,
["lua/vrmod/vrmod_flashlight.lua"]=true,
["lua/vrmod/vrmod_halos.lua"]=true,
["lua/vrmod/vrmod_hud.lua"]=true,
["lua/vrmod/vrmod_input.lua"]=true,
["lua/vrmod/vrmod_locomotion.lua"]=true,
["lua/vrmod/vrmod_mapbrowser.lua"]=true,
["lua/vrmod/vrmod_menu.lua"]=true,
["lua/vrmod/vrmod_network.lua"]=true,
["lua/vrmod/vrmod_pickup.lua"]=true,
["lua/vrmod/vrmod_pickup_arcvr.lua"]=true,
["lua/vrmod/vrmod_pmchange.lua"]=true,
["lua/vrmod/vrmod_seated.lua"]=true,
["lua/vrmod/vrmod_spawnmenu_contextmenu.lua"]=true,
["lua/vrmod/vrmod_sranipal.lua"]=true,
["lua/vrmod/vrmod_steamvr_bindings.lua"]=true,
["lua/vrmod/vrmod_ui.lua"]=true,
["lua/vrmod/vrmod_ui_chat.lua"]=true,
["lua/vrmod/vrmod_ui_heightadjust.lua"]=true,
["lua/vrmod/vrmod_ui_quickmenu.lua"]=true,
["lua/vrmod/vrmod_ui_weaponselect.lua"]=true,
["lua/vrmod/vrmod_viewmodelinfo.lua"]=true,
["lua/vrmod/vrmod_worldtips.lua"]=true,
["lua/weapons/arc9_eft_base.lua"]=true,
["lua/weapons/arcticvr_base/cl_input.lua"]=true,
["lua/weapons/arcticvr_base/cl_melee.lua"]=true,
["lua/weapons/arcticvr_base/cl_misc.lua"]=true,
["lua/weapons/arcticvr_base/cl_reload.lua"]=true,
["lua/weapons/arcticvr_base/cl_shooting.lua"]=true,
["lua/weapons/arcticvr_base/cl_sights.lua"]=true,
["lua/weapons/arcticvr_base/cl_think.lua"]=true,
["lua/weapons/arcticvr_base/sh_attachments.lua"]=true,
["lua/weapons/arcticvr_base/shared.lua"]=true,
["lua/weapons/arcticvr_base_nade/shared.lua"]=true,
["lua/weapons/arcticvr_deagle/shared.lua"]=true,
["lua/weapons/arcticvr_glock/shared.lua"]=true,
["lua/weapons/arcticvr_m9/shared.lua"]=true,
["lua/weapons/arcticvr_mac10/shared.lua"]=true,
["lua/weapons/arcticvr_tmp/shared.lua"]=true,
["lua/weapons/gmod_tool/stools/submaterial.lua"]=true,
["lua/weapons/weapon_357_term.lua"]=true,
["lua/weapons/weapon_ar2_term.lua"]=true,
["lua/weapons/weapon_crossbow_term.lua"]=true,
["lua/weapons/weapon_crowbar_term.lua"]=true,
["lua/weapons/weapon_fists.lua"]=true,
["lua/weapons/weapon_flechettegun.lua"]=true,
["lua/weapons/weapon_flechettegun_term.lua"]=true,
["lua/weapons/weapon_frag_term.lua"]=true,
["lua/weapons/weapon_medkit.lua"]=true,
["lua/weapons/weapon_pistol_term.lua"]=true,
["lua/weapons/weapon_rpg_term.lua"]=true,
["lua/weapons/weapon_shotgun_term.lua"]=true,
["lua/weapons/weapon_slam_term.lua"]=true,
["lua/weapons/weapon_smg1_term.lua"]=true,
["lua/weapons/weapon_stunstick_term.lua"]=true,
["lua/weapons/weapon_term_zombieclaws.lua"]=true,
["lua/weapons/weapon_terminatorfists_term.lua"]=true,
["lua/weapons/weapon_vj_357.lua"]=true,
["lua/weapons/weapon_vj_9mmpistol.lua"]=true,
["lua/weapons/weapon_vj_ak47.lua"]=true,
["lua/weapons/weapon_vj_ar2.lua"]=true,
["lua/weapons/weapon_vj_base/ai_translations.lua"]=true,
["lua/weapons/weapon_vj_blaster.lua"]=true,
["lua/weapons/weapon_vj_controller.lua"]=true,
["lua/weapons/weapon_vj_crossbow.lua"]=true,
["lua/weapons/weapon_vj_crowbar.lua"]=true,
["lua/weapons/weapon_vj_flaregun.lua"]=true,
["lua/weapons/weapon_vj_glock17.lua"]=true,
["lua/weapons/weapon_vj_k3.lua"]=true,
["lua/weapons/weapon_vj_m16a1.lua"]=true,
["lua/weapons/weapon_vj_mp40.lua"]=true,
["lua/weapons/weapon_vj_rpg.lua"]=true,
["lua/weapons/weapon_vj_smg1.lua"]=true,
["lua/weapons/weapon_vj_spas12.lua"]=true,
["lua/weapons/weapon_vj_ssg08.lua"]=true,
["lua/weapons/weapon_zb_combsniper.lua"]=true,
["lua/weapons/weapon_zbase_betau_dpistol.lua"]=true,
["lua/weapons/weapon_zbase_betau_sniper.lua"]=true,
["lua/weapons/weapon_zbase_betau_spear.lua"]=true,
["lua/weapons/weapon_zbase_betau_spear_sg.lua"]=true,
["lua/weapons/weapon_zbase_cmbsniper.lua"]=true,
["lua/weapons/weapon_zbase_myt_pulse_smg.lua"]=true,
["lua/weapons/weapon_zbase_myt_wallhammer_sg.lua"]=true,
["lua/weapons/wep_hmcd_mansion_broomstick.lua"]=true,
["lua/weapons/wep_hmcd_mansion_cuestick.lua"]=true,
["lua/weapons/wep_hmcd_mansion_cup.lua"]=true,
["lua/weapons/wep_hmcd_mansion_knife.lua"]=true,
["lua/weapons/wep_hmcd_mansion_pencils.lua"]=true,
["lua/weapons/wep_hmcd_mansion_poker.lua"]=true,
["lua/zbase/entities/beta_unit_combine_assassin/shared.lua"]=true,
["lua/zbase/entities/beta_unit_combine_sniper/shared.lua"]=true,
["lua/zbase/entities/beta_unit_cremator/shared.lua"]=true,
["lua/zbase/entities/beta_unit_synth_assassin/shared.lua"]=true,
["lua/zbase/entities/beta_unit_synth_brown/shared.lua"]=true,
["lua/zbase/entities/beta_unit_synth_green/shared.lua"]=true,
["lua/zbase/entities/beta_unit_synth_soldier/shared.lua"]=true,
["lua/zbase/entities/beta_unit_synth_wasteland_scanner/shared.lua"]=true,
["lua/zbase/entities/ej_combine_sniper/shared.lua"]=true,
["lua/zbase/entities/zb_combine_juggernaut/shared.lua"]=true,
["lua/zbase/entities/zb_combine_juggernaut_elite/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_advisor/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_echoone/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_echoone_prospekt/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_pain/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_police_armourless/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_shield/shared.lua"]=true,
["lua/zbase/entities/zb_myt_cmb_wallham/shared.lua"]=true,
["lua/zbox_rp/gamemode/main/items/items/test.lua"]=true,
}

local v12 = {
	["lua/autorun/rb655_legacy_addon_props.lua"] = true,
}

local v13 = {
	["lua/ulx/modules/"] = true,
	["lua/postprocess/"] = true,
}

local v6 = {
	["gamemodes/"] = true,
	["lua/vrmod/"] = true,
}

local v7 = {
	["lua/ulib/"] = true,
	["lua/vgui/"] = true,
}

local v4 = {
	"addons/homig2",
	"addons/atlaschat",
	"addons/homigrad",
	"lua/ulx/",
	"lua/autorun/rb655_legacy_addon_props.lua",
	"lua/includes/modules/",
	"igs/",
}

local function compile_autoruns()
	local autoruns = {}
	
	local f, d = file.Find("addons/*", "GAME")
	
	for _, d_name1 in ipairs(d) do
		local f2, _ = file.Find("addons/" .. d_name1 .. "/lua/autorun/*", "GAME")
		
		for _, f_name1 in ipairs(f2) do
			autoruns["addons/" .. d_name1 .. "/lua/autorun/" .. f_name1] = true
		end
		
		local f2, _ = file.Find("addons/" .. d_name1 .. "/lua/autorun/client/*", "GAME")
		
		for _, f_name1 in ipairs(f2) do
			autoruns["addons/" .. d_name1 .. "/lua/autorun/client/" .. f_name1] = true
		end
	end
	
	local f, d = file.Find("lua/autorun/*", "GAME")
	
	for _, f_name1 in ipairs(f) do
		autoruns["lua/autorun/" .. f_name1] = true
	end
	
	local f, d = file.Find("lua/autorun/client/*", "GAME")
	
	for _, f_name1 in ipairs(f) do
		autoruns["lua/autorun/client/" .. f_name1] = true
	end
	
	local f, d = file.Find("lua/skins/*", "GAME")
	
	for _, f_name1 in ipairs(f) do
		autoruns["lua/skins/" .. f_name1] = true
	end
	
	return autoruns
end

local dog_color = Color(0, 0, 255)
DOG_E5A_MissingServerPaths = {}

--; DO NOT FORGET ["lua/includes/init.lua"] = true,

if(!OZ_Cache)then
	SetGlobalString("DOG_MAP", "no_cache")
	MsgC(dog_color, DOG.Name .. ": Cartography is not installed, Ezekiel5A will not work\n")
else
	local full_paths = table.Merge(OZ_Cache, compile_autoruns())
	
	for path, _ in pairs(full_paths) do
		local v8 = true
		
		if(#path >= 40)then
			if(v12[_G["string"]["sub"](path, 1, 40)])then
				v8 = false
			end
		end
		
		if(#path >= 16)then
			if(v13[_G["string"]["sub"](path, 1, 16)])then
				v8 = false
			end
		end
		
		if(#path >= 10)then
			if(v6[_G["string"]["sub"](path, 1, 10)])then
				v8 = false
			end
		end
		
		if(#path >= 9)then
			if(v7[_G["string"]["sub"](path, 1, 9)])then
				v8 = false
			end
		end
		
		if(v8)then
			for v9 = 1, #v4 do
				local v10 = v4[v9]
				
				if(_G["string"]["sub"](path, 1, #v10) == v10)then
					v8 = false
					
					break
				end
			end
		end
		
		if(v8)then
			if(!srv[path])then
				DOG_E5A_MissingServerPaths[path] = true
				
				SetGlobalString("DOG_MAP", "invalid")
				MsgC(dog_color, DOG.Name .. ": Update cartography! new path found (" .. path .. ") Ezekiel5A will not work\n")
			end
		end
	end
end

-- if(!netstream)then
	-- SetGlobalString("DOG_NS", "no")
-- end
--//