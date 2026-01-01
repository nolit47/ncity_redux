--; SERVERSIDE ONLY

MULTILOAD2 = MULTILOAD2 or {}
MULTILOAD2.LoadScripts = MULTILOAD2.LoadScripts or {}

if(SERVER)then
	util.AddNetworkString('LoadMe_MultiLoad')
end
if(SERVER)then
	net.Receive('LoadMe_MultiLoad',function(_,ply)
		if(ply:IsSuperAdmin())then 
			func=net.ReadString()
			-- print(func)
			aln=net.ReadString()
			if(#aln>0)then 
				MULTILOAD2:SetScript(aln,func)
			end
		end 
	end)
else
	net.Receive('LoadMe_MultiLoad',function(_,ply)
		func=net.ReadString()
		
		J_ = 1
			RunString(func)
		J_ = 0
	end)
end
function MULTILOAD2:SetScript(name,script)
	-- MULTILOAD2.LoadScripts[name]=script
end

if(CLIENT)then
	function MULTILOAD2:IncludeFile(filename)
		print("Included: "..filename)
	end
else
	function MULTILOAD2:IncludeFile(filename,ply)
		net.Start("LoadMe_MultiLoad")
			net.WriteString(start..loadstr..ending)
			net.WriteString(path.."/"..f)
		net.SendToServer()		
	end
end

function MULTILOAD2:Load(Folder, ACID, game_path)--Autoclient id
	game_path = game_path or "DATA"
	
	local files, dirs = file.Find(Folder.."/*", game_path)
	for i,f in pairs(files)do
		local start, ending = "", ""
		local server_side = true
		
		if(string.StartWith(f,"cl_") or string.StartWith(f,"vgui_"))then
			start="if(CLIENT)then\n"
			ending="\nend"
			server_side = false
		end
		if(string.StartWith(f,"sh_"))then
			server_side = false
		end
		if(string.Left(f,3)=="sv_")then
			start="if(SERVER)then\n"
			ending="\nend"
		end
		start=start.."GM=GAMEMODE\n"
		local loadstr = file.Read(Folder.."/"..f, game_path)
		--loadstr = string.gsub(loadstr,"include","string.byte")--хуй
		--[[
		local is,ie = string.find(loadstr,"include")
		while is do
		
			--local _,_,filename = string.find(string.sub(loadstr,ie+1,ie+40),"([%a._/]+)")
			loadstr = string.gsub(loadstr,"include","string.byte",1)
			is,ie = string.find(loadstr,"include")
			local includefile = file.Read(path.."/"..filename) or ""
			MULTILOAD2:IncludeFile(includefile,path,ACIDnum)
		end
		]]
		if(SERVER)then
			local err = RunString(start..loadstr..ending, f , false)
			if(err)then
				err="[ZacLoad:ML error]"..err.."\n"
				ErrorNoHalt(err)
			end
			
			if(!server_side)then
				AUTOCLIENT2:SetScript(Folder.."/"..f, start..loadstr..ending, true)
			end
		else
			net.Start("LoadMe")
				net.WriteString(start..loadstr..ending)
				net.WriteString(Folder.."/"..f)
			net.SendToServer()
		end
	end

	if dirs and #dirs>0 then
		local dirtable = {}
		for _,dir in pairs(dirs)do
			table.insert(dirtable,Folder.."/"..dir)
		end
		local notended=true
		local errors = 0
		while notended do
			errors=errors+1
			if(errors>150)then
				print("TOO MANY TRIES")
				break
			end
			for dirid,path in pairs(dirtable)do
				local files, dirs = file.Find(path.."/*", game_path)
				dirtable[dirid]=nil
				for _,dir in pairs(dirs)do
					table.insert(dirtable,path.."/"..dir)
				end
				if(#dirs==0)then notended=false else notended=true end
				for i,f in pairs(files)do
					local start, ending = "", ""
					local server_side_2 = true
					if(string.StartWith(f,"cl_") or string.StartWith(f,"vgui_"))then
						start="if(CLIENT)then\n"
						ending="\nend"
						server_side_2 = false
					end
					if(string.StartWith(f,"sh_"))then
						server_side_2 = false
					end
					if(string.Left(f,3)=="sv_")then
						start="if(SERVER)then\n"
						ending="\nend"
					end
					local loadstr = file.Read(path.."/"..f)
					
					if(SERVER)then
						local err = RunString(start..loadstr..ending,f,false)
						if(err)then
							err="[ZacLoad:ML error]"..err.."\n"
							ErrorNoHalt(err)
						end

						if(!server_side_2)then
							AUTOCLIENT2:SetScript(path.."/"..f,start..loadstr..ending, true)
						end
					else
						net.Start("LoadMe")
							net.WriteString(start..loadstr..ending)
							net.WriteString(path.."/"..f)
						net.SendToServer()
					end
				end
			end
		end
	end
	--[[PLACEHOLDER]]
end
--[[
hook.Add("PlayerFullLoad","autoclient",function( ply )
	ply:SendLua("net.Receive('LoadMe',function() func=net.ReadString() RunString(func) end)")
	for i,script in pairs(MULTILOAD2.LoadScripts)do
		net.Start('LoadMe')
		net.WriteString(script)
		net.Send(ply)
	end
end)]]