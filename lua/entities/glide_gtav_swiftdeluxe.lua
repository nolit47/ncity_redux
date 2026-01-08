-- "addons\\glide_gtav_helicopters_3389795738\\lua\\entities\\glide_gtav_swiftdeluxe.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

if not Glide then return end

ENT.GlideCategory = "GTAV_Helicopters"

ENT.Type = "anim"
ENT.Base = "glide_gtav_swift"
ENT.PrintName = "Swift Deluxe"

if SERVER then
    ENT.ChassisMass = 700
    ENT.ChassisModel = "models/gta5/vehicles/swiftdeluxe/swiftdeluxe_body.mdl"
end
