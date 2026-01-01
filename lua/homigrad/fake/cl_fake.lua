 
local att, ent, oldEntView
follow = follow or nil
local vecZero, vecFull, angZero = Vector(0, 0, 0), Vector(1, 1, 1), Angle(0, 0, 0)
local vecPochtiZero = Vector(0.1, 0.1, 0.1)
local view = {}
local math_Clamp = math.Clamp
local ang
local att_Ang, ot
local angEye = Angle(0, 0, 0)
local firstPerson

local deathLocalAng = Angle(0, 0, 0)

local angle

hook.Add("InputMouseApply", "asdasd2", function(cmd, x, y, angle)
	local tbl = {}

	tbl.cmd = cmd
	tbl.x = x
	tbl.y = y
	tbl.angle = angle

	hook.Run("HG.InputMouseApply", tbl)

	cmd = tbl.cmd
	x = tbl.x
	y = tbl.y
	angle = tbl.angle

	if not tbl.override_angle then
		angle.pitch = math.Clamp(angle.pitch + y / 50, -89, 89)
		angle.yaw = angle.yaw - x / 50
	end

	cmd:SetViewAngles(angle)
	
	return true
end)

local turned = false
hook.Add("HG.InputMouseApply", "asdasd2", function(tbl)
	local cmd = tbl.cmd
	local x = tbl.x
	local y = tbl.y
	local angle = tbl.angle

	if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end

	if LocalPlayer().lean and math.abs(LocalPlayer().lean) < 0.01 then
		oldlean = 0
		lean_lerp = 0
	end
	
	if LocalPlayer():InVehicle() and not IsValid(follow) then
		tbl.override_angle = true
		tbl.angle = angle_zero
		return true
	end

	angle.roll = (turned and 180 or 0) + lean_lerp * 10

	if not IsValid(follow) then
		turned = false
		--[[if turned then
			tbl.angle.roll = tbl.angle.roll - 180
			tbl.angle.yaw = tbl.angle.yaw - 180
			turned = false
		end--]]
		
		/*if math.EqualWithTolerance and math.EqualWithTolerance(tbl.angle.roll, 180, 10) then
			tbl.angle.roll = 0
			tbl.angle.yaw = tbl.angle.yaw - 180
		end*/

		//tbl.override_angle = false
		tbl.angle = angle
		return
	end
	
	local att = follow:GetAttachment(follow:LookupAttachment("eyes"))
	if not att or not istable(att) then return end
	local att_Ang = att.Ang

	local attang = LocalPlayer():EyeAngles()
	local view = render.GetViewSetup(true)
	local anglea = view.angles
	local angRad = math.rad(angle[3])
	local newX = x * math.cos(angRad) - y * math.sin(angRad)
	local newY = x * math.sin(angRad) + y * math.cos(angRad)
	--angle.pitch = math.Clamp( angle.pitch + newY / 50, -89, 89 )
	--angle.yaw = angle.yaw - newX / 50

	angle.pitch = math.Clamp(angle.pitch + newY / 50, -180, 180)
	angle.yaw = angle.yaw - newX / 50
	if math.abs(angle.pitch) > 89 then
		turned = not turned
		//angle.roll = angle.roll + 180
		angle.yaw = angle.yaw + 180
		angle.pitch = 89 * (angle.pitch / math.abs(angle.pitch))
	end

	if math.abs(math.AngleDifference(angle[1],att_Ang[1])) > 45 then
		--angle[1] = att_Ang[1] - math.Clamp(math.AngleDifference(att_Ang[1],angle[1]),-90,90)
	end

	if math.abs(math.AngleDifference(angle[2],att_Ang[2])) > 45 then
		--angle[2] = att_Ang[2] - math.Clamp(math.AngleDifference(att_Ang[2],angle[2]),-45,45)
	end

	tbl.override_angle = true
	tbl.angle = angle
end)

fakeTimer = fakeTimer or nil
local hg_cshs_fake = ConVarExists("hg_cshs_fake") and GetConVar("hg_cshs_fake") or CreateConVar("hg_cshs_fake", 0, FCVAR_ARCHIVE, "fake from cshs", 0, 1)
local hg_firstperson_death = ConVarExists("hg_firstperson_death") and GetConVar("hg_firstperson_death") or CreateConVar("hg_firstperson_death", 0, FCVAR_ARCHIVE, "first person death", 0, 1)
local hg_fov = ConVarExists("hg_fov") and GetConVar("hg_fov") or CreateClientConVar("hg_fov", "70", true, false, "changes fov to value", 75, 100)

local hg_ragdollcombat = ConVarExists("hg_ragdollcombat") and GetConVar("hg_ragdollcombat") or CreateConVar("hg_ragdollcombat", 0, FCVAR_REPLICATED, "ragdoll combat", 0, 1)

local k = 0
local wepPosLerp = Vector(0,0,0)
local CalcView
local angleZero = Angle(0,0,0)

local deathlerp = 0
local tblfollow = {}
local lerpasad = 0
CalcView = function(ply, origin, angles, fov, znear, zfar)
	fov = hg_fov:GetInt()
		
	if not lply:Alive() then
		fakeTimer = fakeTimer or CurTime() + 6
	end
	
	if not lply:Alive() and follow and ((fakeTimer < CurTime()) or lply:KeyPressed(IN_RELOAD)) then
		--fakeTimer = nil
		if not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vector_origin,0.001) then
			follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"), vecFull )
		end

		follow = nil

		--lply:BoneScaleChange()

		return
	end

	if not lply:Alive() and not follow then
		return hook.Run("HG_CalcView", ply, origin, angles, fov, znear, zfar)
	end

	if LocalPlayer().lean and math.abs(LocalPlayer().lean) < 0.01 then
		oldlean = 0
		lean_lerp = 0
	end

	angles.roll = (turned and 180 or 0) + lean_lerp * 10

	if ply:InVehicle() then
		local ex = ply:GetAimVector():AngleEx(ply:GetVehicle():GetUp())
		ex[3] = 0
		angles = ex

		if ply:GetVehicle():GetParent().MovePlayerView then
			ply.lockcamera = false
			ply:GetVehicle():GetParent().MovePlayerView = function() end
		end
	end

	--[[if follow and hg.IsChanged(follow,1,tblfollow) then
		if IsValid(tblfollow[1]) then
			print(tblfollow[1])
			tblfollow[1]:ManipulateBoneScale(tblfollow[1]:LookupBone("ValveBiped.Bip01_Head1"),vecFull)
		elseif IsValid(follow) then
			follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"),firstPerson and vecPochtiZero or vecFull)
		end
		tblfollow[1] = follow
		--ply:BoneScaleChange()
	end--]]
	if not lply:Alive() and hg.DeathCam and hg.DeathCamAvailable(ply) then return hg.DeathCam(ply,origin,angles,fov,znear,zfar) end
	--local follow = IsValid(follow) and follow or lply:GetNWEntity("RagdollDeath")

	if not IsValid(ply) then return end
	if not IsValid(follow) then return end
	if not follow:LookupBone("ValveBiped.Bip01_Head1") then return end
	
	view.fov = GetConVar("hg_fov"):GetInt()
	firstPerson = GetViewEntity() == lply
	if ply:Alive() then
		if not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vecZero,0.001) then
			follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"), firstPerson and vecPochtiZero or vecFull )
		end
	end
	
	if not firstPerson then return end

	att = follow:GetAttachment(follow:LookupAttachment("eyes"))
	if not att or not istable(att) then return end
	ang = angles
	ang:Normalize()
	
	att_Ang = att.Ang
	att_Ang:Normalize()
	
	local _,ot = WorldToLocal(vector_origin,ang,vector_origin,att_Ang)
	ot:Normalize()

	ot[2] = math.Clamp(ot[2], -45, 45)
	ot[1] = math.Clamp(ot[1], -45, 45)
	
	local _,angEye = LocalToWorld(vector_origin,ot,vector_origin,att_Ang)
	angEye:Normalize()
	--att_Ang[1] = angEye[1]
	angEye[3] = ang[3]--ang[3]

	if ply:InVehicle() then
		angEye = angles
	end

	local cshs_fake = hg_cshs_fake:GetBool() or (ply.organism and ply.organism.otrub)

	local pos = hg.eye(ply, 10, follow)
	
	if cshs_fake then
		--print(ply.bGetUp)
		deathlerp = LerpFT(0.1,deathlerp,not ply.bGetUp and 1 or 0)
		local angdeath = LerpAngle(deathlerp,angEye,att_Ang)
		view.angles = angdeath--angEye
	else
		deathlerp = LerpFT(0.1,deathlerp,not ply.bGetUp and 0.3 or 0)
		local angdeath = LerpAngle(deathlerp,angEye,att_Ang)
		view.angles = angdeath--angEye
	end
	
	if ply:Alive() then
		deathLocalAng:Set(view.angles)
	end

	hg.cam_things(ply,view,angleZero)
	
	if hg_ragdollcombat:GetBool() or (fakeTimer and fakeTimer > CurTime()) then
		if hg_firstperson_death:GetBool() then
			deathlerp = LerpFT(0.05,deathlerp,1)
			local angdeath = LerpAngle(deathlerp,deathLocalAng,att_Ang)

			if not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vecZero,0.001) then
				follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"), firstPerson and vecPochtiZero or vecFull )
			end

			view.origin = pos
			view.angles = att_Ang
		else
			if not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vecZero,0.001) then
				follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"),lerpasad > 0.9 and vecFull or vecPochtiZero)
			end

			lerpasad = Lerp(0.1, lerpasad, (IsAimingNoScope(ply) and 0 or 1))

			local ang = ply:EyeAngles()
			local tr = {}
			tr.start = pos
			tr.endpos = pos - ang:Forward() * 60 * lerpasad + ang:Right() * 15 * lerpasad
			tr.filter = {ply,follow}
			tr.mask = MASK_SOLID

			view.origin = util.TraceLine(tr).HitPos + ((tr.endpos - tr.start):GetNormalized() * -5)
			view.angles = ang
		end
	else
		view.origin = pos
	end

	view.angles:Add(ply:GetViewPunchAngles())
	view.origin, view.angles = HGAddView(lply, view.origin, view.angles, 0)
	view.angles:Add(-GetViewPunchAngles2())
	view.znear = 2
	
	view = hook.Run("Camera", ply, view.origin, view.angles, view, vector_origin) or view

	local wep = ply:GetActiveWeapon()
	k = Lerp(0.1,k,ply:KeyDown(IN_JUMP) and 1 or 0)
	--[[if wep.GetMuzzleAtt then
		wep:WorldModel_Transform()
		wep:DrawAttachments()
	end--]]
	
	return view
end

hg.CalcViewFake = CalcView

local MAX_EDICT_BITS = 13

function net.ReadEntity2()

	local i = net.ReadUInt( MAX_EDICT_BITS )
	if ( !i ) then return end

	return Entity( i ), i

end

--hook.Add("EntityNetworkedVarChanged","huhuhuasd",function()
	
--end)

local hook_Run = hook.Run
local indexes = {}
net.Receive("Player Ragdoll", function()
	--local ply, ragdoll_index = net.ReadEntity(), net.ReadInt(32) --,net_ReadTable()
	local ply, ragdoll, ragdoll_index = net.ReadEntity(), net.ReadEntity2() --,net_ReadTable()
	if not ragdoll_index then return end
	local ragdoll = IsValid(ragdoll) and ragdoll
	--print(ragdoll)
	if IsValid(ragdoll) or ragdoll_index == 0 or ragdoll_index == -1 then
		--hook.Run("RagdollEntityCreated",ply, ragdoll, ragdoll_index)
	else
		ply.ragdoll_index = ragdoll_index
	end
end)

hook.Add("NetworkEntityCreated", "HG_GiveRenderOverride", function(ragdoll)
    /*if ragdoll:GetClass() == "prop_ragdoll" then
		ragdoll.RenderOverride = function(self, flags)
			if not IsValid(self) or self:IsDormant() then return end
			if not self:GetBonePosition(1) or self:GetBonePosition(1):IsEqualTol(self:GetPos(), 0.01) then return end
			local ply = (IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply.FakeRagdoll == self) and ply or self
			
			hg.renderOverride(ply, self, flags)
		end
	end*/
end)

local getuptimer = 0.5

hook.Add("RagdollEntityCreated", "RagdollFinder", function(ply, ent, key)
	if not IsValid(ply) then return end
	--print(ply)
	local oldrag = ply.FakeRagdoll
	ply.bGetUp = false
	
	ply.FakeRagdoll = (key == "FakeRagdoll" and ent or ply.FakeRagdoll)-- or (key == "RagdollDeath" and IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ent)
	
	if key == "RagdollDeath" and ply == LocalPlayer() then
		ply.FakeRagdoll = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ent
	end

	--if key == "RagdollDeath" then ply.FakeRagdoll = nil return end

	--ply:SetNWEntity("FakeRagdoll", ent)
	--if not IsValid(oldrag) then oldrag = ent end
	hook.Run("ServerRagdollTransferDecals", ply, ent)

	 

	local ragdoll = ply.FakeRagdoll
	
	ragdoll = IsValid(ragdoll) and ragdoll
	
	if ply == lply then
		follow = ragdoll

		if follow and hg.IsChanged(follow,1,tblfollow) then
			if IsValid(tblfollow[1]) then
				tblfollow[1]:ManipulateBoneScale(tblfollow[1]:LookupBone("ValveBiped.Bip01_Head1"),vecFull)
			elseif IsValid(follow) and not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vecZero,0.001) then
				follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"),vecPochtiZero)
			end

			tblfollow[1] = follow
		end
	end
	
	if ragdoll then
		--ragdoll:SetPredictable(true)--causes ragdoll to shake bruh lol
		ragdoll.ply = ply
		ragdoll.organism = ply.organism

		hg.ragdolls[#hg.ragdolls + 1] = ragdoll
		
		ragdoll:CallOnRemove("RagdollRemove",function()
			hook.Run("RagdollRemove",ply,ragdoll)
		end)

		ply.FakeRagdollOld = nil

		ply.FakeRagdoll = ragdoll
		hook_Run("Fake", ply, ragdoll)
		
		ragdoll.RenderOverride = function(self, flags)
			if not IsValid(self) or self:IsDormant() then return end
			if not self:GetBonePosition(1) or self:GetBonePosition(1):IsEqualTol(self:GetPos(), 0.01) then return end
			local ply = (IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply.FakeRagdoll == self) and ply or self
			
			hg.renderOverride(ply, self, flags)
		end
	else
		if IsValid(ply.FakeRagdoll) then
			ply.fakecd = CurTime() + 2
		end

		if IsValid(ply) then ply:SetNoDraw(false) end
		ply:SetRenderMode(RENDERMODE_NORMAL)
		
		oldrag.ply = nil
		ply.FakeRagdollOld = oldrag

		ply.FakeRagdoll = nil

		hook_Run("FakeUp", ply, ragdoll)
	end
	
	--if IsValid(ply) and ply.BoneScaleChange then ply:BoneScaleChange() end

	ply.ragdollindex = nil
end)

concommand.Add("fake", function(ply)
	if not ply:Alive() then return end
	net.Start("fake")
	net.SendToServer()
end)

local vec123 = Vector(0,0,0)
local entityMeta = FindMetaTable("Entity")

function entityMeta:GetPlayerColor()
	return self:GetNWVector("PlayerColor",vec123)
end

function entityMeta:GetPlayerName()
	return self:GetNWString("PlayerName","")
end

local playerMeta = FindMetaTable("Player")

function playerMeta:GetPlayerViewEntity()
	return (IsValid(self:GetNWEntity("spect")) and self:GetNWEntity("spect")) or (IsValid(self.FakeRagdoll) and self.FakeRagdoll) or self
end

function playerMeta:GetPlayerName()
	return self:GetNWString("PlayerName","")
end

function playerMeta:IsFirstPerson()
	if IsValid(self:GetNWEntity("spect",NULL)) then
		return self:GetNWInt("viewmode",viewmode or 1) == 1
	else
		return (GetViewEntity() == self)
	end
end

local ents_FindByClass = ents.FindByClass
local player_GetAll = player.GetAll
function playerMeta:BoneScaleChange()
	local firstPerson = LocalPlayer():IsFirstPerson()
	local viewEnt = LocalPlayer():GetPlayerViewEntity()
	
	for i,ent in ipairs(ents_FindByClass("prop_ragdoll")) do
		if not ent:LookupBone("ValveBiped.Bip01_Head1") then continue end
		if ent:GetManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1")) == vector_origin then continue end
		--if not hg.RagdollOwner(ent) then continue end
		if ent == viewEnt then
			ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"),firstPerson and vecPochtiZero or vecFull)
		else
			ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"),vecFull)
		end
	end

	for i,ent in ipairs(player_GetAll()) do
		if not ent:LookupBone("ValveBiped.Bip01_Head1") then continue end
		if ent:GetManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1")) == vector_origin then continue end
		if ent == viewEnt then
			ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"),firstPerson and vecPochtiZero or vecFull)
		else
			ent:ManipulateBoneScale(ent:LookupBone("ValveBiped.Bip01_Head1"),vecFull)
		end
	end
end

hook.Add("PostCleanupMap","wtfdude",function()
	LocalPlayer():BoneScaleChange()
end)

local function funcrag(ply, name, oldval, ragdoll)
	--ragdoll = IsValid(ragdoll) and ragdoll or IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll") or ply:GetNWEntity("RagdollDeath")
	--if ply.onetime then return end
	--ply.onetime = true
	pcall(hook.Run, "RagdollEntityCreated", ply, ragdoll, name)
	--ply.onetime = false
end

hook.Add("PlayerInitialSpawn","asdfgacke",function(ply)
	ply:SetNWVarProxy("RagdollDeath",funcrag)
	ply:SetNWVarProxy("FakeRagdoll", funcrag)
end)

hook.Add("InitPostEntity","fuckyou",function()
	for i,ply in ipairs(player.GetAll()) do
		ply:SetNWVarProxy("RagdollDeath",funcrag)
		ply:SetNWVarProxy("FakeRagdoll", funcrag)
	end
end)

hook.Add("Player Getup", "Fake", function(ply)
	if ply == lply then
		ply.bGetUp = true
		fakeTimer = nil
	end

	ply:SetNWVarProxy("RagdollDeath", funcrag)
	ply:SetNWVarProxy("FakeRagdoll", funcrag)
end)

function hg.RagdollOwner(ragdoll)
	if not IsValid(ragdoll) then return end
	local ply = ragdoll:GetNWEntity("ply")
	return IsValid(ply) and ply:GetNWEntity("FakeRagdoll") == ragdoll and ply
end

hook.Add("Player Death", "Fake", function(ply)		
	if ply != lply then return end
	
	fakeTimer = CurTime() + 5

	hg.override[ply] = nil

	timer.Simple(0.5 * math.max(ply:Ping() / 30,1),function()
		//ply:BoneScaleChange()
	end)
end)

local left = Material("vgui/gradient-l")
local white2 = Color(150, 150, 150)
local w, h
local math_Clamp = math.Clamp
local math_max, math_min = math.max, math.min
local k1, k2, k3, k4
local hg_show_hitposragdolleyes = ConVarExists("hg_show_hitposragdolleyes") and GetConVar("hg_show_hitposragdolleyes") or CreateClientConVar("hg_show_hitposragdolleyes", "0", false, false, "enables crosshair in ragdoll, only for admins")
local sv_cheats = GetConVar("sv_cheats")
local tr = {
	filter = {lply}
}

local util_TraceLine = util.TraceLine
local vecUp = Vector(1, 0, 0)
hook.Add("RenderScreenspaceEffects", "gg", function()
	if IsValid(follow) and hg_show_hitposragdolleyes:GetBool() and (sv_cheats:GetBool() or lply:IsAdmin() or lply:IsSuperAdmin()) then
		local att = follow:GetAttachment(follow:LookupAttachment("eyes"))
		tr.start = att.Pos
		local dir = vecZero
		dir:Set(vecUp)
		dir:Rotate(lply:EyeAngles())
		tr.endpos = att.Pos + dir * 8000
		tr.filter[2] = follow
		local pos = util_TraceLine(tr).HitPos:ToScreen()
		draw.RoundedBox(0, pos.x - 2, pos.y - 2, 4, 4, white2)
	end

	if not firstPerson or not IsValid(follow) then return end
	if true then return end
	ot = angEye - lply:EyeAngles()
	ot:Normalize()
	k1 = math_Clamp(ot[2] / -30, 0, 1)
	k2 = math_Clamp(ot[2] / 30, 0, 1)
	k1 = math_min(math_max(k1 - 0.2, 0) / 0.8 * 2, 1)
	k2 = math_min(math_max(k2 - 0.2, 0) / 0.8 * 2, 1)
	k3 = math_Clamp(ot[1] / 30, 0, 1)
	k4 = math_Clamp(ot[1] / -30, 0, 1)
	k3 = math_min(math_max(k3 - 0.2, 0) / 0.8 * 2, 1)
	k4 = math_min(math_max(k4 - 0.2, 0) / 0.8 * 2, 1)
	w, h = ScrW(), ScrH()
	--[[white.a = (k1 + k2) * 128
	s = h / 2 * (k1 + k2)

	draw.RoundedBox(s,w / 2 + k1 * -w / 2 + k2 * w / 2 - s / 2,h / 2 - s / 2,s,s,white)]]
	--
	surface.SetMaterial(left)
	surface.SetDrawColor(0, 0, 0, 255 * k1)
	surface.DrawTexturedRect(0, 0, w * 0.5, h)
	surface.SetDrawColor(0, 0, 0, 255 * k2)
	surface.DrawTexturedRectRotated(w - w * 0.5 / 2 + 1, h * 0.5, w * 0.5, h, 180)
	surface.SetDrawColor(0, 0, 0, 255 * k3)
	surface.DrawTexturedRectRotated(w * 0.5, h * 0.25 - 1, w * 0.5, h * 2, -90)
	surface.SetDrawColor(0, 0, 0, 255 * k4)
	surface.DrawTexturedRectRotated(w * 0.5, h * 0.75 + 1, w * 0.5, h * 2, 90)
end)

function hg.GetCurrentCharacter(ply)
	if not IsValid(ply) then return end
	--local rag = ply:GetNWEntity("FakeRagdoll", NULL)
	--ply.FakeRagdoll = rag
	--rag = IsValid(rag) and rag

	return (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
end

hook.Add("Player Spawn", "fuckingremoveragdoll", function(ply)
	local ragdoll = ply:GetNWEntity("FakeRagdoll")
	
	if IsValid(ragdoll) then
		ragdoll:SetNWEntity("ply", NULL)
	end
	--FUCKING SHIT
	if IsValid(ply.FakeRagdoll) then
		ply.FakeRagdoll.ply = nil
		ply.FakeRagdoll = nil
	end
	
	if ply == lply then
		fakeTimer = nil
		follow = nil
	end

	ply:SetNWEntity("FakeRagdoll", NULL)
	ply:SetNWEntity("RagdollDeath", NULL)

	
end)

local override = {}
hg.override = override
net.Receive("Override Spawn", function() override[net.ReadEntity()] = true end)
hook.Add("Player Spawn", "!Override", function(ply)
	if override[ply] then
		override[ply] = nil
		return false
	end
end)

hook.Add("Player Spawn", "zOverride", function(ply)
	if override[ply] then
		override[ply] = nil
		return false
	end
end)

hook.Add("PlayerFootstep", "CustomFootstep", function(ply) if IsValid(ply.FakeRagdoll) then return true end end)

hook.Add("ServerRagdollTransferDecals","raghuy", function(ent,rag)
    if IsValid(ent) && IsValid(rag) && !rag.DecalTransferDone then
        rag:SnatchModelInstance( ent )
        rag.DecalTransferDone = true
    end
end)


hook.Add("OnEntityCreated", "TryCopyAppearanceNow", function( ent )
	--if not ent:IsRagdoll() then return end
	--for k,ply in ipairs(ents.FindInSphere(ent:GetPos(),15)) do
	--	if ply:IsPlayer() then
	--		ent:SetPlayerColor(ply:GetPlayerColor())
	--		local copy = duplicator.CopyEntTable(ply)
	--		duplicator.DoGeneric(ent,copy)
--
	--		ent:SetNWString("PlayerName",ply:Name())
	--		--ent:SetNWVector("PlayerColor",ply:GetPlayerColor())
	--		ent:SetNetVar("Armor", ply:GetNetVar("Armor",{}))
	--		ent:SetNetVar("Accessories", ply:GetNetVar("Accessories","none"))
	--	end
	--end
end)
local sphereRadius = 12
hook.Add("Move","PushAwayRagdolls",function(ply)
	do return end
	if not ply:Alive() and not hg.GetCurrentCharacter(ply):IsPlayer() then return end
	local playerPos = ply:GetPos()
    local sphereCenter = playerPos
    local entities = ents.FindInSphere(sphereCenter, sphereRadius)
    for _, ent in ipairs(entities) do
		if not ent:IsRagdoll() then continue end
		ent.pushCooldown = ent.pushCooldown or 0
		if ent.pushCooldown < CurTime() then
			if ply:GetVelocity():Length() > 200 then
				ViewPunch(Angle(15,math.random(-1,1),0))
			end
		end
		ent.pushCooldown = CurTime() + 0.1
    end
end)