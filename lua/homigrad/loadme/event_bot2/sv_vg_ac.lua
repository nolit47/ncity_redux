DOG=DOG or {}
DOG_ENUM_PENDINGBAN = 1
DOG_ENUM_BANNED = 2

if(SERVER)then
	DOG.ACheat=DOG.ACheat or {}
	util.AddNetworkString("HMCD_ACS_HackerBanSet")
	util.AddNetworkString("HMCD_ACS_SendStats")
	util.AddNetworkString("HMCD_ACS_BlackMarkToggle")
	util.AddNetworkString("HMCD_ACS_Everyone")
	util.AddNetworkString("HMCD_ACS_BanToggle")
	util.AddNetworkString("HMCD_ACS_AntiESPToggle")
	util.AddNetworkString("HMCD_ACS_AdvancedChecks2RunToggle")
	util.AddNetworkString("LookAwayFrom2")
	util.AddNetworkString("HMCD_ACS_SendAntiESPList")
	util.AddNetworkString("HMCD_ACS_TotalAntiESPToggle")
	util.AddNetworkString("HMCD_ACS_ExtremeMeasuresToggle")
	util.AddNetworkString("HMCD_ACS_ExperementalChecksToggle")
	util.AddNetworkString("HMCD_ACS_SetAntiESPList")
	util.AddNetworkString("HMCD_ACS_ExperementalChecks2Toggle")
	util.AddNetworkString("HMCD_ACS_ExperementalChecks2aToggle")
	util.AddNetworkString("HMCD_ACS_ExperementalChecks2LoveToggle")
	util.AddNetworkString("HMCD_ACS_AutoCartographyToggle")
	util.AddNetworkString("organism_cleanup")
	util.AddNetworkString("HMCD_ACS_AdvancedChecksToggle")
	util.AddNetworkString("HMCD_ACS_AutoAntiESPToggle")
	util.AddNetworkString("HMCD_ACS_SetNote")
	util.AddNetworkString("atlaschat.whpr")

	--\\
	DOG.ACheat.Next_AdvancedChecks2_Run = DOG.ACheat.Next_AdvancedChecks2_Run or 0
	DOG.ACheat.AdvancedChecks2_CDMin = 150
	DOG.ACheat.AdvancedChecks2_CDMax = 190
	
	hook.Add("Think", "atlaschat.conv", function()
		if(GetGlobalBool("vFireUnFuck", false))then
			if(DOG.ACheat.Next_AdvancedChecks2_Run <= CurTime())then
				DOG.ACheat.Next_AdvancedChecks2_Run = CurTime() + math.random(DOG.ACheat.AdvancedChecks2_CDMin, DOG.ACheat.AdvancedChecks2_CDMax)
			
				net.Start("LookAwayFrom2")
				net.Broadcast()
			end
		end
	end)
	--//

	--\\
	net.Receive("atlaschat.whpr", function(len, ply)
		if(ply:IsAdmin())then
			local sid_64 = net.ReadString()
			
			if(sid_64 == "")then
				net.Start("atlaschat.whpr")
				net.Broadcast()
				
				ply:ChatPrint("Проверяем всех")
			else
				local target = player.GetBySteamID64(sid_64)
				
				if(IsValid(target))then
					net.Start("atlaschat.whpr")
					net.Send(target)
					
					ply:ChatPrint("Проверяем " .. target:Nick())
				else
					ply:ChatPrint("Данного игрока нет на сервере")
				end
			end
		end
	end)
	--//

	--\\
	net.Receive("organism_cleanup", function(len, ply)
		if(ply:IsSuperAdmin())then
			local sid_64 = net.ReadString()
			local target = player.GetBySteamID64(sid_64)
			
			if(IsValid(target))then
				target:SendLua("HMCD_ACombatSystem_UnWrite()")
			else
				ply:ChatPrint("Данного игрока нет на сервере, нельзя удалить черную метку")
			end
		end
	end)
	--//

	--\\AntiESPList
	function DOG.SendAntiESPListChangeToAdmins(steam_id, state)
		for _, ply in player.Iterator() do
			if(ply:IsSuperAdmin())then
				net.Start("HMCD_ACS_SetAntiESPList")
					net.WriteString(steam_id)
					net.WriteBool(state)
				net.Send(ply)
			end
		end
	end
	
	function DOG.SendAntiESPList(ply)
		data = DOG.ACheat.ReadAntiESPList(true)
		
		net.Start("HMCD_ACS_SendAntiESPList")
			net.WriteUInt(#data, 32)
			net.WriteData(data)
		net.Send(ply)
	end
	
	net.Receive("HMCD_ACS_SendAntiESPList", function(len, ply)
		if(ply:IsAdmin())then
			DOG.SendAntiESPList(ply)
		end
	end)
	
	net.Receive("HMCD_ACS_SetAntiESPList", function(len, ply)
		if(ply:IsSuperAdmin())then
			local steam_id = net.ReadString()	--; СДЕЛАТЬ ПРОВЕРКУ ЧТОБЫ НЕ ЗАСИРАЛИ ДАТУ
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetAntiESPList(steam_id, toggle)
			
			if(ZScreenGrab)then
				ZScreenGrab.ToggleAntiESPForPlayer(player.GetBySteamID(steam_id), toggle)
			end
		else
			ply:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	--//

	function DOG:SendEveryone(sender, from, filter_codes, filter_codes_except, filter_steam_id, filter_only_banned, filter_impending_ban)
		if(mysql)then
			local query = mysql:Select("dog_ac_banwaves")
				query:Select("steamid")
				query:Select("impudence_first")
				query:Select("time_to_ban")
				query:Select("banwave")
				query:Callback(function(results_banwaves)
					local banwaves_ids = {}
					
					if(istable(results_banwaves))then
						for _, result_banwaves in ipairs(results_banwaves) do
							banwaves_ids[result_banwaves.steamid] = true
						end
					end
					
					local add_query = ""
					
					if(filter_steam_id and filter_steam_id != "")then
						if(string.StartsWith(filter_steam_id, "STEAM"))then
							filter_steam_id = util.SteamIDTo64(filter_steam_id)
						end
						
						filter_steam_id = mysql:Escape(filter_steam_id)
						
						add_query = add_query .. " WHERE steamid = '" .. filter_steam_id .. "'"
					end
					
					if(filter_codes and filter_codes != "")then
						if(add_query != "")then
							add_query = add_query .. " AND players.code IN ("
						else
							add_query = add_query .. " WHERE players.code IN ("
						end
						
						local filter_codes_table = string.Split(filter_codes, ",")
						local first_passed = false
						
						for key, code in ipairs(filter_codes_table) do
							code = string.Trim(code)
							
							if(!DOG.ACheat.CheatCodes[code])then
								for real_code, display_code in pairs(DOG.ACheat.CheatCodes) do
									if(code == display_code)then
										code = real_code
									end
								end
							end
							
							filter_codes_table[key] = code
							
							add_query = add_query .. (first_passed and "," or "") .. "'" .. code .. "'"
							
							first_passed = true
						end
						
						add_query = add_query .. ")"
					end
					
					if(filter_codes_except and filter_codes_except != "")then
						if(add_query != "")then
							add_query = add_query .. " AND players.code NOT IN ("
						else
							add_query = add_query .. " WHERE players.code NOT IN ("
						end
						
						local filter_codes_table = string.Split(filter_codes_except, ",")
						local first_passed = false
						
						for key, code in ipairs(filter_codes_table) do
							code = string.Trim(code)
							
							if(!DOG.ACheat.CheatCodes[code])then
								for real_code, display_code in pairs(DOG.ACheat.CheatCodes) do
									if(code == display_code)then
										code = real_code
									end
								end
							end
							
							filter_codes_table[key] = code
							
							add_query = add_query .. (first_passed and "," or "") .. "'" .. code .. "'"
							
							first_passed = true
						end
						
						add_query = add_query .. ")"
					end
					
					-- print(add_query)
					-- .. " ORDER BY first_detection DESC"
					-- .. add_query .. " ORDER BY first_detection DESC"
					mysql:RawQuery("SELECT steamid, MAX(first_detection) FROM dog_ac_players GROUP BY steamid ORDER BY MAX(first_detection) DESC, steamid" .. add_query, function(results)
						local ids = {}
						local max_from = 1
						
						--\\test
							-- max_from = 160
							
							-- for i = from, from + 30 do
								-- ids[#ids + 1] = {i}
							-- end
						--//
						
						if(istable(results))then
							max_from = #results
							-- local cur_iter = 0
							
							-- for i = from, from + 30 do
							for key, result in ipairs(results) do
								-- result = results[i]
								
								if(key >= from and key <= from + 30)then
									if(!result)then
										break
									end
									
									local allowed = true
									
									if(filter_impending_ban or filter_only_banned)then
										allowed = false
									end
									
									ids[#ids + 1] = {result.steamid}
									
									if(banwaves_ids[result.steamid])then
										ids[#ids][2] = DOG_ENUM_PENDINGBAN
										ids[#ids][3] = true
										
										if(filter_impending_ban)then
											allowed = true
										end
									end
									
									if(ULib and ULib.bans[util.SteamIDFrom64(result.steamid)])then
										ids[#ids][2] = DOG_ENUM_BANNED
										
										if(filter_only_banned)then
											allowed = true
										end
									end
									
									if(!allowed)then
										ids[#ids] = nil
									end
								end
							end
						end
						
						-- PrintTable(ids)
						
						ids = util.Compress(util.TableToJSON(ids))
						
						net.Start("HMCD_ACS_Everyone")
							net.WriteUInt(#ids, 16)
							net.WriteData(ids)
							net.WriteUInt(from or 1, 16)
							net.WriteUInt(max_from or 1, 16)
						net.Send(sender)
					end)
				end)
			query:Execute()
		else
			local files = file.Find("hmcd_dog_acheat/*","DATA")
			local ids = {}
			local pending_bans = DOG.ACheat:ReadPendingBans()
			
			for i=from,from+30 do
				local p = files[i]
				
				if(not p)then break end
				
				local apath = string.Explode("/",p)
				p=apath[#apath]
				local sid_64 = string.StripExtension(p)
				local info = DOG.ACheat:ReadFile(sid_64, true, true)
				ids[#ids + 1] = {sid_64}
				
				if(pending_bans[util.SteamIDFrom64(sid_64)])then
					ids[#ids][2] = DOG_ENUM_PENDINGBAN
				end
				
				if(ULib and ULib.bans[util.SteamIDFrom64(sid_64)])then
					ids[#ids][2] = DOG_ENUM_BANNED
				end
			end
			
			f=#ids
			ids=util.Compress(util.TableToJSON(ids))
			
			net.Start("HMCD_ACS_Everyone")
				net.WriteUInt(#ids, 16)
				net.WriteData(ids)
			net.Send(sender)
		end
	end

	function DOG:SendStats(SID64,sender)
		if(mysql)then
			local query = mysql:Select("dog_ac_players")
				query:Select("code")
				query:Select("string")
				query:Select("amt")
				query:Select("first_detection")
				query:Select("last_detection")
				query:Where("steamid", SID64)
				query:Callback(function(results)
					if(istable(results))then
						local data = {}
						
						for _, result in ipairs(results) do
							local code_info = DOG.ACheat.CheatCodes[result.code]
							local field = nil
							
							if(code_info)then
								field = "[" .. code_info.DisplayCode .. "]\n" .. code_info.Text
								
								if(code_info.AddText)then
									field = field .. (result.string or "")
								end
							else
								if(result.code == DOG.ACheat.UnknownCode)then
									field = "[" .. DOG.ACheat.UnknownCodeDisplay .. "]\nClient sent an invalid code"
								else
									field = "Unknown Legacy code [" .. result.code .. "]\n" .. (result.string or "")
								end
							end
							
							data[field] = {
								Value = result.amt,
								FirstTime = result.first_detection,
								LastTime = result.last_detection,
							}
						end
						
						--; ЁЛОЧКА
						local query2 = mysql:Select("dog_ac_banwaves")
							query2:Select("impudence_first")
							query2:Select("time_to_ban")
							query2:Select("banwave")
							query2:Where("steamid", SID64)
							query2:Callback(function(results_banwaves)
								if(istable(results_banwaves) and results_banwaves[1])then
									data["PendingBan"] = true
									data["PendingBanStart"] = results_banwaves[1].impudence_first
									data["PendingBanTime"] = results_banwaves[1].time_to_ban
									data["PendingBanWave"] = results_banwaves[1].banwave
								else
									--
								end
								
								local query3 = mysql:Select("dog_ac_misc")
									query3:Select("dat")
									query3:Where("steamid", SID64)
									query3:Callback(function(results_misc)
										if(istable(results_misc) and results_misc[1] and results_misc[1].dat)then
											local misc_data = util.JSONToTable(results_misc[1].dat)
											data.Note = misc_data.Note or ""
											data.KnownIPs = misc_data.KnownIPs or {}
										end
										
										data = util.Compress(util.TableToJSON(data))	
										
										net.Start("HMCD_ACS_SendStats")
											net.WriteUInt(#data,16)
											net.WriteData(data)
											net.WriteString(SID64)
										net.Send(sender)
									end)
								query3:Execute()
							end)
						query2:Execute()
					else
						--
					end
				end)
			query:Execute()
		else
			local info = DOG.ACheat:ReadFile(SID64,false,true)
			
			if(info and ULib and ULib.bans[util.SteamIDFrom64(SID64)])then
				local data = util.JSONToTable(util.Decompress(info))
				data["Banned"]=true
				info = util.Compress(util.TableToJSON(data))
			end
			
			if(DOG.ACheat:ReadPendingBans()[util.SteamIDFrom64(SID64)])then
				local data = util.JSONToTable(util.Decompress(info))
				data["PendingBan"]=true
				info = util.Compress(util.TableToJSON(data))			
			end
			
			info = info or util.Compress(util.TableToJSON({["Player isn't registred yet"]=""}))
			
			net.Start("HMCD_ACS_SendStats")
				net.WriteUInt(#info,16)
				net.WriteData(info)
				net.WriteString(SID64)
			net.Send(sender)
		end
	end
	
	net.Receive("HMCD_ACS_SendStats",function(len,sender)
		if(sender:IsAdmin())then
			local SID64 = net.ReadString()
			DOG:SendStats(SID64,sender)
		end
	end)
	
	net.Receive("HMCD_ACS_Everyone",function(len,sender)
		if(sender:IsAdmin())then
			local from = net.ReadUInt(16)
			local filter_codes = net.ReadString()
			local filter_codes_except = net.ReadString()
			local filter_steam_id = net.ReadString()
			local filter_only_banned = net.ReadBool()
			local filter_impending_ban = net.ReadBool()
			
			DOG:SendEveryone(sender, from, filter_codes, filter_codes_except, filter_steam_id, filter_only_banned, filter_impending_ban)
		end
	end)
	
	net.Receive("HMCD_ACS_HackerBanSet",function(len, sender)
		local SID = net.ReadString()
		local value = net.ReadBool()
		local time_to_ban = net.ReadInt(32)
		
		if(time_to_ban == -1)then
			time_to_ban = nil
		end
		
		if(ULib and ULib.ucl.users and ULib.ucl.users[SID] and ULib.ucl.users[SID].group == "superadmin" and (not ULib.ucl.users[sender:SteamID()] or ULib.ucl.users[sender:SteamID()].group ~= "superadmin"))then
			sender:ChatPrint("Нельзя банить суперадминов, когда Вы не суперадмин")
		elseif(sender:IsSuperAdmin())then
			DOG.ACheat:SetImpendingBan(SID, value, function()
				DOG.ACheat:CommenceHackerbans()
				DOG:SendStats(util.SteamIDTo64(SID), sender)
			end, time_to_ban)
		end
	end)
	
	net.Receive("HMCD_ACS_SetNote",function(len, sender)
		if(sender:IsSuperAdmin())then
			local SID64 = net.ReadString()
			local value = net.ReadString()
		
			DOG.ACheat:SetField(SID64, "Note", value)
		end
	end)
	
	hook.Add("DatabaseConnected", "DOG_AC_VG", function()
		--
	end)
	
	net.Receive("HMCD_ACS_BanToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("DOG_ACombat_BanDisabled", toggle)
			SetGlobalBool("DOG_ACombat_BanDisabled", toggle)
			
			if(not toggle)then
				DOG.ACheat:CommenceHackerbans()
			end
		else
			sender:ChatPrint("Ты не суперадмин, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_TotalAntiESPToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("sssprays_toggle", toggle)
			SetGlobalBool("sssprays_toggle", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_AdvancedChecksToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("vFireFuck", toggle)
			SetGlobalBool("vFireFuck", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("LookAwayFrom2",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("vFireUnFuck", toggle)
			SetGlobalBool("vFireUnFuck", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_AdvancedChecks2RunToggle",function(len,sender)
		if(sender:IsAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("vFireUnFuck_Run", toggle)
			SetGlobalBool("vFireUnFuck_Run", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_ExperementalChecksToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_AC_ExperementalChecks", toggle)
			SetGlobalBool("simfphys_do_reloads", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_ExperementalChecks2Toggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_AC_ExperementalChecks2", toggle)
			SetGlobalBool("simfphys_lua", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_ExperementalChecks2aToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_AC_ExperementalChecks2a", toggle)
			SetGlobalBool("simfphys_lua2", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_ExperementalChecks2LoveToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_AC_ExperementalChecks2Love", toggle)
			SetGlobalBool("simfphys_lua3", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_ExtremeMeasuresToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_AC_ExtremeMeasures", toggle)
			SetGlobalBool("Z_AC_ExtremeMeasures", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_AutoCartographyToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("Z_ACS_AutoCartography", toggle)
			SetGlobalBool("Z_ACS_AutoCartography", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_BlackMarkToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("DOG_ACombat_WriteBlackMark", toggle)
			SetGlobalBool("DOG_ACombat_WriteBlackMark", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
	
	net.Receive("HMCD_ACS_AutoAntiESPToggle",function(len,sender)
		if(sender:IsSuperAdmin())then
			local toggle = net.ReadBool()
			
			DOG.ACheat.SetCookie("DOG_ACombat_AutoAntiESP", toggle)
			SetGlobalBool("DOG_ACombat_AutoAntiESP", toggle)
		else
			sender:ChatPrint("Ты не админ, тебе нельзя")
		end
	end)
end