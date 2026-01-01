if SERVER then AddCSLuaFile() end
ENT.Base = "projectile_nonexplosive_base"
ENT.Author = "Sadsalat"
ENT.Category = "ZCity Other"
ENT.PrintName = "Crossbow Projectile"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Model = "models/crossbow_bolt.mdl"
ENT.HitSound = "weapons/crossbow/hit1.wav"

ENT.Damage = 350
ENT.Force = 10

ENT.DesiredSilks = {	--; WARNING POINTER
	{SegmentsDesiredAmt = 5, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
	{SegmentsDesiredAmt = 6, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2.1, 0, 0)},
	{SegmentsDesiredAmt = 10, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
}

function ENT:PostDraw()
	--if(hg.PhysSilk)then
	--	self.Silks = self.Silks or {}
--
	--	for silk_desired_key, silk_desired in ipairs(self.DesiredSilks) do
	--		if(IsValid(self.Silks[silk_desired_key]))then
	--			-- self.Silks[silk_desired_key].Pos = self:LocalToWorld(silk_desired.EntityOffset)
	--		else
	--			local silk = table.Copy(silk_desired)
	--			silk.Pos = self:LocalToWorld(silk_desired.EntityOffset)
	--			silk.Entity = self
	--			self.Silks[silk_desired_key] = hg.PhysSilk.CreateSilk(silk, true)
	--		end
	--	end
	--end
end