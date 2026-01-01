local decalsNormal = {}
local decalsArterial = {}
for i=1, 10 do
    game.AddDecal( "Normal.Blood"..i, "decals/z_blood"..i )
    game.AddDecal( "Arterial.Blood"..i, "decals/arterial_blood"..i)
end

game.AddDecal( "Water.Blood", "effects/smoke_b" )
