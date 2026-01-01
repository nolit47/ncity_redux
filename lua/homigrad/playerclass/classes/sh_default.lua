-- "addons\\homigrad\\lua\\homigrad\\playerclass\\classes\\sh_default.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local CLASS = player.RegClass("default")

function CLASS.Off(self)
    if CLIENT then return end
end

function CLASS.On(self)
    if CLIENT then return end

    ApplyAppearance(self)
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end
end

