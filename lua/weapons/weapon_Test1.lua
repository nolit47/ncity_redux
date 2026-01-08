if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Norse Battle Axe"
SWEP.Instructions = "A heavy two-handed battle axe of Nordic design. Designed for combat, this weapon can cleave through armor and break down doors with devastating force.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Weight = 0

SWEP.HoldType = "pistol"

SWEP.WorldModel = "models/hatedmekkr/boneworks/weapons/melee/blades/axes/bw_wpn_ax_norse.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_bat_metal.mdl"
SWEP.WorldModelExchange = "models/hatedmekkr/boneworks/weapons/melee/blades/axes/bw_wpn_ax_norse.mdl"


SWEP.HoldPos = Vector(-9,0,0)
SWEP.HoldAng = Angle(0,0,-20)
SWEP.weaponAng = Angle(10,-90,80)
SWEP.basebone = 94
SWEP.weaponPos = Vector(3,-0.1,-1)
SWEP.AttackTime = 0.5
SWEP.AnimTime1 = 2
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1,1,-1)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
}

SWEP.AttackPos = Vector(0,0,0)

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_axe")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_axe"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true

SWEP.NoHolster = true

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 65
SWEP.DamageSecondary = 14

SWEP.PenetrationPrimary = 10
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 10

SWEP.PenetrationSizePrimary = 5.5
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 45
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 75
SWEP.AttackLen2 = 40

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanSecondaryAttack()
    --[[self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"--]]
    return false
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(7) > 3 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end
end

SWEP.MinSensivity = 0.7

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBaseBone = "base"
SWEP.ViewPunchDiv = 50

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 75
SWEP.AttackRads2 = 0

SWEP.SwingAng = -20
SWEP.SwingAng2 = 0