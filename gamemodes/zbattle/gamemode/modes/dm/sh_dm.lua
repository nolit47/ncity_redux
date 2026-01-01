
local MODE = MODE

MODE.MapSize = 7500
MODE.ZoneTimeToShrink = 120

function MODE.GetZoneRadius()
	if !zonedistance or !isnumber(zonedistance) then return 0xFFFFFFFF /*UUUUUUUUUUUUUUUUUCK*/ end
	local dist = zonedistance + 2048
	
	return (dist * math.max(((zb.ROUND_START + MODE.ZoneTimeToShrink) - CurTime()) / MODE.ZoneTimeToShrink, 0.025))
end

hook.Add( "StartCommand", "DisallowShostingasdasd", function( ply, mv )
	if zb.CROUND == "dm" and (zb.ROUND_START or 0) + 20 > CurTime() then
		mv:RemoveKey(IN_ATTACK) mv:RemoveKey(IN_ATTACK2)
	end
end)