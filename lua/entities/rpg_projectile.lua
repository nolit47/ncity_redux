if SERVER then AddCSLuaFile() end
ENT.Base = "projectile_base"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "RPG-7 Rocket"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/weapons/tfa_ins2/w_rpg7_projectile.mdl"
ENT.Sound = "snd_jack_bigsplodeclose.wav"
ENT.SoundFar = "snd_jack_c4splodefar.wav"
ENT.SoundWater = "iedins/water/ied_water_detonate_01.wav"
ENT.Speed = 3000
ENT.TruhstTime = 0.4
ENT.IconOverride = "vgui/inventory/weapon_rpg7"

ENT.BlastDamage = 200
ENT.BlastDis = 7

local function superfightermoment(self, ent)
    if ent.organism and ent.organism.superfighter then
        if ent:IsPlayer() then hg.Fake(ent) end

        timer.Simple(0,function()
            local rag = hg.GetCurrentCharacter(ent)
            if IsValid(rag) and rag ~= ent then
                local phys = rag:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetMass(0)
                end
                rag:SetPos(self:GetPos())
                rag:SetParent(self)
                
                --[[timer.Simple(1, function()
                    rag:AddCallback("PhysicsCollide",function(asd, data)
                        if IsValid(self) and (data.HitEntity ~= self:GetPhysicsObject()) and (rag ~= data.HitEntity) then
                            self:Detonate()
                        end
                    end)
                end)--]]

                local cons = constraint.Weld(rag,self,1,0,0,true,true)
            end
        end)

        return true
    end
end

function ENT:AboutToHit2(trace)
    return superfightermoment(self, trace.Entity)
end

function ENT:PhysicsCollide2(data, physobj)
    if superfightermoment(self, data.HitEntity) and not self.dragvec then
        --self:SetVelocity(data.OurOldVelocity)
        --self:SetLocalAngularVelocity(data.OurOldAngularVelocity)
        self.dragvec = data.OurOldVelocity:GetNormalized()
        self.Truhst = CurTime() + 10
        return true
    end
end