if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"

-- Global table for ragdoll impact damage cooldowns
if not RagdollImpactCooldowns then
	RagdollImpactCooldowns = {}
end

local function RagdollOwner(ent)
	return hg.RagdollOwner(ent)
end

SWEP.Category = "ZCity Other"
SWEP.Instructions = "LMB / Reload - raise / lower fists\n\nIn the raised state: LMB - strike, RMB - block\n\nIn the lowered state: RMB - raise the object, R - check the pulse\n\nWhen holding the object: Reload - fix the object in air, E - spin the object in the air."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_nmrih/v_me_fists.mdl"
SWEP.UseHands = true
SWEP.AttackSlowDown = .5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 40
SWEP.HomicideSWEP = true
SWEP.NoDrop = true
SWEP.ShockMultiplier = 1
SWEP.PainMultiplier = 1
SWEP.BreakBoneMul = 0.4
SWEP.Penetration = 1
SWEP.DamageMul = 1
SWEP.ParryStaminaCost = 6  -- Stamina cost for blocking with hands (lower than melee weapons)

-- Blocking configuration for hands (hand-to-hand combat blocking)
SWEP.BlockHoldPos = Vector(-5, 5, 3)  -- Closer blocking position for hands
SWEP.BlockHoldAng = Angle(0, 0, 10)   -- Slight angle for hand blocking
SWEP.BlockDamageReduction = 0.3       -- 30% damage reduction (less than weapons)
SWEP.BlockStaminaCost = 12            -- Stamina cost when taking damage while blocking
SWEP.BlockStaminaThreshold = 30       -- Minimum stamina required to block (lower for hands)
SWEP.ParryWindow = 0.3                -- Shorter parry window for hands
SWEP.ParryCooldown = 1.5              -- Shorter cooldown for hand blocking
SWEP.BlockSound = "Flesh.ImpactHard"  -- Flesh impact sound for hand blocking

-- Advanced Directional Hitbox Blocking System Configuration for Hands
SWEP.BlockHitboxWidth = 60            -- Narrower blocking hitbox for hands
SWEP.BlockHitboxHeight = 55           -- Lower height for hand blocking
SWEP.BlockHitboxDepth = 35            -- Shorter reach for hand blocking
SWEP.BlockHitboxOffset = Vector(20, 0, 0)  -- Closer offset for hand blocking
SWEP.BlockArcAngle = 120              -- Smaller blocking arc for hands (60 degrees each side)
SWEP.BlockVerticalRange = 90          -- Increased vertical range for hand blocking (matches base melee weapon)
SWEP.BlockMinDistance = 3             -- Very close minimum distance for hand blocking
SWEP.BlockMaxDistance = 80            -- Increased maximum distance for hand blocking (was 60, now matches typical combat range)
SWEP.BlockPrecisionSamples = 4        -- Same precision samples as other weapons

SWEP.animtime = 0

-- Carrying optimization settings
SWEP.CarryStaminaMultiplier = 0.02 -- Heavily reduce stamina consumption while carrying (2% of normal)
SWEP.RagdollCarryForceMultiplier = 2 -- Make ragdolls much easier to carry

SWEP.lefthandmodel = "models/weapons/gleb/w_firematch.mdl"
SWEP.offsetVec2 = Vector(4,-1.2,1)
SWEP.offsetAng2 = Angle(10,0,90)
SWEP.ModelScale2 = 1.5

SWEP.blockinganim = 0

local function qerp(delta, a, b)
    local qdelta = -(delta ^ 2) + (delta * 2)
    qdelta = math.Clamp(qdelta, 0, 1)

    return Lerp(qdelta, a, b)
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 5)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
	self:SetIsShoving(false)
	self:SetBlockCounter(0)
	self:SetLastBlockTime(0)
end

function SWEP:OnRemove()
    --[[if IsValid(self.worldModel) then
        self.worldModel:Remove()
    end--]]
end

if CLIENT then
	local blocking_ang = Angle(-40,0,0)

	--[[if IsValid(modelHands) then
		modelHands:Remove()
	end--]]

	function SWEP:GetWM()
		return self.worldModel
	end

	-- Settings...

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		
		if not IsValid(self.worldModel) then
			self.worldModel = ClientsideModel(self.WorldModel)
		end

		if not self:GetFists() then return end

		local WorldModel = self.worldModel
		
		WorldModel:SetCycle(1 - math.Clamp(self.animtime - CurTime(),0,1))

		self.blockinganim = qerp(0.05 * FrameTime() / engine.TickInterval(),self.blockinganim,self:GetBlocking() and 1 or 0)

		if (IsValid(owner)) then
			local ang = owner:EyeAngles()
			local tr = hg.eyeTrace(owner)

			local pos = tr.StartPos + ang:Forward() * (-14) + ang:Up() * -9 * self.blockinganim
			if owner.PlayerClassName == "sc_infiltrator" then
				pos = tr.StartPos + ang:Forward() * (-18) + ang:Up() * -5 -- этим кулакам никакой оффсет не поможет
			end
			local ang = owner:EyeAngles()
			
			local _,ang = LocalToWorld(vector_origin,blocking_ang * self.blockinganim,vector_origin,ang)

			local pos, ang = self:ModelAnim(WorldModel, pos, ang)

			WorldModel:SetRenderOrigin(pos)
			WorldModel:SetRenderAngles(ang)
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:SetupBones()
		--WorldModel:DrawModel()
	end
end

local host_timescale = game.GetTimeScale

local addAng = Angle()
local addPos = Vector()
//local velpunch = Vector()

local vechuy = Vector(-12, 0, 0)

function SWEP:ModelAnim(model, pos, ang)
    local owner = self:GetOwner()

    if !IsValid(owner) or !owner:IsPlayer() then return end

    local ent = hg.GetCurrentCharacter(owner)
    local tr = hg.eyeTrace(owner, 60, ent)
    local eyeAng = owner:EyeAngles()

    local vel = ent:GetVelocity()
    local vellen = vel:Length()

    local vellenlerp = self.velocityAdd and self.velocityAdd:Length() or vellen

    if !tr then return end

    self.walkLerped = LerpFT(0.1, self.walkLerped or 0, (owner:InVehicle()) and 0 or vellenlerp * 200)
	self.walkTime = self.walkTime or 0
    
	local walk = math.Clamp(self.walkLerped / 200, 0, 1)
	
	self.walkTime = self.walkTime + walk * FrameTime() * 1 * game.GetTimeScale() * (owner:OnGround() and 1 or 0)

    self.velocityAdd = self.velocityAdd or Vector()
    self.velocityAddVel = self.velocityAddVel or Vector()

    self.velocityAddVel = LerpFT(0.9, self.velocityAddVel * 0.99, -vel * 0.01)
    self.velocityAddVel[3] = self.velocityAddVel[3]

    self.velocityAdd = LerpFT(0.03, self.velocityAdd, self.velocityAddVel)

	local huy = self.walkTime
	
	local x, y = math.cos(huy) * math.sin(huy) * walk + math.cos(CurTime() * 5) * walk * math.sin(CurTime() * 2) * 0.5, math.sin(huy) * walk * 1 + math.sin(CurTime() * 5) * walk * math.cos(CurTime() * 4) * 0.5

	x = x * 0.5
	y = y * 0.5

    if self:IsLocal() then
		addPos:Zero()
		addAng:Zero()

        addPos.z = x * 2 * vellenlerp * 0.3 - vellenlerp * 1
        addPos.y = y * 2 * vellenlerp * 0.3
    
        addAng.z = -x * 2// * vellenlerp * 0.3
        addAng.y = -y * 2// * vellenlerp * 0.3

        addPos.y = addPos.y - angle_difference.y * 2
        addAng.y = addAng.y + angle_difference.y * 4

        addPos.z = addPos.z + angle_difference.p * 2
        addAng.p = addAng.p + angle_difference.p * 4

        addAng.p = addAng.p + math.cos(CurTime() * 2) * 1

        //addPos.z = addPos.z + eyeAng[1] * 0.05
        addPos.x = addPos.x + eyeAng[1] * 0.05

        local veldot = self.velocityAdd:Dot(tr.Normal:Angle():Right())
        
        addAng.r = addAng.r - veldot * 5 + math.cos(CurTime() * 5) * walk * 2

        //addAng.p = addAng.p + math.cos(CurTime() * 2) * 1
		
        self.lastAddPos = addPos
	end


    //local inattack1 = self:GetAttackType() == 1 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false
    //local inattack2 = self:GetAttackType() == 2 and math.max(self:GetLastAttack() - CurTime(),0) / self.AttackTime > 0 or false

    //self.attackanim = LerpFT(0.1, self.attackanim, (inattack1 and 0.8 or 0) - (inattack2 and 0.3 or 0))
    //self.sprintanim = LerpFT(0.05, self.sprintanim, self:IsSprinting() and 1 or 0)

    local hpos = (self.HoldPos or vector_origin) + vechuy
    local hang = (self.HoldAng or angle_zero)

    local pos, ang = LocalToWorld(hpos + addPos, hang + addAng, tr.StartPos + self.velocityAdd, eyeAng)

    return pos, ang
end

SWEP.supportTPIK = true
SWEP.ismelee = true
function SWEP:Camera(eyePos, eyeAng, view, vellen)
	self:SetHandPos()
	self:DrawWorldModel()
    local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	self.walkinglerp = Lerp(hg.lerpFrameTime2(0.1),self.walkinglerp or 0, owner.InVehicle and owner:InVehicle() and 0 or hg.GetCurrentCharacter(owner):GetVelocity():LengthSqr())
	self.huytime = self.huytime or 0
	local walk = math.Clamp(self.walkinglerp / 10000,0,1)
	
	self.huytime = self.huytime + walk * FrameTime() * 4 * host_timescale()
	if owner:IsSprinting() then
		walk = walk * 2
	end

	local huy = self.huytime
	
	local x,y = math.cos(huy) * math.sin(huy) * walk * 1,math.sin(huy) * walk * 1
	eyePos = eyePos - eyeAng:Up() * walk
	eyePos = eyePos - eyeAng:Up() * x * 0.5
	eyePos = eyePos - eyeAng:Right() * y * 0.5

    view.origin = (eyePos - (angle_difference_localvec * 150) - (position_difference * 0.5))
    
	return view
end

SWEP.rhandik = false
SWEP.lhandik = false

if CLIENT then
	if IsValid(handcuffmodel) then
		handcuffmodel:Remove()
	end

	local lpos,lang = Vector(-3.5,0,0),Angle(0,0,-90)

	--hook.Add("PostDrawPlayerRagdoll","Drawhandcuffs", function(ply,ent)
	function hg.CuffedAnim(ent, ply)
		if ply:IsRagdoll() or ent:IsRagdoll() then return end
		if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() or not ply:GetNetVar("handcuffed",false) then return end
		
		local rh,lh = ply:LookupBone("ValveBiped.Bip01_R_Hand"),ply:LookupBone("ValveBiped.Bip01_L_Hand")
		local rhmat,lhmat = ply:GetBoneMatrix(rh),ply:GetBoneMatrix(lh)
				
		if not rhmat then return end
		
		handcuffmodel = IsValid(handcuffmodel) and handcuffmodel or ClientsideModel( "models/weapons/spy/w_handcuffs.mdl" )
		handcuffmodel:SetNoDraw( true )

		local model = handcuffmodel

		model:SetModelScale(1, 0)

		local angle = (rhmat:GetTranslation() - lhmat:GetTranslation()):Angle()
		angle[3] = -rhmat:GetAngles()[1]
		local pos,ang = LocalToWorld(lpos,lang,rhmat:GetTranslation(),angle)

		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		--model:SetRenderOrigin()
		--model:SetRenderAngles()
		return
	end
	--end)
end

local ang1 = Angle(90,-15,180)
local ang2 = Angle(90,15,0)

local ang4 = Angle(0,0,180)
local ang5 = Angle(0,0,0)

local ang3 = Angle(0,0,180)
local clamp = math.Clamp

function hg.handcuffedhands(ply)
	local posi, ang = ply:GetBonePosition(0)
	local dtime = SysTime() - (ply.dtimehandcuffs or SysTime())
	ply.crouchinglerp = Lerp(hg.lerpFrameTime2(0.1,dtime),ply.crouchinglerp or 0, (ply:IsFlagSet(FL_ANIMDUCKING)) and 1 or 0)
	ply.dtimehandcuffs = SysTime()
	ang1[1] = 90 - 50 * ply.crouchinglerp
	ang2[1] = 90 - 50 * ply.crouchinglerp

	local pos = posi + ang:Up() * (6 + 12 * ply.crouchinglerp) + ang:Right() * (2 + -14 * ply.crouchinglerp) + ang:Forward() * 4 * ply.crouchinglerp
	local pointpos = hg.torsoTrace(ply,20)
	--[[if hg.KeyDown(ply,IN_ATTACK2) then
		pos = pointpos.HitPos
		ply.lerphandpos = Lerp(hg.lerpFrameTime2(0.1,dtime), ply.lerphandpos or Vector(0,0,0), pos)
		hg.DragHandsToPos(ply,ply:GetActiveWeapon(),ply.lerphandpos,true,4.5,pointpos.Normal,ang3,angle_zero)
	else
		ply.lerphandpos = Lerp(hg.lerpFrameTime2(0.1,dtime), ply.lerphandpos or Vector(0,0,0), pos)
		hg.DragHandsToPos(ply,ply:GetActiveWeapon(),ply.lerphandpos,true,4.5,ang:Up(),ang1,ang2)
	end--]]
	hg.DragHandsToPos(ply, ply:GetActiveWeapon(), pos, true, 3.5, ang:Up(), ang1, ang2)
end

SWEP.KnuckleModel = "models/mosi/fallout4/props/weapons/melee/knuckles.mdl"
SWEP.offsetVec = Vector(2.2, -0.5, 0)
SWEP.offsetAng = Angle(0, 90, 90)
SWEP.idleVec = Vector(4.5, -2, -0.2)
SWEP.idleAng = Angle(0, 0, -80)

-- TPIK blocking vectors
local vecBlockingR = Vector(-2, 3, 6)
local vecBlockingL = Vector(-2, -3, 8)

-- TPIK shove animation vectors - arms pushed back
local vecShoveR = Vector(-4, 0, -1)  -- Right hand pushed back
local vecShoveL = Vector(-4, 0, -1)  -- Left hand pushed back

-- Custom idle positioning vectors and angles for higher hand positions
local customIdleVecR = Vector(0,0,2)  -- Right hand higher position
local customIdleAngR = Angle(0,0,0)
local customIdleVecL = Vector(0,0,2) -- Left hand higher position  
local customIdleAngL = Angle(0,0,0)

function SWEP:SetHandPos(noset)
	local ply = self:GetOwner()
	
    if not IsValid(ply) or not IsValid(self.worldModel) then return end
	if IsValid(ply) and (not ply.shouldTransmit or ply.NotSeen) then return end
	ply:SetupBones()

	self.rhandik = (self:GetFists()) or (IsValid(ent) and twohands)
	self.lhandik = (self:GetFists() and hg.CanUseLeftHand(ply)) or IsValid(ent)

	local bones2 = hg.TPIKBonesOther
	
    local ply_spine_index = ply:LookupBone("ValveBiped.Bip01_Spine4")
    if !ply_spine_index then return end
    local ply_spine_matrix = ply:GetBoneMatrix(ply_spine_index)
    local wmpos = ply_spine_matrix:GetTranslation()

	local wm = self:GetWM()
	if !IsValid(wm) then return end

	local inv = ply:GetNetVar("Inventory",{})
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if havekastet then
		self.model = IsValid(self.model) and self.model or ClientsideModel(self.KnuckleModel)
		self.model:SetNoDraw(true)
	end

	if ply:GetNetVar("handcuffed",false) then
		hg.handcuffedhands(ply)

		return
	end

	local break_data = ply.Ability_NeckBreak

	if(break_data and IsValid(break_data.Victim))then
		local victim = break_data.Victim
		local head, anga = victim:GetBonePosition(victim:LookupBone("ValveBiped.Bip01_Head1"))
		head = head + anga:Right() * -3 + anga:Forward() * 2 - anga:Up() * break_data.Progress / 40
		local ang = victim:EyeAngles()

		ang[2] = ang[2] - break_data.Progress / 5
		
		hg.DragHandsToPos(ply, ply:GetActiveWeapon(), head, true, 2, ang:Forward(), ang4, ang5)
	end

	local ang = ply:EyeAngles()

	if self:GetFists() then
		local bones = hg.TPIKBonesRH

		local lastaddpos = self:IsLocal() and self.lastAddPos or vector_origin
		local posadd, _ = LocalToWorld(lastaddpos, angle_zero, vector_origin, ply:EyeAngles())
		//local posadd = self:IsLocal() and self.lastAddPos and -(-self.lastAddPos) or -(-vector_origin)

		-- TPIK blocking for right hand
		self.blockingR = LerpFT(0.1, self.blockingR or vector_origin, (self:GetBlocking() and vecBlockingR or vector_origin))
		local blocking = -(-self.blockingR)
		blocking:Rotate(ang)
		
		-- TPIK shove animation for right hand
		self.shovingR = LerpFT(0.08, self.shovingR or vector_origin, (self:GetIsShoving() and vecShoveR or vector_origin))
		local shoving = -(-self.shovingR)
		shoving:Rotate(ang)
		
		-- Custom idle positioning for right hand
		local targetIdleR = self:GetIsSwinging() and vector_origin or customIdleVecR
		self.customIdleR = LerpFT(0.15, self.customIdleR or vector_origin, targetIdleR)
		local customIdle = -(-self.customIdleR)
		customIdle:Rotate(ang)
		
		-- Fist raising effect for right hand
		local targetRaiseR = (self.fistRaising and Vector(0, 0, 3)) or vector_origin
		self.fistRaiseR = LerpFT(0.2, self.fistRaiseR or vector_origin, targetRaiseR)
		local fistRaise = -(-self.fistRaiseR)
		fistRaise:Rotate(ang)

		if self.rhandik then
			for _, bone in ipairs(bones) do
				local wm_boneindex = wm:LookupBone(self.fuckyoubones and self.fuckyoubones[bone] or bone)
				if !wm_boneindex then continue end
				local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
				if !wm_bonematrix then continue end
				
				local ply_boneindex = ply:LookupBone(bone)
				if !ply_boneindex then continue end
				local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
				if !ply_bonematrix then continue end

				local bonepos = wm_bonematrix:GetTranslation()
				local boneang = wm_bonematrix:GetAngles()

				bonepos.x = clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
				bonepos.y = clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
				bonepos.z = clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

				ply_bonematrix:SetTranslation(bonepos + posadd * -0.2 - ang:Right() * 2 + blocking + shoving + customIdle + fistRaise)
				ply_bonematrix:SetAngles(boneang)
				
				ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
				--ply:SetBonePosition(ply_boneindex, bonepos, boneang)
			end
		end

		local bones = hg.TPIKBonesLH

		posadd:Rotate(Angle(0,0,0))

		-- TPIK blocking for left hand
		self.blockingL = LerpFT(0.1, self.blockingL or vector_origin, (self:GetBlocking() and vecBlockingL or vector_origin))
		local blocking = -(-self.blockingL)
		blocking:Rotate(ang)
		
		-- TPIK shove animation for left hand
		self.shovingL = LerpFT(0.08, self.shovingL or vector_origin, (self:GetIsShoving() and vecShoveL or vector_origin))
		local shovingL = -(-self.shovingL)
		shovingL:Rotate(ang)
		
		-- Custom idle positioning for left hand
		local targetIdleL = self:GetIsSwinging() and vector_origin or customIdleVecL
		self.customIdleL = LerpFT(0.15, self.customIdleL or vector_origin, targetIdleL)
		local customIdleL = -(-self.customIdleL)
		customIdleL:Rotate(ang)
		
		-- Fist raising effect for left hand
		local targetRaiseL = (self.fistRaising and Vector(0, 0, 3)) or vector_origin
		self.fistRaiseL = LerpFT(0.2, self.fistRaiseL or vector_origin, targetRaiseL)
		local fistRaiseL = -(-self.fistRaiseL)
		fistRaiseL:Rotate(ang)

		if self.lhandik then
			for _, bone in ipairs(bones) do
				local wm_boneindex = wm:LookupBone(self.fuckyoubones and self.fuckyoubones[bone] or bone)
				if !wm_boneindex then continue end
				local wm_bonematrix = wm:GetBoneMatrix(wm_boneindex)
				if !wm_bonematrix then continue end
				
				local ply_boneindex = ply:LookupBone(bone)
				if !ply_boneindex then continue end
				local ply_bonematrix = ply:GetBoneMatrix(ply_boneindex)
				if !ply_bonematrix then continue end

				local bonepos = wm_bonematrix:GetTranslation()
				local boneang = wm_bonematrix:GetAngles()

				bonepos.x = clamp(bonepos.x, wmpos.x - 38, wmpos.x + 38) -- clamping if something gone wrong so no stretching (or animator is fleshy)
				bonepos.y = clamp(bonepos.y, wmpos.y - 38, wmpos.y + 38)
				bonepos.z = clamp(bonepos.z, wmpos.z - 38, wmpos.z + 38)

				ply_bonematrix:SetTranslation(bonepos + posadd * -0.7 + ang:Right() * 2 + blocking + shovingL + customIdleL + fistRaiseL)
				ply_bonematrix:SetAngles(boneang)
				
				ply:SetBoneMatrix(ply_boneindex, ply_bonematrix)
				--ply:SetBonePosition(ply_boneindex, bonepos, boneang)
			end
		end
	end

	if IsValid(ply) and havekastet then
		local offsetVec = self:GetFists() and self.offsetVec or self.idleVec
		local offsetAng = self:GetFists() and self.offsetAng or self.idleAng
		local boneid = ply:LookupBone("ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = ply:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		local kastet = self.model
		kastet:SetPos(newPos)
		kastet:SetAngles(newAng)
		kastet:SetupBones()
		kastet:DrawModel()
		kastet:SetModelScale(0.9) -- с новыми руками можно будет 1 оставить
	end

	hg.DragHands(self:GetOwner(),self)
end

function SWEP:IsLocal()
	if SERVER then return end
	return self:GetOwner() == LocalPlayer()
end

if SERVER then
	SWEP.Weight = 0
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = "Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 45
	SWEP.BounceWeaponIcon = false
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_hands")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_hands.png"
	local colWhite = Color(255, 255, 255, 255)
	local colGray = Color(200, 200, 200, 200)
	local lerpthing = 1
	local lerpalpha = 0
	local colwhite = Color(0, 0, 0, 0)
	local colred = Color(122, 0, 0, 0)
	function SWEP:DrawHUD()
		local owner = LocalPlayer()
		if GetViewEntity() ~= owner then return end
		if owner:InVehicle() then return end
		local Tr = hg.eyeTrace(owner,self.ReachDistance)
		if not Tr then return end
		local Size = math.max(math.min(1 - (Tr and Tr.Fraction or 0), 1), 0.1)
		local x, y = Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y

		if Tr.Hit and not self:GetFists() then
			if self:CanPickup(Tr.Entity) then
				lerpthing = Lerp(0.1, lerpthing, 0.1)
				colWhite.a = 255 * Size
				surface.SetDrawColor(colWhite)
				surface.DrawRect(x - 25 * lerpthing, y - 2.5, 50 * lerpthing, 5)
				surface.DrawRect(x - 2.5, y - 25 * lerpthing, 5, 50 * lerpthing)
			else
				lerpthing = Lerp(0.1, lerpthing, 1)
				colWhite.a = 255 * Size
				surface.SetDrawColor(colGray)
				draw.NoTexture()
				surface.SetDrawColor(colWhite)
				draw.NoTexture()
				surface.DrawRect(x - 25 * lerpthing, y - 2.5, 50 * lerpthing, 5)
				surface.DrawRect(x - 2.5, y - 25 * lerpthing, 5, 50 * lerpthing)
			end
		end

		do return end

		local ent = IsValid(Tr.Entity) and Tr.Entity.organism and Tr.Entity or owner
		if ent.organism then
			if Tr.Entity == ent then ent.is_lookedat = hg.KeyDown(owner, IN_RELOAD) end
			lerpalpha = LerpFT(0.1, lerpalpha, hg.KeyDown(owner, IN_RELOAD) and 255 + 2000 or 0)
			local lerpalpha = lerpalpha - 2000
			local org = ent.organism
			local add_x = 0
			local scrw, scrh = ScrW(), ScrH()
			local w, h = ScreenScale(30), ScreenScale(30)
			local add = ScreenScale(2)
			local posx, posy = scrw * 0.05, scrh * 0.95
			colwhite.a = lerpalpha / 1.1
			colred.a = lerpalpha / 1.1

			draw.RoundedBox(0, posx - 4, posy - h * 1.5 - 4, w * 10 + add * 10 + 8, 1.5 * h + 8, colred)
			draw.RoundedBox(0, posx, posy - h * 1.5, w * 10 + add * 10, 1.5 * h, colwhite)

			surface.SetFont("HomigradFontLarge")
			surface.SetTextColor(255, 255, 255, lerpalpha)
			local txt = "Afflictions shown for "..ent:GetPlayerName()..":"
			local w1, h1 = surface.GetTextSize(txt)
			surface.SetTextPos(scrw * 0.05, scrh * 0.95 - h - h1)
			surface.DrawText(txt)

			if org.blood and org.blood < 4000 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (4000 - org.blood) / 4000, hg.afflictions.pale, lerpalpha, "Pale skin")

				add_x = add_x + w + add
			end

			if org.bleed and org.bleed > 0.1 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, math.min(org.bleed / 10, 1), hg.afflictions.bleeding, lerpalpha, "Bleeding")

				add_x = add_x + w + add
			end

			if org.disorientation and org.disorientation > 0.1 and ent == owner then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, math.min(org.disorientation / 2, 1), hg.afflictions.concussion, lerpalpha, "Concussion")

				add_x = add_x + w + add
			end

			if org.rleg and org.rleg > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.rleg, org.rleg > 0.999 and hg.afflictions.lfracture or hg.afflictions.lblunt, lerpalpha, org.rleg > 0.999 and "Right leg fracture" or "Right leg blunt trauma")
				
				add_x = add_x + w + add
			end

			if org.lleg and org.lleg > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.lleg, org.lleg > 0.999 and hg.afflictions.lfracture or hg.afflictions.lblunt, lerpalpha, org.lleg > 0.999 and "Left leg fracture" or "Left leg blunt trauma")
				
				add_x = add_x + w + add
			end

			if org.rarm and org.rarm > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.rarm, org.rarm > 0.999 and hg.afflictions.afracture or hg.afflictions.ablunt, lerpalpha, org.rarm > 0.999 and "Right arm fracture" or "Right arm blunt trauma")

				add_x = add_x + w + add
			end

			if org.larm and org.larm > 0 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, org.larm, org.larm > 0.999 and hg.afflictions.afracture or hg.afflictions.ablunt, lerpalpha, org.larm > 0.999 and "Left arm fracture" or "Left arm blunt trauma")

				add_x = add_x + w + add
			end

			if org.pain and org.pain > 20 and not org.otrub then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (org.pain - 20) / 30, hg.afflictions.pain, lerpalpha, "Pain")

				add_x = add_x + w + add
			end

			if org.o2 and org.o2[1] < 5 then
				hg.DrawAffliction(posx + add_x, posy - h, w, h, (5 - org.o2[1]) / 5, hg.afflictions.lung_failure, lerpalpha, "Lung failure")

				add_x = add_x + w + add
			end

			//hg.DrawAffliction(scrw * 0.05 + add_x, scrh * 0.95 - h, w, h, 1, 3, 255)

			if add_x == 0 then
				surface.SetFont("HomigradFontLarge")
				surface.SetTextColor(255, 255, 255, lerpalpha)
				surface.SetTextPos(scrw * 0.05, scrh * 0.95 - h)
				surface.DrawText("No afflictions.")
			end
		end
	end
end

local function WhomILookinAt(ply, cone, dist)
	local CreatureTr, ObjTr, OtherTr = nil, nil, nil
	for i = 1, 150 * cone do
		local Tr = hg.eyeTrace(ply,dist)
		if Tr.Hit and not Tr.HitSky and Tr.Entity then
			local Ent, Class = Tr.Entity, Tr.Entity:GetClass()
			if Ent:IsPlayer() or Ent:IsNPC() then
				CreatureTr = Tr
			elseif (Class == "prop_physics") or (Class == "prop_physics_multiplayer") or (Class == "prop_ragdoll") then
				ObjTr = Tr
			else
				OtherTr = Tr
			end
		end
	end

	if CreatureTr then return CreatureTr.Entity, CreatureTr.HitPos, CreatureTr.HitNormal, CreatureTr.PhysicsBone end
	if ObjTr then return ObjTr.Entity, ObjTr.HitPos, ObjTr.HitNormal, ObjTr.PhysicsBone end
	if OtherTr then return OtherTr.Entity, OtherTr.HitPos, OtherTr.HitNormal, OtherTr.PhysicsBone end
	return nil, nil, nil, nil
end


function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
	self:NetworkVar("Bool", 5, "IsSwinging")
	self:NetworkVar("Float", 3, "NextShove")
	self:NetworkVar("Bool", 6, "IsShoving")  -- Track shove animation state
	self:NetworkVar("Int", 0, "BlockCounter")  -- Track consecutive blocks
	self:NetworkVar("Float", 4, "LastBlockTime")  -- Track when last block occurred
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation("Draw",1)
		local owner = self:GetOwner()
		if not IsValid(owner:GetViewModel()) then
			owner:GetViewModel():SetPlaybackRate(.1)
		end
		return true
	end

	self:SetNextPrimaryFire(CurTime() + .5)
	self:SetFists(false)
	self:SetIsShoving(false)
	self:SetBlockCounter(0)
	self:SetLastBlockTime(0)
	self:SetNextDown(CurTime())
	self:SetNextShove(CurTime())
	self:DoBFSAnimation("Draw",1)
	if self:GetOwner().PlayerClassName == "sc_infiltrator" then
		self.PrintName = "CQC"
		self.WepSelectIcon = Material("vgui/inventory/perk_quick_reload")
	end
	return true
end

-- function SWEP:Holster()
	-- self:OnRemove()
	-- return true
-- end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return true end
	local class = ent:GetClass()
	if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) then return true end
	return false
end

function SWEP:SecondaryAttack()
	if self:GetOwner():InVehicle() then return end
	if not IsFirstTimePredicted() then return end
	if self:GetFists() and self:GetOwner().PlayerClassName == "sc_infiltrator" then
		self:PrimaryAttack(true)
	end
	if self:GetFists() then return end
	if self:GetOwner():GetNetVar("handcuffed",false) then return end
	if SERVER then
		self:SetCarrying()
		local ply = self:GetOwner()
		local tr = util.QuickTrace(select(1, hg.eye(self:GetOwner())), self:GetOwner():GetAimVector() * self.ReachDistance, {self:GetOwner()})
		--if (IsValid(tr.Entity) or game.GetWorld() == tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
		if (IsValid(tr.Entity)) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(self:GetOwner())) - tr.HitPos):Length()
			--if Dist < self.ReachDistance then
				sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", self:GetOwner():GetShootPos(), 65, math.random(90, 110))
				self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
				tr.Entity.Touched = true
				self:ApplyForce()
			--end
		elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			local Dist = (select(1, hg.eye(self:GetOwner())) - tr.HitPos):Length()
			if Dist < self.ReachDistance then
				sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", self:GetOwner():GetShootPos(), 65, math.random(90, 110))
				self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * 20)
				tr.Entity:SetVelocity(-self:GetOwner():GetAimVector() * 50)
				self:SetNextSecondaryFire(CurTime() + .25)
				
				-- Check if target can be grabbed (superfighter OR Fury-13 OR target has low stamina/blood)
				local canGrab = self:GetOwner().organism.superfighter
				local isFury13 = self:GetOwner():GetNetVar("Fury13_Active", false)
				
				-- Fury-13 allows grabbing anyone regardless of stamina
				if isFury13 then
					canGrab = true
				elseif not canGrab and tr.Entity.organism then
					local targetStamina = tr.Entity.organism.stamina and tr.Entity.organism.stamina[1] or 0
					local targetBlood = tr.Entity.organism.blood or 5000
					canGrab = (targetStamina < 75) or (targetBlood < 3200)
				end
				
				if canGrab then
					hg.LightStunPlayer(tr.Entity, 3)
					timer.Simple(0,function()
						local rag = hg.GetCurrentCharacter(tr.Entity)
						if IsValid(rag) and rag ~= tr.Entity then
							self:SetCarrying(rag, tr.PhysicsBone, tr.HitPos, Dist)
						end
					end)
				end
			end
		end
	end
end

SWEP.Checking = 0

function SWEP:ApplyForce()
	local ply = self:GetOwner()
	local target = self:GetOwner():GetAimVector() * self.CarryDist + select(1, hg.eye(ply))
	if not IsValid(self.CarryEnt) then return end
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryEnt.organism and ((ply.sendTimeOrg or 0) < CurTime()) then
			ply.sendTimeOrg = CurTime() + 0.5

			//hg.send_organism(self.CarryEnt.organism, ply)
		end

		if self.CarryPos then
			if self.CarryEnt:IsRagdoll() then
				TargetPos = LocalToWorld(self.CarryPos, angle_zero, phys:GetPos(), phys:GetAngles())
			else
				TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
			end
		end

		local vec = target - TargetPos
		local len, mul = vec:Length(), phys:GetMass()
		
		vec:Normalize()

		-- Make ragdolls easier to carry
		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			mul = mul * self.RagdollCarryForceMultiplier
		end

		if (ply.organism and ply.organism.superfighter) then
			mul = mul * 5
		end
		
		-- Fury-13 provides enhanced carrying force (3x multiplier)
		local isFury13 = ply:GetNetVar("Fury13_Active", false)
		if isFury13 then
			mul = mul * 3
		end
		
		local avec = vec * len * 3 - phys:GetVelocity()
		
		local Force = avec * mul
		-- Increase force limit for ragdolls to make them more responsive
		local forceLimit = 2000
		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			forceLimit = forceLimit * 1.8
		end
		local ForceMagnitude = math.min(Force:Length(), forceLimit)
		
		Force = Force:GetNormalized() * ForceMagnitude
		
		if len > 15000 then
			self:SetCarrying()
			return
		end

		phys:Wake()
		self.CarryEnt:SetPhysicsAttacker(ply, 5)

		if SERVER then
			if self.CarryEnt.welds then
				for i, weld in pairs(self.CarryEnt.welds) do
					if IsValid(weld) then weld:Remove() end
				end
				self.CarryEnt.welds = nil
			end
			if (ply:GetGroundEntity() == self.CarryEnt) or (ply:GetEntityInUse() == self.CarryEnt) or IsValid(ply.FakeRagdoll) or self.CarryEnt:IsPlayerHolding() then
				self:SetCarrying()
				return
			end
		end

		if self.CarryEnt:GetClass() == "ent_hg_cyanide_canister" then
			ply.Guilt = math.max(ply.Guilt, 5)
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			local ply2 = RagdollOwner(self.CarryEnt) or self.CarryEnt
			local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))
			
			if ply:KeyPressed(IN_RELOAD) then
				if not ply2.noHead and ply2.organism then
					
					if ply2.organism.CantCheckPulse then
						ply:ChatPrint("The armor is too thick to feel the pulse.")
					elseif ((bone == "ValveBiped.Bip01_L_Hand") or (bone == "ValveBiped.Bip01_R_Hand") or (bone == "ValveBiped.Bip01_Head1")) then
						local org = ply2.organism

						if org.heartstop then
							ply:ChatPrint("No pulse.")
						else
							ply:ChatPrint(org.pulse < 20 and "Barely can feel the pulse." or (org.pulse <= 50 and "Low pulse.") or (org.pulse <= 90 and "Normal pulse.") or "High pulse.")
						end

						if (org.last_heartbeat + 60) > CurTime() then
							ply:ChatPrint("The body is still warm.")
						else
							ply:ChatPrint((org.last_heartbeat + 180) < CurTime() and "The body has been here for awhile." or "The body is slightly warm")
						end
						
						if org.blood < 3500 then
							if org.blood < 1000 then
								ply:ChatPrint("Blood is barely present in this body.")
							else
								ply:ChatPrint("Pale skin.")
							end
						end

						if org.bleed > 0 then
							ply:ChatPrint("The body is bleeding "..((org.bleed > 10 and "profusely.") or (org.bleed > 5 and "moderately.") or "slightly."))
						end
						
						//org.bulletwounds = 0
						//org.stabwounds = 0
						//org.slashwounds = 0
						//org.bruises = 0
						//org.burns = 0
						//org.explosionwounds = 0

						if org.bulletwounds > 0 then
							ply:ChatPrint("You notice "..org.bulletwounds.." bullet wounds on this body.")
						end

						if org.stabwounds > 0 then
							ply:ChatPrint("You notice "..org.stabwounds.." stab wounds on this body.")//28 STAB WOUNDS. YOU WOULDNT LEAVE HIM A CHANCE, HUH?
						end

						if org.slashwounds > 0 then
							ply:ChatPrint("You notice "..org.slashwounds.." slashes on this body.")
						end

						if org.bruises > 0 then
							ply:ChatPrint("You notice "..org.bruises.." bruises on this body.")
						end

						if org.burns > 0 then
							ply:ChatPrint("The body was burned.")
						end

						if org.explosionwounds > 0 then
							ply:ChatPrint("The body appears to have blast trauma.")
						end

						if (bone == "ValveBiped.Bip01_Head1") then
							if (org.o2[1] < 10 or not org.alive) then
								ply:ChatPrint("Not breathing.")
							else
								ply:ChatPrint("Breathing.")
							end

							ply:ChatPrint(org.otrub and "No reaction." or "Reaction present.")

							if org.isPly and not org.otrub then
								org.owner:ChatPrint("You were checked for reaction.")
							end
						end
					end
					
					self.Checking = math.min(self.Checking + FrameTime() * 2, 10)
				else
					ply:ChatPrint("I dont think I need to check their vitals.")
				end
			end
		end

		if SERVER then
			local ply2 = self.CarryEnt
			local org = ply2.organism
			if ply:KeyDown(IN_ATTACK) and not ply.organism.superfighter then
				local bone = self.CarryEnt:GetBoneName(self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone))

				local tr = {}
				tr.start = TargetPos
				tr.endpos = TargetPos - vector_up * 16
				tr.mask = MASK_SOLID_BRUSHONLY
				local trace = util.TraceLine(tr)

				if bone != "ValveBiped.Bip01_Spine2" or not trace.Hit then
					-- Adrenaline-based throwing force system
					local baseForce = 10000
					local maxForce = 16500
					local adrenalineLevel = ply.organism and ply.organism.adrenaline or 0
					local adrenalineMultiplier = math.min(adrenalineLevel / 3, 1) -- Cap at adrenaline level 3
					local throwForce = baseForce + (maxForce - baseForce) * adrenalineMultiplier
					
					-- Fury-13 provides 3x throw power
					local isFury13 = ply:GetNetVar("Fury13_Active", false)
					if isFury13 then
						throwForce = throwForce * 3
					end
					phys:ApplyForceCenter(ply:GetAimVector() * throwForce)
					-- Removed body impact sound for throwing
					
					-- Set up ragdoll impact damage system
					if SERVER and self.CarryEnt:IsValid() and self.CarryEnt:GetClass() == "prop_ragdoll" then
						local ragdoll = self.CarryEnt
						local ragdollOwner = RagdollOwner(ragdoll)
						
						if ragdollOwner and ragdollOwner:IsValid() and ragdollOwner:IsPlayer() then
						-- Set up collision detection for thrown ragdoll
						timer.Simple(0.05, function()
							if IsValid(ragdoll) then
								ragdoll.IsThrownRagdoll = true
								ragdoll.ThrownTime = CurTime()
							end
						end)
						end
					end
					
					self:SetCarrying()
				end

				if org and bone == "ValveBiped.Bip01_Spine2" and trace.Hit then
					if self.firstTimePrint then
						if not ply2.noHead then
							ply:ChatPrint("You are beginning to perform CPR.")
						else
							ply:ChatPrint("I dont think CPR would help here...")
						end
					end

					self.firstTimePrint = false
					if (self.CPRThink or 0) < CurTime() then
						self.CPRThink = CurTime() + (1 / 120) * 60
						if org.alive then
							//org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2 * (ply.Profession == "doctor" and 2 or 1), org.o2.range)
							org.pulse = math.min(org.pulse + 5 * (ply.Profession == "doctor" and 2 or 1),70)
							org.CO = math.Approach(org.CO, 0, (ply.Profession == "doctor" and 2 or 1))
							org.COregen = math.Approach(org.COregen, 0, (ply.Profession == "doctor" and 2 or 1))
							
							if math.random(3) == 1 then
								org.lungsfunction = true
							end

							if math.random(50) == 1 and (ply.Profession != "doctor") then
								local dmginfo = DamageInfo()
								dmginfo:SetDamageType(DMG_CRUSH)
								dmginfo:SetInflictor(self)
								hg.organism.input_list.chest(org, 1, 5, dmginfo)
							end

							if org.pulse > 15 then org.heartstop = false end
						end

						phys:ApplyForceCenter(-vector_up * 6000)

						--self.CarryEnt:EmitSound("physics/body/body_medium_impact_soft" .. tostring(math.random(7)) .. ".wav")
					end
				end
			else
				self.firstTimePrint = true
				self.firstTimePrint2 = true
			end

			if ply:KeyDown(IN_ATTACK) and ply.organism.superfighter then
				-- Adrenaline-based superfighter throwing force - extremely powerful
				local baseForce = 15000
				local maxForce = 20000
				local adrenalineLevel = ply.organism and ply.organism.adrenaline or 0
				local adrenalineMultiplier = math.min(adrenalineLevel / 3, 1) -- Cap at adrenaline level 3
				local adrenalineThrowForce = baseForce + (maxForce - baseForce) * adrenalineMultiplier
				local superThrowForce = adrenalineThrowForce * self.Penetration * 2 -- Superfighter multiplier
				
				-- Fury-13 provides additional 3x throw power even for superfighters
				local isFury13 = ply:GetNetVar("Fury13_Active", false)
				if isFury13 then
					superThrowForce = superThrowForce * 3
				end
				phys:ApplyForceCenter(ply:GetAimVector() * superThrowForce)
				-- Removed body impact sound for throwing
				
				-- Set up ragdoll impact damage system for superfighter throws
				if SERVER and self.CarryEnt:IsValid() and self.CarryEnt:GetClass() == "prop_ragdoll" then
					local ragdoll = self.CarryEnt
					local ragdollOwner = RagdollOwner(ragdoll)
					
					if ragdollOwner and ragdollOwner:IsValid() and ragdollOwner:IsPlayer() then
						-- Set up collision detection for thrown ragdoll
						timer.Simple(0.05, function()
							if IsValid(ragdoll) then
								ragdoll.IsThrownRagdoll = true
								ragdoll.ThrownTime = CurTime()
							end
						end)
					end
				end
				
				self:SetCarrying()
			end
		end
		
		if self.CarryPos then
			phys:ApplyForceOffset(Force, TargetPos)
		else
			phys:ApplyForceCenter(Force)
		end

		//hg.ShadowControl(self.CarryEnt, self.CarryBone, 0.1, angle_zero, 0, 0, target, 60, 40)

		if ply:KeyDown(IN_USE) then
			SetAng = SetAng or ply:EyeAngles()
			local commands = ply:GetCurrentCommand()
			local x, y = commands:GetMouseX(), commands:GetMouseY()
			if self.CarryEnt:IsRagdoll() then
				rotate = Vector(0, -x, -y) / 6
			else
				rotate = Vector(0, -x, -y) / 4
			end

			//phys:AddAngleVelocity(rotate * phys:GetMass() / 10)
		end

		phys:ApplyForceCenter(Vector(0, 0, mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if IsValid(ent) or game.GetWorld() == ent then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist
		
		local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

		if ent:GetClass() ~= "prop_ragdoll" then
			self.CarryPos = ent:WorldToLocal(pos)
		else
			self.CarryPos = WorldToLocal(pos, angle_zero, phys:GetPos(), phys:GetAngles())
		end
		
		if not IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent", self.CarryEnt)
			owner:SetNetVar("carrybone", self.CarryBone)
			owner:SetNetVar("carrymass", phys:GetMass())
			owner:SetNetVar("carrypos", self.CarryPos)
		end

		if not self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:SetCustomCollisionCheck(true)
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()

			self.CarryEnt:CallOnRemove("removenarsla",function()
				if not IsValid(owner) then return end
				owner:CollisionRulesChanged()
				owner:SetNetVar("carryent",nil)
				owner:SetNetVar("carrybone",nil)
				owner:SetNetVar("carrymass",nil)
				owner:SetNetVar("carrypos",nil)
			end)

			owner:SetNetVar("carrymass",self.CarryEnt:GetPhysicsObjectNum(self.CarryBone):GetMass())
		end
	else
		if IsValid(self.CarryEnt) and self.CarryEnt:GetCustomCollisionCheck() then
			self.CarryEnt:CollisionRulesChanged()
			owner:CollisionRulesChanged()
			//self.CarryEnt:SetCustomCollisionCheck(false)
		end

		if IsValid(owner:GetNetVar("carryent")) then
			owner:SetNetVar("carryent",nil)
			owner:SetNetVar("carrybone",nil)
			owner:SetNetVar("carrypos",nil)
			owner:SetNetVar("carrymass",0)
		end

		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
	end
end

-- Removed ACT_HL2MP_FIST_BLOCK animation hook - using TPIK blocking only

function SWEP:Think()
	local owner = self:GetOwner()

	self.Checking = math.max(self.Checking - FrameTime(), 0)

	if self:GetOwner():GetNWBool("TauntHolsterWeapons", false) then
		self:SetFists(false)
		self:SetBlocking(false)
		self:SetIsShoving(false)
		self:SetBlockCounter(0)
		self:SetCarrying()
		self:Reload()
		return
	end

	if IsValid(owner) and owner:KeyDown(IN_ATTACK2) and not self:GetFists() then
		if IsValid(self.CarryEnt) or game.GetWorld() == self.CarryEnt then self:ApplyForce() end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if self:GetFists() and owner:KeyDown(IN_ATTACK2) and (self:GetNextSecondaryFire() < CurTime()) and owner.PlayerClassName ~= "sc_infiltrator" then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
		-- Reset block counter when not blocking
		if SERVER then
			self:SetBlockCounter(0)
		end
	end

	local HoldType = "normal"
	if self:GetFists() then
		if CLIENT and self:GetHoldType() != "camera" then
			self:DoBFSAnimation("Draw",1)
		end
		HoldType = "camera"
		local Time = CurTime()
		if self:GetNextIdle() < Time then
			//self:DoBFSAnimation("fists_idle_0" .. math.random(1, 2),2)
			self:UpdateNextIdle()
		end

		if self:GetBlocking() then
			self:SetNextDown(Time + 1)
			//owner:DoAnimationEvent(ACT_HL2MP_FIST_BLOCK)
			--HoldType = "camera"
		end
		
		//if (self:GetNextDown() < Time) or owner:KeyDown(IN_SPEED) then
		if owner:KeyDown(IN_SPEED) then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
			self:SetIsShoving(false)
			self:SetBlockCounter(0)
		end
	else
		HoldType = "normal"
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then HoldType = "normal" end
	if owner:KeyDown(IN_SPEED) then HoldType = "normal" end
	if SERVER then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack(forcespecial)
	if self:GetOwner():InVehicle() then return end
	if (self.attacked or 0) > CurTime() then return end
	local side = "fists_left"
	local rand = math.Round(util.SharedRandom( "fist_Punching", 1, 2 ),0) == 1
	local ply = self:GetOwner()
	local twohands = (ply:GetNetVar("carrymass",0) ~= 0 and ply:GetNetVar("carrymass",0) or ply:GetNetVar("carrymass2",0)) > 15

	local inv = ply:GetNetVar("Inventory",{})
	local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]

	if rand or (CLIENT and ((self:GetOwner():GetTable().ChatGestureWeight >= 0.1) or twohands)) or havekastet then
		side = "fists_right"
	end
	if self:GetOwner():KeyDown(IN_ATTACK2) and self:GetOwner().PlayerClassName ~= "sc_infiltrator" then return end
	if self:GetOwner():GetNetVar("handcuffed",false) then return end
	local olddown = self:GetNextDown()
	self:SetNextDown(CurTime() + 7)
	if not self:GetFists() then
		self:SetFists(true)
		self:DoBFSAnimation("Draw",1)
		self:SetNextPrimaryFire(CurTime() + .35)
		return
	end
	
	if self:GetBlocking() then return end
	if self:GetOwner():KeyDown(IN_SPEED) then return end
	
	-- Check for shove input: E key held while fists are raised
	if self:GetOwner():KeyDown(IN_USE) and self:GetFists() then
		if (self:GetNextShove() or 0) <= CurTime() then
			self:ShoveAttack()
			return
		else
			return -- Still on cooldown
		end
	end
	
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(side,0.5)
		return
	end
	self.attacked = CurTime() + 0.5
	
	local special_attack = (olddown - 5) < CurTime()
	if forcespecial then
		special_attack = true
	end
	
	-- Set swinging state for custom idle positioning
	self:SetIsSwinging(true)
	timer.Simple(special_attack and 1.1 or 0.8, function()
		if IsValid(self) then
			self:SetIsSwinging(false)
		end
	end)
	
	if CLIENT and self.IsLocal and self:IsLocal() then
		if special_attack then
			-- Right hook motion: start with slight right movement, then heavy left swing
			ViewPunch(Angle(-2, 3, -2)) -- Initial right position
			timer.Simple(0.5, function() -- Timing matches Attack_Charge_End
				ViewPunch(Angle(-8, -28, 6)) -- Right hook sideways motion (increased range and wideness)
			end)
		else
			ViewPunch(Angle((-1), -(rand and 2 or -2), (rand and 6 or -6)))
		end
	end
	
	if special_attack then
		-- Right hook sequence: start with charge begin, then quickly to charge end
		self:DoBFSAnimation("Attack_Charge_Begin",0.85)
		timer.Simple(0.5, function()
			if IsValid(self) then
				self:DoBFSAnimation("Attack_Charge_End",1)
				-- Trigger fist raising effect during Attack_Charge_End
				self.fistRaising = true
				-- Attack happens during Attack_Charge_End for special attacks
				if SERVER then
					-- Higher pitch version of shove sound for swing
					sound.Play("weapons/nmrih/items/shove_0" .. math.random(1,5) .. ".wav", self:GetPos(), 65, math.random(130, 150))
					self:AttackFront(special_attack,rand)
				end
				-- Lerp fists back down after Attack_Charge_End completes
				timer.Simple(0.8, function()
					if IsValid(self) then
						self.fistRaising = false
					end
				end)
			end
		end)
	else
		-- Regular punches use the new animation mappings
		if side == "fists_right" then
			self:DoBFSAnimation("Attack_Quick",0.8)
		else
			self:DoBFSAnimation("Attack_Quick2",0.8)
		end
		-- Regular attacks happen immediately
		if SERVER then
			-- Higher pitch version of shove sound for swing
			sound.Play("weapons/nmrih/items/shove_0" .. math.random(1,5) .. ".wav", self:GetPos(), 65, math.random(130, 150))
			self:AttackFront(special_attack,rand)
		end
	end
	
	if CLIENT and self.IsLocal and not self:IsLocal() then
		self:GetOwner():AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,self:GetOwner():LookupSequence((special_attack or rand) and "range_fists_r" or "range_fists_l"),0,true)
	end

	self:UpdateNextIdle()

	self:SetNextPrimaryFire(CurTime() + .6 * math.Clamp((180 - self:GetOwner().organism.stamina[1]) / 90,1,2) + (special_attack and 0.5 or 0))
	self:SetNextSecondaryFire(CurTime() + .6 + (special_attack and 0.5 or 0))
	self:SetLastShootTime(CurTime())
end

function SWEP:AttackFront(special_attack,rand)
	if CLIENT then return end
	local owner = self:GetOwner()
	--self.PenetrationCopy = -(-self.Penetration) -- это как
	owner:LagCompensation(true)
	local Ent, HitPos, _, physbone = WhomILookinAt(owner, .3, special_attack and 35 or 45)
	local AimVec = owner:GetAimVector()
	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		if string.find(Ent:GetClass(),"break") and Ent:GetBrushSurfaces()[1] and string.find(Ent:GetBrushSurfaces()[1]:GetMaterial():GetName(),"glass") then
			Ent:EmitSound("physics/glass/glass_sheet_impact_hard"..math.random(3)..".wav")
			if math.random(1,8) == 8 then
				hg.organism.AddWoundManual(owner, math.Rand(15,25), vector_origin, AngleRand(), owner:LookupBone("ValveBiped.Bip01_"..(rand and "R" or "L").."_Hand"), CurTime())
				Ent:Fire("Break")
			end

			owner:LagCompensation(false) // idiot

			return
		end

		local inv = owner:GetNetVar("Inventory",{})
		local havekastet = inv["Weapons"] and inv["Weapons"]["hg_brassknuckles"]
		local SelfForce, Mul = 150, 1 * (havekastet and 1.7 or 1)
		if self:IsEntSoft(Ent) then
			SelfForce = 25
			if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() and not RagdollOwner(Ent) then
				sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", HitPos, 65, math.random(90, 110))
			else
				sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", HitPos, 65, math.random(90, 110))
			end
		else
			sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", HitPos, 65, math.random(90, 110))
			-- Add pain to attacker when hitting hard surfaces
			if not self:IsEntSoft(Ent) then
				local painAmount = special_attack and math.Rand(8, 15) or math.Rand(3, 8)
				hg.organism.AddWoundManual(owner, painAmount, vector_origin, AngleRand(), owner:LookupBone("ValveBiped.Bip01_"..(rand and "R" or "L").."_Hand"), CurTime())
			end
		end

		-- Increased damage: heavier punches pack more punch
		local DamageAmt = (math.random(6, 9) * (special_attack and 4 or 1)) * (self.DamageMul or 1)
		local ent = Ent
		local vec = AimVec
		if string.find(ent:GetClass(),"prop_") and not ent:IsRagdoll() then
			ent:CallOnRemove("gibbreak",function()
				ent:PrecacheGibs()
				ent:GibBreakServer( vec * 100 )
			end)
			timer.Simple(1,function()
				if IsValid(ent) then ent:RemoveCallOnRemove("gibbreak") end
			end)
		end

		Mul = Mul * (owner.MeleeDamageMul or 1)

		if owner.organism.superfighter then
			Mul = Mul * 5 * self.Penetration
			if Ent.organism then
				Ent.organism.immobilization = 10
			end
		end

		local Dam = DamageInfo()
		Dam:SetAttacker(owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt * Mul * 0.75)
		Dam:SetDamageForce(AimVec * Mul ^ 2)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys = Ent:IsPlayer() and Ent:GetPhysicsObject() or Ent:GetPhysicsObjectNum(physbone or 0)

		if Ent:IsPlayer() then
			if special_attack then
				-- Right hook victim impact: victim looks left from the punch (increased impact)
				Ent:ViewPunch(Angle(-30, -20, 8))
			else
				Ent:ViewPunch(Angle(-5,0,0))
			end
		end

		if IsValid(Phys) then
			if Ent:IsPlayer() then Ent:SetVelocity(AimVec * SelfForce * 1.5 * (owner.organism.superfighter and 5 or 1)) end
			Phys:ApplyForceOffset(AimVec * 5000 * Mul, HitPos)
			owner:SetVelocity(AimVec * SelfForce * .8 * (owner.organism.superfighter and 2 or 1))
		end

		

		--add bleeding when punching glass -- plz dont
	end

	if SERVER then
		-- Heavily reduce stamina consumption when carrying objects
		local staminaCost = 1
		if self:GetIsCarrying() then
			staminaCost = staminaCost * self.CarryStaminaMultiplier
		end
		owner.organism.stamina.subadd = owner.organism.stamina.subadd + staminaCost
	end
	owner:LagCompensation(false)
end

function SWEP:ShoveAttack()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	-- Play shove animation
	self:DoBFSAnimation("Shove", 0.9)
	
	-- Set shove animation state for TPIK
	self:SetIsShoving(true)
	timer.Simple(0.9, function()
		if IsValid(self) then
			self:SetIsShoving(false)
		end
	end)
	
	if CLIENT then return end
	
	-- Set cooldown for shove attacks
	self:SetNextShove(CurTime() + 1.5)
	self:SetNextPrimaryFire(CurTime() + 0.8)
	self:SetNextSecondaryFire(CurTime() + 0.8)
	
	if SERVER then
		-- Random nmrih shove sound
		sound.Play("weapons/nmrih/items/shove_0" .. math.random(1,5) .. ".wav", self:GetPos(), 70, math.random(80, 100))
	end
	
	owner:LagCompensation(true)
	local Ent, HitPos, _, physbone = WhomILookinAt(owner, .6, 70) -- Increased cone (.4 to .6) and range (50 to 70)
	local AimVec = owner:GetAimVector()
	
	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		-- Handle glass breaking with shoves
		if string.find(Ent:GetClass(),"break") and Ent:GetBrushSurfaces()[1] and string.find(Ent:GetBrushSurfaces()[1]:GetMaterial():GetName(),"glass") then
			Ent:EmitSound("physics/glass/glass_sheet_break" .. math.random(1,3) .. ".wav")
			Ent:Fire("Break")
			owner:LagCompensation(false)
			return
		end
		
		local SelfForce = 200 -- Stronger push force than regular punches
		local isPlayerTarget = Ent:IsPlayer()
		local isRagdollTarget = Ent:IsRagdoll() or hg.RagdollOwner(Ent)
		
		if self:IsEntSoft(Ent) then
			sound.Play("fists/hit" .. math.random(1, 10) .. ".wav", HitPos, 70, math.random(85, 105))
		else
			sound.Play("physics/concrete/concrete_impact_hard" .. math.random(1,3) .. ".wav", HitPos, 70, math.random(90, 110))
		end
		
		-- Check if target is blocking and break their block
		if isPlayerTarget and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() then
			-- Break the block
			if Ent:GetActiveWeapon().SetBlocking then
				Ent:GetActiveWeapon():SetBlocking(false)
			end
			if Ent:GetActiveWeapon().SetIsShoving then
				Ent:GetActiveWeapon():SetIsShoving(false)
			end
			-- Reset block counter when block is broken
			if Ent:GetActiveWeapon().SetBlockCounter then
				Ent:GetActiveWeapon():SetBlockCounter(0)
			end
			-- Extra force when breaking blocks
			SelfForce = SelfForce * 1
		end
		
		-- Minimal damage for shoves
		local DamageAmt = math.random(1, 3)
		local Dam = DamageInfo()
		Dam:SetAttacker(owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt)
		Dam:SetDamageForce(AimVec * SelfForce * 2)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		
		-- Check if target is weak and should be ragdolled
		local shouldRagdoll = false
		if isPlayerTarget and Ent.organism then
			local stamina = Ent.organism.stamina[1] or 100
			local blood = Ent.organism.blood or 100
			-- Consider weak if stamina < 95 or blood < 3500
			if stamina < 95 or blood < 3500 then
				shouldRagdoll = true
			end
		end
		
		local Phys = Ent:IsPlayer() and Ent:GetPhysicsObject() or Ent:GetPhysicsObjectNum(physbone or 0)
		
		if IsValid(Phys) then
			-- Apply strong push force
			if Ent:IsPlayer() then 
				Ent:SetVelocity(AimVec * SelfForce * 2.5)
				-- Heavy viewpunch for shoves
				Ent:ViewPunch(Angle(-15, math.random(-8, 8), math.random(-5, 5)))
				
				-- Simple timer-based collision detection for ragdolling when victim hits props
				if not IsValid(Ent.FakeRagdoll) and not RagdollOwner(Ent) and Ent:IsPlayer() and Ent:Alive() then
					-- Start a simple timer to check for prop collisions
					local timerName = "ShoveCollision_" .. Ent:SteamID64()
					local checkCount = 0
					local maxChecks = 10 -- Check for 1 second (10 checks * 0.1 seconds)
					
					timer.Create(timerName, 0.1, maxChecks, function()
						if not IsValid(Ent) or not Ent:Alive() or IsValid(Ent.FakeRagdoll) or RagdollOwner(Ent) then
							timer.Remove(timerName)
							return
						end
						
						checkCount = checkCount + 1
						
						-- Check for props around the player
						local playerPos = Ent:GetPos() + Vector(0, 0, 36) -- Center mass
						local directions = {
							Vector(1, 0, 0),   -- Forward
							Vector(-1, 0, 0),  -- Backward
							Vector(0, 1, 0),   -- Right
							Vector(0, -1, 0),  -- Left
						}
						
						local hitProp = false
						for _, dir in ipairs(directions) do
							local trace = util.TraceLine({
								start = playerPos,
								endpos = playerPos + (dir * 30), -- Check 30 units around player
								filter = Ent,
								mask = MASK_SOLID
							})
							
							if trace.Hit and IsValid(trace.Entity) then
								local hitClass = trace.Entity:GetClass()
								if hitClass == "prop_physics" or 
								   hitClass == "prop_physics_multiplayer" or 
								   hitClass == "prop_dynamic" or
								   hitClass == "func_breakable" or
								   trace.Entity:IsWorld() then
									hitProp = true
									break
								end
							end
						end
						
						-- Ragdoll if touching a prop
						if hitProp then
							hg.Fake(Ent)
							sound.Play("physics/body/body_medium_impact_hard" .. math.random(1,6) .. ".wav", 
									  Ent:GetPos(), 75, math.random(90, 110))
							timer.Remove(timerName)
							return
						end
						
						-- Stop checking after max time
						if checkCount >= maxChecks then
							timer.Remove(timerName)
						end
					end)
				end
				
				-- Ragdoll weak opponents (existing functionality)
				if shouldRagdoll and not RagdollOwner(Ent) then
					hg.LightStunPlayer(Ent, 2) -- 2 second stun
				end
			end
			
			-- Double-check physics object validity before applying force
			if IsValid(Phys) and Phys:IsMotionEnabled() then
				Phys:ApplyForceOffset(AimVec * 8000, HitPos) -- Much stronger than regular punches
			end
			owner:SetVelocity(AimVec * SelfForce * 0.3) -- Less recoil for attacker
		end
	end
	
	-- Stamina cost for shoving
	if SERVER then
		owner.organism.stamina.subadd = owner.organism.stamina.subadd + 6 -- Higher stamina cost than regular punches
	end
	
	owner:LagCompensation(false)
end

heldents = heldents or {}

function hg.RemoveCarryEnt2(ent)
	heldents[ent] = nil

	ent.rememberedang = nil
	ent.oldaddang = nil
	ent.addang = nil

	if IsValid(ent) then
		if ent:GetCustomCollisionCheck() then
			--ent:SetCustomCollisionCheck(false)
			--ent:CollisionRulesChanged()
		end
	end

	ent:RemoveCallOnRemove("removenasral")
end

function hg.SetCarryEnt2(ply, ent, bone, mass, carrypos, targetpos, targetang, dist)
	if not IsValid(ent) then
		local ent2 = ply:GetNetVar("carryent2")

		if IsValid(ent2) then
			hg.RemoveCarryEnt2(ent2)
		end
		
		ply:SetNetVar("carryent2",nil)
		ply:SetNetVar("carrybone2",nil)
		ply:SetNetVar("carrymass2",nil)
		ply:SetNetVar("carrypos2",nil)
	else
		local physnum = ent:TranslateBoneToPhysBone(bone)
		local phys = bone ~= -1 and ent:GetPhysicsObjectNum(physnum) or ent:GetPhysicsObject()
		
		ent:CallOnRemove("removenasral",function()
			ply:SetNetVar("carryent2",nil)
			ply:SetNetVar("carrybone2",nil)
			ply:SetNetVar("carrymass2",nil)
			ply:SetNetVar("carrypos2",nil)
		end)
		
		ent.rememberedang = nil
		ent.oldaddang = nil
		ent.addang = nil

		ply:SetNetVar("carryent2", ent)
		ply:SetNetVar("carrybone2", physnum)
		ply:SetNetVar("carrymass2", mass)
		ply:SetNetVar("carrypos2", carrypos)
		
		if not ent:GetCustomCollisionCheck() then
			ent:SetCustomCollisionCheck(true)
			ent:CollisionRulesChanged()
		end

		local dist = dist or phys:GetPos():Distance(ply:EyePos())
		
		local targetpos, _ = WorldToLocal(targetpos or (ply:GetAimVector() * dist + ply:EyeAngles():Up() * 10 + ply:GetShootPos()), angle_zero, ply:EyePos(), ply:EyeAngles())

		local ang = ply:EyeAngles()
		ang[3] = 0
		local _, targetang = WorldToLocal(vector_origin, targetang or phys:GetAngles(), vector_origin, ang)

		heldents[ent:EntIndex()] = {ent, ply, dist, targetpos, bone ~= -1 and physnum or 0, carrypos, targetang}
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	self:SetFists(false)
	self:SetBlocking(false)
	self:SetIsShoving(false)
	self:SetBlockCounter(0)

	local ent = self:GetCarrying()
	
	if SERVER then
		local target,_ = WorldToLocal(self:GetOwner():GetAimVector() * (self.CarryDist or 50) + self:GetOwner():GetShootPos(),angle_zero,self:GetOwner():EyePos(),self:GetOwner():EyeAngles())

		if IsValid(ent) then
			local owner = self:GetOwner()
			local bon = self.CarryEnt:TranslatePhysBoneToBone(self.CarryBone)
			local bone = self.CarryEnt:GetBoneName(bon)
			local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

			if ((bone ~= "ValveBiped.Bip01_L_Hand") and (bone  ~= "ValveBiped.Bip01_R_Hand") and (bone ~= "ValveBiped.Bip01_Head1")) then
				if not heldents[ent:EntIndex()] then
					hg.SetCarryEnt2(owner, ent, bon, phys:GetMass(), self.CarryPos, owner:GetAimVector() * (self.CarryDist or 50) + owner:GetShootPos())
				else
					--hg.SetCarryEnt2(owner)
				end
			end

			--self:SetCarrying()
		end
	end
end

if SERVER then
	local angZero = Angle(0, 0, 0)
	hook.Add("Think", "held-entities", function()
		heldents = heldents or {}
		for i, tbl in pairs(heldents) do
			if not tbl or not IsValid(tbl[1]) then
				if IsValid(tbl[2]) then
					hg.SetCarryEnt2(tbl[2])
				end
				heldents[i] = nil
				continue
			end

			local ent, ply, dist, target, bone, pos, lang = tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6], tbl[7]
			local phys = ent:GetPhysicsObjectNum(bone)
			
			if not IsValid(phys) or not IsValid(ply) or not IsValid(ent) or not ply:Alive() or (ply:GetGroundEntity() == ent) or (ply:GetEntityInUse() == ent) or IsValid(ply.FakeRagdoll) or ply:KeyPressed(IN_RELOAD) then
				hg.SetCarryEnt2(ply)
				heldents[i] = nil
				continue
			end
			
			if ply:GetActiveWeapon().GetCarrying and ply:GetActiveWeapon():GetCarrying() == ent then continue end

			if ply:KeyDown(IN_USE) then
				if not ent.rememberedang or not ent.oldaddang then
					ent.oldaddang = ent.addang or Angle(0,0,0)
					ent.rememberedang = ply:EyeAngles()
				end

				local _,ang = WorldToLocal(vector_origin, ply:EyeAngles(), vector_origin, ent.rememberedang)
				ent.addang = ang + ent.oldaddang
				ent.addang[1] = math.Clamp(ent.addang[1],-80,80)
				ent.addang[2] = math.Clamp(ent.addang[2],-80,80)
				ent.addang[3] = math.Clamp(ent.addang[3],-80,80)
				ent.rememberedang[1] = math.Clamp(ent.rememberedang[1],ply:EyeAngles()[1] - 40,ply:EyeAngles()[1] + 40)
				ent.rememberedang[2] = math.Clamp(ent.rememberedang[2],ply:EyeAngles()[2] - 40,ply:EyeAngles()[2] + 40)
				ent.rememberedang[3] = math.Clamp(ent.rememberedang[3],ply:EyeAngles()[3] - 40,ply:EyeAngles()[3] + 40)
			else
				ent.oldaddang = ent.addang or Angle(0,0,0)
				ent.rememberedang = ply:EyeAngles()
			end

			local TargetPos = phys:GetPos()
			
			if ent:IsRagdoll() then
				TargetPos = LocalToWorld(pos, angle_zero, phys:GetPos(), phys:GetAngles())
			else
				TargetPos = ent:LocalToWorld(pos)
			end

			local target,_ = LocalToWorld(target,angle_zero,ply:EyePos(),(ent.rememberedang or ply:EyeAngles()) - (not ply:KeyDown(IN_USE) and ent.addang or ent.oldaddang or angle_zero))
			local vec = target - TargetPos
			local len, mul = vec:Length(), phys:GetMass()
			
			vec:Normalize()
	
			if (ply.organism and ply.organism.superfighter) then
				mul = mul * 5
			end
			
			local avec = vec * len * 3 - phys:GetVelocity()
			
			local Force = avec * mul
			local ForceMagnitude = math.min(Force:Length(), 2000)
			
			phys:Wake()

			if len > 12000 then
				hg.SetCarryEnt2(ply)
				heldents[i] = nil
			end

			Force = Force:GetNormalized() * ForceMagnitude
			
			--ply:SetLocalVelocity(ply:GetVelocity() - (avec - velo / 2))

			local ang = (ent.rememberedang or ply:EyeAngles()) - (ent.oldaddang or angle_zero)
			ang[3] = 0
			local _,huy = WorldToLocal(vector_origin,phys:GetAngles(),vector_origin,ang)
			local _,needed_ang = WorldToLocal(vector_origin,lang,vector_origin,huy)
			
			local vec = Vector(0,0,0)
			vec[3] = needed_ang[2]
			vec[1] = needed_ang[3]
			vec[2] = needed_ang[1]
			
			if tbl[6] then
				phys:ApplyForceOffset(Force, TargetPos)
			else
				phys:ApplyForceCenter(Force)
			end

			phys:ApplyForceCenter(Vector(0, 0, mul))
			local m2 = 1 / phys:GetMass() * math.min(phys:GetMass(), 5)
			phys:AddAngleVelocity(-phys:GetAngleVelocity() * m2 + vec / 1 * (ent:IsRagdoll() and 1 or 1) * m2)
		end
	end)
	

end

if SERVER then
	hook.Add( "StartCommand", "tuda-suda-hahaha", function( ply, cmd )
		local whl = cmd:GetMouseWheel()
		if ( whl != 0 ) then
			if IsValid(ply:GetNetVar("carryent2")) then
				local ent = ply:GetNetVar("carryent2")
				local target = heldents[ent:EntIndex()][4]
				local targetLen = target:LengthSqr()
				
				if (targetLen > 40*40 and whl > 0) or (targetLen < 10 * 10 and whl < 0) then return end
				heldents[ent:EntIndex()][4] = target + target:Angle():Forward() * whl
			end
		end
	end )
end

function SWEP:DoBFSAnimation(anim,time)
	if CLIENT and IsValid(self:GetWM()) then
		self:GetWM():SetSequence(anim)
		self.animtime = CurTime() + time
	end
	if SERVER then
		net.Start("play_anim")
		net.WriteEntity(self)
		net.WriteString(anim)
		net.WriteFloat(time)
		net.SendPVS(self:GetOwner():GetPos())
	end
end

if CLIENT then
	net.Receive("play_anim",function()
		local self = net.ReadEntity()
		local anim = net.ReadString()
		if not IsValid(self) then return end
		if self.IsLocal and not self:IsLocal() then
			if not self.DoBFSAnimation then return end
		self:DoBFSAnimation(anim,net.ReadFloat())
		if anim == "Attack_Quick2" or anim == "Attack_Quick" or anim == "Attack_Charge_Begin" or anim == "Attack_Charge_End" or anim == "Shove" then
			self:GetOwner():AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD,self:GetOwner():LookupSequence((anim == "Attack_Quick" or anim == "Attack_Charge_Begin" or anim == "Attack_Charge_End" or anim == "Shove") and "range_fists_r" or "range_fists_l"),0,true)
		end
		end
	end)
else
	util.AddNetworkString("play_anim")
end

function SWEP:UpdateNextIdle()
	self:SetNextIdle(CurTime() + 0.5)
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer() or hg.RagdollOwner(ent) or ent:IsRagdoll()
end

hook.Add("ShouldCollide","CustomCollisions",function(ent1,ent2)
	if ent2:IsPlayer() and ent1:IsRagdoll() then
		if (IsValid(ent2:GetNetVar("carryent")) and ent2:GetNetVar("carryent") == ent1) or (IsValid(ent2:GetNetVar("carryent2")) and ent2:GetNetVar("carryent2") == ent1) then
			return false
		end
    end
end)

-- Progressive stamina system for blocking
function SWEP:HandleBlockStamina(attacker, damage)
	if not SERVER then return end
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner.organism then return end
	
	local currentTime = CurTime()
	local lastBlockTime = self:GetLastBlockTime()
	local blockCounter = self:GetBlockCounter()
	
	-- Reset counter if more than 3 seconds since last block
	if currentTime - lastBlockTime > 3 then
		blockCounter = 0
	end
	
	-- Increment block counter
	blockCounter = blockCounter + 1
	self:SetBlockCounter(blockCounter)
	self:SetLastBlockTime(currentTime)
	
	-- Calculate progressive stamina cost
	local baseStaminaCost = self.ParryStaminaCost or 6
	local progressiveMultiplier = 1 + (blockCounter - 1) * 0.4  -- 40% increase per consecutive block
	local finalStaminaCost = baseStaminaCost * progressiveMultiplier
	
	-- Apply stamina cost
	owner.organism.stamina.subadd = owner.organism.stamina.subadd + finalStaminaCost
	
	-- Optional: Add feedback for high block counts
	if blockCounter >= 3 then
		-- Heavy breathing effect or screen shake could be added here
		owner:EmitSound("player/pl_pain" .. math.random(5,7) .. ".wav", 50, math.random(90, 110))
	end
end

function SWEP:Animation()
	local owner = self:GetOwner()

	if IsValid(owner.FakeRagdoll) then return end

	if owner:GetNetVar("handcuffed",false) then
	end

	if SERVER then
		if not self:GetBlocking() and self:GetFists() then
		end
	end

	if CLIENT and LocalPlayer() != self:GetOwner() then return end
	if SERVER then return end
	if CLIENT and GetViewEntity() != LocalPlayer() then return end
end

function SWEP:Holster( wep )
	if not IsFirstTimePredicted() then return true end
	local owner = self:GetOwner()

	if owner:GetNetVar("handcuffed",false) then return false end
	return true
end

-- Advanced Directional Hitbox Blocking System Functions for Hands
function SWEP:CalculateBlockingHitbox(player)
    if not IsValid(player) then return nil end
    
    local eyePos = player:EyePos()
    local eyeAngles = player:EyeAngles()
    local forward = eyeAngles:Forward()
    local right = eyeAngles:Right()
    local up = eyeAngles:Up()
    
    -- Calculate hitbox center position with weapon-specific offset
    local hitboxCenter = eyePos + forward * self.BlockHitboxOffset.x + right * self.BlockHitboxOffset.y + up * self.BlockHitboxOffset.z
    
    -- Account for blocking stance - adjust position based on weapon blocking position
    if self:GetBlocking() and self.lerpedBlockPos then
        local blockProgress = math.Clamp(1 - (self.lerpedBlockPos:Length() / ((self.BlockHoldPos or Vector()) - self.HoldPos):Length()), 0, 1)
        local stanceOffset = forward * (5 * blockProgress) + up * (-3 * blockProgress)
        hitboxCenter = hitboxCenter + stanceOffset
    end
    
    return {
        center = hitboxCenter,
        forward = forward,
        right = right,
        up = up,
        angles = eyeAngles
    }
end

function SWEP:IsAttackWithinBlockingHitbox(attackerPos, targetPlayer, weapon)
    if not IsValid(targetPlayer) or not IsValid(weapon) then return false end
    
    local hitbox = weapon:CalculateBlockingHitbox(targetPlayer)
    if not hitbox then return false end
    
    local attackVector = attackerPos - hitbox.center
    local attackDistance = attackVector:Length()
    
    -- Check distance bounds
    if attackDistance < weapon.BlockMinDistance or attackDistance > weapon.BlockMaxDistance then
        return false, "distance_out_of_range", attackDistance
    end
    
    attackVector:Normalize()
    
    -- Calculate horizontal angle (yaw) from forward direction
    local attackDirection2D = Vector(attackVector.x, attackVector.y, 0):GetNormalized()
    local forward2D = Vector(hitbox.forward.x, hitbox.forward.y, 0):GetNormalized()
    local horizontalDot = forward2D:Dot(attackDirection2D)
    local horizontalAngle = math.deg(math.acos(math.Clamp(horizontalDot, -1, 1)))
    
    -- Check if attack is within horizontal blocking arc
    local maxHorizontalAngle = weapon.BlockArcAngle / 2
    if horizontalAngle > maxHorizontalAngle then
        return false, "outside_horizontal_arc", horizontalAngle
    end
    
    -- Calculate vertical angle from eye level
    local verticalAngle = math.deg(math.asin(math.Clamp(attackVector.z, -1, 1)))
    local absVerticalAngle = math.abs(verticalAngle)
    
    -- Check if attack is within vertical blocking range
    if absVerticalAngle > weapon.BlockVerticalRange then
        return false, "outside_vertical_range", absVerticalAngle
    end
    
    -- Simplified precision check using multiple sample points (more forgiving)
    local precisionSamples = weapon.BlockPrecisionSamples or 8
    local validSamples = 0
    
    for i = 1, precisionSamples do
        local angle = (i - 1) * (360 / precisionSamples)
        local sampleOffset = Vector(
            math.cos(math.rad(angle)) * weapon.BlockHitboxWidth * 0.3,
            math.sin(math.rad(angle)) * weapon.BlockHitboxHeight * 0.3,
            math.sin(math.rad(angle * 2)) * weapon.BlockHitboxHeight * 0.2
        )
        
        local samplePos = hitbox.center + hitbox.right * sampleOffset.x + hitbox.up * sampleOffset.y + hitbox.forward * sampleOffset.z
        local sampleVector = (attackerPos - samplePos):GetNormalized()
        local sampleDot = hitbox.forward:Dot(sampleVector)
        
        if sampleDot > -0.1 then -- Much more forgiving sample point validation (was 0.2)
            validSamples = validSamples + 1
        end
    end
    
    local precisionRatio = validSamples / precisionSamples
    
    -- Require only 20% of sample points to be valid for blocking (was 40% - much more forgiving)
    if precisionRatio < 0.2 then
        return false, "insufficient_precision_coverage", precisionRatio
    end
    
    -- Calculate blocking effectiveness based on angle and distance (more forgiving)
    local horizontalEffectiveness = math.max(0.3, 1 - (horizontalAngle / maxHorizontalAngle)) -- Minimum 30% effectiveness
    local verticalEffectiveness = math.max(0.3, 1 - (absVerticalAngle / weapon.BlockVerticalRange)) -- Minimum 30% effectiveness
    local distanceEffectiveness = math.max(0.4, 1 - math.abs(attackDistance - weapon.BlockMinDistance) / (weapon.BlockMaxDistance - weapon.BlockMinDistance))
    local precisionEffectiveness = math.max(0.3, precisionRatio)
    
    local overallEffectiveness = (horizontalEffectiveness + verticalEffectiveness + distanceEffectiveness + precisionEffectiveness) / 4
    
    return true, "success", {
        horizontalAngle = horizontalAngle,
        verticalAngle = absVerticalAngle,
        distance = attackDistance,
        effectiveness = overallEffectiveness,
        precisionRatio = precisionRatio
    }
end

function SWEP:GetBlockingDebugInfo(attackerPos, targetPlayer)
    if not IsValid(targetPlayer) then return "Invalid target player" end
    
    local hitbox = self:CalculateBlockingHitbox(targetPlayer)
    if not hitbox then return "Failed to calculate hitbox" end
    
    local success, reason, data = self:IsAttackWithinBlockingHitbox(attackerPos, targetPlayer, self)
    
    local debugInfo = string.format(
        "Hitbox Center: %s | Attack Distance: %.1f | Reason: %s",
        tostring(hitbox.center),
        (attackerPos - hitbox.center):Length(),
        reason
    )
    
    if type(data) == "table" then
        debugInfo = debugInfo .. string.format(
            " | H-Angle: %.1f° | V-Angle: %.1f° | Effectiveness: %.2f | Precision: %.2f",
            data.horizontalAngle or 0,
            data.verticalAngle or 0,
            data.effectiveness or 0,
            data.precisionRatio or 0
        )
    elseif type(data) == "number" then
        debugInfo = debugInfo .. string.format(" | Value: %.2f", data)
    end
    
    return debugInfo
end

-- Hook for progressive stamina loss during blocking
if SERVER then
	hook.Add("EntityTakeDamage", "HandsProgressiveBlockStamina", function(target, dmginfo)
		if not IsValid(target) or not target:IsPlayer() then return end
		
		local activeWeapon = target:GetActiveWeapon()
		if not IsValid(activeWeapon) or activeWeapon:GetClass() ~= "weapon_hands_sh" then return end
		
		-- Check if blocking
		if not activeWeapon:GetBlocking() then return end
		
		-- Check if attack is from front (blocking only works from front)
		local attacker = dmginfo:GetAttacker()
		if not IsValid(attacker) or not attacker:IsPlayer() then return end
		
		local targetForward = target:GetAngles():Forward()
		local attackDirection = (attacker:GetPos() - target:GetPos()):GetNormalized()
		local dot = targetForward:Dot(attackDirection)
		
		if dot < 0.3 then return end -- Same threshold as blocking
		
		-- Apply progressive stamina cost
		activeWeapon:HandleBlockStamina(attacker, dmginfo:GetDamage())
	end)
	
	-- Ragdoll impact damage system
	hook.Add("PhysicsCollide", "RagdollImpactDamage", function(data, phys)
		local ent = data.HitEntity
		
		-- Check if this is a thrown ragdoll
		if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" or not ent.IsThrownRagdoll then return end
		
		-- Check if enough time has passed since throwing (prevent immediate damage)
		if not ent.ThrownTime or CurTime() - ent.ThrownTime < 0.2 then return end
		
		-- Get the ragdoll owner
		local ragdollOwner = RagdollOwner(ent)
		if not ragdollOwner or not ragdollOwner:IsValid() or not ragdollOwner:IsPlayer() then return end
		
		-- Check cooldown to prevent spam damage
		local ragdollID = ent:EntIndex()
		if RagdollImpactCooldowns[ragdollID] and CurTime() - RagdollImpactCooldowns[ragdollID] < 1.0 then return end
		
		-- Check what we hit
		local hitEnt = data.HitObject:GetEntity()
		local isValidTarget = false
		
		-- Check if we hit a prop or world geometry
		if IsValid(hitEnt) then
			local hitClass = hitEnt:GetClass()
			if hitClass == "prop_physics" or hitClass == "prop_physics_multiplayer" or hitClass == "worldspawn" then
				isValidTarget = true
			end
		else
			-- Hit world geometry
			isValidTarget = true
		end
		
		if not isValidTarget then return end
		
		-- Calculate damage based on impact speed
		local speed = data.OurOldVelocity:Length()
		if speed < 100 then return end -- Minimum speed threshold
		
		local damage = math.min(speed * 0.08, 45) -- Max 45 damage, scales with speed
		
		-- Apply damage to the ragdoll owner
		if ragdollOwner.organism then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(DMG_CLUB)
			dmginfo:SetDamage(damage)
			dmginfo:SetInflictor(ent)
			dmginfo:SetAttacker(ent) -- The ragdoll itself is the attacker
			
			-- Apply damage to random body part (simulating impact trauma)
			local bodyParts = {"head", "chest", "stomach", "larm", "rarm", "lleg", "rleg"}
			local randomPart = bodyParts[math.random(#bodyParts)]
			
			if hg.organism.input_list[randomPart] then
				hg.organism.input_list[randomPart](ragdollOwner.organism, 1, damage, dmginfo)
			end
			
			-- Play impact sound based on damage
			local soundFiles = {
				"physics/body/body_medium_impact_hard1.wav",
				"physics/body/body_medium_impact_hard2.wav",
				"physics/body/body_medium_impact_hard3.wav",
				"physics/body/body_medium_impact_hard4.wav",
				"physics/body/body_medium_impact_hard5.wav",
				"physics/body/body_medium_impact_hard6.wav"
			}
			local randomSound = soundFiles[math.random(1, #soundFiles)]
			local volume = math.Clamp(damage / 45, 0.3, 1.0) -- Scale volume based on damage
			sound.Play(randomSound, ent:GetPos(), 75, math.random(90, 110), volume)
			
			-- Set cooldown
			RagdollImpactCooldowns[ragdollID] = CurTime()
			
			-- Clear the thrown flag to prevent further damage from this throw
			ent.IsThrownRagdoll = false
			
			-- Optional: Print damage for debugging (remove in production)
			-- print(string.format("Ragdoll impact: %s took %.1f damage from hitting at %.1f speed", ragdollOwner:Name(), damage, speed))
		end
	end)
end