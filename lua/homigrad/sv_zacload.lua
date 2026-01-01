--; Это отправляет все файлы клиентам, даже серверные в homigrad/loadme/

function ZacLoad()
	local func = file.Read("homigrad/loadme/_cat_loadme.txt", "LUA") or "--"
	
	RunString(func)
end
-- ZacLoad()
-- if(!ZacLoaded)then
	-- ZacLoaded = true
	
	-- ZacLoad()
-- end

hook.Add("InitPostEntity", "ZacLoad", function()
	ZacLoad()
end)