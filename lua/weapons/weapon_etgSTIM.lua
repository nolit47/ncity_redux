if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "etqSTIM"
SWEP.Instructions = "Mannitol is used intravenously to reduce acutely raised intracranial pressure until more definitive treatment can be applied, e.g., after head trauma. While mannitol injection is the mainstay for treating high pressure in the skull after a bad brain injury, it is no better than hypertonic saline as a first-line treatment. In treatment-resistant cases, hypertonic saline works better. Intra-arterial infusions of mannitol can transiently open the blood-brain barrier by disrupting tight junctions."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/carlsmei/escapefromtarkov/medical/etg_change.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_manitol.png")
	SWEP.IconOverride = "vgui/icons/ico_manitol.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -0.9, -3)
SWEP.offsetAng = Angle(0, 0, 0)
SWEP.modeNames = {
	[1] = "adrenaline"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)
	self.modeValues = {
		[1] = 1
	}
	self.net_cooldown2 = 0
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

SWEP.showstats = false

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
	-- Ограничиваем hold до 100 для застывания
	hold = math.min(hold, 100)
	
	-- Когда hold = 0, используем оригинальную анимацию для правильного удержания
	-- Когда hold > 0, применяем анимацию поднесения к телу
	if hold == 0 then
		-- Оригинальная анимация для правильного удержания (как у медкита)
		self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 5, -30 + hold / 2 + 20 * aimvec[3], 5 - hold / 4))
		self:BoneSet("r_forearm", vector_origin, Angle(hold / 25, -hold / 2.5, 35 - hold / 1.4))
	else
		-- Анимация поднесения к телу: рука движется к груди/животу
		self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 2.5, -30 + hold / 1.2 + 20 * aimvec[3], 5 - hold / 2.5))
		self:BoneSet("r_forearm", vector_origin, Angle(hold / 12, -hold / 1.8, 35 - hold / 1.1))
	end

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	-- Увеличиваем Holding при зажатии ЛКМ
	if SERVER and owner:KeyDown(IN_ATTACK) then
		local wasBelow100 = self:GetHolding() < 100
		if wasBelow100 then
			self:SetHolding(math.min(self:GetHolding() + 8, 100))
		end
		
		-- Когда Holding достигает 100, сразу используем предмет
		if self:GetHolding() >= 100 and wasBelow100 then
			self:SetHolding(0)
			self.healbuddy = owner
			local done = self:Heal(self.healbuddy, self.mode)
			
			if(done and self.PostHeal)then
				self:PostHeal(self.healbuddy, self.mode)
			end

			if self.net_cooldown2 < CurTime() then
				self:SetNetVar("modeValues",self.modeValues)
				self.net_cooldown2 = CurTime() + 0.1
			end
		end
	else
		-- Уменьшаем Holding когда не зажата кнопка
		self:SetHolding(math.max(self:GetHolding() - 4, 0))
	end
end

function SWEP:PrimaryAttack()
	-- Логика использования перенесена в Think() для плавной анимации
end

if SERVER then
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		org.mannitol = math.Approach(org.mannitol, 4, self.modeValues[1] * 2)
		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		-- Активируем регенерацию на 45 секунд и размытие на 15 секунд
		org.etgSTIMRegenEndTime = CurTime() + 45
		org.etgSTIMBlurEndTime = CurTime() + 15
		
		-- Устанавливаем сетевую переменную для клиента (размытие)
		if ent:IsPlayer() then
			ent:SetNetVar("etgSTIMBlurEndTime", org.etgSTIMBlurEndTime)
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
	
	-- Глобальный хук для регенерации частей тела (как в примере с serial_killer)
	hook.Add("Org Think", "ETGSTIM_Regen", function(owner, org, timeValue)
		if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
		if not org or not org.etgSTIMRegenEndTime then return end
		if CurTime() >= org.etgSTIMRegenEndTime then
			org.etgSTIMRegenEndTime = nil
			org.etgSTIMBlurEndTime = nil
			if owner:IsPlayer() then
				owner:SetNetVar("etgSTIMBlurEndTime", 0)
			end
			return
		end
		
		-- Медленная регенерация всех частей тела
		local regenRate = timeValue * 0.020 -- Скорость регенерации
		
		-- Конечности
		if org.lleg and org.lleg > 0 then
			org.lleg = math.max(org.lleg - regenRate, 0)
		end
		if org.rleg and org.rleg > 0 then
			org.rleg = math.max(org.rleg - regenRate, 0)
		end
		if org.larm and org.larm > 0 then
			org.larm = math.max(org.larm - regenRate, 0)
		end
		if org.rarm and org.rarm > 0 then
			org.rarm = math.max(org.rarm - regenRate, 0)
		end
		
		-- Органы
		if org.brain and org.brain > 0 then
			org.brain = math.max(org.brain - regenRate, 0)
		end
		if org.jaw and org.jaw > 0 then
			org.jaw = math.max(org.jaw - regenRate, 0)
		end
		if org.spine1 and org.spine1 > 0 then
			org.spine1 = math.max(org.spine1 - regenRate, 0)
		end
		if org.spine2 and org.spine2 > 0 then
			org.spine2 = math.max(org.spine2 - regenRate, 0)
		end
		if org.spine3 and org.spine3 > 0 then
			org.spine3 = math.max(org.spine3 - regenRate, 0)
		end
		if org.chest and org.chest > 0 then
			org.chest = math.max(org.chest - regenRate, 0)
		end
		if org.pelvis and org.pelvis > 0 then
			org.pelvis = math.max(org.pelvis - regenRate, 0)
		end
		if org.skull and org.skull > 0 then
			org.skull = math.max(org.skull - regenRate, 0)
		end
		if org.stomach and org.stomach > 0 then
			org.stomach = math.max(org.stomach - regenRate, 0)
		end
		if org.intestines and org.intestines > 0 then
			org.intestines = math.max(org.intestines - regenRate, 0)
		end
		
		-- Органы-таблицы (лёгкие, печень)
		if org.lungsL and org.lungsL[1] and org.lungsL[1] > 0 then
			org.lungsL[1] = math.max(org.lungsL[1] - regenRate, 0)
		end
		if org.lungsL and org.lungsL[2] and org.lungsL[2] > 0 then
			org.lungsL[2] = math.max(org.lungsL[2] - regenRate, 0)
		end
		if org.lungsR and org.lungsR[1] and org.lungsR[1] > 0 then
			org.lungsR[1] = math.max(org.lungsR[1] - regenRate, 0)
		end
		if org.lungsR and org.lungsR[2] and org.lungsR[2] > 0 then
			org.lungsR[2] = math.max(org.lungsR[2] - regenRate, 0)
		end
		if org.liver and org.liver[1] and org.liver[1] > 0 then
			org.liver[1] = math.max(org.liver[1] - regenRate, 0)
		end
		if org.liver and org.liver[2] and org.liver[2] > 0 then
			org.liver[2] = math.max(org.liver[2] - regenRate, 0)
		end
		
		-- Дополнительные органы
		if org.trachea and org.trachea > 0 then
			org.trachea = math.max(org.trachea - regenRate, 0)
		end
		if org.pneumothorax and org.pneumothorax > 0 then
			org.pneumothorax = math.max(org.pneumothorax - regenRate, 0)
		end
	end)
	
	-- Очистка при смерти игрока
	hook.Add("PlayerDeath", "ETGSTIM_Cleanup_Server", function(ply)
		if IsValid(ply) and ply.organism then
			local org = ply.organism
			if org.etgSTIMRegenEndTime then
				org.etgSTIMRegenEndTime = nil
				org.etgSTIMBlurEndTime = nil
				ply:SetNetVar("etgSTIMBlurEndTime", 0)
			end
		end
	end)
end

if CLIENT then
	local blurMaterial = Material("pp/blurscreen")
	
	-- Хук для размытия экрана через RenderScreenspaceEffects
	hook.Add("RenderScreenspaceEffects", "ETGSTIM_Blur", function()
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then 
			return
		end
		
		local blurEndTime = ply:GetNetVar("etgSTIMBlurEndTime", 0)
		if blurEndTime > 0 and CurTime() < blurEndTime then
			-- Применяем размытие экрана
			local blurStrength = math.min((blurEndTime - CurTime()) / 15, 1) * 0.5 -- Сила размытия уменьшается со временем
			
			DrawMotionBlur(0.1, blurStrength, 0.01)
		end
	end)
	
	-- Очистка при смерти игрока
	hook.Add("PlayerDeath", "ETGSTIM_Cleanup", function(ply)
		if ply == LocalPlayer() then
			ply:SetNetVar("etgSTIMBlurEndTime", 0)
		end
	end)
end