if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Hemostatic Agent"
SWEP.Instructions = "A fast-acting hemostatic injection that temporarily stops external bleeding and significantly reduces susceptibility to new bleeding wounds. The agent works by promoting rapid coagulation at wound sites, effectively sealing external injuries for approximately 25 seconds. Note: This medication does not affect internal bleeding and should be used as a temporary measure to stabilize a patient before proper medical treatment. Right-click to use on someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/carlsmei/escapefromtarkov/medical/zagustin.mdl"
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
SWEP.offsetVec = Vector(4, -1.5, -3)
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
		-- Рука застывает пока зажата кнопка
	else
		-- Уменьшаем Holding когда не зажата кнопка
		self:SetHolding(math.max(self:GetHolding() - 4, 0))
	end
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
	-- Анимация поднесения к телу: рука движется к груди/животу
	-- При hold=0 рука внизу, при hold=100 рука поднесена к телу и застывает
	-- Ограничиваем hold до 100 для застывания
	hold = math.min(hold, 100)
    self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 2.5, -30 + hold / 1.2 + 20 * aimvec[3], 5 - hold / 2.5))
    self:BoneSet("r_forearm", vector_origin, Angle(hold / 12, -hold / 1.8, 35 - hold / 1.1))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:PrimaryAttack()
	-- Логика использования перенесена в Think() для плавной анимации
	-- Эта функция вызывается при нажатии ЛКМ, но основная логика в Think()
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

		-- Останавливаем кровотечение и повышаем устойчивость к новому кровотечению
		if not org.zagustinActive then
			org.zagustinActive = true
			org.zagustinTime = CurTime()
			org.zagustinBleedMulStart = org.bleedingmul or 1
			
			-- Останавливаем текущее кровотечение
			org.bleed = 0
			
			-- Устанавливаем модификатор кровотечения на 0 для полной остановки кровотечения из ран
			org.bleedingmul = 0
			
			-- Устанавливаем сетевую переменную для клиента
			if ent:IsPlayer() then
				ent:SetNetVar("zagustinActive", true)
			end
			
			-- Используем метатаблицу для перехвата всех попыток записи в org.bleed
			if not org._zagustinMetaTable then
				org._zagustinMetaTable = true
				local originalMeta = getmetatable(org) or {}
				local zagustinMeta = {
					__index = originalMeta.__index or function(t, k)
						return rawget(t, k)
					end,
					__newindex = function(t, k, v)
						-- Блокируем установку bleed и bleedingmul если активен zagustin
						-- Для bleed сохраняем только внутреннее кровотечение
						if rawget(t, "zagustinActive") and (k == "bleed" or k == "bleedingmul") then
							if k == "bleed" then
								-- Сохраняем только внутреннее кровотечение
								local internalBleedValue = (rawget(t, "internalBleed") or 0) / 14
								rawset(t, k, internalBleedValue)
							elseif k == "bleedingmul" then
								rawset(t, k, 0)
							end
						else
							if originalMeta.__newindex then
								originalMeta.__newindex(t, k, v)
							else
								rawset(t, k, v)
							end
						end
					end
				}
				setmetatable(org, zagustinMeta)
			end
			
			-- Перехватываем функцию модуля крови для обнуления кровотечения после расчета
			if not hg.organism.module.blood._zagustinOriginal then
				hg.organism.module.blood._zagustinOriginal = hg.organism.module.blood[2]
				hg.organism.module.blood[2] = function(owner_check, org_check, mulTime)
					-- Если активен zagustin, временно обнуляем размер ран для расчета, затем восстанавливаем
					local savedWounds = {}
					if org_check.zagustinActive and org_check.wounds then
						for i, wound in ipairs(org_check.wounds) do
							savedWounds[i] = wound[1]
							wound[1] = 0
						end
					end
					
					local savedArterialWounds = {}
					if org_check.zagustinActive and org_check.arterialwounds then
						for i, wound in ipairs(org_check.arterialwounds) do
							savedArterialWounds[i] = wound[1]
							wound[1] = 0
						end
					end
					
					-- Вызываем оригинальную функцию
					hg.organism.module.blood._zagustinOriginal(owner_check, org_check, mulTime)
					
					-- Восстанавливаем размер ран
					if org_check.zagustinActive and org_check.wounds then
						for i, savedSize in ipairs(savedWounds) do
							if org_check.wounds[i] then
								org_check.wounds[i][1] = savedSize
							end
						end
					end
					
					if org_check.zagustinActive and org_check.arterialwounds then
						for i, savedSize in ipairs(savedArterialWounds) do
							if org_check.arterialwounds[i] then
								org_check.arterialwounds[i][1] = savedSize
							end
						end
					end
					
					-- Обнуляем только внешнее кровотечение, сохраняя внутреннее
					if org_check.zagustinActive then
						-- Сохраняем значение внутреннего кровотечения
						local internalBleedValue = (org_check.internalBleed or 0) / 14
						-- Обнуляем кровотечение (включает внешнее и внутреннее)
						rawset(org_check, "bleed", internalBleedValue)
						rawset(org_check, "bleedingmul", 0)
					end
				end
			end
			
			-- Блокируем вызов BloodDroplet2 для этого организма
			local hookName = "ZagustinBloodDroplet_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			hook.Add("HG_BloodParticleStartedDropping", hookName, function(owner_check, org_check, wound, dir, artery)
				if org_check == org and org.zagustinActive then
					-- Блокируем создание визуальных эффектов кровотечения
					return true
				end
			end)
			
			-- Добавляем хук для уменьшения нового кровотечения при получении урона
			local bleedHookName = "ZagustinBleedResist_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			hook.Add("PreHomigradDamageBulletBleedAdd", bleedHookName, function(ply, org_check, dmgInfo, hitgroup, harm, hitBoxs, inputHole, hook_info)
				if not IsValid(ent) or org_check ~= org or not org.zagustinActive then
					return
				end
				
				-- Уменьшаем новое кровотечение на 80%
				if hook_info.bleed then
					hook_info.bleed = hook_info.bleed * 0.2
				end
			end)
			
			-- Добавляем дополнительный хук для обнуления кровотечения после его расчета в модуле крови
			local bleedResetHookName = "ZagustinBleedReset_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			hook.Add("Think", bleedResetHookName, function()
				if not IsValid(ent) or not org or not org.zagustinActive then
					hook.Remove("Think", bleedResetHookName)
					return
				end
				
				-- Обнуляем только внешнее кровотечение, сохраняя внутреннее
				local internalBleedValue = (org.internalBleed or 0) / 14
				rawset(org, "bleed", internalBleedValue)
				-- Также устанавливаем модификатор на 0 для предотвращения нового кровотечения
				rawset(org, "bleedingmul", 0)
			end)
			
			-- Используем хук "Org Think" с очень низким приоритетом (выполняется последним) для обнуления кровотечения после расчета модуля крови
			local orgThinkHookName = "zzz_ZagustinOrgThink_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			hook.Add("Org Think", orgThinkHookName, function(owner_check, org_check, timeValue)
				if not IsValid(ent) or org_check ~= org or not org.zagustinActive then
					hook.Remove("Org Think", orgThinkHookName)
					return
				end
				
				-- Обнуляем только внешнее кровотечение, сохраняя внутреннее
				local internalBleedValue = (org.internalBleed or 0) / 14
				rawset(org, "bleed", internalBleedValue)
				rawset(org, "bleedingmul", 0)
			end)
			
			-- Используем таймер с очень высокой частотой для гарантированного обнуления кровотечения
			local timerName = "ZagustinBleedTimer_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			timer.Create(timerName, 0.001, 0, function()
				if not IsValid(ent) or not org or not org.zagustinActive then
					timer.Remove(timerName)
					return
				end
				
				-- Обнуляем только внешнее кровотечение, сохраняя внутреннее
				local internalBleedValue = (org.internalBleed or 0) / 14
				rawset(org, "bleed", internalBleedValue)
				rawset(org, "bleedingmul", 0)
			end)
			
			-- Добавляем хук Think для поддержания эффекта и очистки
			local thinkHookName = "ZagustinThink_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
			hook.Add("Think", thinkHookName, function()
				if not IsValid(ent) or not org or not org.zagustinActive then
					hook.Remove("Think", thinkHookName)
					hook.Remove("PreHomigradDamageBulletBleedAdd", bleedHookName)
					hook.Remove("HG_BloodParticleStartedDropping", hookName)
					hook.Remove("Think", bleedResetHookName)
					local orgThinkHookName = "ZagustinOrgThink_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
					hook.Remove("Org Think", orgThinkHookName)
					local timerName = "ZagustinBleedTimer_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
					timer.Remove(timerName)
					if ent:IsPlayer() then
						ent:SetNetVar("zagustinActive", false)
					end
					return
				end
				
				local elapsed = CurTime() - org.zagustinTime
				
				-- Поддерживаем остановку внешнего кровотечения, сохраняя внутреннее
				local internalBleedValue = (org.internalBleed or 0) / 14
				rawset(org, "bleed", internalBleedValue)
				rawset(org, "bleedingmul", 0)
				
				-- Очищаем эффект через 25 секунд
				if elapsed >= 25 then
					org.zagustinActive = nil
					org.zagustinTime = nil
					org.bleedingmul = org.zagustinBleedMulStart or 1
					hook.Remove("Think", thinkHookName)
					hook.Remove("PreHomigradDamageBulletBleedAdd", bleedHookName)
					hook.Remove("HG_BloodParticleStartedDropping", hookName)
					hook.Remove("Think", bleedResetHookName)
					local orgThinkHookName = "ZagustinOrgThink_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
					hook.Remove("Org Think", orgThinkHookName)
					local timerName = "ZagustinBleedTimer_" .. (ent:IsPlayer() and ent:EntIndex() or tostring(ent:GetCreationID()))
					timer.Remove(timerName)
					-- Восстанавливаем оригинальную функцию модуля крови если больше нет активных zagustin эффектов
					local hasActiveZagustin = false
					for _, ply in ipairs(player.GetAll()) do
						if IsValid(ply) and ply.organism and ply.organism.zagustinActive then
							hasActiveZagustin = true
							break
						end
					end
					if not hasActiveZagustin and hg.organism.module.blood._zagustinOriginal then
						hg.organism.module.blood[2] = hg.organism.module.blood._zagustinOriginal
						hg.organism.module.blood._zagustinOriginal = nil
					end
					if ent:IsPlayer() then
						ent:SetNetVar("zagustinActive", false)
					end
				end
			end)
		else
			-- Если эффект уже активен, обновляем время
			org.zagustinTime = CurTime()
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
end

if CLIENT then
	-- Блокируем визуальные эффекты кровотечения когда активен zagustin
	local zagustinBloodBlock = {}
	
	hook.Add("Player-Ragdoll think", "ZagustinNoBloodVisuals", function(ply, ent, time)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		
		-- Проверяем сетевую переменную
		if ply:GetNetVar("zagustinActive", false) then
			zagustinBloodBlock[ply] = true
		else
			zagustinBloodBlock[ply] = nil
		end
	end)
	
	-- Перехватываем создание частиц крови
	local originalAddBloodPart = hg.addBloodPart
	local originalAddBloodPart2 = hg.addBloodPart2
	
	if originalAddBloodPart then
		hg.addBloodPart = function(pos, vel, mat, w, h, artery, kishki, owner)
			if IsValid(owner) and owner:IsPlayer() and zagustinBloodBlock[owner] then
				-- Блокируем создание частиц крови для игрока с активным zagustin
				return
			end
			return originalAddBloodPart(pos, vel, mat, w, h, artery, kishki, owner)
		end
	end
	
	if originalAddBloodPart2 then
		hg.addBloodPart2 = function(pos, vel, mat, w, h, time, water, owner)
			if IsValid(owner) and owner:IsPlayer() and zagustinBloodBlock[owner] then
				-- Блокируем создание частиц крови для игрока с активным zagustin
				return
			end
			return originalAddBloodPart2(pos, vel, mat, w, h, time, water, owner)
		end
	end
end