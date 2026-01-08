if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Morphine"
SWEP.Instructions = [[Gives Endurance 305s, 15%
Gives Hindered 120s, -30u
Cures Concussion
Cures Dark Vision

Homigrad: Strong painkiller, reduces pain and disorientation]]
SWEP.Category = "Z-City TPIK Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/sweps/eft/injector/w_meds_injector.mdl"
SWEP.WorldModelReal = "models/weapons/sweps/eft/injector/v_meds_injector.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/vgui_morphine")
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.WMSkin = 1  -- Skin для морфина

SWEP.modeNames = {
	[1] = "morphine"
}

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
	self.modeValuesdef = {
		[1] = 1,
	}
	
	local FilePathSEF = "lua/SEF/SEF_Functions.lua"
	self.INI_SEF = file.Exists(FilePathSEF, "GAME")
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.AnimList = {
	["deploy"] = { "idle", 1, false },
	["attack"] = { "use", 5, false, false, function(self)
		if CLIENT then return end
		timer.Simple(2, function()
			if IsValid(self) and IsValid(self:GetOwner()) then
				self:Heal(self:GetOwner())
			end
		end)
	end },
	["idle"] = { "idle", 5, true }
}

SWEP.HoldPos = Vector(2, 0, -1)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.CallbackTimeAdjust = 0
SWEP.showstats = false

SWEP.DeploySnd = "weapons/eft/injector/item_injector_00_draw.wav"
SWEP.FallSnd = ""

-- Звуки анимации
SWEP.AnimsSounds = {
	["use"] = {
		[0] = function(self) self:EmitSound("weapons/eft/injector/item_injector_01_kolpachok.wav", 70) end,
		[0.5] = function(self) self:EmitSound("weapons/eft/injector/item_injector_02_injection.wav", 70) end,
		[0.9] = function(self) self:EmitSound("weapons/eft/injector/item_injector_03_putaway.wav", 70) end
	}
}

if SERVER then
	function SWEP:PrimaryAttack()
		if not self.modeValues or self.modeValues[1] <= 0 then return end
		
		self:PlayAnim("attack")
		self:SetNextPrimaryFire(CurTime() + 5)
	end

	function SWEP:Heal(ent)
		if not self.modeValues then return end
		if self.modeValues[1] <= 0 then return end
		
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		
		local org = ent.organism
		if not org then return end
		
		-- Применение эффектов
		if self.INI_SEF then
			if ent.ApplyEffect then
				ent:ApplyEffect("Endurance", 305, 15)
				ent:ApplyEffect("Hindered", 120, -30)
				ent:RemoveEffect("Concussion")
				ent:RemoveEffect("DarkVision")
			end
		else
			-- Homigrad organism логика
			if org then
				-- Сильное обезболивание
				org.analgesiaAdd = math.min((org.analgesiaAdd or 0) + 3, 5)
				org.painkiller = math.max((org.painkiller or 0), 300)
				
				-- Убираем дезориентацию и контузию
				if org.disorientation then
					org.disorientation = 0
				end
				if org.concussion then
					org.concussion = 0
				end
				
				-- Замедление движения
				org.slowdown = CurTime() + 120
			end
		end
		
		-- Звук использования уже проигрывается через AnimsSounds
		
		self.modeValues[1] = self.modeValues[1] - 1
		
		if self.modeValues[1] <= 0 then
			timer.Simple(0.5, function()
				if IsValid(owner) then
					owner:SelectWeapon("weapon_hands_sh")
				end
				if IsValid(self) then
					self:Remove()
				end
			end)
		end
		
		return true
	end
end
