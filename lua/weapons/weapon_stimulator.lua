if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Стимулятор"
SWEP.Instructions = "Стимулятор: Позволяет бегать человеку без отдышки в 2.5 раза дольше на 5 минут. ПКМ для инъекции в кого-то другого."
SWEP.Category = "Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/weapons/w_models/w_jyringe_jroj.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_adrenaline")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_adrenaline.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(5, -1.5, -2.5)
SWEP.offsetAng = Angle(90, 00, -90)
SWEP.modeNames = {
	[1] = "stimulator"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

SWEP.showstats = false

function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, (-55*hold/65) + hold / 2, 0))
    self:BoneSet("r_forearm", vector_origin, Angle(-hold / 6, -hold / 0.8, (-20*hold/100)))
end

if SERVER then
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))

		-- Stamina regen boost: 2.5x for 5 minutes (300 seconds)
		local timerName = "stamina_regen_boost_" .. ent:EntIndex()
		timer.Remove(timerName)
		org.stamina.regen = 2.5
		timer.Simple(300, function()
			if IsValid(ent) and ent.organism then
				ent.organism.stamina.regen = 1
			end
		end)

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()
	end
end