if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "L1 Norepinephrine"
SWEP.Instructions = [[Gives Tenacity 3s, 35%
Gives Exhausted 60s
Cures Dark Vision]]
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
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/hud/vgui_L1")
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.WMSkin = 4  -- Skin для модели

SWEP.modeNames = {
	[1] = "l1_injector"
}

function SWEP:Initialize()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1  -- 1 использование
	}
	self.modeValuesdef = {
		[1] = 1,
	}
	
	-- Проверка наличия SEF
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
			-- Если есть SEF система
			if ent.ApplyEffect then
				ent:ApplyEffect("Exhaust", 93)
				ent:ApplyEffect("Tenacity", 3, 35)
				ent:RemoveEffect("DarkVision")
			end
		else
			-- Альтернативная логика для Homigrad organism
			if org then
				-- Добавляем адреналин и выносливость
				org.adrenalineAdd = math.min((org.adrenalineAdd or 0) + 0.5, 1)
				org.stamina.subadd = math.max((org.stamina.subadd or 0) - 50, -100)
				
				-- Убираем дезориентацию
				if org.disorientation then
					org.disorientation = math.max(org.disorientation - 5, 0)
				end
			end
		end
		
		-- Звук использования уже проигрывается через AnimsSounds
		
		-- Уменьшаем количество использований
		self.modeValues[1] = self.modeValues[1] - 1
		
		-- Удаляем предмет если использован
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
	
	function SWEP:SecondaryAttack()
		-- Можно добавить использование на других игроков
	end
end
