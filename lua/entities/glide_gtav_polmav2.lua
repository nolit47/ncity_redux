-- "addons\\glide_gtav_helicopters_3389795738\\lua\\entities\\glide_gtav_polmav2.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_polmav"
ENT.PrintName = "Maverick (Ambulance)"

if SERVER then
    ENT.ChassisMass = 500
    ENT.ChassisModel = "models/gta5/vehicles/polmav/polmav2_body.mdl"
end
