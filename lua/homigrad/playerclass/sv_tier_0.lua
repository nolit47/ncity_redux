local classList = player.classList
local Player = FindMetaTable("Player")
function Player:SetPlayerClass(value, bNoWeapons)
	value = value or "none"
	local old = self.PlayerClassName
	self.PlayerClassNameOld = old
	old = classList[old]
	if old and old.Off then old.Off(self) end
	self.PlayerClassName = value
	self:PlayerClassEvent("On", bNoWeapons) -- WHO WRITE THIS SHIT
    net.Start("setupclass")
        net.WriteEntity(self)
        net.WriteString(value)
        net.WriteString(self.PlayerClassNameOld or "")
        net.WriteTable({})
    net.Broadcast()
end

function Player:GiveSwep(list, mulClip1) -- улучшенный tdm.GiveSwep
	if not list then return end
	local wep = self:Give(type(list) == "table" and list[math.random(#list)] or list)
	mulClip1 = mulClip1 or 3
	if IsValid(wep) then
		wep:SetClip1(wep:GetMaxClip1())
		self:GiveAmmo(wep:GetMaxClip1() * mulClip1, wep:GetPrimaryAmmoType())
	end
end

util.AddNetworkString("setupclass")
hook.Add("PlayerInitializeSpawn", "PlayerClass", function(plySend)
	for i, ply in pairs(player.GetAll()) do
		if not ply:GetPlayerClass() then continue end
        net.Start("setupclass")
        net.WriteEntity(ply)
        net.WriteString(ply:GetNWString("Class"))
        net.WriteString(ply:GetNWString("ClassOld"))
        net.WriteTable({})
        net.Send(plySend)
	end
end)

hook.Add("PlayerDeath", "PlayerClass", function(ply, inf, att)
	if IsValid(att) and att:IsPlayer() then att:PlayerClassEvent("PlayerKill", ply) end
	ply:PlayerClassEvent("PlayerDeath", att)
end)

hook.Add("Player Think", "PlayerClass", function(ply) end)
hook.Add("Move", "PlayerClass", function(ply,mv)  end)
