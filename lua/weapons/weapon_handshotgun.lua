SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Handmade Shotgun"
SWEP.Author = "N/A"
SWEP.Instructions = "An very unstable gun!"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/dayr/db_shotgun/w_db_shotgun.mdl"

SWEP.addSprayMul = 2
SWEP.ShellEject = false
SWEP.ScrappersSlot = "Primary"
SWEP.CustomShell = "12x70"
SWEP.weight = 3
SWEP.addweight = 4
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 1
SWEP.Primary.Spread = Vector(0.02, 0.02, 0.02)
SWEP.Primary.Force = 1
SWEP.Primary.Sound = {"weapons/tfa_ins2/doublebarrel_sawnoff/doublebarrelsawn_fire.wav", 80, 100, 75}
SWEP.Primary.Wait = 0.1
SWEP.OpenBolt = true
SWEP.LocalMuzzlePos = Vector(18.893,0.388,1.648)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Chocking = false 

SWEP.punchmul = 1
SWEP.punchspeed = 0.1

SWEP.NumBullet = 4
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 5
SWEP.ReloadSound = "weapons/tfa_ins2/doublebarrel/shellinsert1.wav"
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "pistol"
SWEP.ZoomPos = Vector(-26, 0.3401, 2.2773)
SWEP.RHandPos = Vector(-15, -2, 4)
SWEP.LHandPos = false 
SWEP.SprayRand = {Angle(-0.5, -0.2, 0), Angle(-1, 0.2, 0)}
SWEP.Ergonomics = 0.95
SWEP.Penetration = 1
SWEP.WorldPos = Vector(9, -1, -3.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.lengthSub = 15
SWEP.DistSound = "toz_shotgun/toz_dist.wav"

SWEP.IsPistol = false
SWEP.podkid = 2
SWEP.animposmul = 1
SWEP.ReloadTime = 4

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.5)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(-25,10,25)
local finger2 = Angle(0,25,0)
local finger3 = Angle(31,1,-25)
local finger4 = Angle(-10,-5,-5)
local finger5 = Angle(0,-65,-15)
local finger6 = Angle(2,-2,-22)

local vector_zero = Vector(0,0,0)

if CLIENT then
	function SWEP:ReloadStart()
		if not self or not IsValid(self:GetOwner()) then return end
		hook.Run("HGReloading", self)
		self:SetHold(self.ReloadHold or self.HoldType)
		--self:GetOwner():SetAnimation(PLAYER_RELOAD)
		if self.ReloadSound then self:GetOwner():EmitSound(self.ReloadSound, 55, 100, 0.8, CHAN_AUTO) end
	end
end

function SWEP:PrimaryShootPost()
	local att = self:GetMuzzleAtt(gun, true)
	local eff = EffectData()
	eff:SetOrigin(att.Pos + att.Ang:Up() * -4 + att.Ang:Forward() * -1)
	eff:SetNormal(att.Ang:Forward())
	eff:SetScale(1)
	util.Effect("eff_jack_rockettrust", eff)
end

function SWEP:AnimHoldPost()
	--self:BoneSet("r_finger0", vector_zero, finger6)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
	--self:BoneSet("l_finger1", vector_zero, finger3)
	--self:BoneSet("r_finger1", vector_zero, finger4)
	--self:BoneSet("r_finger11", vector_zero, finger5)
end

SWEP.ShootAnimMul = 7

local vector_one = Vector(1,1,1)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4,self.shooanim or 0,self:Clip1() > 0 and 0 or 3)
		wep:ManipulateBonePosition(4,Vector(0 ,0 ,-1*self.shooanim ),false)
		wep:ManipulateBoneScale(2,self:Clip1() > 0 and vector_one or vector_zero)
	end
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(16,1,0),
	Vector(16,1,0),
	Vector(14,-2,0),
	Vector(12,-2,0),
	Vector(12,-2,0),
	Vector(11,-2,0),
	Vector(12,2,0),
	Vector(14,2,0),
	Vector(14,2,0),
	Vector(13,-2,0),
	Vector(12,-2,0),
	Vector(10,-2,0),
	Vector(8,-2,0),
	Vector(4,-1,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-25,60),
	Angle(0,-25,60),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,-25,90),
	Angle(0,-25,60),
	Angle(0,-25,60),
	Angle(0,0,0)
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,10,50),
	Angle(0,25,45),
	Angle(0,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
	Angle(0,25,45),
	Angle(0,25,45),
	Angle(5,25,45),
	Angle(3,25,45),
	Angle(0,0,0)
}

SWEP.InspectAnimLH = {
	Vector(0,0,0)
}
SWEP.InspectAnimLHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimRH = {
	Vector(0,0,0)
}
SWEP.InspectAnimRHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(6,0,5),
	Angle(15,0,14),
	Angle(16,0,16),
	Angle(4,0,12),
	Angle(-6,0,-2),
	Angle(-15,7,-15),
	Angle(-16,18,-35),
	Angle(-17,17,-42),
	Angle(-18,16,-44),
	Angle(-14,10,-46),
	Angle(-2,2,-4),
	Angle(0,0,0)
}
