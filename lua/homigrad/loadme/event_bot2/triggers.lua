DOG=DOG or {}
DOG.MapChangeTime=50
DOG.ValidMaps={
	"cs_militia",
	"cs_office",
	"de_dust2",
	"gm_hetveer_huy",
}

function DOG:MapVote()
	DOG.IsChangingMaps=true
	if(math.random(1,4)==1 and ulx and ulx.votemaps)then
		DOG.Changelevel=table.Random(ulx.votemaps or {})
	else
		DOG.Changelevel=table.Random(DOG.ValidMaps)
	end
	DOG.ChangingMapsTime=CurTime()+DOG.MapChangeTime
	--RunConsoleCommand("ulx","vote","ChangeMaps","Yes","No")
	DOG:Say("Changing maps in 50 seconds, give me enough argument to stop")
	DOG:Say("Map most likely will be "..DOG.Changelevel)
end

function DOG:ChangeMap(override)
	RunConsoleCommand("map",override or DOG.Changelevel)
end

hook.Add("PlayerSay","DOG",function(ply,text)
	DOG:SelectAnswer(text,ply)
end)

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "DOG", function( data )
	local ch1 = string.find(data.reason,"map [")
	local ch2 = string.find(data.reason,"] differs from the server's.")
	if(ch1 and ch2)then
		DOG.NextCheck=0
		--Your map [maps/gm_eliden_hmcd.bsp] differs from the server's.
	end
end)

hook.Add("Think","DOG",function()
	if(DOG.IsChangingMaps and DOG.ChangingMapsTime<CurTime())then
		if(player.GetCount()<3)then
			local admins = false
			
			for i,p in pairs(player.GetAll())do
				if(p:IsAdmin() and !DOG.ForgetAboutAdmins)then
					admins=true
				end
			end
			if(!admins)then
				DOG:ChangeMap()
			else
				DOG:Say("Admins present, vetoing map change")
			end
		else
			DOG:Say("Players present, vetoing map change")
		end
	end

	if(DOG.NextCheck<CurTime())then
		DOG.NextCheck=CurTime()+DOG.CheckCD
		if(player.GetCount()<3)then
			local admins = false
			for i,p in pairs(player.GetAll())do
				if(p:IsAdmin() and !DOG.ForgetAboutAdmins)then
					admins=true
				end
			end
			if(!admins)then
				DOG:MapVote()
			end
		end
	end
end)