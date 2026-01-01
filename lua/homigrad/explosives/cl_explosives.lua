-- "addons\\homigrad\\lua\\homigrad\\explosives\\cl_explosives.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--
local ExplosiveSound = {
    Fire = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"}
    },
    Sharpnel = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"}
    },
    Normal = {
        Near = {"ied/ied_detonate_01.wav","ied/ied_detonate_02.wav","ied/ied_detonate_03.wav"},
        Far = {"ied/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"}
    }
}

local function PlaySndDist(snd,snd2,pos,isOnWater,watersnd)
    if SERVER then return end
    local view = render.GetViewSetup(true)
    local time = pos:Distance(view.origin) / 17836
    --print(time)
    timer.Simple(time, function()
        local owner = Entity(0)
        if not isOnWater then
            EmitSound(snd2, pos, 0, CHAN_WEAPON, 1, 110, 0, 100, 0, nil)
            EmitSound(snd, pos, 0, CHAN_AUTO, 1, time > 0.6 and 140 or 110, 0, 100, 0, nil)
        else
            EmitSound(watersnd, pos, 0, CHAN_WEAPON, 1, 100, 0, 85, 0, nil)
        end
    end)
end

net.Receive("hg_booom",function()
    local pos = net.ReadVector()
    local type = net.ReadString()

    PlaySndDist(table.Random(ExplosiveSound[type].Near),table.Random(ExplosiveSound[type].Far),pos,false,"huy")
end)