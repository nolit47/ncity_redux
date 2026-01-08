if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Antirad"
SWEP.Instructions = "Anti-radiation drugs. Can be used to relieve radiation symptoms. RMB to use on someone else."
SWEP.Category = "Z-City TPIK Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/sweps/stalker2/antirad/w_item_antirad.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/stalker2/antirad/v_item_antirad.mdl"
SWEP.WorldModelExchange = false
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_painpills")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_painpills.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.modeNames = {
	[1] = "antirad"
}

function SWEP:Initialize()
    self:SetHold(self.HoldType)
    self.modeValues = {
        [1] = 1  -- 5 uses like painkillers
    }
    self.modeValuesdef = {
        [1] = 5,
    }
 
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldAng = Angle(0,0,0)
SWEP.AnimList = {
    ["deploy"] = { "anim_draw", 1, false },
    ["attack"] = { "use", 5, false, false, function(self)
		if CLIENT then return end
		self:Heal(self:GetOwner())
	end },
	["idle"] = {"anim_idle", 5, true}
}

SWEP.HoldPos = Vector(1,0,-1)

SWEP.CallbackTimeAdjust = 1.8

SWEP.showstats = false

SWEP.DeploySnd = "snd_jack_hmcd_pillsbounce.wav"
SWEP.FallSnd = "snd_jack_hmcd_pillsbounce.wav"

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()

end

if SERVER then

	function SWEP:PrimaryAttack()
		self:PlayAnim("attack")
	end

	local rndsounds = {"snd_jack_hmcd_pillsuse.wav"}
	function SWEP:Heal(ent, mode)
		if not self.modeValues then return end
		
		local org = ent.organism
		if not org then return end
		if ent ~= self:GetOwner() and not ent.organism.otrub then return end
		
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound(table.Random(rndsounds), 60, math.random(95, 105))
		
		local injected = math.min(FrameTime() * 10, self.modeValues[1])
		org.analgesiaAdd = math.min(org.analgesiaAdd + injected, 4)
		self.modeValues[1] = math.max(self.modeValues[1] - FrameTime() * 2, 0)

		owner.injectedinto = owner.injectedinto or {}
		owner.injectedinto[org.owner] = owner.injectedinto[org.owner] or 0
		owner.injectedinto[org.owner] = owner.injectedinto[org.owner] + injected

		if owner.injectedinto[org.owner] > 1 and injected > 0 then
			local dmgInfo = DamageInfo()
			dmgInfo:SetAttacker(owner)
			hook.Run("HomigradDamage", org.owner, dmgInfo, HITGROUP_RIGHTARM, hg.GetCurrentCharacter(org.owner), injected * 100)
		end

		if self.poisoned2 then
			org.poison4 = CurTime()
			self.poisoned2 = nil
		end

	
		if self.modeValues[1] <= 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
		
		return true
	end
end