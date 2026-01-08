if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Knife"
SWEP.Instructions = "A sharp kitchen knife. Simple and reliable.\n\nLMB to attack.\nR + LMB to change attack mode (stab/slash).\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "knife"

SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.WorldModelReal = "models/weapons/salat/reanim/c_s&wch0014.mdl"
SWEP.WorldModelExchange = "models/weapons/w_knife_t.mdl"

SWEP.BleedMultiplier = 1.5
SWEP.PainMultiplier = 1.8

SWEP.BreakBoneMul = 0.5
SWEP.ImmobilizationMul = 0.45
SWEP.StaminaMul = 0.5
SWEP.HadBackBonus = true

SWEP.attack_ang = Angle(0,0,0)

SWEP.HoldPos = Vector(-4,0,-1)
SWEP.HoldAng = Angle(0,0,0)
SWEP.weaponPos = Vector(0,-4,-0.3)
SWEP.weaponAng = Angle(160,180,99)
SWEP.basebone = 39
SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "stab",
    ["attack2"] = "midslash1",
    ["duct_cut"] = "cut",
    ["inspect"] = "inspect"
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

SWEP.DamagePrimary = 10
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
    local check = self:GetBlocking() and self:GetWM():GetSequenceName(self:GetWM():GetSequence()) != "cut"
    addPosLerp.z = addPosLerp.z + (check and 2 or 0)
    addPosLerp.x = addPosLerp.x + (check and 0 or 0)
    addPosLerp.y = addPosLerp.y + (check and 3 or 0)
    addAngLerp.r = addAngLerp.r + (check and -15 or 0)
    addAngLerp.y = addAngLerp.y + (check and 8 or 0)
    
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