AddCSLuaFile()
hg.ammotypes = hg.ammotypes or {}

/*
BulletSettings = {
			Damage = 8,
			Force = 5,
			Penetration = 4,
			Shell = "9x18",
			Speed = 259,
			Diameter = 11.19,
			Distance = 10,
			Mass = 10,
			AirResistMul = 0.0001,
			NumBullet = 1,
		}
*/

-- Локализация
local lang = {
	["en"] = {
		["unload_ammo"] = "Unload Ammo",
		["change_ammo_type"] = "Change Ammo Type",
		["changed_ammotype"] = "Changed ammotype to: "
	},
	["ru"] = {
		["unload_ammo"] = "Разрядить оружие",
		["change_ammo_type"] = "Сменить тип патронов",
		["changed_ammotype"] = "Тип патронов изменён на: "
	}
}

-- Функция получения локализованного текста
local function GetText(key, ply)
	local playerLang = "en"
	
	if CLIENT then
		playerLang = GetConVar("gmod_language"):GetString()
		if playerLang ~= "en" and playerLang ~= "ru" then
			playerLang = "en"
		end
	elseif SERVER and IsValid(ply) then
		playerLang = ply:GetInfoNum("gmod_language", 0) == 0 and "en" or "ru"
	end
	
	return lang[playerLang] and lang[playerLang][key] or lang["en"][key]
end

function SWEP:ApplyAmmoChanges(type_)
	if not self.AmmoTypes or not istable(self.AmmoTypes) then
		print("ЭРРАР: Таблица не валдинайа")
		return
	end

	local ammo = self.AmmoTypes[type_]
	if not ammo then
		print("ЭРРАР: ИНВАЛИД ТИП ПАТРОНААА")
		return
	end

	local ammohuy = hg.ammotypeshuy[ammo[1]]
	if not ammohuy then
		print("ЭРРАР: говно с патриками в hg.ammotypeshuy")
		return
	end

	local ammotype = ammohuy.BulletSettings
	if not ammotype then
		print("ЭРРАР: Нет настройек огузки") -- дека дебил
		return
	end

	self.Primary.Ammo = ammo[1]
	self.newammotype = type_
	self.RealAmmoType = ammo[1]
	self.Primary.Damage = ammotype.Damage
	self.Penetration = ammotype.Penetration
	self.NumBullet = ammotype.NumBullet
	--self.Primary.Force = ammotype.Force

	if SERVER then
		net.Start("syncAmmoChanges")
		net.WriteEntity(self)
		net.WriteInt(type_, 4)
		net.Broadcast()
	end
end


if SERVER then
	util.AddNetworkString("syncAmmoChanges")
else
	net.Receive("syncAmmoChanges", function()
		local self = net.ReadEntity()
		local type_ = net.ReadInt(4)
		if self.ApplyAmmoChanges then
			self:ApplyAmmoChanges(type_)
		end
	end)
end

if CLIENT then
	 
	hg.weapons = hg.weapons or {}
	concommand.Add("hg_unload_ammo", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		if wep and ishgweapon(wep) and wep:Clip1() > 0 and wep:CanUse() then
			net.Start("unload_ammo")
			net.WriteEntity(wep)
			net.SendToServer()
			wep:SetClip1(0)
			wep.drawBullet = nil
		end
	end)

	concommand.Add("hg_change_ammotype", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		local type_ = math.Round(args[1])
		if wep and ishgweapon(wep) and wep:Clip1() == 0 or wep.AllwaysChangeAmmo and wep:CanUse() and wep.AmmoTypes and wep.AmmoTypes[type_] then
			--wep:ApplyAmmoChanges(type_)
			ply:ChatPrint(GetText("changed_ammotype", ply) .. wep.AmmoTypes[type_][1])
			net.Start("changeAmmoType")
			net.WriteEntity(wep)
			net.WriteInt(type_, 4)
			net.SendToServer()
		end
	end)

	local function unloadAmmo()
		RunConsoleCommand("hg_unload_ammo")
	end

	local function changeAmmoType(chosen)
		RunConsoleCommand("hg_change_ammotype", chosen)
	end

	hook.Add("radialOptions", "2", function()
		local wep = LocalPlayer():GetActiveWeapon()
		local organism = LocalPlayer().organism or {}

		if organism.otrub then return end

		if IsValid(wep) and ishgweapon(wep) then
			if (wep:Clip1() == 0 or wep.AllwaysChangeAmmo) and wep.AmmoTypes and not wep.reload then
				
				local ammotypes = {}
				for k,ammotype in ipairs(wep.AmmoTypes) do
					ammotypes[k] = ammotype[1]
				end 
				local tbl = {
					changeAmmoType,
					GetText("change_ammo_type"),
					true,
					ammotypes
				}

				hg.radialOptions[#hg.radialOptions + 1] = tbl
			elseif wep:Clip1() > 0 then
				local tbl = {unloadAmmo, GetText("unload_ammo")}
				hg.radialOptions[#hg.radialOptions + 1] = tbl
			end
		end
	end)

	net.Receive("unload_ammo",function()
		local wep = net.ReadEntity()
		if wep.Unload then
			wep:Unload()
		end
	end)
else
	util.AddNetworkString("unload_ammo")
	util.AddNetworkString("changeAmmoType")
	net.Receive("unload_ammo", function(len, ply)
		local wep = net.ReadEntity()
		wep.drawBullet = nil
		if wep and wep:GetOwner() == ply and ishgweapon(wep) and wep:Clip1() > 0 and wep:CanUse() then
			ply:GiveAmmo(wep:Clip1(), wep:GetPrimaryAmmoType(), true)
			wep:SetClip1(0)
			if wep.Unload then
				wep:Unload()
			end
			net.Start("unload_ammo")
			net.WriteEntity(wep)
			net.Broadcast()
			hg.GetCurrentCharacter(ply):EmitSound("snd_jack_hmcd_ammotake.wav")
		end
	end)

	net.Receive("changeAmmoType", function(len, ply)
		local wep = net.ReadEntity()
		local type_ = net.ReadInt(4)
		if wep and ishgweapon(wep) and wep:Clip1() == 0 or wep.AllwaysChangeAmmo and wep:CanUse() and wep.AmmoTypes and wep.AmmoTypes[type_] then wep:ApplyAmmoChanges(type_) end
	end)
	--bruh probably need to broadcast this bullshit after
end