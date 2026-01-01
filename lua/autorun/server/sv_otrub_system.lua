CreateConVar("hg_otrub", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "toggle otrub", 0, 1)

util.AddNetworkString("hg_sync_server_convar")

concommand.Add("hg_toggle_otrub", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then 
        print("ti ne admin nahui daun")
        return 
    end
    
    local hg_otrub = GetConVar("hg_otrub")
    local newValue = args[1] and tonumber(args[1]) or (hg_otrub:GetBool() and 0 or 1)
    
    hg_otrub:SetInt(newValue)
    
    local status = newValue == 1 and "enabled" or "disabled"
    print("Otrub system has been " .. status)
    net.Start("hg_sync_server_convar")
    net.WriteString("hg_otrub")
    net.WriteBool(newValue == 1)
    net.Broadcast()
end)
concommand.Add("hg_request_server_convars", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local hg_otrub = GetConVar("hg_otrub")
    
    net.Start("hg_sync_server_convar")
    net.WriteString("hg_otrub")
    net.WriteBool(hg_otrub:GetBool())
    net.Send(ply)
end)
hook.Add("PlayerInitialSpawn", "SyncServerConvars", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        
        local hg_otrub = GetConVar("hg_otrub")
        
        net.Start("hg_sync_server_convar")
        net.WriteString("hg_otrub")
        net.WriteBool(hg_otrub:GetBool())
        net.Send(ply)
    end)
end)

hook.Add("Org Think", "OtrubSystemToggle", function(owner, org, timeValue)
    if not IsValid(owner) then return end
    
    local hg_otrub = GetConVar("hg_otrub")
    if not hg_otrub or not hg_otrub:GetBool() then
        org.needotrub = false
        if org.otrub then
            org.otrub = false
            if owner:IsPlayer() and owner:Alive() then
            end
        end
    end
end)