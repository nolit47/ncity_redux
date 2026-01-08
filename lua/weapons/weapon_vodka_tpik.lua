if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Vodka"
SWEP.Instructions = "Strong vodka. Has negative effects on the body. RMB to use on someone else."
SWEP.Category = "Z-City TPIK Food"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/sweps/stalker2/vodka/w_item_vodka.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/stalker2/vodka/v_item_vodka.mdl"
SWEP.WorldModelExchange = false
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_fooddrink")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_fooddrink.png"
	SWEP.BounceWeaponIcon = false
end
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.modeNames = {
	[1] = "vodka"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
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

SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.CallbackTimeAdjust = 1.8

SWEP.showstats = false

SWEP.DeploySnd = "snd_jack_hmcd_foodbounce.wav"
SWEP.FallSnd = "snd_jack_hmcd_foodbounce.wav"

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	
end

if SERVER then

	function SWEP:PrimaryAttack()
		self:PlayAnim("attack")
	end

	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		if ent ~= self:GetOwner() and not ent.organism.otrub then return end
		
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		
		
		org.disorientation = org.disorientation + 10
		org.painadd = org.painadd + 5  
		entOwner:EmitSound("snd_jack_hmcd_drink"..math.random(3)..".wav", 60, math.random(95, 105))
		
		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()
		
		return true
	end
end