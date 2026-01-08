
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Fury-13"
SWEP.Instructions = "Fury-13 is an incredibly potent stimulator drug. Instead of \"modifying\" how your organism works, this drug aims to provide additional resources instead, making you stronger than ever before. Side effects may include permanent brain damage."
SWEP.Category = "ZCity Other"
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
	[1] = "fury-13"
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

-- Network strings for Fury-13 effects
if SERVER then
	util.AddNetworkString("Fury13_StartEffects")
	util.AddNetworkString("Fury13_EndEffects")
	util.AddNetworkString("Fury13_PlayerMarker")
	util.AddNetworkString("Fury13_RemoveMarker")
	util.AddNetworkString("Fury13_ClearAllMarkers")
end

-- Client-side Fury-13 effects
if CLIENT then
	local fury13_active = false
	local fury13_delayEnd = 0
	local fury13_endTime = 0
	local fury13_soundPlaying = false
	local fury13_markedPlayers = {} -- Table to track marked players
	
	-- Receive start effects
	net.Receive("Fury13_StartEffects", function()
		fury13_delayEnd = net.ReadFloat()
		fury13_endTime = net.ReadFloat()
		fury13_active = true
		fury13_soundPlaying = false
	end)
	
	-- Receive end effects
	net.Receive("Fury13_EndEffects", function()
		fury13_active = false
		fury13_soundPlaying = false
	end)
	
	-- Receive player marker
	net.Receive("Fury13_PlayerMarker", function()
		local ply = net.ReadEntity()
		local startTime = net.ReadFloat()
		local endTime = net.ReadFloat()
		
		if IsValid(ply) then
			fury13_markedPlayers[ply] = {
				startTime = startTime,
				endTime = endTime
			}
		end
	end)
	
	-- Receive marker removal
	net.Receive("Fury13_RemoveMarker", function()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			fury13_markedPlayers[ply] = nil
		end
	end)
	
	-- Receive clear all markers
	net.Receive("Fury13_ClearAllMarkers", function()
		fury13_markedPlayers = {}
	end)
	
	-- Visual effects hook
	hook.Add("RenderScreenspaceEffects", "Fury13_VisualEffects", function()
		if not fury13_active then return end
		
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then 
			fury13_active = false
			return 
		end
		
		local currentTime = CurTime()
		
		-- Check if effects should end
		if currentTime >= fury13_endTime then
			fury13_active = false
			return
		end
		
		-- Play sound when delay ends (clientside only, follows player, slowed pitch)
		if currentTime >= fury13_delayEnd and not fury13_soundPlaying then
			ply:EmitSound("utterrage.mp3", 75, 95, 1, CHAN_AUTO) -- Pitch reduced to 95 (0.95)
			fury13_soundPlaying = true
		end
		
		-- Visual effects only during active period (after delay)
		if currentTime >= fury13_delayEnd then
			local activeTime = currentTime - fury13_delayEnd
			local totalActiveTime = fury13_endTime - fury13_delayEnd
			local progress = math.Clamp(activeTime / totalActiveTime, 0, 1)
			
			-- Fade in effect (first 1 second)
			local fadeInTime = 1
			local fadeInProgress = math.Clamp(activeTime / fadeInTime, 0, 1)
			
			-- Fade out effect (last 3 seconds)
			local fadeOutTime = 3
			local timeUntilEnd = fury13_endTime - currentTime
			local fadeOutProgress = 1
			if timeUntilEnd <= fadeOutTime then
				fadeOutProgress = math.Clamp(timeUntilEnd / fadeOutTime, 0, 1)
			end
			
			-- Combined fade multiplier
			local fadeMultiplier = fadeInProgress * fadeOutProgress
			
			-- Alarm-like pulsing effect (smooth dark red to bright red transition)
			local pulseSpeed = 2.5 -- Alarm-like speed
			local pulseRaw = math.sin(currentTime * pulseSpeed) -- -1 to 1
			local pulseNormalized = (pulseRaw + 1) / 2 -- 0 to 1
			
			-- Create more pronounced dark-to-bright-to-dark effect
			local minIntensity = 0.2 -- Dark red baseline
			local maxIntensity = 1.0 -- Bright red peak
			local pulseIntensity = minIntensity + (pulseNormalized * (maxIntensity - minIntensity))
			
			-- Apply fade to pulse
			pulseIntensity = pulseIntensity * fadeMultiplier
			
			-- Red tint intensity (more pronounced)
			local redIntensity = pulseIntensity * 1.2
			local alpha = pulseIntensity * 0.4
			
			-- Apply color modification with smooth transitions
			local colorMod = {}
			colorMod["$pp_colour_addr"] = redIntensity
			colorMod["$pp_colour_addg"] = 0
			colorMod["$pp_colour_addb"] = 0
			colorMod["$pp_colour_brightness"] = 0.02 * fadeMultiplier
			colorMod["$pp_colour_contrast"] = 1 + (0.3 * fadeMultiplier)
			colorMod["$pp_colour_colour"] = 1 + (0.4 * fadeMultiplier)
			colorMod["$pp_colour_mulr"] = 1 + (0.3 * fadeMultiplier)
			colorMod["$pp_colour_mulg"] = 1 - (0.2 * fadeMultiplier)
			colorMod["$pp_colour_mulb"] = 1 - (0.2 * fadeMultiplier)
			
			DrawColorModify(colorMod)
			
			-- Additional red overlay with smooth pulsing
			surface.SetDrawColor(189, 18, 18, alpha * 255)
			surface.DrawRect(0, 0, ScrW(), ScrH())
		end
	end)
	
	-- Clean up on player death
	hook.Add("PlayerDeath", "Fury13_ClientCleanup", function(victim)
		if victim == LocalPlayer() then
			fury13_active = false
			fury13_soundPlaying = false
		end
		-- Remove marker for dead player
		fury13_markedPlayers[victim] = nil
	end)
	
	-- Player marker HUD
	hook.Add("HUDPaint", "Fury13_PlayerMarkers", function()
		local currentTime = CurTime()
		local localPlayer = LocalPlayer()
		
		-- Clean up expired markers
		for ply, data in pairs(fury13_markedPlayers) do
			if not IsValid(ply) or currentTime >= data.endTime then
				fury13_markedPlayers[ply] = nil
			end
		end
		
		-- Draw markers for victim players (targets)
		for ply, data in pairs(fury13_markedPlayers) do
			if IsValid(ply) and ply ~= localPlayer and ply:Alive() then
				local pos = ply:GetPos() + Vector(0, 0, 80) -- Above player's head
				local screenPos = pos:ToScreen()
				
				if screenPos.visible then
					-- Calculate fade-in effect
					local activeTime = currentTime - data.startTime
					local fadeInTime = 2 -- 2 second fade-in
					local fadeAlpha = math.Clamp(activeTime / fadeInTime, 0, 1)
					
					-- Calculate distance-based size
					local distance = localPlayer:GetPos():Distance(ply:GetPos())
					local size = math.Clamp(64 - (distance / 50), 16, 64)
					
					-- Draw the alert icon (target marker)
					surface.SetMaterial(Material("vgui/notification_icon_alert_red.png"))
					surface.SetDrawColor(255, 255, 255, 255 * fadeAlpha)
					surface.DrawTexturedRect(screenPos.x - size/2, screenPos.y - size/2, size, size)
				end
			end
		end
	end)
end

local rage_thoughts = {
	"BLOOD... VIOLENCE... KILL THEM ALL!",
	"RAGE CONSUMES ME!",
	"DESTROY EVERYTHING!",
	"I NEED TO HURT SOMEONE!",
	"THE FURY BURNS THROUGH MY VEINS!",
	"VIOLENCE IS THE ONLY ANSWER!",
	"TEAR THEM APART!",
	"CRUSH! KILL! DESTROY!",
	"I AM UNSTOPPABLE!",
	"FEED THE RAGE!"
}


local kill_count_words = {
	[1] = "ONE", [2] = "TWO", [3] = "THREE", [4] = "FOUR", [5] = "FIVE",
	[6] = "SIX", [7] = "SEVEN", [8] = "EIGHT", [9] = "NINE", [10] = "TEN",
	[11] = "ELEVEN", [12] = "TWELVE", [13] = "THIRTEEN", [14] = "FOURTEEN", [15] = "FIFTEEN",
	[16] = "SIXTEEN", [17] = "SEVENTEEN", [18] = "EIGHTEEN", [19] = "NINETEEN", [20] = "TWENTY"
}

-- Global Fury-13 functions to avoid self context issues
local function UpdateFury13Effects(ent)
	if not IsValid(ent) or not ent:IsPlayer() or not ent.organism then return end
	
	local org = ent.organism
	local currentTime = CurTime()
	local delayEnd = ent:GetNetVar("Fury13_DelayEnd", 0)
	local endTime = ent:GetNetVar("Fury13_EndTime", 0)
	
	-- Check if effects should end
	if currentTime >= endTime then
		EndFury13Effects(ent)
		return
	end
	
	-- Check if delay period has ended and effects should start
	if currentTime >= delayEnd and not ent:GetNetVar("Fury13_Active", false) then
		ent:SetNetVar("Fury13_Active", true)
		
		-- Display rage thoughts when effects kick in
		if ent:IsPlayer() and ent.organism and ent.organism.isPly then
			local thought = rage_thoughts[math.random(#rage_thoughts)]
			ent:Notify(thought, 1, "fury_rage", 3, nil, nil)
		end
		
		-- Initialize kill counter
		ent:SetNetVar("Fury13_KillCount", 0)
	end
	
	-- Apply effects if active
	if ent:GetNetVar("Fury13_Active", false) then
		-- Calculate fade-in progress (0 to 1 over first 1 second of active period)
		local activeTime = currentTime - delayEnd
		local fadeProgress = math.Clamp(activeTime / 1, 0, 1)
		
		-- Max out rage and anger with fade-in
		org.rage = math.Clamp(org.rage + (1 - org.rage) * fadeProgress * 0.8, 0, 1)
		org.anger = math.Clamp(org.anger + (1 - org.anger) * fadeProgress * 0.8, 0, 1)
		
		-- Set adrenaline to max (12) - changed from 10 to 12, faster fade-in
		org.adrenaline = math.min(org.adrenaline + fadeProgress * 1.0, 15)
		
		-- Increase stamina regen by 3x
		org.stamina.regen = ent:GetNetVar("Fury13_OriginalStaminaRegen", 1) * (1 + 2 * fadeProgress)
		
		-- Set melee damage multiplier
		local originalMul = ent:GetNetVar("Fury13_OriginalMeleeDamageMul", 1)
		ent.MeleeDamageMul = originalMul * (1 + 2 * fadeProgress)
		ent.Fury13DamageMul = 1 + 2 * fadeProgress -- 3x total damage
		ent:SetNetVar("Fury13_MeleeDamageMul", 3)
	end
end

local function EndFury13Effects(ent)
	if not IsValid(ent) then return end
	
	local timerName = "Fury13_Effects_" .. ent:SteamID64()
	timer.Remove(timerName)
	
	-- Start rapid adrenaline withdrawal
	local withdrawalTimerName = "Fury13_Withdrawal_" .. ent:SteamID64()
	timer.Create(withdrawalTimerName, 0.1, 40, function() -- 4 seconds total (0.1 * 40)
		if not IsValid(ent) or not ent:IsPlayer() or not ent.organism then
			timer.Remove(withdrawalTimerName)
			return
		end
		
		local org = ent.organism
		-- Rapidly decrease adrenaline (2.0 per second = 0.2 per 0.1 second)
		org.adrenaline = math.max(org.adrenaline - 0.3, 0)
		
		-- Stop withdrawal when adrenaline reaches 0
		if org.adrenaline <= 0 then
			timer.Remove(withdrawalTimerName)
		end
	end)
	
	if ent:IsPlayer() and ent.organism then
		local org = ent.organism
		
		-- Immediate withdrawal effects
		org.stamina[1] = math.max(org.stamina[1] - 60, 0) -- Heavily decrease current stamina
		org.stamina.regen = ent:GetNetVar("Fury13_OriginalStaminaRegen", 1) -- Restore original regen
		
		-- Gradually reduce rage and anger
		org.rage = math.max(org.rage - 0.3, 0)
		org.anger = math.max(org.anger - 0.3, 0)
	end
	
	-- Clear all victim markers for the drug user
	if ent:IsPlayer() then
		net.Start("Fury13_ClearAllMarkers")
		net.Send(ent)
	end
	
	-- Clean up network variables
	CleanupFury13Effects(ent)
	
	-- Send end effects to client
	if ent:IsPlayer() then
		net.Start("Fury13_EndEffects")
		net.Send(ent)
	end
end

local function CleanupFury13Effects(ent)
	if not IsValid(ent) then return end
	
	-- Clear all net variables
	ent:SetNetVar("Fury13_Active", nil)
	ent:SetNetVar("Fury13_StartTime", nil)
	ent:SetNetVar("Fury13_DelayEnd", nil)
	ent:SetNetVar("Fury13_EndTime", nil)
	ent:SetNetVar("Fury13_OriginalStaminaRegen", nil)
	ent:SetNetVar("Fury13_MeleeDamageMul", nil)
	ent:SetNetVar("Fury13_KillCount", nil)
	
	-- Restore original melee damage multiplier
	local originalMul = ent:GetNetVar("Fury13_OriginalMeleeDamageMul", 1)
	ent.MeleeDamageMul = originalMul == 1 and nil or originalMul
	ent:SetNetVar("Fury13_OriginalMeleeDamageMul", nil)
	
	-- Clear damage multiplier
	ent.Fury13DamageMul = nil
end

if SERVER then
	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end
		self:SetBodygroup(1, 1)
		local owner = self:GetOwner()
		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		
		-- Start Fury-13 effects
		self:StartFury13Effects(ent)
		
		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()
			self.poisoned2 = nil
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
	end
	
	function SWEP:StartFury13Effects(ent)
		if not IsValid(ent) or not ent:IsPlayer() or not ent.organism then return end
		
		local org = ent.organism
		local owner = self:GetOwner()
		
		-- Set Fury-13 state
		ent:SetNetVar("Fury13_Active", false) -- Will be set to true after delay
		ent:SetNetVar("Fury13_StartTime", CurTime())
		ent:SetNetVar("Fury13_DelayEnd", CurTime() + math.random(4, 5)) -- 4-5 second delay
		ent:SetNetVar("Fury13_EndTime", CurTime() + math.random(4, 5) + 18) -- Total duration: delay + 20 seconds
		
		-- Store original values for restoration
		ent:SetNetVar("Fury13_OriginalStaminaRegen", org.stamina.regen)
		
		-- Store original melee damage multiplier
		ent:SetNetVar("Fury13_OriginalMeleeDamageMul", ent.MeleeDamageMul or 1)
		
		-- Send client-side effects start signal
		net.Start("Fury13_StartEffects")
		net.WriteFloat(ent:GetNetVar("Fury13_DelayEnd"))
		net.WriteFloat(ent:GetNetVar("Fury13_EndTime"))
		net.Send(ent)
		
		-- Send victim markers for all OTHER players to the drug user
		for _, victim in pairs(player.GetAll()) do
			if IsValid(victim) and victim ~= ent and victim:Alive() then
				net.Start("Fury13_PlayerMarker")
				net.WriteEntity(victim)
				net.WriteFloat(ent:GetNetVar("Fury13_DelayEnd"))
				net.WriteFloat(ent:GetNetVar("Fury13_EndTime"))
				net.Send(ent)
			end
		end
		
		-- Start the effect timer
		local timerName = "Fury13_Effects_" .. ent:SteamID64()
		timer.Create(timerName, 0.1, 0, function()
			if not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() then
				timer.Remove(timerName)
				CleanupFury13Effects(ent)
				return
			end
			
			UpdateFury13Effects(ent)
		end)
	end
	
	-- Hook to clean up on player death
	hook.Add("PlayerDeath", "Fury13_Cleanup", function(victim, inflictor, attacker)
		if IsValid(victim) and victim:GetNetVar("Fury13_Active") then
			CleanupFury13Effects(victim)
		end
	end)
	
	-- Hook to clean up on player disconnect
	hook.Add("PlayerDisconnected", "Fury13_Cleanup", function(ply)
		if IsValid(ply) then
			local timerName = "Fury13_Effects_" .. ply:SteamID64()
			timer.Remove(timerName)
			local withdrawalTimerName = "Fury13_Withdrawal_" .. ply:SteamID64()
			timer.Remove(withdrawalTimerName)
		end
	end)
	
	-- Kill counter hook
	hook.Add("PlayerDeath", "Fury13_KillCounter", function(victim, inflictor, attacker)
		if IsValid(attacker) and attacker:IsPlayer() and attacker:GetNetVar("Fury13_Active", false) then
			local killCount = attacker:GetNetVar("Fury13_KillCount", 0) + 1
			
			-- Cap at 20 kills
			if killCount <= 20 then
				attacker:SetNetVar("Fury13_KillCount", killCount)
				
				-- Display kill count thought
				local killWord = kill_count_words[killCount]
				if killWord and attacker.organism and attacker.organism.isPly then
					attacker:Notify(killWord, 1, "fury_kill_" .. killCount, 2, nil, nil)
				end
			end
		end
	end)
end