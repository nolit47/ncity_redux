if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Gravity Gun"
SWEP.Category = "ZCity Other"
SWEP.Instructions = ""
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true

SWEP.WorldModel = "models/mmod/weapons/w_physics.mdl"
SWEP.WorldModelReal = "models/mmod/weapons/c_physcannon.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "slam"

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

SWEP.supportTPIK = true

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.animtime = 0
SWEP.animspeed = 0
SWEP.cycling = false
SWEP.reverseanim = false

if CLIENT then
	--SWEP.WepSelectIcon = Material("vgui/hud/tfa_iw7_tactical_knife")
	--SWEP.IconOverride = "vgui/hud/tfa_iw7_tactical_knife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.sprint_ang = Angle(30,0,0)

SWEP.HoldPos = Vector(-10,-3,-3)
SWEP.HoldAng = Angle(-5,0,0)

SWEP.basebone = 1

SWEP.WorkWithFake = true

SWEP.modelscale = 1
SWEP.modelscale2 = 0.75

SWEP.AnimList = {
	["deploy"] = {"draw", 1, false},
    ["attack"] = {"fire", 1, false},
	["attack_alt"] = {"altfire", 1, false},
	["idle_hold"] = {"hold_idle", 1, true},
	["holster"] = {"fire", 1, false},
	["idle"] = {"idle", 1, true},
}
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
    self:PlayAnim("attack")
	self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
    self:PlayAnim("idle_hold")
	self:SetNextSecondaryFire(CurTime() + 0.8)
end