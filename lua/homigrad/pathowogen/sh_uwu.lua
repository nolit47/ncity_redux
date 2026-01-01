-- "addons\\homigrad\\lua\\homigrad\\pathowogen\\sh_uwu.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local function check(self, ent, ply)
    if not ply:ZCTools_GetAccess() then return false end 
	if ( !IsValid( ent ) ) then return false end
	if ( ent:IsPlayer() ) then return true end
    local pEnt = hg.RagdollOwner( ent )
    if ( ent:IsRagdoll() ) and pEnt and pEnt:IsPlayer() and pEnt:Alive() then return true end
end

properties.Add( "furrify", {
	MenuLabel = "Furrify :3", -- Name to display on the context menu
	Order = 10, -- The order to display this property relative to other properties
	MenuIcon = "vgui/entities/npc_nukude_proto_h", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()
        
		if not self:Filter(ent, ply) then return end
        ent = hg.RagdollOwner(ent) or ent

        hg.Furrify(ent)
    end 
} )