if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Adrenaline"
SWEP.Instructions = [[Heals 15HP over 15s
Gives Haste 65s
Gives Vulnerability 60s

Homigrad: Boosts stamina and speed, heals blood]]
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
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/vgui_eftadrenaline")
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.WMSkin = 0  -- Skin для адреналина

SWEP.modeNames = {
	[1] = "adrenaline"
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

SWEP.CallbackTimeAdjust = 1.
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
				ent:SetHealth(math.min(ent:Health() + 15, ent:GetMaxHealth()))
				ent:ApplyEffect("Haste", 65)
				ent:ApplyEffect("Vulnerability", 60)
			end
		else
			-- Homigrad organism логика
			if org then
				-- Восстановление крови
				org.bloodAdd = math.min((org.bloodAdd or 0) + 500, 1000)
				
				-- Увеличение адреналина и выносливости
				org.adrenalineAdd = math.min((org.adrenalineAdd or 0) + 0.8, 1)
				org.stamina.subadd = math.max((org.stamina.subadd or 0) - 80, -100)
				
				-- Временное ускорение
				org.speedboost = CurTime() + 65
				
				-- Уязвимость (больше урона)
				org.vulnerable = CurTime() + 60
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
