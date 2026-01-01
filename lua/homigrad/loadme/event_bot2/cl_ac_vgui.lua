DOG=DOG or {}
DOG_ENUM_PENDINGBAN = 1
DOG_ENUM_BANNED = 2

if(CLIENT)then
	surface.CreateFont("DOG_WARNING", {
		font = "Arial",
		extended = false,
		size = ScreenScale(15),
		weight = 500,
		blursize = 1,
		scanlines = 6,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	
	local function draw_stylish_panel(x, y, w, h, text, color, color_bg)
		color_bg = color_bg or Color(100, 100, 100)
		local skew = 20
		local inner_offset = 3
		local inner_width = 5
		local offsets = 10
		x = x + offsets
		w = w - offsets * 2
		local poly = {
			{x = x + skew, y = y},
			{x = x + w, y = y},
			{x = x + w - skew, y = y + h},
			{x = x, y = y + h},
		}
		
		surface.SetDrawColor(color_bg)
		draw.NoTexture()
		surface.DrawPoly(poly)
		-- draw.DrawText(text, "DOG_WARNING", x + w / 2, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.DrawText(text, "DOG_WARNING", x + skew + inner_width + inner_offset, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		local poly_left = {
			{x = x + skew + inner_offset, y = y + inner_offset},
			{x = x + skew + inner_offset + inner_width, y = y + inner_offset},
			{x = x + inner_offset * 2 + inner_width, y = y + h - inner_offset},
			{x = x + inner_offset * 2, y = y + h - inner_offset},
		}
		
		surface.SetDrawColor(color)
		surface.DrawPoly(poly_left)
	end
	
	hook.Add( "HUDPaint", "DOG_PHB", function()
		local used_y = 0
		
		if(false)then
			if(GetGlobalBool("DOG_PHB") and LocalPlayer():IsAdmin())then
				if(!PHB_NextFlash or PHB_NextFlash <= CurTime())then
					PHB_NextFlash=CurTime()+0.1
					system.FlashWindow()
				end
				
				surface.SetDrawColor(Color(200,40,0,255))
				surface.DrawRect(0, 0, ScrW(), 50)
				//draw.DrawText("Commencing Hackerbans", "DermaLarge", ScrW() * 0.5, 25 / 2, color_white, TEXT_ALIGN_CENTER )
				
				used_y = used_y + 50
			end
			
			if(GetGlobalString("DOG_CAI") != "" and LocalPlayer():IsAdmin())then
				local offsets = 10
				local height = ScreenScale(15)
				
				//draw_stylish_panel(0, used_y + offsets, ScrW() / 2, height, "Пёс: Условия не соблюдены, загрузка невозможна", Color(190, 10, 0))
				
				used_y = used_y + height + offsets + offsets
			end
			
			if(GetGlobalString("DOG_MAP") == "no_cache" and LocalPlayer():IsAdmin())then
				local offsets = 10
				local height = ScreenScale(15)
				
				//draw_stylish_panel(0, used_y + offsets, ScrW() / 2, height, "Пёс: Картография невозможна", Color(255, 165, 0))
				
				used_y = used_y + height + offsets + offsets
			end
			
			if(!GetGlobalBool("Z_ACS_AutoCartography") and GetGlobalString("DOG_MAP") == "invalid" and LocalPlayer():IsAdmin())then
				local offsets = 10
				local height = ScreenScale(15)
				
				//draw_stylish_panel(0, used_y + offsets, ScrW() / 2, height, "Пёс: Выполните картографию", Color(255, 215, 0))
				
				used_y = used_y + height + offsets + offsets
			end
			
			if(GetGlobalBool("Z_ACS_AutoCartography") and GetGlobalString("DOG_MAP") == "invalid" and LocalPlayer():IsAdmin())then
				local offsets = 10
				local height = ScreenScale(15)
				
				//draw_stylish_panel(0, used_y + offsets, ScrW() / 2, height, "Пёс: Авто картография замен. ошиб. картографию", Color(200, 200, 200))
				
				used_y = used_y + height + offsets + offsets
			end
			
			if(GetGlobalString("DOG_NS") == "no" and LocalPlayer():IsAdmin())then
				local offsets = 10
				local height = ScreenScale(15)
				
				//draw_stylish_panel(0, used_y + offsets, ScrW() / 2, height, "Пёс: Нет netstream", Color(255, 215, 0))
				
				used_y = used_y + height + offsets + offsets
			end
		end
	end)
end

if(CLIENT)then
	net.Receive("HMCD_ACS_SendStats",function()
		local bytes = net.ReadUInt(16)
		local data = net.ReadData(bytes)
		local SID64 = net.ReadString()
		local info = util.JSONToTable(util.Decompress(data))
		DOG:ShowStats(info, SID64)
	end)
	
	net.Receive("HMCD_ACS_Everyone",function()
		local bytes = net.ReadUInt(16)
		local data = net.ReadData(bytes)
		local from = net.ReadUInt(16)
		local max_from = net.ReadUInt(16)
		local ids = util.JSONToTable(util.Decompress(data))
		
		if(not DOG.Panel or (DOG.Panel and not DOG.Panel.Everyone))then
			DOG:ShowEveryone(ids, from, max_from)
		else
			DOG:AddToEveryone(ids, from, max_from)
		end
	end)
	
	net.Receive("HMCD_ACS_SendAntiESPList",function()
		local bytes = net.ReadUInt(32)
		local data = net.ReadData(bytes)
		local ids = util.JSONToTable(util.Decompress(data))
		
		if(not DOG.Panel or (DOG.Panel and not DOG.Panel.AntiESPList))then
			DOG.ShowAntiESPList(ids)
		end
	end)
	
	concommand.Add("dog_opendebug",function()
		DOG:RequestEveryone(1)
	end)	
end

function DOG:RequestEveryone(from, filter_codes, filter_codes_except, filter_steam_id, filter_only_banned, filter_impending_ban)
	net.Start("HMCD_ACS_Everyone")
		net.WriteUInt(from or 1, 16)
		net.WriteString(filter_codes or "")
		net.WriteString(filter_codes_except or "")
		net.WriteString(filter_steam_id or "")
		net.WriteBool(filter_only_banned or false)
		net.WriteBool(filter_impending_ban or false)
	net.SendToServer()
end

function DOG:RequestStats(SID64)
	net.Start("HMCD_ACS_SendStats")
	net.WriteString(SID64)
	net.SendToServer()
end

function DOG:SetImpendingBan(SID, value, time_to_ban)
	if(value)then
		print("Commencing ban on join: " .. SID)
	else
		print("Vetoing ban on join: " .. SID)
	end
	
	time_to_ban = time_to_ban or -1
	
	net.Start("HMCD_ACS_HackerBanSet")
		net.WriteString(SID)
		net.WriteBool(value)
		net.WriteInt(time_to_ban, 32)
	net.SendToServer()
end

if(CLIENT)then
	function DOG:ShowStats(info, SID64)
		chat.AddText(Color(50,150,0), "Stats opened")
		
		if(IsValid(DOG.Panel))then
			DOG.Panel:Remove()
		end
		
		DOG.Panel = vgui.Create("DFrame")
		local frame = DOG.Panel

		local size={math.max(ScrW()* 0.4,640),math.max(ScrH()* 0.8,640)}
		
		frame:SetSize(size[1], size[2])
		frame:Center()
		frame:MakePopup()
		-- frame:SetKeyboardInputEnabled(true)
		frame:SetDraggable(false)
		frame:ShowCloseButton(true)
		frame:SetTitle(SID64)
		frame:DockPadding(4,24,4,4)

		function frame:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
		end

		frame.name = Label("Loading...", frame)
		frame.name:SetFont("CloseCaption_Normal")
		if(info["Banned"])then
			frame.name:SetTextColor(Color(150,50,0))
		elseif(info["PendingBan"])then
			frame.name:SetTextColor(Color(150,100,0))
		else
			frame.name:SetTextColor(team.GetColor(2))
		end
		frame.name:Dock(TOP)
		frame.name:DockPadding(16,16,4,4)
		steamworks.RequestPlayerInfo( SID64, function( steamName )
			frame.name:SetText(steamName)
			frame.name:SizeToContents()
		end )

		local copyid64 = vgui.Create("DButton",frame)
		copyid64:SetFont("CloseCaption_Bold")
		copyid64:SetText("Clipboard SteamID")
		copyid64:SizeToContents()
		local x,y = frame.name:GetPos()
		copyid64:SetPos(size[1]-copyid64:GetWide()-10,y+26)
		function copyid64:DoClick()
			if(input.IsKeyDown(KEY_LSHIFT))then
				SetClipboardText(SID64)
			else
				SetClipboardText(util.SteamIDFrom64(SID64))
			end
		end

		local returnbut = vgui.Create("DButton",frame)
		returnbut:SetFont("CloseCaption_Bold")
		returnbut:SetText("<-")
		returnbut:SizeToContents()
		returnbut:SetPos(size[1]-returnbut:GetWide()-230,y+26)
		function returnbut:DoClick()
			DOG:RequestEveryone()
		end

		--\\
		local label_ban_time = vgui.Create("DLabel", frame)
		label_ban_time:SetFont("CloseCaption_Bold")
		label_ban_time:SizeToContents()
		label_ban_time:DockMargin(0, 0, 0, 4)
		label_ban_time:Dock(TOP)
		label_ban_time:DockPadding(0,0,0,0)
		label_ban_time:SetText("Нет плана на бан")
		
		if(info["PendingBanTime"])then
			label_ban_time:SetText("Будет забанен " .. os.date("%d.%m.%Y - %H:%M", info["PendingBanStart"] + info["PendingBanTime"]))
		end
		-- function button_remove_blackmark:DoClick()
			-- chat.AddText("Чёрная метка удалена из data/ (если она там вообще была)")
			-- net.Start("organism_cleanup")
				-- net.WriteString(SID64)
			-- net.SendToServer()
		-- end
		
		-- function button_remove_blackmark:Paint(w,h)
			-- surface.SetDrawColor(140, 140, 40, 255)
			-- surface.DrawRect(0, 0, w, h)
		-- end
		--//

		local pendban = vgui.Create("DButton",frame)
		pendban.Set = info["PendingBan"]
		pendban:SetFont("CloseCaption_Bold")
		
		if(pendban.Set)then
			pendban:SetText("Veto Hackerban on join")
		else
			pendban:SetText("Pend Hackerban on join")
		end
		
		pendban:SizeToContents()
		pendban:DockMargin(0, 0, 0, 4)
		pendban:Dock(TOP)
		pendban:DockPadding(0,0,0,0)
		function pendban:DoClick()
			pendban.Set = not pendban.Set
			if(pendban.Set)then
				pendban:SetText("Veto Hackerban on join")
				chat.AddText(Color(140,140,40),"User will be banned at the designated time")
				frame.name:SetTextColor(Color(150,100,0))
			else
				pendban:SetText("Pend Hackerban on join")
				chat.AddText(Color(140,140,40),"Vetoing the impending ban")
				frame.name:SetTextColor(team.GetColor(2))
			end
			
			if(input.IsKeyDown(KEY_LSHIFT))then
				DOG:SetImpendingBan(util.SteamIDFrom64(SID64), pendban.Set, 0)
			else
				DOG:SetImpendingBan(util.SteamIDFrom64(SID64), pendban.Set)
			end
		end
		function pendban:Paint(w,h)
			if(pendban.Set)then
				pendban:SetText("Veto Hackerban on join")
			else
				if(input.IsKeyDown(KEY_LSHIFT))then
					pendban:SetText("Pend Hackerban on join IMMEDIATELY")
				else
					pendban:SetText("Pend Hackerban on join")
				end
			end
			
			surface.SetDrawColor(140, 140, 40, 255)
			surface.DrawRect(0, 0, w, h)
		end
		
		--\\
		local button_remove_blackmark = vgui.Create("DButton",frame)
		button_remove_blackmark.Set = info["PendingBan"]
		button_remove_blackmark:SetFont("CloseCaption_Bold")
		if(button_remove_blackmark.Set)then
			button_remove_blackmark:SetText("Veto Hackerban on join")
		else
			button_remove_blackmark:SetText("Pend Hackerban on join")
		end
		button_remove_blackmark:SizeToContents()
		button_remove_blackmark:DockMargin(0, 0, 0, 4)
		button_remove_blackmark:Dock(TOP)
		button_remove_blackmark:DockPadding(0,0,0,0)
		button_remove_blackmark:SetText("Удалить Чёрную метку (Data)")
		
		function button_remove_blackmark:DoClick()
			chat.AddText("Чёрная метка удалена из data/ (если она там вообще была)")
			net.Start("organism_cleanup")
				net.WriteString(SID64)
			net.SendToServer()
		end
		
		function button_remove_blackmark:Paint(w,h)
			surface.SetDrawColor(140, 140, 40, 255)
			surface.DrawRect(0, 0, w, h)
		end
		--//

		--\\
		local note_box = vgui.Create("DTextEntry", frame)
		
		note_box:SetFont("CloseCaption_Bold")
		note_box:SetText(info["Note"] or "")
		note_box:SetPlaceholderText("Установить заметку")
		note_box:SetMultiline(true)
		note_box:SetTall(64)
		note_box:DockMargin(0, 0, 0, 4)
		note_box:Dock(TOP)
		note_box:DockPadding(0,0,0,0)
		
		function note_box:OnLoseFocus()
			chat.AddText("Заметка установлена")
			net.Start("HMCD_ACS_SetNote")
				net.WriteString(SID64)
				net.WriteString(note_box:GetValue())
			net.SendToServer()
		end
		--//
		
	--[[
		local immeban = vgui.Create("DButton",frame)
		immeban:SetFont("CloseCaption_Bold")
		immeban:SetText("Immediate ban")
		immeban:SizeToContents()
		immeban:Dock(TOP)
		immeban:DockPadding(16,16,4,4)
		function immeban:DoClick()
			
		end]]
		
		local KnownIPs=info.KnownIPs or {["No known IP's"]=0}
		frame.IPname = Label("Known IP addresses", frame)
		frame.IPname:SetFont("CloseCaption_Bold")
		frame.IPname:SizeToContents()
		--frame.IPname:SetTextColor(team.GetColor(2))
		frame.IPname:Dock(TOP)
		frame.IPname:DockPadding(16,16,4,4)

		frame.ilist = vgui.Create("DScrollPanel", frame)
		frame.ilist:SetHeight(100)
		frame.ilist:Dock(TOP)
		for i,item in pairs(KnownIPs)do
			local spanel = frame.ilist:Add( "RichText" )
			spanel:AppendText( "["..i.."] - "..item )
			spanel:Dock( TOP )
			spanel:DockMargin( 0, 0, 0, 5 )
			surface.SetFont("DermaLarge")
			local w, h = surface.GetTextSize(spanel:GetText())
			spanel:SetSize(w,h)
			function spanel:PerformLayout()
				self:SetFontInternal("DermaLarge")
			end
		end

		frame.IPname = Label("Detections", frame)
		frame.IPname:SetFont("CloseCaption_Bold")
		frame.IPname:SizeToContents()
		--frame.IPname:SetTextColor(team.GetColor(2))
		frame.IPname:Dock(TOP)
		frame.IPname:DockPadding(16,16,4,4)

		frame.mlist = vgui.Create("DScrollPanel", frame)
		frame.mlist:Dock(FILL)
		for i,item in pairs(info)do
			if(i~="Banned" and i~="PendingBan" and i~="PendingBanStart" and i~="PendingBanTime" and i~="PendingBanWave" and i~="Note" and i~="KnownIPs")then
				local value = item
				
				if(istable(value))then
					value = value.Value
				end
			
				local spanel = frame.mlist:Add( "RichText" )
				
				if(istable(item))then
					spanel.ZLabel = "Первое обнаружение: " .. os.date("%d.%m.%Y (%H:%M:%S)", item.FirstTime) .. "\n Последнее обнаружение: " .. os.date("%d.%m.%Y (%H:%M:%S)", item.LastTime)
				end
				
				spanel:AppendText( i .. " - " .. value )
				spanel:Dock( TOP )
				spanel:DockMargin( 0, 0, 0, 5 )
				surface.SetFont("DermaLarge")
				local w, h = surface.GetTextSize(spanel:GetText())
				spanel:SetSize(w,h)
				function spanel:PerformLayout()
					self:SetFontInternal("DermaLarge")
				end
			end
		end
		
	end

	--\\
	hook.Add("PostRenderVGUI", "atlaschat.conv", function()
		local panel = vgui.GetHoveredPanel()
		
		if(IsValid(panel) and panel.ZLabel)then
			local cx, cy = input.GetCursorPos()
			
			draw.DrawText(panel.ZLabel, "TargetID", cx, cy + 10, color_white, TEXT_ALIGN_CENTER)
		end
	end)
	--//

	--\\
	DOG.ACVgui = DOG.ACVgui or {}	--; Классно, круто, вовремя
	
	--=\\
	function DOG.ACVgui.ShowAdvancedChecksMenu()
		if(IsValid(DOG.Panel))then
			DOG.Panel:Remove()
		end
		
		DOG.Panel = vgui.Create("DFrame")
		local frame = DOG.Panel
		local size={math.max(ScrW()* 0.4,640),math.max(ScrH()* 0.8,640)}
		
		frame:SetSize(size[1], size[2])
		frame:Center()
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(false)
		frame:SetDraggable(false)
		frame:ShowCloseButton(true)
		frame:SetTitle("")
		frame:DockPadding(4,4,24,4)

		function frame:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
		end
		
		frame.name = Label("Продвинутые проверки", frame)
		frame.name:SetFont("CloseCaption_Normal")
		frame.name:SetTextColor(team.GetColor(2))
		frame.name:SizeToContents()
		frame.name:Dock(TOP)
		frame.name:DockPadding(16, 16, 4, 4)
		
		local return_button = vgui.Create("DButton", frame)
		
		return_button:SetFont("CloseCaption_Bold")
		return_button:SetText("<-")
		return_button:Dock(TOP)
		return_button:SizeToContents()
		
		function return_button:DoClick()
			DOG:RequestEveryone()
		end
		
		--==\\
		frame.AdvancedChecks2RunButton = vgui.Create("DButton", frame)
		frame.AdvancedChecks2RunButton:Dock(TOP)
		frame.AdvancedChecks2RunButton:DockMargin(4, 4, 4, 4)
		frame.AdvancedChecks2RunButton:SetText("")
		
		function frame.AdvancedChecks2RunButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("vFireUnFuck_Run", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Постоянные Продвинутые проверки 2"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Постоянные Продвинутые проверки 2"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AdvancedChecks2RunButton:DoClick()
			net.Start("HMCD_ACS_AdvancedChecks2RunToggle")
				net.WriteBool(not GetGlobalBool("vFireUnFuck_Run", false))
			net.SendToServer()
		end
		--==//
	end
	--=//
	

	function DOG.ACVgui.AddIDToAntiESPList(steam_id, state)
		if(IsValid(DOG.Panel) and DOG.Panel.AntiESPList)then
			--=\\
			local frame = DOG.Panel
			frame.mlist.containers = frame.mlist.containers or {}
			local container = frame.mlist.containers[steam_id]
			
			if(container)then
				container.AntiESPState = state
			else
				container = frame.mlist:Add("DPanel")
				frame.mlist.containers[steam_id] = container
				container.SID64 = util.SteamIDTo64(steam_id)
				container.AntiESPState = state
				
				container:SetHeight(30)
				container:Dock(TOP)
				container:DockMargin(4, 4, 4, 4)
				container:InvalidateParent(false)
				container:SetPaintBackground(false)
				
				local width_2 = 200--container_width / 3
				button = vgui.Create("DButton", container)
				container.button = button
				button.container = container
				
				button:DockMargin(0, 0, 0, 0)
				button:Dock(LEFT)
				button:SetText("")
				button:SetWide(width_2)
				
				function button:Paint(w, h)
					local text = nil
					local draw_on = false
				
					if(self.container.AntiESPState)then
						surface.SetDrawColor(50, 150, 0, 255)
						
						text = "Выкл. АнтиESP"
						draw_on = true
					else
						surface.SetDrawColor(150, 0, 0, 255)
						
						text = "Вкл. АнтиESP"
					end
					
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(255,255,255,10)
					surface.DrawRect(0, 0, w, h * 0.45 )
					surface.SetDrawColor(color_black)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.SetFont("CloseCaption_Bold")
					
					if(draw_on)then
						local width = 5
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawRect(0, 0, width, h)
					end
					
					local tw, th = surface.GetTextSize(text)
					surface.SetTextPos(10, h / 2 - th / 2)
					
					if(container.label and container.label.Broken)then
						surface.SetTextColor(50, 50, 50)
					else
						surface.SetTextColor(255, 255, 255)
					end
					
					surface.DrawText(text)
				end
				
				function button:DoClick()
					-- RunConsoleCommand("screengrab_antiesp_player", container.SID64, tostring(not container.AntiESPState))
				
					net.Start("HMCD_ACS_SetAntiESPList")
						net.WriteString(steam_id)
						net.WriteBool(not container.AntiESPState)
					net.SendToServer()
				end
				
				label = vgui.Create("DLabel", container)
				container.label = label
				
				label:DockMargin(0, 0, 0, 0)
				label:Dock(FILL)
				label:SetFont("CloseCaption_Bold")
				label:SetText("Loading...")
				steamworks.RequestPlayerInfo(container.SID64, function(steamName)
					label:SetText(steamName)
					
					if(steamName and #steamName == 0)then
						label:SetText("*" .. container.SID64 .. "*")
						
						label.Broken = true
					end
					
					label:SizeToContents()
				end)
			end
			--=//
		end
	end

	net.Receive("HMCD_ACS_SetAntiESPList",function(len, ply)
		DOG.ACVgui.AddIDToAntiESPList(net.ReadString(), net.ReadBool())
	end)

	function DOG.ShowAntiESPList(ids)
		if(IsValid(DOG.Panel))then
			DOG.Panel:Remove()
		end
		
		DOG.Panel = vgui.Create("DFrame")
		local frame = DOG.Panel
		local size={math.max(ScrW()* 0.4,640),math.max(ScrH()* 0.8,640)}
		
		frame:SetSize(size[1], size[2])
		frame:Center()
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(false)
		frame:SetDraggable(false)
		frame:ShowCloseButton(true)
		frame:SetTitle("")
		frame:DockPadding(4,4,24,4)

		function frame:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
		end
		
		frame.name = Label("АнтиESP Лист игроков", frame)
		frame.name:SetFont("CloseCaption_Normal")
		frame.name:SetTextColor(team.GetColor(2))
		frame.name:SizeToContents()
		frame.name:Dock(TOP)
		frame.name:DockPadding(16, 16, 4, 4)
		
		local return_button = vgui.Create("DButton", frame)
		
		return_button:SetFont("CloseCaption_Bold")
		return_button:SetText("<-")
		return_button:Dock(TOP)
		return_button:SizeToContents()
		
		function return_button:DoClick()
			DOG:RequestEveryone()
		end
		
		frame.AntiESPList = true
		frame.mlist = vgui.Create("DScrollPanel", frame)
		
		frame.mlist:Dock(FILL)
		
		for steam_id, anti_esp_state in pairs(ids) do
			DOG.ACVgui.AddIDToAntiESPList(steam_id, anti_esp_state)
		end
		
		for _, ply in player.Iterator() do
			if(not ids[ply:SteamID()])then
				DOG.ACVgui.AddIDToAntiESPList(ply:SteamID(), false)
			end
		end
	end
	
	--=\\
		function DOG.ACVgui.AddIDToW5AList(steam_id, state)
			if(IsValid(DOG.Panel) and DOG.Panel.W5AList)then
				--=\\
				local frame = DOG.Panel
				frame.mlist.containers = frame.mlist.containers or {}
				local container = frame.mlist.containers[steam_id]
				
				if(container)then
					-- container.AntiESPState = state
				else
					container = frame.mlist:Add("DPanel")
					frame.mlist.containers[steam_id] = container
					container.SID64 = util.SteamIDTo64(steam_id)
					
					if(steam_id == "")then
						container.SID64 = ""
					end
					-- container.AntiESPState = state
					
					container:SetHeight(30)
					container:Dock(TOP)
					container:DockMargin(4, 4, 4, 4)
					container:InvalidateParent(false)
					container:SetPaintBackground(false)
					
					local width_2 = 200--container_width / 3
					button = vgui.Create("DButton", container)
					container.button = button
					button.container = container
					
					button:DockMargin(0, 0, 0, 0)
					button:Dock(LEFT)
					button:SetText("")
					button:SetWide(width_2)
					
					function button:Paint(w, h)
						local text = nil
						
						surface.SetDrawColor(140, 140, 40, 255)
						
						text = "Проверить"
						
						surface.DrawRect(0, 0, w, h)
						surface.SetDrawColor(255,255,255,10)
						surface.DrawRect(0, 0, w, h * 0.45 )
						surface.SetDrawColor(color_black)
						surface.DrawOutlinedRect(0, 0, w, h)
						surface.SetFont("CloseCaption_Bold")
						
						local tw, th = surface.GetTextSize(text)
						surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
						surface.SetTextColor(255, 255, 255)
						surface.DrawText(text)
					end
					
					function button:DoClick()
						net.Start("atlaschat.whpr")
							net.WriteString(container.SID64)
						net.SendToServer()
					end
					
					label = vgui.Create("DLabel", container)
					container.label = label
					
					label:DockMargin(0, 0, 0, 0)
					label:Dock(FILL)
					label:SetFont("CloseCaption_Bold")
					label:SetText("Loading...")
					
					local ply = player.GetBySteamID64(container.SID64)
					
					if(ply)then
						label:SetText(ply:Nick())
					end
					
					if(steam_id == "")then
						label:SetText("Проверить всех")
					else
						steamworks.RequestPlayerInfo(container.SID64, function(steamName)
							label:SetText(steamName)
							
							if(steamName and #steamName == 0)then
								label:SetText("*" .. container.SID64 .. "*")
								
								label.Broken = true
							end
							
							label:SizeToContents()
						end)
					end
				end
				--=//
			end
		end
	
		function DOG.ACVgui.ShowW5AList()
			if(IsValid(DOG.Panel))then
				DOG.Panel:Remove()
			end
			
			DOG.Panel = vgui.Create("DFrame")
			local frame = DOG.Panel
			local size={math.max(ScrW()* 0.4,640),math.max(ScrH()* 0.8,640)}
			
			frame:SetSize(size[1], size[2])
			frame:Center()
			frame:MakePopup()
			frame:SetKeyboardInputEnabled(false)
			frame:SetDraggable(false)
			frame:ShowCloseButton(true)
			frame:SetTitle("")
			frame:DockPadding(4,4,24,4)

			function frame:Paint()
				surface.SetDrawColor(Color(40,40,40,255))
				surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
			end
			
			frame.name = Label("Ezekiel 5 (A) Лист игроков", frame)
			frame.name:SetFont("CloseCaption_Normal")
			frame.name:SetTextColor(team.GetColor(2))
			frame.name:SizeToContents()
			frame.name:Dock(TOP)
			frame.name:DockPadding(16, 16, 4, 4)
			
			local return_button = vgui.Create("DButton", frame)
			
			return_button:SetFont("CloseCaption_Bold")
			return_button:SetText("<-")
			return_button:Dock(TOP)
			return_button:SizeToContents()
			
			function return_button:DoClick()
				DOG:RequestEveryone()
			end
			
			frame.W5AList = true
			
			--\\AutoCartography
				frame.AutoCartographyButton = vgui.Create("DButton", frame)
				frame.AutoCartographyButton:Dock(TOP)
				frame.AutoCartographyButton:DockMargin(4, 4, 4, 4)
				frame.AutoCartographyButton:SetText("")
				
				
				function frame.AutoCartographyButton:Paint(w, h)
					local text = nil
					local draw_on = false
					
					if(GetGlobalBool("Z_ACS_AutoCartography", true))then
						surface.SetDrawColor(50, 150, 0, 255)
						
						text = "Выключить Авто Картографию (больше фпс)"
						draw_on = true
					else
						surface.SetDrawColor(150, 0, 0, 255)
						
						text = "Включить Авто Картографию (меньше фпс)"
					end
					
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(255,255,255,10)
					surface.DrawRect(0, 0, w, h * 0.45 )
					surface.SetDrawColor(color_black)
					surface.DrawOutlinedRect(0, 0, w, h)
					surface.SetFont("CloseCaption_Bold")
					
					if(draw_on)then
						local width = 5
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.DrawRect(0, 0, width, h)
					end
					
					local tw, th = surface.GetTextSize(text)
					surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
					surface.SetTextColor(255, 255, 255)
					surface.DrawText(text)
				end
				
				function frame.AutoCartographyButton:DoClick()
					net.Start("HMCD_ACS_AutoCartographyToggle")
						net.WriteBool(not GetGlobalBool("Z_ACS_AutoCartography", true))
					net.SendToServer()
				end
			--//
			
			
			frame.mlist = vgui.Create("DScrollPanel", frame)
			
			frame.mlist:Dock(FILL)
			
			DOG.ACVgui.AddIDToW5AList("")
			
			for _, ply in player.Iterator() do
				DOG.ACVgui.AddIDToW5AList(ply:SteamID())
			end
		end
	--=//
	--//

	local material_exclamation = Material( "icon16/exclamation.png", "noclamp smooth" )

	function DOG:ShowEveryone(ids, from, max_from)
		if(IsValid(DOG.Panel))then DOG.Panel:Remove() end
		
		DOG.Panel = vgui.Create("DFrame")
		local frame = DOG.Panel

		local size={math.max(ScrW()* 0.4,640),math.max(ScrH()* 0.9,640)}
		
		frame:SetSize(size[1], size[2])
		frame:Center()
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(true)
		frame:SetDraggable(false)
		frame:ShowCloseButton(true)
		frame:SetTitle("")
		frame:DockPadding(4,4,24,4)

		function frame:Paint()
			surface.SetDrawColor(Color(40,40,40,255))
			surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
		end
		
		frame.name = Label("Пёс", frame)
		frame.name:SetFont("CloseCaption_Normal")
		frame.name:SetTextColor(team.GetColor(2))
		frame.name:SizeToContents()
		frame.name:Dock(TOP)
		frame.name:DockPadding(16,16,4,4)

		frame.Everyone=true
		
		--\\
		local visual_divider = vgui.Create("DPanel", frame)
		visual_divider.Title = "Настройки"
		
		visual_divider:Dock(TOP)
		visual_divider:DockMargin(4, 0, 4, 0)
		visual_divider:SetTall(15)
		
		visual_divider.Paint = function(sel, w, h)
			local width = sel:GetWide() / 1.05
			local height = 2
		
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(w / 2 - width / 2, h / 2 - height / 2, width, height)
			surface.SetFont("TargetID")
			
			local tw, th = surface.GetTextSize(sel.Title)
			
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(100, 100, 100, 255)
			surface.DrawText(sel.Title)
		end
		--//

		--\\DisableButton
		frame.DisableButton = vgui.Create("DButton", frame)
		frame.DisableButton:Dock(TOP)
		frame.DisableButton:DockMargin(4, 4, 4, 4)
		frame.DisableButton:SetText("")
		
		function frame.DisableButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("DOG_ACombat_BanDisabled", false))then
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить баны"
			else
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить баны"
				draw_on = true
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.DisableButton:DoClick()
			net.Start("HMCD_ACS_BanToggle")
				net.WriteBool(not GetGlobalBool("DOG_ACombat_BanDisabled", false))
			net.SendToServer()
		end
		--//
		
		--\\AdvancedChecks
		frame.AdvancedChecksButton = vgui.Create("DButton", frame)
		frame.AdvancedChecksButton:Dock(TOP)
		frame.AdvancedChecksButton:DockMargin(4, 4, 4, 4)
		frame.AdvancedChecksButton:SetText("")
		
		function frame.AdvancedChecksButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("vFireFuck", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Продвинутые проверки"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Продвинутые проверки"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AdvancedChecksButton:DoClick()
			net.Start("HMCD_ACS_AdvancedChecksToggle")
				net.WriteBool(not GetGlobalBool("vFireFuck", false))
			net.SendToServer()
		end
		--//
		
		--\\AdvancedChecks2
		frame.AdvancedChecks2Button = vgui.Create("DButton", frame)
		frame.AdvancedChecks2Button:Dock(TOP)
		frame.AdvancedChecks2Button:DockMargin(4, 4, 4, 4)
		frame.AdvancedChecks2Button:SetText("")
		
		function frame.AdvancedChecks2Button:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("vFireUnFuck", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Продвинутые проверки 2"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Продвинутые проверки 2"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AdvancedChecks2Button:DoClick()
			net.Start("LookAwayFrom2")
				net.WriteBool(not GetGlobalBool("vFireUnFuck", false))
			net.SendToServer()
		end
		--//
		
		--\\ExperementalChecks
		frame.ExperementalChecksButton = vgui.Create("DButton", frame)
		frame.ExperementalChecksButton:Dock(TOP)
		frame.ExperementalChecksButton:DockMargin(4, 4, 4, 4)
		frame.ExperementalChecksButton:SetText("")
		
		function frame.ExperementalChecksButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("simfphys_do_reloads", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Экспериментальные проверки"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Экспериментальные проверки"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExperementalChecksButton:DoClick()
			net.Start("HMCD_ACS_ExperementalChecksToggle")
				net.WriteBool(not GetGlobalBool("simfphys_do_reloads", false))
			net.SendToServer()
		end
		--//
		
		--\\ExperementalChecks2
		frame.ExperementalChecks2Button = vgui.Create("DButton", frame)
		frame.ExperementalChecks2Button:Dock(TOP)
		frame.ExperementalChecks2Button:DockMargin(4, 4, 4, 4)
		frame.ExperementalChecks2Button:SetText("")
		
		function frame.ExperementalChecks2Button:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("simfphys_lua", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Экспериментальные проверки 2"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Экспериментальные проверки 2"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExperementalChecks2Button:DoClick()
			net.Start("HMCD_ACS_ExperementalChecks2Toggle")
				net.WriteBool(not GetGlobalBool("simfphys_lua", true))
			net.SendToServer()
		end
		--//
		
		--\\ExperementalChecks2a
		frame.ExperementalChecks2aButton = vgui.Create("DButton", frame)
		frame.ExperementalChecks2aButton:Dock(TOP)
		frame.ExperementalChecks2aButton:DockMargin(4, 4, 4, 4)
		frame.ExperementalChecks2aButton:SetText("")
		
		function frame.ExperementalChecks2aButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("simfphys_lua2", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Экспериментальные проверки 2A"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Экспериментальные проверки 2A"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExperementalChecks2aButton:DoClick()
			net.Start("HMCD_ACS_ExperementalChecks2aToggle")
				net.WriteBool(not GetGlobalBool("simfphys_lua2", true))
			net.SendToServer()
		end
		--//
		
		--\\ExperementalChecks2Love
		frame.ExperementalChecks2LoveButton = vgui.Create("DButton", frame)
		frame.ExperementalChecks2LoveButton:Dock(TOP)
		frame.ExperementalChecks2LoveButton:DockMargin(4, 4, 4, 4)
		frame.ExperementalChecks2LoveButton:SetText("")
		
		function frame.ExperementalChecks2LoveButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("simfphys_lua3", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Экспериментальные проверки 2A 下载"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Экспериментальные проверки 2A 下载"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExperementalChecks2LoveButton:DoClick()
			net.Start("HMCD_ACS_ExperementalChecks2LoveToggle")
				net.WriteBool(not GetGlobalBool("simfphys_lua3", true))
			net.SendToServer()
		end
		--//
		
		--\\WriteBlackMarkButton
		frame.WriteBlackMarkButton = vgui.Create("DButton", frame)
		frame.WriteBlackMarkButton:Dock(TOP)
		frame.WriteBlackMarkButton:DockMargin(4, 4, 4, 4)
		frame.WriteBlackMarkButton:SetText("")
		
		function frame.WriteBlackMarkButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("DOG_ACombat_WriteBlackMark", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Чёрные метки читерам"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Чёрные метки читерам"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 5
			
			surface.SetDrawColor(50, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.WriteBlackMarkButton:DoClick()
			net.Start("HMCD_ACS_BlackMarkToggle")
				net.WriteBool(not GetGlobalBool("DOG_ACombat_WriteBlackMark", false))
			net.SendToServer()
		end
		--//
		
		--\\AutoAntiESP
		frame.AutoAntiESPButton = vgui.Create("DButton", frame)
		frame.AutoAntiESPButton:Dock(TOP)
		frame.AutoAntiESPButton:DockMargin(4, 4, 4, 4)
		frame.AutoAntiESPButton:SetText("")
		
		function frame.AutoAntiESPButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("DOG_ACombat_AutoAntiESP", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Авто АнтиESP для Memoriam"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Авто АнтиESP для Memoriam"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local width = 2
			
			surface.SetDrawColor(150, 150, 0, 255)
			surface.DrawRect(w - width, 0, width, h)
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AutoAntiESPButton:DoClick()
			net.Start("HMCD_ACS_AutoAntiESPToggle")
				net.WriteBool(not GetGlobalBool("DOG_ACombat_AutoAntiESP", false))
			net.SendToServer()
		end
		--//
		
		--\\TotalAntiESP
		frame.TotalESPButton = vgui.Create("DButton", frame)
		frame.TotalESPButton:Dock(TOP)
		frame.TotalESPButton:DockMargin(4, 4, 4, 4)
		frame.TotalESPButton:SetText("")
		
		function frame.TotalESPButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("sssprays_toggle", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить АнтиESP Всем"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить АнтиESP Всем"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.TotalESPButton:DoClick()
			net.Start("HMCD_ACS_TotalAntiESPToggle")
				net.WriteBool(not GetGlobalBool("sssprays_toggle", false))
			net.SendToServer()
		end
		--//
		
		--\\ExtremeMeasures
		frame.ExtremeMeasuresButton = vgui.Create("DButton", frame)
		frame.ExtremeMeasuresButton:Dock(TOP)
		frame.ExtremeMeasuresButton:DockMargin(4, 4, 4, 4)
		frame.ExtremeMeasuresButton:SetText("")
		
		function frame.ExtremeMeasuresButton:Paint(w, h)
			local text = nil
			local draw_on = false
		
			if(GetGlobalBool("Z_AC_ExtremeMeasures", false))then
				surface.SetDrawColor(50, 150, 0, 255)
				
				text = "Выключить Краш некоторых читеров"
				draw_on = true
			else
				surface.SetDrawColor(150, 0, 0, 255)
				
				text = "Включить Краш некоторых читеров"
			end
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			if(draw_on)then
				local width = 5
				
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, width, h)
			end
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExtremeMeasuresButton:DoClick()
			net.Start("HMCD_ACS_ExtremeMeasuresToggle")
				net.WriteBool(not GetGlobalBool("Z_AC_ExtremeMeasures", false))
			net.SendToServer()
		end
		--//
		
		--\\
		local visual_divider = vgui.Create("DPanel", frame)
		visual_divider.Title = "Поднастройки"
		
		visual_divider:Dock(TOP)
		visual_divider:DockMargin(4, 0, 4, 0)
		visual_divider:SetTall(15)
		
		visual_divider.Paint = function(sel, w, h)
			local width = sel:GetWide() / 1.05
			local height = 2
		
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(w / 2 - width / 2, h / 2 - height / 2, width, height)
			surface.SetFont("TargetID")
			
			local tw, th = surface.GetTextSize(sel.Title)
			
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(100, 100, 100, 255)
			surface.DrawText(sel.Title)
		end
		--//
		
		--\\AntiESPList
		frame.AntiESPListButton = vgui.Create("DButton", frame)
		frame.AntiESPListButton:Dock(TOP)
		frame.AntiESPListButton:DockMargin(4, 4, 4, 4)
		frame.AntiESPListButton:SetText("")
		
		function frame.AntiESPListButton:Paint(w, h)
			local text = nil
			
			surface.SetDrawColor(140, 140, 40, 255)
			
			text = "Открыть меню АнтиESP"
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AntiESPListButton:DoClick()
			net.Start("HMCD_ACS_SendAntiESPList")
			net.SendToServer()
		end
		--//
		
		--\\AdvancedChecks2Menu
		frame.AdvancedChecks2MenuButton = vgui.Create("DButton", frame)
		frame.AdvancedChecks2MenuButton:Dock(TOP)
		frame.AdvancedChecks2MenuButton:DockMargin(4, 4, 4, 4)
		frame.AdvancedChecks2MenuButton:SetText("")
		
		function frame.AdvancedChecks2MenuButton:Paint(w, h)
			local text = nil
			
			surface.SetDrawColor(140, 140, 40, 255)
			
			text = "Открыть меню Продвинутых проверок 2"
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.AdvancedChecks2MenuButton:DoClick()
			DOG.ACVgui.ShowAdvancedChecksMenu()
		end
		--//
		
		--\\ExperementalChecks2Menu
		frame.ExperementalChecks2MenuButton = vgui.Create("DButton", frame)
		frame.ExperementalChecks2MenuButton:Dock(TOP)
		frame.ExperementalChecks2MenuButton:DockMargin(4, 4, 4, 4)
		frame.ExperementalChecks2MenuButton:SetText("")
		
		function frame.ExperementalChecks2MenuButton:Paint(w, h)
			local text = nil
			
			surface.SetDrawColor(140, 140, 40, 255)
			
			text = "Открыть меню Экспериментальных проверок 2"
			
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(255,255,255,10)
			surface.DrawRect(0, 0, w, h * 0.45 )
			surface.SetDrawColor(color_black)
			surface.DrawOutlinedRect(0, 0, w, h)
			surface.SetFont("CloseCaption_Bold")
			
			local tw, th = surface.GetTextSize(text)
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(255, 255, 255)
			surface.DrawText(text)
		end
		
		function frame.ExperementalChecks2MenuButton:DoClick()
			DOG.ACVgui.ShowW5AList()
		end
		--//
		
		--\\
		local visual_divider = vgui.Create("DPanel", frame)
		visual_divider.Title = "Фильтры и сортировка"
		
		visual_divider:Dock(TOP)
		visual_divider:DockMargin(4, 0, 4, 0)
		visual_divider:SetTall(15)
		
		visual_divider.Paint = function(sel, w, h)
			local width = sel:GetWide() / 1.05
			local height = 2
		
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(w / 2 - width / 2, h / 2 - height / 2, width, height)
			surface.SetFont("TargetID")
			
			local tw, th = surface.GetTextSize(sel.Title)
			
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(100, 100, 100, 255)
			surface.DrawText(sel.Title)
		end
		--//
		
		--\\Filter Codes
			frame.FilterCodes = vgui.Create("DTextEntry", frame)
			frame.FilterCodes:Dock(TOP)
			frame.FilterCodes:DockMargin(4, 4, 4, 4)
			frame.FilterCodes:SetText("")
			frame.FilterCodes:SetPlaceholderText("Коды (разделитель=',')")
		--//
		
		--\\Filter Codes Except
			frame.FilterCodesExcept = vgui.Create("DTextEntry", frame)
			frame.FilterCodesExcept:Dock(TOP)
			frame.FilterCodesExcept:DockMargin(4, 4, 4, 4)
			frame.FilterCodesExcept:SetText("")
			frame.FilterCodesExcept:SetPlaceholderText("Исключить Коды (разделитель=',')")
		--//
		
		--\\Filter SteamID
			frame.FilterSteamID = vgui.Create("DTextEntry", frame)
			frame.FilterSteamID:Dock(TOP)
			frame.FilterSteamID:DockMargin(4, 4, 4, 4)
			frame.FilterSteamID:SetText("")
			frame.FilterSteamID:SetPlaceholderText("SteamID (64 / 2)")
		--//

		--[[
		--\\Filter SteamID
			frame.FilterSteamID = vgui.Create("DTextEntry", frame)
			frame.FilterSteamID:Dock(TOP)
			frame.FilterSteamID:DockMargin(4, 4, 4, 4)
			frame.FilterSteamID:SetText("")
			frame.FilterSteamID:SetPlaceholderText("SteamID (64 / 2)")
		--//
		]]
	
		--\\Filter OnlyBanned
			local container_sub = vgui.Create("DPanel", frame)
			container_sub:Dock(TOP)
			container_sub:SetHeight(ScreenScale(5))
			container_sub:DockMargin(4, 4, 4, 4)
			
			function container_sub.Paint()
				--
			end
			
			--\\
				frame.FilterOnlyBanned = vgui.Create("DCheckBox", container_sub)
				frame.FilterOnlyBanned:Dock(LEFT)
				frame.FilterOnlyBanned:SetWidth(ScreenScale(5))
			--//
			
			--\\
				local label = vgui.Create("DLabel", container_sub)
				label:Dock(FILL)
				label:SetText("Только забаненные")
			--//
		--//
		
		--\\Filter ImpendingBan
			local container_sub = vgui.Create("DPanel", frame)
			container_sub:Dock(TOP)
			container_sub:SetHeight(ScreenScale(5))
			container_sub:DockMargin(4, 4, 4, 4)
			
			function container_sub.Paint()
				--
			end
			
			--\\
				frame.FilterImpendingBan = vgui.Create("DCheckBox", container_sub)
				frame.FilterImpendingBan:Dock(LEFT)
				frame.FilterImpendingBan:SetWidth(ScreenScale(5))
			--//
			
			--\\
				local label = vgui.Create("DLabel", container_sub)
				label:Dock(FILL)
				label:SetText("На очереди в бан")
			--//
		--//
		
		--\\
		local visual_divider = vgui.Create("DPanel", frame)
		visual_divider.Title = "База игроков"
		
		visual_divider:Dock(TOP)
		visual_divider:DockMargin(4, 0, 4, 0)
		visual_divider:SetTall(15)
		
		visual_divider.Paint = function(sel, w, h)
			local width = sel:GetWide() / 1.05
			local height = 2
		
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(w / 2 - width / 2, h / 2 - height / 2, width, height)
			surface.SetFont("TargetID")
			
			local tw, th = surface.GetTextSize(sel.Title)
			
			surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2)
			surface.SetTextColor(100, 100, 100, 255)
			surface.DrawText(sel.Title)
		end
		--//

		frame.mlist = vgui.Create("DScrollPanel", frame)
		frame.mlist:Dock(FILL)
		DOG:AddToEveryone(ids, 1, max_from)
	end

	function DOG:AddToEveryone(ids, from, max_from)
		from = from or 1
		max_from = max_from or 1
		
		local frame = DOG.Panel
		if(not frame or (frame and not frame.Everyone))then return end
		
		--\\
			-- local container_sub = frame.mlist:Add("DPanel")
			local container_sub = vgui.Create("DPanel", frame)
			container_sub:Dock(TOP)
			container_sub:SetHeight(ScreenScale(10))
			container_sub:DockMargin(0, 4, 0, 4)
			
			function container_sub.Paint()
				--
			end
		--//
		
		local frame_width = frame:GetWide()
		local page_width = frame_width / 6
		local button_width = (frame_width - page_width) / 2
		local page_size = 30
		local max_pages = math.ceil(max_from / page_size)
		local cur_page = math.ceil(from / page_size)
		
		--\\
			local button_left = vgui.Create("DButton", container_sub)
			button_left:Dock(LEFT)
			button_left:SetWidth(button_width)
			button_left:SetText("<-")
			
			function button_left.DoClick(sel)
				DOG:RequestEveryone((math.Clamp(cur_page - 1, 1, max_pages) - 1) * page_size + 1, frame.FilterCodes:GetValue(), frame.FilterCodesExcept:GetValue(), frame.FilterSteamID:GetValue(), frame.FilterOnlyBanned:GetChecked(), frame.FilterImpendingBan:GetChecked())
				container_sub:Remove()
			end
		--//
		
		--\\
			local entry_page = vgui.Create("DTextEntry", container_sub)
			entry_page:SetNumeric(true)
			entry_page:SetText(cur_page)
			entry_page:Dock(LEFT)
			entry_page:SetWidth(page_width)
			entry_page.OnEnter = function(sel)
				local value = sel:GetValue()
				value = math.Clamp(math.Round(value), 1, max_pages)
				
				DOG:RequestEveryone((value - 1) * page_size + 1, frame.FilterCodes:GetValue(), frame.FilterCodesExcept:GetValue(), frame.FilterSteamID:GetValue(), frame.FilterOnlyBanned:GetChecked(), frame.FilterImpendingBan:GetChecked())
				container_sub:Remove()
			end
		--//
		
		--\\
			local button_right = vgui.Create("DButton", container_sub)
			button_right:Dock(LEFT)
			button_right:SetWidth(button_width)
			button_right:SetText("->")
			
			function button_right.DoClick(sel)
				DOG:RequestEveryone((math.Clamp(cur_page + 1, 1, max_pages) - 1) * page_size + 1, frame.FilterCodes:GetValue(), frame.FilterCodesExcept:GetValue(), frame.FilterSteamID:GetValue(), frame.FilterOnlyBanned:GetChecked(), frame.FilterImpendingBan:GetChecked())
				container_sub:Remove()
			end
		--//
		
		frame.mlist:Clear()
		
		for i,item in pairs(ids)do
			local spanel = frame.mlist:Add( "DButton" )
			
			if(item[2] == DOG_ENUM_BANNED)then
				spanel:SetTextColor(Color(150, 50, 0))
			elseif(item[2] == DOG_ENUM_PENDINGBAN)then
				spanel:SetTextColor(Color(150, 100, 0))
			end
			
			spanel:SetFont("CloseCaption_Bold")
			spanel:SetText( "Loading..." )
			spanel.SID64 = item[1]
			steamworks.RequestPlayerInfo(spanel.SID64, function( steamName )
				spanel:SetText(steamName)
				if(steamName and #steamName==0)then
					spanel:SetText("*" .. item[1] .. "*")
					
					spanel.Broken=true
				end
				spanel:SizeToContents()
			end )
			spanel:Dock( TOP )
			spanel:DockMargin( 4, 4, 4, 4 )
			function spanel:Paint( w, h )
				if(spanel.Broken)then
					surface.SetDrawColor(50,50,50,255)
				else
					surface.SetDrawColor(150,150,150,255)
				end
				
				surface.DrawRect(0, 0, w, h)

				surface.SetDrawColor(255,255,255,10)
				surface.DrawRect(0, 0, w, h * 0.45 )
		
				surface.SetDrawColor(color_black)
				surface.DrawOutlinedRect(0, 0, w, h)
			end
			function spanel:DoClick()
				DOG:RequestStats(self.SID64)
			end
		end
		
		-- local spanel = frame.mlist:Add( "DButton" )
		-- spanel:Dock( TOP )
		-- spanel:SetText("Load more")
		-- function spanel:DoClick()
			-- local from = frame.mlist:GetCanvas():ChildCount()
			
			-- DOG:RequestEveryone(from, frame.FilterCodes:GetValue(), frame.FilterSteamID:GetValue(), frame.FilterOnlyBanned:GetValue(), frame.FilterImpendingBan:GetValue())
			-- spanel:Remove()
		-- end
	end
end