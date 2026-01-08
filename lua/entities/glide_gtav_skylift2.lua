-- "addons\\glide_gtav_helicopters_3389795738\\lua\\entities\\glide_gtav_skylift2.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_skylift"
ENT.PrintName = "Skylift (No magnet)"

if SERVER then
    ENT.ChassisModel = "models/gta5/vehicles/skylift/skylift2_body.mdl"
    ENT.HasMagnet = false
end
