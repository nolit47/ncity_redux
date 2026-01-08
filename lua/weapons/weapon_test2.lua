if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Combat Dagger"
SWEP.Instructions = "A sharp double-edged combat dagger. Perfect for quick stabs and slashes. Can cause severe bleeding.\n\nLMB to attack.\nR + LMB to change attack mode (stab/slash).\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "knife"

SWEP.WorldModel = "models/hatedmekkr/boneworks/weapons/melee/blades/daggers/bw_wpn_dgr_dagger.mdl"
SWEP.WorldModelReal = "models/weapons/gleb/c_knife_t.mdl"
SWEP.WorldModelExchange = "models/hatedmekkr/boneworks/weapons/melee/blades/daggers/bw_wpn_dgr_dagger.mdl"

SWEP.BleedMultiplier = 1.5
SWEP.PainMultiplier = 1.8

SWEP.BreakBoneMul = 0.5
SWEP.ImmobilizationMul = 0.45
SWEP.StaminaMul = 0.5
SWEP.HadBackBonus = true

SWEP.attack_ang = Angle(0,0,0)

SWEP.HoldPos = Vector(-2,-5,-5)
SWEP.HoldAng = Angle(-15,20,-10)
SWEP.weaponAng = Angle(90,180,0)
SWEP.basebone = 76
SWEP.weaponPos = Vector(-1,0,0)
SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab_miss",
    ["attack2"] = "midslash1",
}
SWEP.AttackTime = 0.5
SWEP.AnimTime1 = 0.9
SWEP.WaitTime1 = 0.55

SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.4

SWEP.AttackPos = Vector(0,0,0)
SWEP.AttackingPos = Vector(0,0,0)

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_knife")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_knife.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true

SWEP.NoHolster = false

SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 4

function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self.Initialzed = true
    self:PlayAnim("idle",10,true)

    self:SetHold(self.HoldType)

    self:InitAdd()
end

function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -4 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 15 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -7 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 60 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 90 or 0)
	addAngLerp.x = addAngLerp.x + (self:GetBlocking() and -60 or 0)
    
    return true
end

function SWEP:CanSecondaryAttack()
    return self.allowsec and true or false
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 35
SWEP.AttackRads2 = 65

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true