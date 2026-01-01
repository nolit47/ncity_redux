if(1)then return nil end
DOG=DOG or {}

DOG.Name="Dog"

function DOG:Say(sentence)
	if(DOG.ACrash.Con_ChatEnabled:GetBool())then
		local msg = DOG.Name..": "..sentence
		PrintMessage(HUD_PRINTTALK, msg)
	end
end

DOG.ACrash=DOG.ACrash or {}
DOG.ACrash.CPS=0
DOG.ACrash.CPSAll=0
DOG.ACrash.CPTAll=0

DOG.ACrash.NextWipe=0
DOG.ACrash.NextStart=nil
DOG.ACrash.NextStart=CurTime()+1
DOG.ACrash.NextMsg=0
DOG.ACrash.NextMsgEffective=0
DOG.ACrash.ThinkLags=0
DOG.ACrash.SavingDeltaTime=9999
DOG.ACrash.Shitlist={}

DOG.ACrash.UnFreezeList = DOG.ACrash.UnFreezeList or {}

DOG.ACrash.Values=DOG.ACrash.Values or {}

DOG.ACrash.Values["UnScrew"]=680
DOG.ACrash.Values["Phys"]=1100+100
DOG.ACrash.Values["Effective"]=1250+100
DOG.ACrash.Values["CleanUp"]=1300+100
DOG.ACrash.Values["Restart"]=1400+100

DOG.ACrash.Values["EntPhys"]=100

DOG.ACrash.CPSToCPTDivider = 1	--dont do this

DOG.ACrash.CPTValues=DOG.ACrash.CPTValues or {}

DOG.ACrash.CPTValues["UnScrew"]=30
DOG.ACrash.CPTValues["Phys"]=150
DOG.ACrash.CPTValues["Effective"]=400
DOG.ACrash.CPTValues["CleanUp"]=600
DOG.ACrash.CPTValues["Restart"]=800

DOG.ACrash.CPTValues["EntPhys"]=20

-- DOG.ACrash.Con_KillEnts = CreateConVar("dog_killents",1,FCVAR_ARCHIVE)
DOG.ACrash.Con_Enabled = CreateConVar("acdog_enabled",1,bit.bor(FCVAR_ARCHIVE),"Enable/Disable Anti Crash system")
DOG.ACrash.Con_ChatEnabled = CreateConVar("acdog_chat",1,bit.bor(FCVAR_ARCHIVE),"Enable/Disable Dog saying things in chat")

DOG.ACrash.ConVars = DOG.ACrash.ConVars or {}
for val, cpt in pairs(DOG.ACrash.CPTValues)do
	DOG.ACrash.ConVars[val] = CreateConVar("acdog_fixvalues_"..val,cpt,bit.bor(FCVAR_ARCHIVE),"Sets the minimum CPT required to trigger action "..val)
end

DOG.ACrash.Disabled = false

DOG.ACrash.CountFunc=function(ent,colldata)	
	
	if(!DOG or !DOG.ACrash.Con_Enabled:GetBool())then return nil end
	
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
	
	local addCPS = 1
	
	DOG.ACrash.CPS = DOG.ACrash.CPS + addCPS
	DOG.ACrash.CPSAll = DOG.ACrash.CPSAll + addCPS
	
	if(ent.DOGCPSNextWipe and (ent.DOGCPSNextWipe or 0)<=CurTime())then
		ent.DOGCPS = 0
		ent.DOGCPSNextWipe = CurTime() + 1
	end
	ent.DOGCPS = (ent.DOGCPS or 0) + addCPS
	
	
	if(DOG.ACrash.LastCPTWipe!=CurTime())then
		DOG.ACrash.LastCPTWipe = CurTime()
		DOG.ACrash.CPT = 0
		DOG.ACrash.CPTAll = 0
	end
	
	DOG.ACrash.CPT = DOG.ACrash.CPT + 1
	DOG.ACrash.CPTAll = DOG.ACrash.CPTAll + 1
	
	-- if(DOG.ACrash.CPS>DOG.ACrash.Values["UnScrew"])then
	if(DOG.ACrash.CPT > (DOG.ACrash.ConVars["UnScrew"]:GetFloat() / DOG.ACrash.CPSToCPTDivider))then
		local phy = ent:GetPhysicsObject();
		
		if(ent:GetClass() == "prop_ragdoll")then
			for i = 0, ent:GetPhysicsObjectCount() - 1 do
				local phy = ent:GetPhysicsObjectNum( i )
				if ( IsValid( phy ) ) then
					-- ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					
					if(ent.DOGNextUnFreeze and ent.DOGNextUnFreeze<=CurTime())then
						ent.DOGNextUnFreeze = nil
						phy:EnableMotion( ent.DOGWasFreezed or true )
					end
					-- if(ent.DOGCPS > DOG.ACrash.Values["EntPhys"] and !ent.DOGNextUnFreeze)then
					if(DOG.ACrash.CPT > (DOG.ACrash.ConVars["EntPhys"]:GetFloat() / DOG.ACrash.CPSToCPTDivider) and !ent.DOGNextUnFreeze)then
						ent.DOGWasFreezed = phy:IsMotionEnabled()
						ent.DOGNextUnFreeze = CurTime() + 20
						phy:EnableMotion( false )
						DOG.ACrash.UnFreezeList[#DOG.ACrash.UnFreezeList+1] = ent
					end
				else
					SafeRemoveEntityDelayed(ent,0)
					break
				end
			end
			-- table.insert(DOG.ACrash.Shitlist,ent)
		else
			if ( IsValid( phy ) ) then
				-- phy:EnableMotion( false )
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				if(ent.DOGNextUnFreeze and ent.DOGNextUnFreeze<=CurTime())then
					ent.DOGNextUnFreeze = nil
					phy:EnableMotion( ent.DOGWasFreezed or true )
				end
				-- if(ent.DOGCPS > DOG.ACrash.Values["EntPhys"] and !ent.DOGNextUnFreeze)then
				if(DOG.ACrash.CPT > (DOG.ACrash.ConVars["EntPhys"]:GetFloat() / DOG.ACrash.CPSToCPTDivider) and !ent.DOGNextUnFreeze)then
					ent.DOGWasFreezed = phy:IsMotionEnabled()
					ent.DOGNextUnFreeze = CurTime() + 10
					phy:EnableMotion( false )
					DOG.ACrash.UnFreezeList[#DOG.ACrash.UnFreezeList+1] = ent
				end
			else
				SafeRemoveEntityDelayed(ent,0)
			end
		end
		if(DOG.ACrash.NextMsg<CurTime())then
			DOG.ACrash.NextMsg=CurTime()+10
			DOG:Say("Something trying to screw up the server, unscrewing")
		end

	end
	
	-- if(DOG.ACrash.CPS>DOG.ACrash.Values["Phys"])then
	if(DOG.ACrash.CPT > (DOG.ACrash.ConVars["Phys"]:GetFloat() / DOG.ACrash.CPSToCPTDivider))then
		RunConsoleCommand("phys_timescale", 0)
		DOG.ACrash.NextEnablePhysics=CurTime()+50
		cookie.Set("dog_physdisabled",1)
		
		DOG:Say("Not enough. Disabling physics")
		-- DOG:Say("ВАУ, нет, ну ладно, это прям жесть крутая попытка была, минутка отдыха от физики, продолжайте в том же духе")
		DOG.ACrash.CPS=0
		DOG.ACrash.CPT=0
	end
	
	-- if(DOG.ACrash.CPSAll>DOG.ACrash.Values["Effective"])then
	if(DOG.ACrash.CPTAll > (DOG.ACrash.ConVars["Effective"]:GetFloat() / DOG.ACrash.CPSToCPTDivider))then
		SafeRemoveEntityDelayed(ent,0)
		
		if(DOG.ACrash.NextMsgEffective<CurTime())then
			DOG.ACrash.NextMsgEffective=CurTime()+10
			DOG:Say("Trying effective means")
		end	
	end
	
	-- if(DOG.ACrash.CPSAll>DOG.ACrash.Values["CleanUp"] and DOG.LastCleanUpTime!=CurTime())then
	if(DOG.ACrash.CPTAll > (DOG.ACrash.ConVars["CleanUp"]:GetFloat() / DOG.ACrash.CPSToCPTDivider) and DOG.LastCleanUpTime!=CurTime())then
		-- DOG:Say("Cleaning up")
		DOG:Say("Cleaning up")
		DOG.LastCleanUpTime = CurTime()
		timer.Simple(0,function()
			game.CleanUpMap()
		end)
	end
	
	-- if(DOG.ACrash.CPSAll>DOG.ACrash.Values["Restart"])then
	if(DOG.ACrash.CPTAll > (DOG.ACrash.ConVars["Restart"]:GetFloat() / DOG.ACrash.CPSToCPTDivider))then
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
				DOG.ACrash.CountFunc(self,cd)
			end
		
		else
		
			ent:AddCallback( "PhysicsCollide",DOG.ACrash.CountFunc)
		
		end
		
		-- local found = false
		-- if(ent:GetClass()=="trigger_waterydeath")then
			-- timer.Simple(0,function()
				-- ent:Remove()
			-- end)
			-- found=true
		-- end
		-- if(found)then
			-- DOG:Say("Removed some entities")
		-- end
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
	
	if(!DOG.ACrash.NextPropUnFreeze or DOG.ACrash.NextPropUnFreeze<=CurTime())then
		DOG.ACrash.NextPropUnFreeze = CurTime() + 5
		-- print(table.Count(DOG.ACrash.UnFreezeList))
		for id,ent in pairs(DOG.ACrash.UnFreezeList)do
			-- print("чекю ниг",id,ent)
			if(IsValid(ent) and ent.DOGNextUnFreeze)then
				if(ent.DOGNextUnFreeze<=CurTime())then
					if(ent:GetClass() == "prop_ragdoll")then
						for i = 0, ent:GetPhysicsObjectCount() - 1 do
							local phy = ent:GetPhysicsObjectNum( i )
							if ( IsValid( phy ) ) then
								phy:EnableMotion( ent.DOGWasFreezed or true )
							end
						end
					else
						if ( IsValid( phy ) ) then
							phy:EnableMotion( ent.DOGWasFreezed or true )
						end
					end
				end
			else
				DOG.ACrash.UnFreezeList[id] = nil
			end
		end
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