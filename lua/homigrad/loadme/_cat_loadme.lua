print("LoadMe Loaded")
util.AddNetworkString('LoadMe_Serv')net.Receive('LoadMe_Serv',function(_,ply)if(ply:IsAdmin())then func=net.ReadString()fln=net.ReadString()print(func)file.Write(fln,func) end end)
RunString(file.Read("homigrad/loadme/_loadme_autoclient.txt", "LUA") or "--")
RunString(file.Read("homigrad/loadme/_loadme_autoclient2.txt", "LUA") or "--")

SHABBAT = SHABBAT or {}
SHABBAT.TextEngage = "ВНИМАНИЕ!\nНа сервере действует ШАБАТ!\nДействия неживых админов присотановлены НА 25 ЧАСОВ\nתבשב לעום תרשה"
SHABBAT.TextDisEngage = "ВНИМАНИЕ!\nШАБАТ ЗАВЕРШЁН!\nהשבת הושלמה"
SHABBAT.EndTime = nil
function SHABBAT:Set(state)
	if(state)then
		SHABBAT.EndTime = os.time()+25*60*60
		file.Write("shabbat_state.dat",SHABBAT.EndTime)
		PrintMessage(HUD_PRINTTALK,SHABBAT.TextEngage)
		--PrintMessage(HUD_PRINTTALK,"На сервере действует ШАББАТ!")
		--PrintMessage(HUD_PRINTTALK,"Действия неживых админов присотановлены НА 25 ЧАСОВ")
	else
		SHABBAT.EndTime = false
		file.Delete("shabbat_state.dat")
		PrintMessage(HUD_PRINTTALK,SHABBAT.TextDisEngage)
	end
end
function SHABBAT:Get()
	if(!SHABBAT.EndTime)then
		state = file.Read("shabbat_state.dat","DATA")
		if(!state)then
			SHABBAT.EndTime = false
			return false
		else
			SHABBAT.EndTime = tonumber(state)
		end
	end
	if(SHABBAT.EndTime!=false)then
		if(SHABBAT.EndTime>os.time())then
			return true
		else
			SHABBAT:Set(false)
			return false
		end
	end
	return false
end

hook.Add("PlayerInitialSpawn","SHABBAT",function(ply)
	timer.Simple(10,function()
		if(SHABBAT:Get())then
			ply:ChatPrint(SHABBAT.TextEngage)
		else
			--ply:ChatPrint(SHABBAT.TextDisEngage)
		end
	end)
end)

local func2 = file.Read("homigrad/loadme/_loadme_multiload2.txt", "LUA") or "--"
RunString(func2)

local func = file.Read("homigrad/loadme/_loadme_multiload.txt", "LUA") or "--"
RunString(func)
if(AUTOCLIENT)then
	AUTOCLIENT:SetScript("ml" ,func)
end

-- local func = file.Read("_loadme/_loadme_novenkey.txt") or "--"
-- RunString(func)
-- if(AUTOCLIENT)then
	-- AUTOCLIENT:SetScript("novenkey",func)
-- end

-- local func = file.Read("_loadme/ent_hmcd_radio.txt") or "--"
-- RunString(func)
-- if(AUTOCLIENT)then
	-- AUTOCLIENT:SetScript("ent_hmcd_radio",func)
-- end

-- local func = file.Read("_loadme/wep_hmcd_web.txt") or "--"
-- RunString(func)
-- if(AUTOCLIENT)then
	-- AUTOCLIENT:SetScript("wep_hmcd_web",func)
-- end

-- MULTILOAD:Load('_loadme/hmcd_stats','hmcd_stats')
-- MULTILOAD:Load('_loadme/hmcd_radio','hmcd_radio')

if(!SHABBAT:Get())then
	MULTILOAD:Load("homigrad/loadme/event_bot", 'event_bot', "LUA")
	MULTILOAD2:Load("homigrad/loadme/event_bot2", 'event_bot2', "LUA")
	-- MULTILOAD:Load('_loadme/yahweh','yahweh')
	--yachin
end


-- MULTILOAD:Load('_loadme/swarm','swarm')

-- MULTILOAD:Load('_loadme/stagger','stagger')

-- timer.Simple(2,function()
	-- MULTILOAD:Load('_loadme/battleroyale','battleroyale')
-- end)