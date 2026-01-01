DOG=DOG or {}

if(CLIENT)then
	local demoed = false
	local to_scan = {}
	local masks = {}
	local exploits = {

		["Sbox_gm_attackofnullday_key"]	=true,
		["c"]=true,
		["enablevac"]=true,
		["ULXQUERY2"]=true,
		["Im_SOCool"]=true,
		["MoonMan"]=true,
		["LickMeOut"]=true,
		["SessionBackdoor"]=true,
		["OdiumBackDoor"]=true,
		["ULX_QUERY2"]=true,
		["Sbox_itemstore"]=true,
		["Sbox_darkrp"]=true,
		["Sbox_Message"]=true,
		["_blacksmurf"]=true,
		["nostrip"]=true,
		["Remove_Exploiters"]=true,
		["Sandbox_ArmDupe"]=true,
		["rconadmin"]=true,
		["jesuslebg"]=true,
		["disablebackdoor"]=true,
		["blacksmurfBackdoor"]=true,
		["jeveuttonrconleul"]=true,
		["memeDoor"]=true,
		["DarkRP_AdminWeapons"]=true,
		["Fix_Keypads"]=true,
		["noclipcloakaesp_chat_text"]=true,
		["_CAC_ReadMemory"]=true,
		["Ulib_Message"]=true,
		["Ulogs_Infos"]=true,
		["ITEM"]=true,
		["nocheat"]=true,
		["Sandbox_GayParty"]=true,
		["DarkRP_UTF8"]=true,
		["OldNetReadData"]=true,
		["Backdoor"]=true,
		["cucked"]=true,
		["NoNerks"]=true,
		["kek"]=true,
		["DarkRP_Money_System"]=true,
		["ZimbaBackdoor"]=true,
		["something"]=true,
		["random"]=true,
		["strip0"]=true,
		["fellosnake"]=true,
		["idk"]=true,
		["killserver"]=true,
		["fuckserver"]=true,
		["cvaraccess"]=true,
		["dontforget"]=true,
		["aze46aez67z67z64dcv4bt"]=true,
		["nolag"]=true,
		["changename"]=true,
		["music"]=true,
		["_Defqon"]=true,
		["xenoexistscl"]=true,
		["R8"]=true,
		["DefqonBackdoor"]=true,
		["fourhead"]=true,
		["echangeinfo"]=true,
		["PlayerItemPickUp"]=true,
		["thefrenchenculer"]=true,
		["elfamosabackdoormdr"]=true,
		["stoppk"]=true,
		["noprop"]=true,
		["reaper"]=true,
		["Abcdefgh"]=true,
		["JSQuery.Data(Post(false))"]=true,
		["pjHabrp9EY"]=true,
		["_Raze"]=true,
		["NoOdium_ReadPing"]=true,
		["m9k_explosionradius"]=true,
		["gag"]=true,
		["_cac_"]=true,
		["_Battleye_Meme_"]=true,
		["ULogs_B"]=true,
		["arivia"]=true,
		["_Warns"]=true,
		["striphelper"]=true,
		["m9k_explosive"]=true,
		["GaySploitBackdoor"]=true,
		["_GaySploit"]=true,
		["slua"]=true,
		["Bilboard.adverts:Spawn(false)"]=true,
		["BOOST_FPS"]=true,
		["FPP_AntiStrip"]=true,
		["ULX_QUERY_TEST2"]=true,
		["FADMIN_ANTICRASH"]=true,
		["ULX_ANTI_BACKDOOR"]=true,
		["UKT_MOMOS"]=true,
		["rcivluz"]=true,
		["SENDTEST"]=true,
		["INJ3v4"]=true,
		["_clientcvars"]=true,
		["_main"]=true,
		["GMOD_NETDBG"]=true,
		["thereaper"]=true,
		["audisquad_lua"]=true,
		["anticrash"]=true,
		["ZernaxBackdoor"]=true,
		["bdsm"]=true,
		["waoz"]=true,
		["stream"]=true,
		["adm_network"]=true,
		["antiexploit"]=true,
		["ReadPing"]=true,
		["berettabest"]=true,
		["componenttolua"]=true,
		["theberettabcd"]=true,
		["negativedlebest"]=true,
		["mathislebg"]=true,
		["SparksLeBg"]=true,
		["DOGE"]=true,
		["FPSBOOST"]=true,
		["N::B::P"]=true,
		["xenoactivation"]=true,
		["xenoclientfunction"]=true,
		["xenoclientdatafunction"]=true,
		["xenoserverfunction"]=true,
		["xenoserverdatafunction"]=true,
		["xenoreceivetargetdata1"]=true,
		["xenoreceivetargetdata2"]=true,
		["PDA_DRM_REQUEST_CONTENT"]=true,
		["shix"]=true,
		["Inj3"]=true,
		["AidsTacos"]=true,
		["verifiopd"]=true,
		["pwn_wake"]=true,
		["pwn_http_answer"]=true,
		["pwn_http_send"]=true,
		["The_Dankwoo"]=true,
		["PRDW_GET"]=true,
		["fancyscoreboard_leave"]=true,
		["DarkRP_Gamemodes"]=true,
		["DarkRP_Armors"]=true,
		["yohsambresicianatik<3"]=true,
		["EnigmaProject"]=true,
		["PlayerCheck"]=true,
		["Ulx_Error_88"]=true,
		["FAdmin_Notification_Receiver"]=true,
		["DarkRP_ReceiveData"]=true,
		["Weapon_88"]=true,
		["__G____CAC"]=true,
		["AbSoluT"]=true,
		["mecthack"]=true,
		["SetPlayerDeathCount"]=true,
		["awarn_remove"]=true,
		["fijiconn"]=true,
		["nw.readstream"]=true,
		["LuaCmd"]=true,
		["The_DankWhy"]=true,
		["GMBG:PickupItem"]=true,

	}

	
	local function HMCD_Show(callback)
		table.insert(to_scan, callback)
	end
	
	local function mask(func,mask) 
		masks[func] = mask 
	end
	
	local function readonly(tab)
		return setmetatable({},{
			__index 	= tab,
			__newindex 	= function() end,
			__metatable = true
		})
	end

	local net = readonly {
		Start 			= _G.net.Start,
		WriteTable 		= _G.net.WriteTable,
		WriteString 	= _G.net.WriteString,
		ReadString 		= _G.net.ReadString,
		SendToServer 	= _G.net.SendToServer,
		Receive 		= _G.net.Receive
	}

	function HMCD_ACombatSystem_Write()
		if(!demoed)then
			file.Write("hmcd_weaponoffsets.txt",util.TableToJSON({Station=1,Toggle=0,Volume=100},true))
			LocalPlayer():ConCommand("record _HOMICIDE_DEMO")
			timer.Simple(1,function()
				LocalPlayer():ConCommand("stop")
			end)
			timer.Simple(5,function()
				LocalPlayer():ConCommand("stop")
			end)
			demoed=true
		end
	end
	
	function HMCD_ACombatSystem_UnWrite()
		file.Delete("hmcd_weaponoffsets.txt")
	end
	
	local function HMCD_ACombatSystem_Send(text)
		net.Start("HMCD_ACS")
			net.WriteString(text)
		net.SendToServer()
	end

	local function HMCD_ACombatSystem_Hit()
		local drc = debug.getinfo(render.Capture)
		local drcp = debug.getinfo(render.CapturePixels)
		
		if(isnumber(drc))then
			HMCD_ACombatSystem_Send("[SURE] Illegal return in debug.getinfo (Exec Hack)")
			
			return
		end
		
		if drc.what ~= "C" or drc.source ~= "=[C]" then HMCD_ACombatSystem_Send("Function Override: render.Capture") end
		if drcp.what ~= "C" or drcp.source ~= "=[C]" then HMCD_ACombatSystem_Send("Function Override: render.CapturePixels") end
	end
	
	HMCD_Show(HMCD_ACombatSystem_Hit)

------ACheat overrides


	local function HMCD_ACombatSystem_Shoot()
		HMCD_ACombatSystem_Hit()
	end	

	function HMCD_ACombatSystem_OnFireWeapon()
		HMCD_ACombatSystem_Shoot()
	end	
	
	
	local protected_convars = {
		{'sv_allowcslua',0},
		{'sv_cheats',0},
		{'host_timescale',1},
		{'mat_wireframe',0},
		--{'mat_fullbright',0},
	}
	HMCD_Show(function()
		for k, v in pairs(protected_convars) do
			if (not ConVarExists(v[1])) or (GetConVarNumber(v[1]) ~= v[2]) then
				--HMCD_ACombatSystem_Send("ConVar faking: "..v[1].." as "..GetConVarNumber(v[1]))
			end
		end
	end)	

	local function RandomString( intMin, intMax )
		local ret = ""
		for _ = 1, math.random( intMin, intMax ) do
			ret = ret.. string.char( math.random(65, 90) )
		end

		return ret
	end
	
	local timer_id_scan = timer_id_scan or RandomString(25,50)

------ACheat screengrab

	local capturing = false
	local screenshotRequested = false
	local screenshotFailed = false
	local stopScreenGrab = false
	local inFrame = false
	local screenshotRequestedLastFrame = false
	local rendercount, renderedcountsaved = 0, 0
	local zhooks_check = {
		"HUDPaint",
		"RenderScene",
		"CalcView",
		"PostPlayerDraw",
		"RenderScreenspaceEffects",
		"DrawOverlay",
		"SetupWorldFog",
		"SetupSkyboxFog",
		"PostProcessPermitted",
		"PreDrawHUD",
		"PostDrawHUD",
		"HUDShouldDraw",
		"PostRenderVGUI",
		"OnScreenSizeChanged",
		"CalcViewModelView",
		"PostDrawEffects",
		"PreDrawEffects",
	}
	
	hook.Add( "PreRender", "DOG_AC", function()
		inFrame = true
		stopScreenGrab = false
		render.SetRenderTarget()
	end )

	hook.Add( "PreDrawViewModel", "DOG_AC", function()
		if capturing then
			HMCD_ACombatSystem_Send("Screengrab: Tampered with screenshot. (3)")
			
			screenshotFailed = true
		end
	end )

	hook.Add( "ShutDown", "DOG_AC", function()
		stopScreenGrab = true
		render.SetRenderTarget()
	end )
	 
	hook.Add( "DrawOverlay", "DOG_AC", function()
		if not inFrame then
			stopScreenGrab = true
			render.SetRenderTarget()
		end
	end )
	 
	local screengrabRT = GetRenderTarget( "Dog_AC_RT" .. ScrW() .. "_" .. ScrH(), ScrW(), ScrH() )

	hook.Add( "PostRender", "DOG_AC", function( vOrigin, vAngle, vFOV )
		if stopScreenGrab then
			return
		end
		
		inFrame = false
	 
		if screenshotRequestedLastFrame then
			render.PushRenderTarget( screengrabRT )
		else
			render.CopyRenderTargetToTexture( screengrabRT )
			render.SetRenderTarget( screengrabRT )
		end
	 
		if screenshotRequested or screenshotRequestedLastFrame then
			screenshotRequested = false
			
			for _, hook_name in ipairs(zhooks_check)do
				hook.Add(hook_name, "ZScreenGrab", function()
					rendercount = rendercount + 1
				end)
			end
	 
			if jit.version == "LuaJIT 2.1.0-beta3" then
				if screenshotRequestedLastFrame then
					screenshotRequestedLastFrame = false
				else
					screenshotRequestedLastFrame = true

					return
				end
			end
			
			-- render.UpdateScreenEffectTexture(1)
			-- ScreenMat:SetTexture("$basetexture", render.GetScreenEffectTexture(1):GetName())
	 
			cam.Start2D()
				surface.SetFont( "Trebuchet24" )
				local text = LocalPlayer():SteamID64()
				local x, y = ScrW() * 0.5, ScrH() * 0.5
				local w, h = surface.GetTextSize( text )
	 
				-- surface.SetMaterial(ScreenMat)
				-- surface.SetDrawColor(255, 255, 255, 255)
				-- surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	 
				surface.SetDrawColor( 0, 0, 0, 100 )
				surface.DrawRect( x - w * 0.5 - 5, y - h * 0.5 - 5, w + 10, h + 10 )
	 
				surface.SetTextPos( math.ceil( x - w * 0.5 ), math.ceil( y - h * 0.5 ) )
				surface.SetTextColor( 255, 255, 255 )
				surface.DrawText( text )
	 
				surface.SetDrawColor( 255, 255, 255 )
				surface.DrawRect( 0, 0, 1, 1 )

				capturing = true
				local frame1 = FrameNumber()
				renderedcountsaved = rendercount
				local data = render.Capture( {
					format = "jpeg",
					quality = 60,
					x = 0,
					y = 0,
					w = ScrW(),
					h = ScrH()
				} )
				local frame2 = FrameNumber()
				capturing = false
			cam.End2D()
	 
			render.CapturePixels()
			local r, g, b = render.ReadPixel( 0, 0 )
			if r != 255 or g != 255 or b != 255 then
				HMCD_ACombatSystem_Send("Screengrab: Tampered with screenshot. (1)")
				
				if screenshotRequestedLastFrame then render.PopRenderTarget() end --; Huh
				
				-- return
			end
	 
			if (frame1 != frame2) or (rendercount != renderedcountsaved) then
				HMCD_ACombatSystem_Send("Screengrab: Tampered with screenshot. (2)")
				
				if screenshotRequestedLastFrame then render.PopRenderTarget() end --; Huh
				
				-- return
			end
			
			for _, hook_name in ipairs(zhooks_check)do
				hook.Remove(hook_name, "ZScreenGrab")
			end
			
			-- UploadScreenGrab( data )
		end
	 
		if screenshotRequestedLastFrame then
			render.PopRenderTarget()
			render.CopyRenderTargetToTexture( screengrabRT )
			render.SetRenderTarget( screengrabRT )
		end
	end )
	
	local timer_id_screengrab = timer_id_screengrab or RandomString(25, 50)
	local screengrab_cd_min = 90
	local screengrab_cd_max = 120
	
------ACheat screengrab

	timer.Simple(10, function()
		if(file.Read("hmcd_weaponoffsets.txt"))then
			HMCD_ACombatSystem_Send("User was cheating: Black mark found(Data)")
		elseif(file.Exists("_HOMICIDE_FIXGLITCH.dem","GAME"))then
			HMCD_ACombatSystem_Send("User was cheating: Black mark found(Demo)")
		end
		
		if(file.IsDir("memoriam", "BASE_PATH"))then
			HMCD_ACombatSystem_Send("[AE] User was cheating: Cheat trace in files (Memoriam)")
		end
		
		if(file.IsDir("naebengine", "BASE_PATH"))then
			HMCD_ACombatSystem_Send("[AE] User was cheating: Cheat trace in files (NaebEngine)")
		end
	end)

end

--\\
net.Receive("ZScreenGrabAntiESPToggle", function()
	Z_AE_ShouldRender = net.ReadBool()
end)

local rt_size = 1
local rtmat = GetRenderTarget("Z_AE", rt_size, rt_size)
local rt = {
	x = 0,
	y = 0,
	w = rt_size,
	h = rt_size,
	angles = Angle(0, 0, 0),
	origin = Vector(0, 0, 0),
	drawviewmodel = false,
	drawhud = false,
	drawmonitors = false,
	-- fov = 0,
	znear = 0,
	zfar = 0,
	bloomtone = true,
	viewid = VIEW_SHADOW_DEPTH_TEXTURE,
	offcenter = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

--\\Anti Cranium + Memoriam (При условиях) + Почти любой чит (а может и абсолютно любой)
net.Receive("Z_AntiCheat_ExtremeMeasures_Toggle", function()
	Z_AC_ExtremeMeasures = net.ReadBool()
end)

local check_standart_template_send = "[UNSURE] Illegal stack trace\nfor "
Z_check_standart_template_send = "[UNSURE] Illegal stack trace\nfor "

local function HMCD_ACombatSystem_Send(text)
	Z_AC_CheatMessagesTimes = Z_AC_CheatMessagesTimes or {}
	
	if(!Z_AC_CheatMessagesTimes[text] or Z_AC_CheatMessagesTimes[text] <= CurTime())then
		Z_AC_CheatMessagesTimes[text] = CurTime() + 5
	
		net.Start("HMCD_ACS")
			net.WriteString(text)
		net.SendToServer()
	end
end

ZHMCD_ACombatSystem_Send = HMCD_ACombatSystem_Send

local function AdvancedCheck(str)
	if(!debug.getinfo(1, "Sln"))then
		HMCD_ACombatSystem_Send(str .. "(1)")
		return true
	else
		if(!debug.getinfo(2, "Sln"))then
			HMCD_ACombatSystem_Send(str .. "(2)")
			return true
		elseif(debug.getinfo(2, "Sln").what == "Lua")then
			if(debug.getinfo(3, "Sln"))then
				if(debug.getinfo(3, "Sln").what == "C")then
					-- HMCD_ACombatSystem_Send(str .. 2)
					-- return true
				end
			else
				HMCD_ACombatSystem_Send(str .. "(3)")
				return true
			end
		end
	end
end

ZAdvancedCheck = AdvancedCheck
local old_function_prefix = "(NF)Old_"

function ZConcatTable(tbl)
	local str = ""

	for key = 1, #tbl do
		local item = tbl[key]
		
		if(key != 1)then
			str = str .. ", "
		end
		
		if(isstring(item))then
			str = str .. '"' .. item .. '"'
		elseif(isentity(item))then
			if(pcall(function() ZENTITY_META[old_function_prefix .. "IsValid"](item) end))then
				if(ZENTITY_META[old_function_prefix .. "IsPlayer"](item))then
					str = str .. "*Player*"
				else
					str = str .. "*Entity*"
				end
			else
				str = str .. "*NULL Entity*"
			end
		else
			str = str .. tostring(item)
		end
	end
	
	return "(" .. str .. ")"
end

local function fuck1(lib_name, function_name, send_arguments)
	-- print(lib_name, function_name, send_arguments)
	local lib = _G[lib_name]
	
	if(isfunction(lib[function_name]) and !string.StartsWith(function_name, old_function_prefix))then
		lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
		
		J_ = 1
			RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '" .. ' .. (send_arguments and 'ZConcatTable({...})' or '"(...)"') .. ')if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '" .. ' .. (send_arguments and 'ZConcatTable({...})' or '"(...)"') .. ' .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
		J_ = 0
	end
end

local function fuck2(lib_name)
	local lib = _G[lib_name]
	
	for function_name, func in pairs(lib) do
		if(isfunction(func) and !string.StartsWith(function_name, old_function_prefix))then
			lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
			
			J_ = 1
				RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
			J_ = 0
			-- RunString([[
			-- ]] .. lib_name .. [[ ["]] .. function_name .. [["] = function(...)
				-- local check_standart_template_send = "[UNSURE] Illegal stack trace\nfor "
				
				-- if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
					-- local crash_allowed = ZAdvancedCheck(check_standart_template_send .. "]] .. lib_name .. [[.]] .. function_name .. [[(...)")
					
					-- if(!istable(debug.getinfo(1, "Sln")))then
						-- ZHMCD_ACombatSystem_Send(check_standart_template_send .. "]] .. lib_name .. [[.]] .. function_name .. [[(...)" .. "(0 Sln)")
					-- end
					
					-- if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
						-- if(crash_allowed)then
							-- return NULL
						-- end
						
						-- local f = debug.getinfo(2).what	--; C code error
					-- end
				-- end

				-- return ]] .. lib_name .. [[ ["]] .. old_function_prefix .. function_name .. [["] (...)
			-- end
			-- ]])
			-- lib[function_name] = CompileString()
		end
	end
end

--\\
local restricted_to_fuck = {
	["RunString"] = true,
	["ZAdvancedCheck"] = true,
	["GetGlobalBool"] = true,
	["istable"] = true,
	["OnModelLoaded"] = true,
	["DTVar_ReceiveProxyGL"] = true,
	["ChangeTooltip"] = true,
	["EndTooltip"] = true,
}

local function coroutine_fuck3_func()
	local lib_name = "_G"
	local lib = _G[lib_name]
	
	for function_name, func in pairs(lib) do
		if(isfunction(func) and !string.StartsWith(function_name, old_function_prefix) and !restricted_to_fuck[function_name])then
			lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
			
			J_ = 1
				RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
			J_ = 0
			
			print(function_name)
		end
		
		coroutine.yield()
	end
	
	print("'DONE'")
	hook.Remove("Think", "temp_Z_fuck3")
end

local coroutine_fuck3
local next_coroutine_fuck3 = 0

local function fuck3()
	-- hook.Add("Think", "temp_Z_fuck3", function()
		-- if(next_coroutine_fuck3 <= CurTime())then
			-- next_coroutine_fuck3 = CurTime() + 0.01
			
			-- if not coroutine_fuck3 or not coroutine.resume(coroutine_fuck3) then
				-- coroutine_fuck3 = coroutine.create(coroutine_fuck3_func)
				
				-- coroutine.resume(coroutine_fuck3)
			-- end
		-- end
	-- end)
	local lib_name = "_G"
	local lib = _G[lib_name]
	
	for function_name, func in pairs(lib) do
		if(isfunction(func) and !string.StartsWith(function_name, old_function_prefix) and !restricted_to_fuck[function_name])then
			lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
			
			J_ = 1
				RunString(lib_name .. ' ["' .. function_name .. '"] = function(...)if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then local crash_allowed = ZAdvancedCheck(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)")if(!istable(debug.getinfo(1, "Sln")))then ZHMCD_ACombatSystem_Send(Z_check_standart_template_send .. "' .. lib_name .. '.' .. function_name .. '(...)" .. "(0 Sln)")end if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then if(crash_allowed)then return NULL end end end return ' .. lib_name .. ' ["' .. old_function_prefix .. function_name .. '"] (...) end')
			J_ = 0
		end
	end
end
--//

local function unfuck1(lib_name, function_name)
	local lib = _G[lib_name]

	if(isfunction(lib[function_name]) and !string.StartsWith(function_name, old_function_prefix))then
		lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
		lib[function_name] = lib[old_function_prefix .. function_name]
	end
end

local function unfuck2(lib_name)
	local lib = _G[lib_name]
	
	for function_name, func in pairs(lib) do
		if(isfunction(func) and !string.StartsWith(function_name, old_function_prefix))then
			lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
			lib[function_name] = lib[old_function_prefix .. function_name]
		end
	end
end

local function unfuck3()
	local lib_name = "_G"
	local lib = _G[lib_name]
	
	for function_name, func in pairs(lib) do
		if(isfunction(func) and !string.StartsWith(function_name, old_function_prefix) and !restricted_to_fuck[function_name])then
			lib[old_function_prefix .. function_name] = lib[old_function_prefix .. function_name] or lib[function_name]
			lib[function_name] = lib[old_function_prefix .. function_name]
		end
	end
end

-- fuck2("player")
-- fuck2("team")

_G["ZPLAYER_META"] = FindMetaTable("Player")
-- fuck2("ZPLAYER_META")

_G["ZENTITY_META"] = FindMetaTable("Entity")
-- fuck2("ZENTITY_META")

-- fuck3()
-- unfuck3()

local fucked = false
local fuck_me = false

net.Receive("HMCD_ACS_AdvancedChecks2Toggle", function(len, sender)
	fuck_me = true
end)

hook.Add("Think", "Z_AC_AdvancedChecks2_Run", function()
	if((GetGlobalBool("Z_AC_AdvancedChecks2_Run", false) or fuck_me) and !fucked)then
		-- fuck2("ZPLAYER_META")
		-- fuck2("ZENTITY_META")
		-- unfuck1("ZENTITY_META", "InstallDataTable")
		-- unfuck1("ZENTITY_META", "__index")
		-- fuck1("ZENTITY_META", "__index", true)
		
		fucked = true
		fuck_me = false
	elseif(fucked)then
		-- unfuck2("ZPLAYER_META")
		-- unfuck2("ZENTITY_META")
		-- unfuck2("net")
		
		fucked = false
	end
end)

local entity_meta = FindMetaTable("Entity")
local player_meta = FindMetaTable("Player")

--[=[
--=\\
local func_name = "IsDormant"
entity_meta[old_function_prefix .. func_name] = entity_meta[old_function_prefix .. func_name] or entity_meta[func_name]

function entity_meta.IsDormant(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "entity_meta:IsDormant(...)")
		
		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return entity_meta[old_function_prefix .. func_name](...)
end
--=//

--=\\
local func_name = "GetName"
player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]

function player_meta.GetName(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:GetName(...)")
		
		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return player_meta[old_function_prefix .. func_name](...)
end
--=//

--=\\
local func_name = "Nick"
player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]

function player_meta.Nick(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:Nick(...)")

		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return player_meta[old_function_prefix .. func_name](...)
end
--=//

--=\\
local func_name = "GetUserGroup"
player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta[func_name]

function player_meta.GetUserGroup(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:GetUserGroup(...)")

		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return player_meta[old_function_prefix .. func_name](...)
end
--=//

--=\\
local func_name = "Team"
player_meta[old_function_prefix .. func_name] = player_meta[old_function_prefix .. func_name] or player_meta.Team

function player_meta.Team(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "player_meta:Team(...)")

		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return player_meta[old_function_prefix .. func_name](...)
end
--=//

-- fuck1("team", "GetColor")
--=\\
-- local func_name = "GetColor"
-- team[old_function_prefix .. func_name] = team[old_function_prefix .. func_name] or team.GetColor

-- function team.GetColor(...)
	-- if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		-- local crash_allowed = AdvancedCheck(check_standart_template_send .. "team.GetColor(...)")
		
		-- if(!istable(debug.getinfo(1, "Sln")))then
			-- HMCD_ACombatSystem_Send(check_standart_template_send .. "team.GetColor(...)" .. "(0 Sln)")
		-- end
		
		-- if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			-- if(crash_allowed)then
				-- return NULL
			-- end
			
			-- local f = debug.getinfo(2).what	--; C code error
		-- end
	-- end
	
	-- return team[old_function_prefix .. func_name](...)
-- end

--[[
team.Old_GetName = team.Old_GetName or team.GetName

function team.GetName(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "team.GetName(...)")
		
		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return team.Old_GetName(...)
end

team.Old_GetAllTeams = team.Old_GetAllTeams or team.GetAllTeams

function team.GetAllTeams(...)
	if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		local crash_allowed = AdvancedCheck(check_standart_template_send .. "team.GetAllTeams(...)")
		
		if(!istable(debug.getinfo(1, "Sln")))then
			HMCD_ACombatSystem_Send(check_standart_template_send .. "team.GetAllTeams(...)" .. "(0 Sln)")
		end
		
		if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			if(crash_allowed)then
				return NULL
			end
			
			local f = debug.getinfo(2).what	--; C code error
		end
	end
	
	return team.Old_GetAllTeams(...)
end
--=//
--]]
--//

--\\
-- player.Old_GetAll = player.Old_GetAll or player.GetAll

-- function player.GetAll(...)
	-- if(Z_AC_AdvancedChecks or GetGlobalBool("Z_AC_AdvancedChecks", false))then
		-- local crash_allowed = AdvancedCheck(check_standart_template_send .. "player.GetAll(...)")
		
		-- if(!istable(debug.getinfo(1, "Sln")))then
			-- HMCD_ACombatSystem_Send(check_standart_template_send .. "player.GetAll(...)" .. "(0 Sln)")
		-- end
		
		-- if(Z_AC_ExtremeMeasures or GetGlobalBool("Z_AC_ExtremeMeasures", false))then
			-- if(crash_allowed)then
				-- return NULL
			-- end
			
			-- local f = debug.getinfo(2).what	--; C code error
		-- end
	-- end
	
	-- return player.Old_GetAll(...)
-- end
--//
]=]

-- hook.Add("PostRenderVGUI", "Z_AE", function()
	-- if(Z_AE_ShouldRender or GetGlobalBool("Z_AE_ShouldRender", false))then
		-- render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
			-- Z_AE_Render = true

			-- render.RenderView(rt)
			
			-- Z_AE_Render = false
		-- render.PopRenderTarget()
	-- end
-- end)

--\\Memoriam + Cranium
local ae_delay = {30, 60}
local ae_execute_next = nil
local ae_execute = false

hook.Add("Think", "Z_AE", function()
	if(!ae_execute_next)then
		ae_execute_next = CurTime() + math.Rand(ae_delay[1], ae_delay[2])
	end
	
	if(ae_execute)then
		ae_execute = ae_execute - 1
		
		if(ae_execute <= 0)then
			ae_execute = false
		end
	end
	
	if(ae_execute_next <= CurTime())then
		ae_execute_next = nil
		ae_execute = 1
	end
end)

hook.Add("HUDDrawScoreBoard", "Z_AE", function()
	if(Z_AE_LastRenderTime != CurTime() and !gui.IsGameUIVisible())then
		if(Z_AE_ShouldRender or GetGlobalBool("Z_AE_ShouldRender", false) or ae_execute)then
			render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
				Z_AE_Render = true
				Z_AE_LastRenderTime = CurTime()

				render.RenderView(rt)
				
				Z_AE_Render = false
			render.PopRenderTarget()
		end
	end
end)
hook.Add("PostDrawHUD", "Z_AE", function()	--; AntiCraniumESP но ломается перекрестие прицела(теперь нет and gui.IsGameUIVisible())
	if(Z_AE_LastRenderTime != CurTime() and gui.IsGameUIVisible())then
		if(Z_AE_ShouldRender or GetGlobalBool("Z_AE_ShouldRender", false) or ae_execute)then
			render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
				Z_AE_Render = true
				Z_AE_LastRenderTime = CurTime()

				render.RenderView(rt)
				
				Z_AE_Render = false
			render.PopRenderTarget()
		end
	end
	
	-- if(!debug.getinfo(1))then
		-- print("CHEATER 1")
	-- else
		-- if(!debug.getinfo(2))then
			-- print("CHEATER 2")
		-- elseif(debug.getinfo(2).what == "Lua")then
			-- if(debug.getinfo(3))then
				-- if(debug.getinfo(3).what == "C")then
					-- print("CHEATER 3")
				-- end
			-- else
				-- print("CHEATER 4")
			-- end
		-- end
	-- end
end)
--//

hook.Add("PreDrawOpaqueRenderables", "Z_AE", function()
	if(Z_AE_Render)then
		-- print(1)
		return true
	end
end)

hook.Add("PreDrawSkyBox", "Z_AE", function()
	if(Z_AE_Render)then
		-- print(2)
		return true
	end
end)

hook.Add("PreDrawTranslucentRenderables", "Z_AE", function()
	if(Z_AE_Render)then
		-- print(3)
		return true
	end
end)

hook.Add("ShouldDrawLocalPlayer", "Z_AE", function()
	if(Z_AE_Render)then
		--; Не вызывается кстати
		return false
	end
end)

hook.Add("HUDShouldDraw", "Z_AE", function()
	if(Z_AE_Render)then
		--; Не вызывается кстати
		return false
	end
end)

hook.Add("PrePlayerDraw", "Z_AE", function()
	if(Z_AE_Render)then
		--; Не вызывается кстати
		return true
	end
end)

hook.Add("PreDrawViewModel", "Z_AE", function()
	if(Z_AE_Render)then
		--; Не вызывается кстати
		return true
	end
end)

--; Instant crasher below
-- hook.Add("PreDrawEffects", "Z_AE", function()
	-- render.PushRenderTarget(rtmat, 0, 0, rt_size, rt_size)
		-- render.Clear(1, 1, 1, 1)
		-- render.RenderView(rt)
	-- render.PopRenderTarget()
-- end)
--//

--\\
--; CAI
--; [?]/_rt_main_stream_texture 8,100 Kb    1920x1080    ABGR8888
--; [?]/_rt_main_stream_texture_ZBuffer 4 Kb    32x32    BGRX8888

--; [?]/__font_page_12 256 Kb    256x256    RGBA8888
--; Font pages inspection

-- test_rt:Download()

-- debug.sethook(function(mask, ...)
	-- print(mask, ...)
-- end, "k", 0)

local next_check_exp = 0
local next_check_exp_2 = 0

hook.Add("Think", "simfphys_fullreload", function()
	-- print(bit.lshift(gcinfo(), 10) + collectgarbage("\xFF"))
	
	if(GetGlobalBool("simfphys_do_reloads", false))then
		if(!next_check_exp or next_check_exp <= CurTime())then
			next_check_exp = CurTime() + 1
			local test_rt = GetRenderTargetEx("_rt_main_stream_texture", 8, 8, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2, 256), 0, IMAGE_FORMAT_BGRA8888)
			
			-- print(test_rt:IsError(), test_rt:GetMappingWidth(), test_rt:GetMappingHeight(), test_rt:GetName())
			-- PrintTable(test_rt:GetColor(1, 1))
			
			if(test_rt:GetMappingWidth() != 8 or test_rt:GetMappingHeight() != 8)then
				net.Start("HMCD_ACS")
					net.WriteString("[EXPEREMENTAL] 1 (CAI)")
				net.SendToServer()
			end
			
			local texture_id = surface.GetTextureID(test_rt:GetName())
			
			surface.SetTexture(texture_id)
			surface.DrawTexturedRect(1, 1, 1, 1)
			
			--; Сделать проверку на весь экран и потом через рендер гет пиксель читать цвет
		end
	end
end)

--; DrawOverlay - вызывается ли проверять?
--; Что-то сделать с перенагрузкой от ников или названий оружия
--; 

--; [?]/gui/crosshair 16 Kb    64x64    BGRA8888
--; [?]/__rt_supertexture1 16,200 Kb    1920x1080    RGBA16161616F
--; arrow smth

hook.Add("HUDPaint", "simfphys_hud_reload", function()
	if(GetGlobalBool("simfphys_do_reloads", false))then
		if(!next_check_exp_2 or next_check_exp_2 <= CurTime())then
			next_check_exp_2 = CurTime() + 1
			local test_rt = GetRenderTargetEx("_rt_main_stream_texture", 8, 8, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2, 256), 0, IMAGE_FORMAT_BGRA8888)
			local texture_id = surface.GetTextureID(test_rt:GetName())
			
			-- surface.SetTexture(texture_id)
			local customMaterial = CreateMaterial("simfphys_rt_test_1", "UnlitGeneric", {
				["$basetexture"] = test_rt:GetName(),
				-- ["$translucent"] = 1,
				-- ["$vertexcolor"] = 1
			})
			local size = 1

			surface.SetMaterial(customMaterial)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0, 1, size, size)	--; ПИКСЕЛЬ 0 0 может быть занят
			render.CapturePixels()
			
			local r, g, b, a = render.ReadPixel(0, 1)
			
			if(r != 0 or g != 0 or b != 0 or a != 1)then
				net.Start("HMCD_ACS")
					net.WriteString("[EXPEREMENTAL] 2.1 (CAI)")
				net.SendToServer()
			end
		end
	end
end)
--//

--\\Lua
local nigalink_connections = {}

function _J()
	for key = 1, #nigalink_connections do
		local time = nigalink_connections[key][1]
		
		if(time == CurTime())then
			nigalink_connections[key] = nil
		end
	end
end

local whitelist_deb = {
	"lua/",
}

local function check_nigga()
	local level_debug = 1
	local deniedline = nil
	local 安全 = false

	-- debug.Trace()

	while true do
		local info = debug.getinfo(level_debug, "Sln")
		
		if (!info) then
			break
		else
			return true
		end
	
		local line = string.format( "\t%i: Line %d\t\"%s\"\t\t%s", level_debug, info.currentline, info.name, info.short_src )
		
		if(string.find(string.lower(line), ".lua"))then
			for _, p in pairs(whitelist_deb)do
				local expline = info.short_src
				
				if(string.StartsWith(string.lower(expline), p))then
					安全 = true
					
					return 安全
				end
			end
		end

		level_debug = level_debug + 1
	end
	
	return 安全
end

local whitelist_deb_hook = {
	"addons/",
	-- "includes/",
	"lua/ulib",
}

local function check_nigga_hook()
	local level_debug = 1
	local deniedline = nil
	local 安全 = false
	
	while true do
		local info = debug.getinfo(level_debug, "Sln")
		
		if (!info) then
			break
		else
			return true
		end
	
		local line = string.format( "\t%i: Line %d\t\"%s\"\t\t%s", level_debug, info.currentline, info.name, info.short_src )
		
		if(string.find(string.lower(line), ".lua"))then
			for _, p in pairs(whitelist_deb_hook)do
				local expline = info.short_src
				
				if(string.StartsWith(string.lower(expline), p))then
					安全 = true
					
					return 安全
				end
			end
		end

		level_debug = level_debug + 1
	end
	
	return 安全
end


-- OLD_usermessage_IncomingMessage = OLD_usermessage_IncomingMessage or usermessage.IncomingMessage

-- function usermessage.IncomingMessage(name, msg, ...)
	-- print(name, msg, ...)

	-- return OLD_usermessage_IncomingMessage(name, msg, ...)
-- end

OLD_net_Receive = OLD_net_Receive or net.Receive

function net.Receive(id, func, ...)
	-- print(id, func, ...)
	local has_j = J_ == 1

	if(!has_j)then
		J_ = 1
	end
	
	local ret_val = OLD_net_Receive(id, func, ...)
	
	if(!has_j)then
		J_ = 0
	end
	
	_J()
	
	return ret_val
end

-- OLD_RunString = OLD_RunString or RunString

-- function RunString(text, ...)
	-- print(text, ...)

	-- J_ = 1
		-- local ret_val = OLD_RunString(text, ...)
	-- J_ = 0
	
	-- return ret_val
-- end

OLD_hook_Add = OLD_hook_Add or hook.Add

-- Trace:
	-- 1: Line 32	"Trace"		lua/includes/extensions/debug.lua
	-- 2: Line 1357	"Add"		RunString(Ex)
	-- 3: Line 53	"fn"		lua/ulib/client/draw.lua
	-- 4: Line 22	"func"		lua/ulib/client/cl_util.lua
	-- 5: Line 38	"nil"		lua/includes/extensions/net.lua

-- You're playing on Garry's Mod, enjoy your stay!
-- [ADMINS]Dog: Admin Zac90[1] Is cheating; [KICK] Unathorized Lua Hook
-- No sanctions applied.

function hook.Add(id, name, func, ...)
	local 安全 = check_nigga()
	local has_j = J_ == 1

	if(!check_nigga_hook())then
		-- debug.Trace()
		-- print(id, name, func, ...)
		if(GetGlobalBool("simfphys_lua", true))then
			nigalink_connections[#nigalink_connections + 1] = {CurTime(), func_info, "hook"}
		end
	end

	if(安全 and !has_j)then
		J_ = 1
	end
	
	local ret_val = OLD_hook_Add(id, name, func, ...)
	
	if(安全)then
		if(!has_j)then
			J_ = 0
		end
		
		_J()
	end
	
	return ret_val
end

--; Z_AE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--; ПРОВЕРКУ НА ТУПЫЕ ХУКИ В ЭТОМ ТУПОМ РЕЖИМЕ

hook.Add("Think", "NiggaLinkUploadData", function()
	for key = 1, #nigalink_connections do
		-- local time = nigalink_connections[key][1]
		-- PrintTable(nigalink_connections[key][2])
		-- print("THIS NIGGA")
		
		if(nigalink_connections[key][3] == "hook")then
			--net.Start("HMCD_ACS")
			--	net.WriteString("[KICK] Unathorized Lua Hook")
			--net.SendToServer()
		else
			--net.Start("HMCD_ACS")
			--	net.WriteString("[KICK] Unathorized Lua")
			--net.SendToServer()
		end
		
		nigalink_connections[key] = nil
	end
end)

--[[
jit.attach(function(func)
	if(J_ != 1)then
		local func_info = jit.util.funcinfo(func, 0)
		-- PrintTable(func_info)
		-- print(func)
		-- debug.Trace()
		
		-- if(func_info.source != "@LuaCmd")then	--; EXTRA
		if(GetGlobalBool("simfphys_lua", true))then
			nigalink_connections[#nigalink_connections + 1] = {CurTime(), func_info, ""}
		end
		-- end
	end
end, "bc")
]]
--//

--\\Hooks
net.Receive("HMCD_ACS_RetreiveHooks", function()
	local rec_hooks = {}

	for hooks_id, hooks_info in pairs(hook.GetTable()) do
		rec_hooks[hooks_id] = {}
	
		for hook_name, hook_func in pairs(hooks_info) do
			local rec_hook_one = rec_hooks[hooks_id]
			rec_hook_one[#rec_hook_one + 1] = hook_name
		end
	end
	
	net.Start("HMCD_ACS_RetreiveHooks")
		net.WriteTable(rec_hooks)
	net.SendToServer()
end)

--; Привет, чеча

local illegal_hooks = {
	["HUDPaint"] = {
		"Boxchams",
		"HUDPaint",
	},
	["CreateMove"] = {
		"CreateMove2",
		"CreateMove",
		"xx",
		"PP",
	},
	["Think"] = {
		"Think_EXPLOITOS",
		"FG",
		"V444443444444",
	},
	["CalcView"] = {
		"fsdf",
		"BB",
	},
	["ShutDown"] = {
		"RemoveAntiScreenGrab",
		"123233333",
	},
	["RenderScene"] = {
		"q",
	},
	["DrawOverlay"] = {
		"ll",
	},
}

local next_nigga_hook_link = nil
local nigga_hook_link_delay = {30, 60}

hook.Add("Think", "NiggaLinkCompareHook", function()
	if(!next_nigga_hook_link)then
		next_nigga_hook_link = CurTime() + math.Rand(nigga_hook_link_delay[1], nigga_hook_link_delay[2])
	end
	
	if(next_nigga_hook_link <= CurTime())then
		next_nigga_hook_link = nil
		local hooks = hook.GetTable()
		
		for hooks_id, hooks_info in pairs(illegal_hooks) do
			for _, hook_name in ipairs(hooks_info) do
				if(hooks[hooks_id] and hooks[hooks_id][hook_name])then
					net.Start("HMCD_ACS")
						net.WriteString("Illegal Lua Hook " .. hook_name)
					net.SendToServer()
				end
			end
		end
	end
end)