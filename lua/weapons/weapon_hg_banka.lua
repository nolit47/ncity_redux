if not file.Exists("autorun/ba2_shared.lua", "LUA") then return end -- furryian

if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Viral Sample"
SWEP.Instructions = "A dangerous biological weapon in a fragile glass jar. What could go wrong?...\n\nLMB to attack.\nR + LMB to change attack mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.WorldModel = "models/ba2/objects/ba2_virus_sample.mdl"
SWEP.WorldModelReal = "models/weapons/combatknife/tactical_knife_iw7_vm.mdl"
SWEP.WorldModelExchange = "models/ba2/objects/ba2_virus_sample.mdl"

SWEP.weaponPos = Vector(0,0.3,-1)
SWEP.weaponAng = Angle(0,-90,90)

SWEP.BreakBoneMul = 0.18

SWEP.AnimList = {
    ["idle"] = "vm_knifeonly_idle",
    ["deploy"] = "vm_knifeonly_raise",
    ["attack"] = "vm_knifeonly_stab",
    ["attack2"] = "vm_knifeonly_swipe",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_pepperspray")
	SWEP.IconOverride = "entities/ba2_virus_sample.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true

SWEP.NoHolster = true

SWEP.AttackPos = Vector(0,0,0)
SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 1.4
SWEP.PenetrationSecondary = 1.15

SWEP.MaxPenLen = 4

SWEP.PainMultiplier = 0.75

SWEP.HoldPos = Vector()
SWEP.HoldAng = Angle()

SWEP.PenetrationSizePrimary = 1
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 7
SWEP.StaminaSecondary = 4

SWEP.AttackLen1 = 45
SWEP.AttackLen2 = 30

SWEP.AttackHit = "GlassBottle.ImpactHard"
SWEP.Attack2Hit = "GlassBottle.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "GlassBottle.ImpactSoft"

function SWEP:PrimaryAttackAdd(ent,trace)
    if SERVER and ent and math.random(1, 4) == 2 then
        local banka = ents.Create("ba2_virus_sample")
        banka:SetPos(trace.HitPos)
        banka:TakeDamage(10, self:GetOwner())
        self:GetOwner():EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
        self:Remove()
    end
end

function SWEP:SecondaryAttackAdd(ent,trace)
    if SERVER and ent and math.random(1, 4) == 2 then
        local banka = ents.Create("ba2_virus_sample")
        banka:SetPos(trace.HitPos)
        banka:TakeDamage(10, self:GetOwner())
        self:GetOwner():EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
        self:Remove()
    end
end

function SWEP:CustomAttack2()
    local ent = ents.Create("ent_throwable")
    ent.WorldModel = self.WorldModelExchange or self.WorldModel

    local ply = self:GetOwner()

    ent:SetPos(select(1, hg.eye(ply,60,hg.GetCurrentCharacter(ply))) - ply:GetAimVector() * 2)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent:Spawn()

    ent.localshit = Vector(0,0,0)
    ent.wep = self:GetClass()
    ent.owner = ply
    ent.damage = self.DamagePrimary * 0.7
    ent.MaxSpeed = 1200
    ent.DamageType = self.DamageType
    ent.AttackHit = "GlassBottle.ImpactHard"
    ent.AttackHitFlesh = "Flesh.ImpactHard"

    ent.func = function(data)
        if ent.removed then return end
        ent.removed = true
        timer.Simple(0, function()
			local banka = ents.Create("ba2_virus_sample")
			if IsValid(banka) then
				banka:SetPos(ent:GetPos())
				banka:TakeDamage(10, self:GetOwner())
			end
			self:GetOwner():EmitSound("physics/glass/glass_pottery_break"..math.random(1,4)..".wav")
			self:Remove()
        end)
    end

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocity(ply:GetAimVector() * ent.MaxSpeed)
        phys:AddAngleVelocity(VectorRand() * 500)
    end

    //ply:EmitSound("weapons/slam/throw.wav",50,math.random(95,105))
    ply:ViewPunch(self.ViewPunch1 * 0.6)
    ply:SelectWeapon("weapon_hands_sh")

    self:Remove()

    return true
end