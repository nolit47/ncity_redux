if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Панацея"
SWEP.Instructions = "Лишь одна таблетка и все твои органы,кости,тело будет как новенькое!"
SWEP.Category = "Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bloocobalt/l4d/items/w_eq_pills.mdl"
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
SWEP.offsetVec = Vector(2.5, -2.5, 0)
SWEP.offsetAng = Angle(-30, 20, 180)
SWEP.modeNames = {
	[1] = "painkiller"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.showstats = false

SWEP.DeploySnd = "snd_jack_hmcd_pillsbounce.wav"
SWEP.FallSnd = "snd_jack_hmcd_pillsbounce.wav"

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -10 -hold / 2, 10))
    self:BoneSet("r_forearm", vector_origin, Angle(-5, -hold / 2.5, -hold / 1.5))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

if SERVER then
	local rndsounds = {"snd_jack_hmcd_pillsuse.wav"}
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		if ent ~= self:GetOwner() and not ent.organism.otrub then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound(table.Random(rndsounds), 60, math.random(95, 105))
		--org.adrenaline = math.min(org.adrenaline + self.modeValues[1] / 4, 3)
		//org.painkiller = math.min(org.painkiller + self.modeValues[1] * 1, 3)
		org.analgesiaAdd = math.min(org.analgesiaAdd + self.modeValues[1] * 0.3, 4)

		-- Полное восстановление организма (панацея)
		-- Кровь и кровотечение
		org.blood = 5000
		org.bleed = 0
		org.internalBleed = 0
		org.internalBleedHeal = 0
		org.arteria = 0
		org.rarmartery = 0
		org.larmartery = 0
		org.rlegartery = 0
		org.llegartery = 0
		org.spineartery = 0
		org.bleedStart = 0
		org.wounds = {}
		org.arterialwounds = {}
		org.wantToVomit = 0
		org.hemotransfusionshock = 0
		org.survivalchance = 1

		-- Легкие и дыхание
		org.lungsL = {0, 0}
		org.lungsR = {0, 0}
		org.trachea = 0
		org.pneumothorax = 0
		org.needle = false
		org.nextCough = nil
		org.o2 = {range = 30, regen = 4, k = 0.5, curregen = 4, [1] = 30}
		org.lungsfunction = true
		org.CO = 0
		org.COregen = 0
		org.mannitol = 0

		-- Сердце и пульс
		org.heart = 0
		org.heartstop = false
		org.pulse = 70
		org.bpressure = 1
		org.pulseStart = 0

		-- Боль и шок
		org.shock = 0
		org.pain = 0
		org.avgpain = 0
		org.painadd = 0
		org.hurt = 0
		org.hurtadd = 0
		org.painkiller = 0
		org.analgesia = 0
		org.analgesiaAdd = 0
		org.naloxone = 0
		org.naloxoneadd = 0
		org.immobilization = 0
		org.paincritical = 60
		org.painlessen = 0
		org.tranquilizer = 0
		org.stun = 0
		org.lightstun = 0

		-- Выносливость и адреналин
		org.adrenaline = 0
		org.adrenalineAdd = 0
		org.stamina = {range = 60 * 3, regen = 1, sub = 0, subadd = 0, weight = 0, max = 60 * 3, [1] = 60 * 3}
		org.energy = 0
		org.moveMaxSpeed = IsValid(owner) and owner:IsPlayer() and owner:GetMaxSpeed() or 250

		-- Метаболизм и голод
		org.satiety = 100
		org.hungry = 0
		org.hungryDmgCd = 0

		-- Печень и токсины
		org.liver = {0, 0.5}
		org.toxic = {natural = {0, 10, 0.5}}

		-- Кости и конечности
		org.lleg = 0
		org.rleg = 0
		org.larm = 0
		org.rarm = 0
		org.skull = 0
		org.brain = 0
		org.spine2 = 0
		org.spine3 = 0
		org.chest = 0
		org.stomach = 0
		org.intestines = 0
		org.pelvis = 0

		-- Вирус (если присутствует)
		if ent.Virus then
			ent.Virus = nil
		end

		-- Дополнительные состояния
		org.alive = true
		org.otrub = false
		org.needotrub = false
		org.needfake = false
		org.incapacitated = false
		org.critical = false
		org.fear = 0
		org.fearadd = 0
		org.disorientation = 0
		org.consciousness = 1
		org.regeneratehp = 0

		-- Восстановление здоровья игрока
		ent:SetHealth(ent:GetMaxHealth())

		self.modeValues[1] = 0
		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
		
		return true
	end
end