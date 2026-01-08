local CLASS = player.RegClass("sc_infiltrator")

function CLASS.Off(self)
	if CLIENT then return end

	self:SetNWString("PlayerRole", nil)
	self:DrawShadow(true)
end

local subnames = {
	"Big ",
	"Liquid ",
	"Solid ",
	"Venom ",
	"Agent "
}

local bb1 = {
	"Big ",
	"Great ",
	"Huge ",
	"Grand ",
	"Large ",
	"Colossal "
}

local bb2 = {
	"Boss",
	"Leader",
	"Captain",
	"Chief",
	"General",
	"Director"
}

local mdls = {
	["models/kuma96/gta5_splintercell/gta5_splintercell_pm.mdl"] = true,
	["models/epangelmatikes/e3_elite_suit.mdl"] = true,
	["models/blacklist/spy1.mdl"] = true,
}

CLASS.NoGloves = true
function CLASS.On(self)
	self:SetPlayerColor(vector_origin)
	self:SetSubMaterial()

	if SERVER then
		if self:GetNWString("PlayerRole") == "sc_elite" then
			self:SetModel("models/epangelmatikes/e3_elite_suit.mdl")
			self:SetBodygroup(1, 0)
		else
			self:SetModel("models/kuma96/gta5_splintercell/gta5_splintercell_pm.mdl")
			--self:SetBodygroup(1, math.random(0, 1))
		end

		ApplyAppearance(self,nil,nil,nil,true)
		local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
		Appearance.AAttachments = ""
		Appearance.AColthes = ""
		self:SetNetVar("Accessories", "")
		self.CurAppearance = Appearance

		local name = math.random(1, 2) == 1 and (subnames[math.random(#subnames)] .. Appearance.AName) or bb1[math.random(#bb1)] .. bb2[math.random(#bb2)]
		self:SetNWString("PlayerName", name)
	end

	self:DrawShadow(false)
end

function CLASS.Guilt(self, Victim)
	if CLIENT then return end

	if Victim:GetPlayerClass() == self:GetPlayerClass() then
		return 2
	end

	return 0
end

------------------------ anims shit ------------------------
local function isMoving(ply)
	return ply:GetVelocity():LengthSqr() > 900 and ply:OnGround()
end

local function isSprinting(ply)
	return ply:IsSprinting() and ply:GetVelocity():LengthSqr() > 30000 and ply:OnGround()
end

local Vector, Angle = Vector, Angle
local angs = {
	Angle(15, -10, 10),
	Angle(-5, 13, -20),
	Angle(0, -80, -30),
	Angle(0, -80, 40),

	Angle(5, -15, 0),
	Angle(-3, -20, 0),
	Angle(0, 30, 0),
	Angle(0, 20, 0),
	Angle(0, -15, 5),
}

local angs2 = {
	Angle(0, -20, 0),
	Angle(-10, -20, -40),
	Angle(10, 20, 5),
	Angle(-10, -20, -40),
}
local vecdown = Vector(0,0,-2)
local vecZero, angZero = Vector(0,0,0), Angle(0,0,0)

local mul = 0.25
local setbone = hg.bone.Set
local pref = "ValveBiped.Bip01_"
hook.Add("Bones", "sc-stealthanim", function(ply)
	if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end
	if IsValid(ply.FakeRagdoll) or not ply:OnGround() then return end
	-- пжоалуйста ПОМОГИТЕ
	local wep = ply:GetActiveWeapon()
	local sprint = isSprinting(ply)
	if wep == NULL or wep:GetHoldType() == "normal" then
		if not ply:IsFlagSet(FL_ANIMDUCKING) then
			local sprintmul1 = sprint and 10 or 20
			local sprintmul2 = sprint and 10 or 30
			setbone(ply, "spine1", vecZero, Angle(0, mul * (30 + (isMoving(ply) and 10 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine2", vecZero, Angle(0, mul * (70 + (isMoving(ply) and sprintmul1 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine", vecZero, Angle(0, mul * (40 + (isMoving(ply) and sprintmul1 or 0)), 0), "stealth", 0.2)
			setbone(ply, "head", vecZero, Angle(0, mul * (120 + ply:EyeAngles()[1] + (isMoving(ply) and sprintmul2 or 0)), ply:EyeAngles()[3]), "stealth", 0.2)
			if not sprint then
				setbone(ply, "r_upperarm", vecZero, isMoving(ply) and angs[1] / 2 or angs[1], "stealth", 0.2)
				setbone(ply, "l_upperarm", vecZero, isMoving(ply) and angs[2] / 2 or angs[2], "stealth", 0.2)
				setbone(ply, "r_forearm", vecZero, isMoving(ply) and angs[3] / 2 or angs[3], "stealth", 0.2)
				setbone(ply, "l_forearm", vecZero, isMoving(ply) and angs[4] / 2 or angs[4], "stealth", 0.2)
				setbone(ply, pref.."Pelvis", vecdown, angZero, "stealth", 0.2)

				setbone(ply, pref.."L_Thigh", vecZero, isMoving(ply) and angs[6] / 2 or angs[6], "stealth", 0.2)
				setbone(ply, pref.."L_Calf", vecZero, isMoving(ply) and angs[8] / 2 or angs[8], "stealth", 0.2)
				setbone(ply, pref.."R_Thigh", vecZero, isMoving(ply) and angs[5] / 2 or angs[5], "stealth", 0.2)
				setbone(ply, pref.."R_Calf", vecZero, isMoving(ply) and angs[7] / 2 or angs[7], "stealth", 0.2)
				setbone(ply, pref.."R_Foot", vecZero, isMoving(ply) and angs[9] / 2 or angs[9], "stealth", 0.2)
			end
		else
			setbone(ply, "spine1", vecZero, Angle(0, mul * (20 + (isMoving(ply) and 10 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine2", vecZero, Angle(0, mul * (20 + (isMoving(ply) and 10 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine", vecZero, Angle(0, mul * (15 + (isMoving(ply) and 20 or 0)), 0), "stealth", 0.2)
			setbone(ply, "head", vecZero, Angle(0, mul * (40 + (isMoving(ply) and 30 or 0)), 0), "stealth", 0.2)
			if isMoving(ply) then
				setbone(ply, "r_upperarm", vecZero, angs2[1], "stealth", 0.2)
				setbone(ply, "r_forearm", vecZero, angs2[2], "stealth", 0.2)
				setbone(ply, "l_upperarm", vecZero, angs2[3], "stealth", 0.2)
				setbone(ply, "l_forearm", vecZero, angs2[4], "stealth", 0.2)
				setbone(ply, pref.."Pelvis", vecdown, angZero, "stealth", 0.2)
			end
		end
	else
		local sprintmul1 = sprint and 10 or 20
		local sprintmul2 = sprint and 10 or 30
		if wep:GetHoldType() ~= "knife" then
			setbone(ply, "spine1", vecZero, Angle(0, mul * (20 + (isMoving(ply) and 10 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine2", vecZero, Angle(0, mul * (20 + (isMoving(ply) and sprintmul1 or 0)), 0), "stealth", 0.2)
			setbone(ply, "spine", vecZero, Angle(0, mul * (50 + (isMoving(ply) and sprintmul1 or 0)), 0), "stealth", 0.2)
		end
		setbone(ply, "r_upperarm", vecdown * (wep:GetHoldType() == "camera" and 4 or 2), angZero, "stealth", 0.2)
		setbone(ply, "l_upperarm", -vecdown * (wep:GetHoldType() == "camera" and 4 or 2), angZero, "stealth", 0.2)
		setbone(ply, "head", vecZero, Angle(0, mul * (85 + (isMoving(ply) and sprintmul2 or 0)), 0), "stealth", 0.2)
		setbone(ply, "ValveBiped.Bip01_Pelvis", vecdown, angZero, "stealth", 0.2)
	end
end)
------------------------ anims shit end ------------------------
local render, hg = render, hg
function zb.PreDrawPlayer(ply, ent, draw)
	if ply.PlayerClassName == "sc_infiltrator" or mdls[ply:GetModel()] then
		local vel = ply:GetVelocity():Length()
		if IsValid(ply.FakeRagdoll) then vel = 0 end

		render.OverrideColorWriteEnable(true, false)

		ent:SetupBones()
		DrawPlayerRagdoll(ent, ply)
		ent:DrawModel()
		hg.HomigradBones(ply, CurTime(), FrameTime())

		render.OverrideColorWriteEnable(false, false)
		render.SetBlend(math.Clamp(1 * (vel / 50), 0.07, 1))
		ent:DrawModel()
		DrawPlayerRagdoll(ent, ply)

		render.SetBlend(1)

		return ply, ent, false
	end

	return ply, ent, true
end

hook.Add("PlayerCanPickupWeapon","sc-cantpickupweapons",function(ply,ent)
	if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end

	if ent.Base == "homigrad_base" and ent:GetClass() ~= "weapon_tranquilizer" and ply:GetNWString("PlayerRole") ~= "sc_elite" then
		return false
	end
end)

hook.Add("EntityEmitSound", "sc-stealthragdoll", function(data)
	local ent = data.Entity
	if IsValid(ent) and ent:GetClass() == "prop_ragdoll" and mdls[ent:GetModel()] then
		return false
	end
end)

hook.Add("HG_PlayerFootstep", "sc-stealthfootsteps", function(ply, pos, foot, snd, vol)
	if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end

	if not ply:IsSprinting() then
		return true
	end
end)

if SERVER then
	util.AddNetworkString("SC-BeingVictimOfDisarmament")
	util.AddNetworkString("SC-DisarmingOther")
end

function GetPlayerTraceToOther(ply, aim_vector, dist)
	local trace = hg.eyeTrace(ply, dist, nil, aim_vector)
	if trace then
		local aim_ent = trace.Entity
		local other_ply = nil
		if IsValid(aim_ent) then
			if aim_ent:IsPlayer() then
				other_ply = aim_ent
			elseif aim_ent:IsRagdoll() then
				if IsValid(aim_ent.ply) then other_ply = aim_ent.ply end
			end
		end
		return aim_ent, other_ply, trace
	else
		return nil
	end
end

function GetPlayerTraceToOtherVictim(ply, victim, dist)
	if IsValid(victim) then
		local ragdoll = victim.FakeRagdoll or victim:GetNWEntity("RagdollDeath", victim.FakeRagdoll)
		if IsValid(ragdoll) then
			--
		else
			ragdoll = victim
		end

		local bone_id = ragdoll:LookupBone("ValveBiped.Bip01_Spine2")
		if bone_id then
			local bone_matrix = ragdoll:GetBoneMatrix(bone_id)
			if bone_matrix then
				local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
				local ply_offset_normal = pos - ply:GetShootPos()
				local ply_aim_normal = ply:GetAimVector()
				ply_offset_normal:Normalize()
				ply_aim_normal:Normalize()
				local ang_diff = -(math.deg(math.acos(ply_aim_normal:DotProduct(-ply_offset_normal))) - 180)
				if ang_diff < 80 then
					local aim_ent, other_ply, trace = GetPlayerTraceToOther(ply, ply_offset_normal, dist)
					if IsValid(aim_ent) then
						return aim_ent, other_ply, trace
					else
						return GetPlayerTraceToOther(ply, dist)
					end
				else
					return GetPlayerTraceToOther(ply, dist)
				end
			end
		end
	end
end

function CanPlayerDisarmOther(ply, aim_ent)
	if aim_ent:IsRagdoll() then
		local bone_id = aim_ent:LookupBone("ValveBiped.Bip01_Spine2")
		if bone_id then
			local bone_matrix = aim_ent:GetBoneMatrix(bone_id)
			if bone_matrix then
				local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
				local other_normal = ang:Right()
				local ply_normal = pos - ply:GetShootPos()
				local dist_z = math.abs(pos.z - ply:GetShootPos().z)
				if dist_z < 50 then
					ply_normal:Normalize()
					local ang_diff = -(math.deg(math.acos(ply_normal:DotProduct(other_normal))) - 180)
					if ang_diff < 90 then
						return 2
					else
						return 1.5
					end
				end
			end
		end
	elseif aim_ent:IsPlayer() then
		local other_angle = aim_ent:EyeAngles()[2]
		local ply_angle = (aim_ent:GetPos() - ply:GetPos()):Angle()[2] --ply:EyeAngles()[2]
		local ang_diff = math.abs(math.AngleDifference(other_angle, ply_angle))
		if ang_diff < 70 then
			return 2
		else
			return 1.5
		end
	end
	return false
end

function DisarmOther(ply, other_ply, aim_ent)
	if other_ply:Alive() then
		local weapon = other_ply:GetActiveWeapon()
		if IsValid(weapon) and not weapon.NoDrop then
			other_ply:DropWeapon(weapon)
			ply:PickupWeapon(weapon, false)
		end

		hg.LightStunPlayer(other_ply)
		timer.Simple(0, function()
			local rag = hg.GetCurrentCharacter(other_ply)
			if IsValid(rag) and rag ~= other_ply then
				local bon = rag:LookupBone("ValveBiped.Bip01_Head1")
				local physnum = rag:TranslateBoneToPhysBone(bon)
				local phys = rag:GetPhysicsObjectNum(physnum)
				local dist = 25 --phys:GetPos():Distance(ply:EyePos())
				hg.SetCarryEnt2(ply, rag, bon, phys:GetMass(), Vector(-2, 0, 0), ply:GetAimVector() * dist + ply:EyeAngles():Up() * 5 + ply:EyeAngles():Right() * -5 + ply:GetShootPos(), ply:EyeAngles() + Angle(-90, 90, 0))
			end
		end)
	end
end

function StartDisarmingOther(ply, other_ply)
	ply.Ability_Disarm = {
		Victim = other_ply,
		Progress = 0,
	}

	other_ply.BeingVictimOfDisarmament = true
	if SERVER then
		-- other_ply:ViewPunch(Angle(0, -10, -10))
		net.Start("SC-BeingVictimOfDisarmament")
		net.WriteBool(true)
		net.Send(other_ply)
		net.Start("SC-DisarmingOther")
		net.WriteBool(true)
		net.WriteEntity(other_ply)
		net.Send(ply)
	end
end

function StopDisarmingOther(ply)
	if ply.Ability_Disarm and IsValid(ply.Ability_Disarm.Victim) then ply.Ability_Disarm.Victim.BeingVictimOfDisarmament = false end
	if SERVER and ply.Ability_Disarm and IsValid(ply.Ability_Disarm.Victim) then
		net.Start("SC-BeingVictimOfDisarmament")
		net.WriteBool(false)
		net.Send(ply.Ability_Disarm.Victim)
		net.Start("SC-DisarmingOther")
		net.WriteBool(false)
		net.Send(ply)
	end

	ply.Ability_Disarm = nil
end

function ContinueDisarmingOther(ply)
	local ability_data = ply.Ability_Disarm
	local victim = ability_data.Victim
	local aim_ent, other_ply, trace = GetPlayerTraceToOtherVictim(ply, victim, DisarmReach)
	if IsValid(aim_ent) and (aim_ent:IsPlayer() or aim_ent:IsRagdoll()) then
		local disarm_strength = CanPlayerDisarmOther(ply, aim_ent)
		if IsValid(victim) and victim:Alive() and disarm_strength and other_ply == victim then
			ability_data.Progress = ability_data.Progress + FrameTime() * 250 * disarm_strength
			if ability_data.Progress >= 100 then
				if SERVER then DisarmOther(ply, victim, aim_ent) end
				StopDisarmingOther(ply)
			end
		else
			StopDisarmingOther(ply)
		end
	else
		StopDisarmingOther(ply)
	end
end

hook.Add("PlayerPostThink", "sc-disarm", function(ply)
	if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end
	if ply:KeyDown(IN_WALK) then
		if ply:KeyPressed(IN_USE) then
			local aim_ent, other_ply, trace = GetPlayerTraceToOther(ply, nil, DisarmReach)
			if IsValid(aim_ent) then if other_ply and CanPlayerDisarmOther(ply, aim_ent, DisarmReach) then StartDisarmingOther(ply, other_ply) end end
		elseif ply:KeyDown(IN_USE) then
			if ply.Ability_Disarm then ContinueDisarmingOther(ply) end
		end

		if ply:KeyReleased(IN_USE) then StopDisarmingOther(ply) end
	else
		StopDisarmingOther(ply)
	end
end)

if CLIENT then
	net.Receive("SC-BeingVictimOfDisarmament", function(len, ply)
		LocalPlayer().BeingVictimOfDisarmament = net.ReadBool()
		if LocalPlayer().BeingVictimOfDisarmament then
			BeingVictimOfDisarmamentResetTime = CurTime() + 5
		else
			BeingVictimOfDisarmamentResetTime = nil
		end
	end)

	net.Receive("SC-DisarmingOther", function(len, ply)
		local status = net.ReadBool()
		if status then
			local other_ply = net.ReadEntity()
			StartDisarmingOther(LocalPlayer(), other_ply)
		else
			StopDisarmingOther(LocalPlayer())
		end
	end)

	------------------------ camera shit ------------------------
	local lerpaim = 0
	local lerpasad = 0
	local lerpfovadd = 0
	local view = render.GetViewSetup()
	local vecZero, vecFull = Vector(0, 0, 0), Vector(1, 1, 1)
	local whitelist = {
		weapon_physgun = true,
		gmod_tool = true,
		gmod_camera = true,
		weapon_crowbar = true,
		weapon_pistol = true,
		weapon_crossbow = true,
		gmod_smoothcamera = true,
		none = true
	}

	--hook.Add("HG_RealCalcView", "sc-camera", function(ply, origin, angles, fov)
	function zb.OverrideCalcView(ply, origin, angles, fov)
		if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return nil end

		if IsValid(ply) and ply:Alive() then
			lerpfovadd = Lerp(0.01,lerpfovadd,(ply:IsSprinting() and ply:GetVelocity():LengthSqr() > 1500 and 10 or 0) - ( ply.organism and (ply.organism and (((ply.organism.immobilization or 0) / 4) - (ply.organism.adrenaline or 0) * 5)) or 0) / 2 - (ply.suiciding and (ply:GetNetVar("suicide_time",CurTime()) < CurTime()) and (1 - math.max(ply:GetNetVar("suicide_time",CurTime()) + 8 - CurTime(),0) / 8) * 20 or 0))
			lerpaim = LerpFT(0.1, lerpaim, not IsAimingNoScope(ply) and 1 or 0)
			local leanmul1 = ((ply.lean < 0 and ply.lean * 2.2 or 0) + 1)
			origin = origin + ((angles:Forward() * -30 + angles:Right() * 15 * leanmul1) * lerpaim)
			view = hook.Run("Camera", ply, view.origin, view.angles, view, vector_origin) or view
			local wep = ply:GetActiveWeapon()
			lerpasad = Lerp(0.1, lerpasad, ((IsAimingNoScope(ply) or IsValid(wep) and wep:GetClass() == "weapon_hidebox" and wep.Hidden) and 0.001 or 1))

			local pos = hg.eye(ply, 10, follow)
			local ang = ply:EyeAngles()
			local tr = {}
			tr.start = pos
			tr.endpos = pos - ang:Forward() * 60 * lerpasad + ang:Right() * 15 * lerpasad
			tr.filter = {ply}
			tr.mask = MASK_SOLID

			view.origin = util.TraceLine(tr).HitPos + ((tr.endpos - tr.start):GetNormalized() * -5)
			view.angles = angles
			view.drawviewer = true
			view.fov = 95 + lerpfovadd

			ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), vecFull)
			return view
		end

		result = hook_Run("Camera", ply, eyePos, angles, view, velLen * 200)
		view.origin, view.angles = HGAddView(ply, view.origin, view.angles, velLen)

		if result == view then
			traceBuilder.start = origin
			traceBuilder.endpos = view.origin
			local trace = hg.hullCheck(ply:EyePos() - vector_up * 10,view.origin,ply)
			view.origin = trace.HitPos
			view.angles:Add(-GetViewPunchAngles2())
			return view
		end

		view.origin = eyePos
		view.angles = angles
		view.angles:Add(-GetViewPunchAngles2())

		wep = ply:GetActiveWeapon()
		if IsValid(wep) and whitelist[wep:GetClass()] then return end
	end

	follow = follow or nil
	local vecPochtiZero = Vector(0.1, 0.1, 0.1)
	hook.Add("Camera", "sc-fakecamera", function(ply, origin, angles, view, vector_origin)
		if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end

		if IsValid(ply) then
			if not IsValid(follow) then
				return
			end

			if not follow:GetManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1")):IsEqualTol(vecZero,0.001) then
				follow:ManipulateBoneScale(follow:LookupBone("ValveBiped.Bip01_Head1"),lerpasad > 0.9 and vecFull or vecPochtiZero)
			end

			local pos = hg.eye(ply, 10, follow)

			local wep = ply:GetActiveWeapon()
			lerpasad = Lerp(0.1, lerpasad, ((IsAimingNoScope(ply) or IsValid(wep) and wep:GetClass() == "weapon_hidebox" and wep.Hidden) and 0 or 1))

			local ang = ply:EyeAngles()
			local tr = {}
			tr.start = pos
			tr.endpos = pos - ang:Forward() * 60 * lerpasad + ang:Right() * 15 * lerpasad
			tr.filter = {ply,follow}
			tr.mask = MASK_SOLID

			view.origin = util.TraceLine(tr).HitPos + ((tr.endpos - tr.start):GetNormalized() * -5)
			view.angles = ang
		end
	end)
	------------------------ camera shit end ------------------------

	hook.Add("HUDPaint", "sc-stealthhud", function()
		local lply = LocalPlayer()
		if lply.PlayerClassName ~= "sc_infiltrator" or not mdls[lply:GetModel()] then return end

		local StartTime = zb.ROUND_START or CurTime()
		if StartTime + 10 > CurTime() or not lply:Alive() or GetViewEntity() ~= lply or lply:InVehicle() then return end

		local tr = hg.eyeTrace(lply, 2048)
		local toScreen = tr.HitPos:ToScreen()
		surface.SetDrawColor(25, 200, 0 ,155)
		surface.DrawRect(toScreen.x-2.5, toScreen.y-2.5, 5, 5)
	end)
end

------------------------ nvg shit ------------------------
if CLIENT then
	local pnv_enabled = false
	local next_toggle_time = 0
	local toggle_cooldown = 1
	local transition_time = 1
	local transition_start = 0
	local sc_nvg = nil

	local pnv_color_1 = {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0.2,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.01,
		["$pp_colour_contrast"] = 0.6,
		["$pp_colour_colour"] = 0.08,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0.1,
		["$pp_colour_mulb"] = 0.2
	}
	local pnv_color_2 = {
		["$pp_colour_addr"] = 0.2,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0.05,
		["$pp_colour_contrast"] = 0.6,
		["$pp_colour_colour"] = 0.08,
		["$pp_colour_mulr"] = 0.2,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	local function DrawNoise(amt, alpha)
		local W, H = ScrW(), ScrH()

		for i = 0, amt do
			local Bright = math.random(0, 255)
			surface.SetDrawColor(Bright, Bright, Bright, alpha)
			local X, Y = math.random(0, W), math.random(0, H)
			surface.DrawRect(X, Y, 1, 1)
		end
	end

	local mat = Material("mats_jack_gmod_sprites/hard_vignette.png")
	local function togglePNV()
		local ply = LocalPlayer()
		if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] or not ply:Alive() then
			if pnv_enabled then
				pnv_enabled = false
				surface.PlaySound("items/nvg_off.wav")
				hook.Remove("RenderScreenspaceEffects","sc-nvg_cc")
				if IsValid(sc_nvg) then
					sc_nvg:Remove()
					sc_nvg = nil
				end
			end
			return
		end

		pnv_enabled = not pnv_enabled
		transition_start = CurTime()

		if pnv_enabled then
			transitioning = true
			surface.PlaySound("items/nvg_on.wav")
			hook.Add("RenderScreenspaceEffects","sc-nvg_cc",function()
				if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end
				local progress = math.min((CurTime() - transition_start)/transition_time,1)
				local class = ply:GetNWString("PlayerRole")
				local cc = class == "sc_elite" and table.Copy(pnv_color_2) or table.Copy(pnv_color_1)
				for k,v in pairs(cc) do
					cc[k] = v * progress
				end
				DrawColorModify(cc)
				DrawBloom(0.1*progress,1*progress,2*progress,2*progress,1*progress,0.4*progress,1,1,1)
				DrawNoise(500,255)

				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(mat)
				local viewpunching = GetViewPunchAngles()
				surface.DrawTexturedRect(-ScrW()+(ScrW()*1.5)/2 - viewpunching.r * 5, -20 - viewpunching.x*5, ScrW()*1.5, ScrH()+40)
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect(-ScrW()+(ScrW()*1.5)/2,(ScrH()+20) - viewpunching.x*5, ScrW()*1.5, ScrH()+40)
				surface.DrawRect(-ScrW()+(ScrW()*1.5)/2,-(ScrH()+40) - viewpunching.x*5, ScrW()*1.5, ScrH()+40)
				if progress >= 1 then transitioning = false end
			end)
		else
			transitioning = false
			surface.PlaySound("items/nvg_off.wav")
			hook.Remove("RenderScreenspaceEffects","sc-nvg_cc")
		end
	end

	hook.Add("RenderScreenspaceEffects","sc-nvg_cc",function()
		local ply = LocalPlayer()
		if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end
		if pnv_enabled then
			local class = ply:GetNWString("PlayerRole")
			local cc = class == "sc_elite" and pnv_color_2 or pnv_color_1
			DrawColorModify(cc)
			DrawBloom(0.1,0.5,2,2,1,0.4,1,1,1)
		end
	end)

	hook.Add("PreDrawHalos","sc_nvg",function()
		local ply = LocalPlayer()
		if ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()] then return end
		if pnv_enabled then
			if not IsValid(sc_nvg) then
				sc_nvg = ProjectedTexture()
				sc_nvg:SetTexture("effects/flashlight001")
				sc_nvg:SetBrightness(2)
				sc_nvg:SetEnableShadows(false)
				sc_nvg:SetConstantAttenuation(0.02)
				sc_nvg:SetNearZ(12)
				sc_nvg:SetFOV(120)
			end
			sc_nvg:SetPos(ply:EyePos())
			sc_nvg:SetAngles(ply:EyeAngles())
			sc_nvg:Update()
		elseif IsValid(sc_nvg) then
			sc_nvg:Remove()
			sc_nvg = nil
		end
	end)

	hook.Add("Think", "sc-nvg_think",function()
		local ply = LocalPlayer()
		if ply:Alive() and (ply.PlayerClassName == "sc_infiltrator" or mdls[ply:GetModel()]) then
			if input.IsKeyDown(KEY_F) and not gui.IsGameUIVisible() and not IsValid(vgui.GetKeyboardFocus()) and (CurTime() > next_toggle_time) then
				togglePNV()
				next_toggle_time = CurTime() + toggle_cooldown
			end
		end
		if not ply:Alive() and pnv_enabled then togglePNV() end
		if (ply.PlayerClassName ~= "sc_infiltrator" or not mdls[ply:GetModel()]) and pnv_enabled then togglePNV() end

		if pnv_enabled and IsValid(sc_nvg) then
			sc_nvg:SetPos(ply:EyePos())
			sc_nvg:SetAngles(ply:EyeAngles())
			sc_nvg:Update()
		end
	end)
end
------------------------ nvg shit end ------------------------