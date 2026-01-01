if SERVER then AddCSLuaFile() end
ENT.Type = "anim"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "Projectile NoneExplosive Base"
ENT.Spawnable = false
ENT.AdminOnly = true

ENT.Model = ""
ENT.HitSound = "weapons/crossbow/hit1.wav"
ENT.FleshHit = "weapons/crossbow/bolt_skewer1.wav"

ENT.Damage = 200
ENT.Force = 0.2
// THE MOST PLUV
if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(1)
			phys:Wake()
		end
	end

	ENT.Hit = false

	function ENT:Hit(ent, hit_pos, phys_bone_id)
		self:SetPos(hit_pos)
		constraint.Weld(self, ent, 0, phys_bone_id, 0, true, false)
		
		local phys_obj = ent:GetPhysicsObjectNum(phys_bone_id)
		local offset_pos = nil
		local offset_ang = nil
		
		if(IsValid(phys_obj))then
			offset_pos, offset_ang = WorldToLocal(hit_pos, self:GetAngles(), phys_obj:GetPos(), phys_obj:GetAngles())
		end
		
		self.Hit = true
		ent.LodgedEntities = ent.LodgedEntities or {}
		ent.LodgedEntities[#ent.LodgedEntities + 1] = {
			Ent = self,
			PhysBoneID = phys_bone_id,
			OffsetPos = offset_pos,
			OffsetAng = offset_ang,
		}
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > .2 and data.Speed > 200 and !self.Hit then
            local dir = data.HitPos - (data.HitPos + self:GetAngles():Forward() * -5)
            --print(dir:GetNormalized())
            local hitNormal = data.HitNormal
            local ApproachAngle = math.deg(math.asin(hitNormal:DotProduct(dir:GetNormalized())))
	        local MaxRicAngle = 10
            --print(ApproachAngle)

            --if ApproachAngle < MaxRicAngle * 1 then 
            --        --[[local effectpoint = self:GetPos()
            --        timer.Simple(.1,function()
            --            local effectdata = EffectData()
            --            effectdata:SetOrigin( effectpoint )
            --            effectdata:SetScale(1)
            --            effectdata:SetMagnitude(2)
            --            effectdata:SetRadius(0.1)
            --            util.Effect( "Sparks", effectdata )
            --        end)
            --        local NewVec = dir:Angle()
            --        NewVec:RotateAroundAxis(hitNormal, 180)
            --        NewVec = NewVec:Forward()
            --        self:SetVelocity(self:GetAngles():Forward() * -1000)]]--
--
            --    return 
            --end

            timer.Simple(.1,function()
                local effectdata = EffectData()
                effectdata:SetOrigin( data.HitPos )
                effectdata:SetScale(0.1)
                effectdata:SetMagnitude(2)
                effectdata:SetRadius(0.1)
                util.Effect( "Sparks", effectdata )
            end)
			self:Hit(data.HitEntity, data.HitPos, 0)
            self:DamagePly(data.HitEntity,data.HitObject:GetMaterial(),data.HitPos) 
            return 
		end
	end

	function AeroDrag(ent, forward, mult, spdReq)
		if(constraint.HasConstraints(ent))then
			return
		end
		
		if ent:IsPlayerHolding() then return end
		local Phys = ent:GetPhysicsObject()
		if not IsValid(Phys) then return end
		local Vel = Phys:GetVelocity()
		local Spd = Vel:Length()
	
		if not spdReq then
			spdReq = 300
		end
	
		if Spd < spdReq then return end
		mult = mult or 1
		local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
		Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
		Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * Mass / 1000)
	end

    local vecSmoke = Vector(255,255,255)
    function ENT:Think()
		AeroDrag(self, self:GetAngles():Forward(), .6)
        self:NextThink(CurTime() + 0.1)
    end

	function ENT:Use(ply)
	end

	function ENT:OnTakeDamage(dmginfo)
	end
    local fleshmats = {
        ["flesh"] = true,
        ["player"] = true
    }
	function ENT:DamagePly(ent,mat,hitpos)
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self
        local DmgInfo = DamageInfo()
        DmgInfo:SetDamage(self.Damage)
        DmgInfo:SetDamageForce(self:GetAngles():Forward() * self.Force)
        DmgInfo:SetDamagePosition(hitpos)
        DmgInfo:SetDamageType(DMG_BULLET)
        DmgInfo:SetInflictor(self)
        DmgInfo:SetAttacker(self)
        ent:TakeDamageInfo(DmgInfo)
        --print(mat)
        self:EmitSound( fleshmats[mat] and self.FleshHit or self.HitSound)
        util.Decal( fleshmats[mat] and "Impact.Flesh" or "Impact.Concrete", SelfPos + self:GetAngles():Forward() * -5, SelfPos + self:GetAngles():Forward() * 500, self )
        self:Remove()
	end

elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
		
		if(self.PostDraw)then
			self:PostDraw()
		end
	end
end