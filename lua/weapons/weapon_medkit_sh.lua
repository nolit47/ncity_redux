if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"

local function GetLang()
	return GetConVar("gmod_language"):GetString() == "ru" and "ru" or "en"
end

local Localization = {
	en = {
		printname = "Medkit",
		instructions = "A small bag containing medical supplies. Has bandages, painkillers, tourniquets and internal bleeding medicine. A necessary thing in hiking, military conditions and just a necessary thing in everyday life. RMB to apply on others, R to change use mode.",
		category = "Medicine",
		switch_hint = "Press R to switch Medicine",
		modes = {
			[1] = "bandaging",
			[2] = "painkiller",
			[3] = "tranexamic acid",
			[4] = "tourniquet",
			[5] = "decompression needle",
		}
	},
	ru = {
		printname = "Аптечка",
		instructions = "Небольшая сумка с медицинскими принадлежностями. Содержит бинты, обезболивающие, жгуты и лекарство от внутреннего кровотечения. Необходимая вещь в походах, военных условиях и просто в повседневной жизни. ПКМ для применения на других, R для смены режима использования.",
		category = "Медицина",
		switch_hint = "Нажмите R для смены лекарства",
		modes = {
			[1] = "бинтование",
			[2] = "обезболивающее",
			[3] = "транексамовая кислота",
			[4] = "жгут",
			[5] = "декомпрессионная игла",
		}
	}
}

SWEP.PrintName = "Medkit"
SWEP.Instructions = "A small bag containing medical supplies. Has bandages, painkillers, tourniquets and internal bleeding medicine. A necessary thing in hiking, military conditions and just a necessary thing in everyday life. RMB to apply on others, R to change use mode."
SWEP.Category = "Medicine"

SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_medkit")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_medkit.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -0.5, -3)
SWEP.offsetAng = Angle(-30, 20, 90)
SWEP.modes = 5
SWEP.modeNames = {}
SWEP.ofsV = Vector(-2,-10,8)
SWEP.ofsA = Angle(90,-90,90)

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 80,
		[2] = 1,
		[3] = 10,
		[4] = 1,
		[5] = 1,
	}
	local lang = GetLang()
	self.modeNames = {
		[1] = Localization[lang].modes[1],
		[2] = Localization[lang].modes[2],
		[3] = Localization[lang].modes[3],
		[4] = Localization[lang].modes[4],
		[5] = Localization[lang].modes[5],
	}
end

SWEP.modeValuesdef = {
	[1] = {80,true},
	[2] = {1,false},
	[3] = {10,true},
	[4] = {1,true},
	[5] = {1,false},
}
SWEP.ShouldDeleteOnFullUse = true

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 5, -30 + hold / 2 + 20 * aimvec[3], 5 - hold / 4))
    self:BoneSet("r_forearm", vector_origin, Angle(hold / 25, -hold / 2.5, 35 -hold / 1.4))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

if CLIENT then
	function SWEP:DrawHUD()s
		if self.BaseClass and self.BaseClass.DrawHUD then
			self.BaseClass.DrawHUD(self)
		end
		
		local lang = GetLang()
		local hint = Localization[lang].switch_hint
		
		draw.SimpleText(hint, "DermaDefault", ScrW() / 2, 50, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

if SERVER then
	function SWEP:Heal(ent, mode, bone)
		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		if self.mode == 2 then
			if self.modeValues[2] == 0 then return end
			if ent ~= owner and not org.otrub then return end
			--org.painkiller = math.min(org.painkiller + self.modeValues[2], 3)
			--self.modeValues[2] = 0
			org.analgesiaAdd = math.min(org.analgesiaAdd + self.modeValues[2] * 0.3, 4)
			self.modeValues[2] = 0
			entOwner:EmitSound("snds_jack_gmod/ez_medical/15.wav", 60, math.random(95, 105))
		elseif self.mode == 3 then
			if self.modeValues[3] == 0 then return end
			--[[local val = org.lungsL[1]
			local healed = math.max(val - self.modeValues[3], 0)
			self.modeValues[3] = self.modeValues[3] - (val - healed)
			org.lungsL[1] = healed
			local val = org.lungsR[1]
			local healed = math.max(val - self.modeValues[3], 0)
			self.modeValues[3] = self.modeValues[3] - (val - healed)
			org.lungsR[1] = healed]]
			local internalBleed = org.internalBleed - org.internalBleedHeal
			
			if self.poisoned2 then
				org.poison4 = CurTime()

				self.poisoned2 = nil
			end

			if internalBleed > 0 then
				local healed = math.max(internalBleed - self.modeValues[3], 0)
				self.modeValues[3] = self.modeValues[3] - (internalBleed - healed) * (owner.Profession == "doctor" and 0.5 or 1)
				org.internalBleedHeal = org.internalBleedHeal + (internalBleed - healed)
				entOwner:EmitSound("snds_jack_gmod/ez_medical/" .. math.random(16, 18) .. ".wav", 60, math.random(95, 105))
			end
		elseif self.mode == 1 then
			self:Bandage(ent, bone)
		elseif self.mode == 4 then
			if self:Tourniquet(ent, bone) then self.modeValues[4] = 0 end
		elseif self.mode == 5 then
			if ((org.lungsL[2] + org.lungsR[2]) / 2 >= 0.5) and not org.needle then
				if self.poisoned2 then
					org.poison4 = CurTime()
	
					self.poisoned2 = nil
				end

				org.lungsR[2] = 0
				org.lungsL[2] = 0
				org.needle = true
				self.modeValues[5] = 0
				entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
			end
		end

		if self.modeValues[1] == 0 and self.modeValues[2] == 0 and self.modeValues[3] == 0 and self.modeValues[4] == 0 and self.modeValues[5] == 0 and self.ShouldDeleteOnFullUse then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end