if(1)then return nil end

DOG=DOG or {}
DOG.ACrash=DOG.ACrash or {}
DOG.ACrash.CPS=0
DOG.ACrash.CPSAll=0
DOG.ACrash.NextWipe=0
DOG.ACrash.NextStart=nil
DOG.ACrash.NextStart=CurTime()+1
DOG.ACrash.NextMsg=0
DOG.ACrash.NextMsgEffective=0
DOG.ACrash.ThinkLags=0
DOG.ACrash.SavingDeltaTime=9999
DOG.ACrash.Shitlist={}

DOG.ACrash.Values=DOG.ACrash.Values or {}

DOG.ACrash.Values["UnScrew"]=980
DOG.ACrash.Values["Phys"]=1100
DOG.ACrash.Values["Effective"]=1250
DOG.ACrash.Values["CleanUp"]=1300
DOG.ACrash.Values["Restart"]=1400

DOG.ACrash.Con_KillEnts=CreateConVar("dog_killents",1,FCVAR_ARCHIVE)

DOG.ACrash.CountFunc=function(ent)	
	
	if(!DOG or DOG.ACrash.Disabled)then return nil end
	
	if (    not IsValid(ent)   )    then return nil end;
	if (    ent:IsPlayer()     )    then return nil end;
	if (    ent:IsNPC()        )    then return nil end;
	if (    ent:IsVehicle()    )    then return nil end;

	if(DOG.ACrash.NextStart)then return nil end
	
	if(DOG.ACrash.NextWipe and DOG.ACrash.NextWipe+1<CurTime())then
		DOG.ACrash.CPS=0
		DOG.ACrash.CPSAll=0
		DOG.ACrash.NextWipe=CurTime()
	end

	--ent:GetClass() == "prop_physics" and
	--if ( dmginfo:GetDamageType() == DMG_CRUSH ) then
	DOG.ACrash.CPS=DOG.ACrash.CPS+1
	DOG.ACrash.CPSAll=DOG.ACrash.CPSAll+1

	--end
	
	if(DOG.ACrash.CPS>DOG.ACrash.Values["UnScrew"])then
		local phy = ent:GetPhysicsObject();
		
		if(ent:GetClass() == "prop_ragdoll")then
			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local phy = ent:GetPhysicsObjectNum( i )
				if ( IsValid( phy ) ) then
					phy:EnableMotion( false )
				else
					SafeRemoveEntityDelayed(ent,0)
					--ent:Remove()
					break
				end
			end
			table.insert(DOG.ACrash.Shitlist,ent)
		else
			if ( IsValid( phy ) ) then
				phy:EnableMotion( false )
				table.insert(DOG.ACrash.Shitlist,ent)
			else
				SafeRemoveEntityDelayed(ent,0)
				--ent:Remove()
			end
		end
		if(DOG.ACrash.NextMsg<CurTime())then
			DOG.ACrash.NextMsg=CurTime()+10
			DOG:Say("Something trying to screw up the server, unscrewing")
		end

	end
	
	if(DOG.ACrash.CPS>DOG.ACrash.Values["Phys"])then
		RunConsoleCommand("phys_timescale", 0)
		DOG.ACrash.NextEnablePhysics=CurTime()+50
		cookie.Set("dog_physdisabled",1)
		
		DOG:Say("Not enough. Disabling physics")
		DOG.ACrash.CPS=0
	end
	
	if(DOG.ACrash.CPSAll>DOG.ACrash.Values["Effective"])then
		SafeRemoveEntityDelayed(ent,0)
		
		if(DOG.ACrash.NextMsgEffective<CurTime())then
			DOG.ACrash.NextMsgEffective=CurTime()+10
			DOG:Say("Trying effective means")
		end	
	end
	
	if(DOG.ACrash.CPSAll>DOG.ACrash.Values["CleanUp"])then
		DOG:Say("Cleaning up")
		timer.Simple(0,function()
			game.CleanUpMap()
		end)
	end			
	
	if(DOG.ACrash.CPSAll>DOG.ACrash.Values["Restart"])then
		DOG:Say("Restarting")
		--DOG.ACrash.CPSAll=0
		--game.LoadNextMap()
		RunConsoleCommand("changelevel",game.GetMap())
	end		
end

--[[
hook.Add("InitPostEntity","DOG",function()
	DOG.ACrash.NextStart=nil
end)]]

hook.Add("OnEntityCreated","DOG",function(ent)
	if(SERVER)then
		if(ent.PhysicsCollide)then
		
			ent.OldPhysicsCollide=ent.OldPhysicsCollide or ent.PhysicsCollide
			function ent:PhysicsCollide(cd,col)
				ent:OldPhysicsCollide(cd,col)
				DOG.ACrash.CountFunc(self)
			end
		
		else
		
			ent:AddCallback( "PhysicsCollide",DOG.ACrash.CountFunc)
		
		end
		
		local found = false
		if(ent:GetClass()=="trigger_waterydeath")then
			timer.Simple(0,function()
				ent:Remove()
			end)
			found=true
		end
		if(found)then
			DOG:Say("Removed some entities")
		end
		if(ent:GetClass()=="ent_jack_hmcd_snowball")then
			SafeRemoveEntityDelayed(ent,30)
		end
	end
end)

if(cookie.GetNumber("dog_physdisabled",0)==1)then
	RunConsoleCommand("phys_timescale", 1)
end

hook.Add("PostCleanupMap","DOG_AC",function()
	DOG.ACrash.NextStart=CurTime()+1
end)

hook.Add("Think","DOG_AC",function()
	if(((DOG.ACrash.NextEnablePhysics and DOG.ACrash.NextEnablePhysics<CurTime()) or !DOG.ACrash.NextEnablePhysics) and cookie.GetNumber("dog_physdisabled",0)==1)then
		RunConsoleCommand("phys_timescale", 1)
		DOG.ACrash.NextEnablePhysics=nil
		cookie.Set("dog_physdisabled",0)
	end
	
	if(DOG.ACrash.NextStart and DOG.ACrash.NextStart<=CurTime())then
		DOG.ACrash.NextStart=nil
	end
	--[[
	local NormalizateTime = SysTime() - CurTime()
	if ( ( DOG.ACrash.SavingDeltaTime + 1 ) < NormalizateTime ) then
		DOG.ACrash.ThinkLags=DOG.ACrash.ThinkLags+1
		DOG.ACrash.NextWipeLags=CurTime()
	end
	DOG.ACrash.SavingDeltaTime = NormalizateTime
	
	if(DOG.ACrash.ThinkLags>5)then
		DOG:Say("Lol")
	end
	
	if(DOG.ACrash.NextWipeLags and DOG.ACrash.NextWipeLags+1<CurTime())then
		DOG.ACrash.NextWipeLags=CurTime()
	end
	]]
end)
--[[
hook.Add( "EntityTakeDamage", "DOG", function( ent, dmginfo )

   -- if ( false ) then return nil end;
    
    if (    not IsValid(ent)   )    then return nil end;
    if (    ent:IsPlayer()     )    then return nil end;
    if (    ent:IsNPC()        )    then return nil end;
    if (    ent:IsVehicle()    )    then return nil end;
	
	if(DOG.ACrash.NextWipe and DOG.ACrash.NextWipe+1<CurTime())then
		DOG.ACrash.CPS=0
		DOG.ACrash.CPSAll=0
	end

	--ent:GetClass() == "prop_physics" and
    if ( dmginfo:GetDamageType() == DMG_CRUSH ) then
		DOG.ACrash.CPS=DOG.ACrash.CPS+1
		DOG.ACrash.CPSAll=DOG.ACrash.CPSAll+1
		DOG.ACrash.NextWipe=CurTime()
	end
	
	if(DOG.ACrash.CPS>200)then
		local phy = ent:GetPhysicsObject();
		
		if(ent:GetClass() == "prop_ragdoll")then
			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local phy = ent:GetPhysicsObjectNum( i )
				if ( IsValid( phy ) ) then
					phy:EnableMotion( false )
				else
					ent:Remove()
					break
				end
			end
			table.insert(DOG.ACrash.Shitlist,ent)
		else
			if ( IsValid( phy ) ) then
				phy:EnableMotion( false )
				table.insert(DOG.ACrash.Shitlist,ent)
			else
				ent:Remove()
			end
		end
		if(DOG.ACrash.NextMsg<CurTime())then
			DOG.ACrash.NextMsg=CurTime()+10
			DOG:Say("Something trying to screw up the server, unscrewing")
		end

	end
	
	if(DOG.ACrash.CPS>500)then
		RunConsoleCommand("phys_timescale", 0)
		DOG.ACrash.NextEnablePhysics=CurTime()+50
		cookie.Set("dog_physdisabled",1)
		
		DOG:Say("Not enough. Disabling physics")
		DOG.ACrash.CPS=0
	end
	
	if(DOG.ACrash.CPSAll>700)then
		SafeRemoveEntity(ent)
		
		if(DOG.ACrash.NextMsgEffective<CurTime())then
			DOG.ACrash.NextMsgEffective=CurTime()+10
			DOG:Say("Trying effective means")
		end	
	end
	
	if(DOG.ACrash.CPSAll>900)then
		DOG:Say("Restarting")
		DOG.ACrash.CPSAll=0
		RunConsoleCommand("map",game.GetMap())
	end	
end)
]]