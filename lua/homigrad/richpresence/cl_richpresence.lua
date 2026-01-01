-- "addons\\homigrad\\lua\\homigrad\\richpresence\\cl_richpresence.lua"

function StartDiscordPresence()
    if not util.IsBinaryModuleInstalled("gdiscord") then return end
    require("gdiscord")

    local discord_id = "842781900228657173"
    local refresh_time = 30
    local discord_start = -1

    local mapImages = {
        ["gm_flatgrass"] = "flatgrass_image",
        ["gm_construct"] = "construct_image",
        ["default"] = "default_image"
    }

    local function DiscordUpdate()
        local ply = LocalPlayer()

        local rpc_data = {}
        local ip = game.GetIPAddress()
        local showip = ip

        if ip == "loopback" then
            rpc_data["state"] = "Local Server"
            showip = "Local Server"
        end

        rpc_data["partySize"] = player.GetCount()
        rpc_data["partyMax"] = game.MaxPlayers()

        local map = game.GetMap()
        local imageKey = mapImages[map] or mapImages["default"]

        local gm = gmod.GetGamemode().Name .. " | " .. string.NiceName(zb ~= nil and zb.GetRoundName or map)
        local text = "Дом Пеннивайза | " .. gm .. " | " .. showip .. " | " .. (ply.exp or 0) .. " XP " .. math.Round(ply.skill or 0, 3) .. " Skill"

        rpc_data["details"] = text
        rpc_data["startTimestamp"] = discord_start
        rpc_data["largeImageKey"] = imageKey
        rpc_data["largeImageText"] = showip

        DiscordUpdateRPC(rpc_data)
    end

    timer.Simple(5, function()
        discord_start = os.time()

        DiscordRPCInitialize(discord_id)
        DiscordUpdate()

        if timer.Exists("UpdateDiscordRichPresence") then timer.Remove("UpdateDiscordRichPresence") end
        timer.Create("UpdateDiscordRichPresence", refresh_time, 0, DiscordUpdate)
    end)
end

function StartSteamPresence()
    if not util.IsBinaryModuleInstalled("steamrichpresencer") then return end
    require("steamrichpresencer")

    local richtext = ""
    local refresh_time = 30

    local function SteamUpdate()
        local ply = LocalPlayer()
        local gm = gmod.GetGamemode().Name .. " | " .. string.NiceName(zb ~= nil and zb.GetRoundName or game.GetMap())
        local ip = game.GetIPAddress()
        local showip = ip
        if ip == "loopback" then showip = "Local Server" end

        local updatedtext = gm .. " | " .. showip .. " | " .. (ply.exp or 0) .. " XP " .. math.Round(ply.skill or 0, 3) .. " Skill"

        if richtext ~= updatedtext then
            richtext = updatedtext
            steamworks.SetRichPresence("generic", richtext)
        end
    end

    timer.Simple(5, function()
        SteamUpdate()

        if timer.Exists("UpdateSteamRichPresence") then timer.Remove("UpdateSteamRichPresence") end
        timer.Create("UpdateSteamRichPresence", refresh_time, 0, SteamUpdate)
    end)
end

hook.Add("OnGamemodeLoaded", "UpdateDiscordStatus", function()
    StartDiscordPresence()
    StartSteamPresence()
end)

-- Debug print
-- print("steam: "..tostring(util.IsBinaryModuleInstalled("steamrichpresencer")),"discord: "..tostring(util.IsBinaryModuleInstalled("gdiscord")))
