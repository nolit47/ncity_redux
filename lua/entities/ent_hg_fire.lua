if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Fire"
ENT.Category = "ZCity Other"
ENT.Spawnable = false
ENT.AdminOnly = true
--ENT.Small = true
ENT.Radius = 80
ENT.totalparticles = 30

hg.particles = hg.particles or {}

if CLIENT then
	local tbl = {}
    local oldtbl = {}
    local sendtime = CurTime() + 1
    net.Receive("fire_debug",function()
        table.CopyFromTo(tbl,oldtbl)
        tbl = net.ReadTable()
        sendtime = CurTime() + 1
    end)
	local mat = Material("particle/particle_smokegrenade")
	local colSmoke = Color(122,122,122,122)
    hook.Add("PreDrawEffects","fire_debug",function()
        if not tbl then return end
        
        for i, tbl2 in ipairs(tbl) do
            if not tbl2 then continue end
            if not oldtbl[i] then continue end

            local pos = tbl2[1]
            local oldpos = oldtbl[i][1]
            local lerp = 1 - (sendtime - CurTime())
            local poss = LerpVector(lerp,oldpos,pos)
			local size = math.max( math.min((1-math.abs( ((tbl2[3]) - CurTime() )/120 ))*2.5,1), 0 )
			render.SetMaterial(mat)
			colSmoke.a = 122*math.max( ((tbl2[3]) - CurTime() )/120, 0)
			render.DrawSprite(poss,256*size,256*size,colSmoke)
        end

		--[[cam.Start2D()
        for i,tbl2 in ipairs(tbl) do
            if not tbl2 then continue end
            if not oldtbl[i] then continue end

            local pos = tbl2[1]
            local oldpos = oldtbl[i][1]
            local lerp = 1 - (sendtime - CurTime())
            local poss = LerpVector(lerp,oldpos,pos):ToScreen()
            
            surface.SetDrawColor(255,255,255,255)
            surface.DrawRect(poss.x,poss.y,10,10)
        end
		cam.End2D()--]]
    end)
end

if CLIENT then return end
--local boundVector1, boundVector2 = Vector(-20, -20, -10), Vector(20, 20, 10)

util.AddNetworkString("fire_debug")
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetNoDraw(true)
	--self:SetCollisionBounds(boundVector1, boundVector2)
	--self:PhysicsInitBox(boundVector1, boundVector2)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableCollisions(false) end
	self:SetNotSolid(true)
	self.NextSound = 0
	self.NextParticle = 0
	self.particles = 0
	self.spawntime = CurTime()
	if not self.Initiator then self.Initiator = self:GetOwner() end
	SafeRemoveEntityDelayed(self, 30)
end

function ENT:OnRemove()
	--[[self.particles = {}
	net.Start("fire_debug")
	net.WriteTable(self.particles)
	net.Broadcast()--]]
end

local mattypes = {
	[MAT_FLESH] = true,
	[MAT_ALIENFLESH] = true,
	[MAT_ANTLION] = true,
	[MAT_WOOD] = true,
	[MAT_FOLIAGE] = true,
	[MAT_GRASS] = true,
	[MAT_DIRT] = true
}

local vfireshit = {
	["vfire"] = true,
	["vfire_ball"] = true,
	["vfire_cluster"] = true,
	["entityflame"] = true
}

local ents_FindInSphere = ents.FindInSphere
function ENT:Think()
	local SelfPos = self:GetPos() + Vector(0, 0, math.random(0, 100)) + VectorRand() * math.random(0, 100)
	if self.Radius > 50 then
		local Foof = EffectData()
		Foof:SetOrigin(SelfPos)
		Foof:SetRadius(self.Radius)
		util.Effect("eff_hg_fire", Foof, true, true)
	end
	if SERVER then
		for key, obj in ipairs(ents.FindInSphere(SelfPos, self.Radius)) do
			if vfireshit[ obj:GetClass() ] then continue end
			if (obj ~= self) and not obj:IsOnFire() then
				--print(mattypes[obj:GetMaterialType()]) -- WORKING!! :steamhappy:
				local Dist = (obj:GetPos() - self:GetPos()):Length()
				local Frac = 1 - (Dist / self.Radius)
				if self:Visible(obj) then
					local Dmg = DamageInfo()
					-- если создается огонь то ему нужно будет назначить ent.Initiator (это чето типо овнера)
					Dmg:SetAttacker(IsValid(self.Initiator) and self.Initiator or self or game.GetWorld())
					Dmg:SetInflictor(self)
					Dmg:SetDamageType(DMG_BURN)
					Dmg:SetDamagePosition(SelfPos)
					Dmg:SetDamageForce(vector_origin)
					local dmgmul = obj:WaterLevel() < 1 and Frac * 0.6 or Frac * 0.2
					if obj:IsRagdoll() then dmgmul = Frac * 0.3 end
					Dmg:SetDamage(dmgmul)
					obj:TakeDamageInfo(Dmg)
					Frac = math.max(Frac,0)
					if IsValid(obj) and obj:IsPlayer() and obj:Alive() then
						local org = obj.organism
						
						if org then
							org.lungsL[1] = math.min(org.lungsL[1] + 0.03 * math.min(Frac,0.4),1)
							org.lungsR[1] = math.min(org.lungsR[1] + 0.03 * math.min(Frac,0.4),1)
						end
					end
					if IsValid(obj) and ((not obj:IsPlayer()) and not obj:IsOnFire() and obj:WaterLevel() < 1) then 
						obj:Ignite() 
					end
				end
			end
		end
		if self.NextSound < CurTime() then
			self.NextSound = CurTime() + 7

			sound.Play("snd_jack_firebomb.wav", SelfPos, 80, 100)
			hg.EmitAISound(SelfPos, 300, 7, 8)
		end

		if self.NextParticle < CurTime() then
			self.NextParticle = CurTime() + 1
			
			if self.spawntime + 0 > CurTime() then return end

			if (self.particles < self.totalparticles) and ((math.Round(CurTime() - self.spawntime) % 3) == 0) then
				table.insert(hg.particles,{SelfPos,VectorRand(-15,15),CurTime() + 120})
				self.particles = self.particles + 1
			end

			if (self.particles == self.totalparticles) then
				return
			end
		end

		if self:WaterLevel() > 0 then
			self.Radius = self.Radius - 6
		else
			self.Radius = self.Radius + (self.Small and 2 or 4)
		end

		if self.Radius < 1 then SafeRemoveEntity(self) end
		self:NextThink(CurTime() + .2)
	end
	return true
end

local time2 = CurTime()
hook.Add("Think","hg_fire_particles",function()
	if time2 >= CurTime() then return end
	time2 = CurTime() + 1
	
	--hg.particles.count = 0
	local co = coroutine.create(function()
		local LastUpdate = SysTime()
		for i = #hg.particles, 1, -1 do--lua is awful
			LastUpdate = SysTime()
			local tbl = hg.particles[i]--i have to do ts so tables iterate normally

			if not tbl then table.remove(hg.particles, i) continue end

			local pos, vel, time = tbl[1], tbl[2], tbl[3]

			if time < CurTime() then table.remove(hg.particles, i) continue end

			--hg.particles.count = hg.particles.count + 1

			tbl[2] = vel + vector_up * 1

			local tr = util.TraceLine({start = pos,endpos = pos + vel,mask = MASK_SOLID_BRUSHONLY})

			tbl[1] = (tr.Hit and tr.HitPos or pos + vel)

			local velLen = vel:Length()
			if tr.Hit then
				local vec = vel:Angle()
				vec:RotateAroundAxis(tr.HitNormal, 180)
				tbl[2] = (-vec:Forward() * velLen ) + vector_up * 3
			end

			if tr.HitSky then
				table.remove(hg.particles, i)
				continue
			end

			local size = math.max( math.min((1-math.abs( ((time) - CurTime() )/120 ))*2.5,1), 0 )
			for i, ent in ipairs(ents_FindInSphere(pos,256*size)) do
				if not ent.organism then return end
				if ent:IsPlayer() and not ent:Alive() then continue end--fucking idiot
				local org = ent.organism
				local owner = org.owner
				if owner != ent and ent:IsRagdoll() then continue end
				if not hg.isVisible(pos,ent:EyePos(), ent, MASK_SOLID_BRUSHONLY) then continue end
				if !org.lungsfunction or org.holdingbreath then continue end
				if org.superfighter then continue end
				if ent.armors and ent.armors.face == "mask2" then continue end //пофиг, пусть будет

				ent.nextCoughHuy = ent.nextCoughHuy or CurTime()
				if ent.nextCoughHuy < CurTime() and not org.otrub then
					ent.nextCoughHuy = CurTime() + math.Rand(2,10)
					hg.organism.module.random_events.TriggerRandomEvent(hg.RagdollOwner(ent) or ent, "Cough")
				end

				org.COregen = math.Approach(org.COregen, 60, 2 * size)
			end

			LastUpdate = SysTime() - LastUpdate

			if LastUpdate > 0.001 then
				coroutine.yield()
			end
		end
		
	end)

	if #hg.particles > 0 then
		coroutine.resume(co)
	end
	--if #hg.particles > 0 then -- все же не хочу чтобы срало ГОВНОМ КАЖДЫЙ ТИК, пусть будет невидимый.
		--net.Start("fire_debug")
		--	net.WriteTable(hg.particles)
		--net.Broadcast()
	--end
end)

hook.Add("PostCleanupMap","removeparticlesfire",function()
	table.Empty(hg.particles)
end)