AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Animated Model"
ENT.Category = "ZCity Other"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true -- Must be set on client

function ENT:Think()

	self:NextThink( CurTime() )

	return true
end



function ENT:Draw( flags )

	self:SetRenderBounds( self:GetModelBounds() )

	self:DrawModel( flags )

end