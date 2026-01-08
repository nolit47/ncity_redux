AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

util.AddNetworkString("zb_heli_phase_update")

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local function netPhase(ent, phase, waitStart)
	net.Start("zb_heli_phase_update")
		net.WriteEntity(ent)
		net.WriteString(phase or "")
		net.WriteFloat(waitStart or 0)
	net.Broadcast()
end

function ENT:SetPhase(phase)
	self.Phase = phase
	if phase == "waiting" then
		self.WaitingStartTime = CurTime()
		netPhase(self, phase, self.WaitingStartTime)
	else
		netPhase(self, phase, 0)
	end
end

function ENT:StopAllSounds()
	if self.ActiveSounds then
		for _, s in ipairs(self.ActiveSounds) do
			if s and s.Stop then s:Stop() end
		end
	end
	self.ActiveSounds = {}
end

function ENT:PlaySoundTable(tbl)
	self.ActiveSounds = self.ActiveSounds or {}
	for _, it in ipairs(tbl or {}) do
		local snd = CreateSound(self, it.s)
		if snd then
			if it.v then snd:ChangeVolume(math.Clamp((it.v or 75) / 150, 0, 1)) end
			snd:Play()
			self.ActiveSounds[#self.ActiveSounds + 1] = snd
		end
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:DrawShadow(true)
	self:SetupBoneColliders()
	self:StopAllSounds()
	self:PlaySoundTable(self.SoundTable)
	self:SetPhase("waiting")
	self.NextThinkTime = CurTime() + 0.1
end

function ENT:BeginDepart()
	self:StopAllSounds()
	self:SetPhase("depart")
	self.RemoveAt = CurTime() + 5
end

function ENT:Think()
	if self.Phase == "waiting" then
		if not self.WaitingLoopStarted then
			self:PlaySoundTable(self.WaitingSounds)
			self.WaitingLoopStarted = true
		end
		local wt = self:GetWaitTime()
		local start = self.WaitingStartTime or CurTime()
		if CurTime() - start >= wt then
			self:BeginDepart()
		end
	elseif self.Phase == "depart" then
		if self.RemoveAt and CurTime() >= self.RemoveAt then
			self:Remove()
			return
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:OnRemove()
	self:StopAllSounds()
end
