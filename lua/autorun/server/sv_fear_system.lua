CreateConVar("hg_fear", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "toggle fear system", 0, 1)

util.AddNetworkString("hg_sync_fear_convar")

concommand.Add("hg_toggle_fear", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then 
        print("poshel nahui")
        return 
    end
    
    local hg_fear = GetConVar("hg_fear")
    local newValue = args[1] and tonumber(args[1]) or (hg_fear:GetBool() and 0 or 1)
    
    hg_fear:SetInt(newValue)
    
    local status = newValue == 1 and "enabled" or "disabled"
    net.Start("hg_sync_fear_convar")
    net.WriteString("hg_fear")
    net.WriteBool(newValue == 1)
    net.Broadcast()
end)

concommand.Add("hg_request_fear_convar", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local hg_fear = GetConVar("hg_fear")
    
    net.Start("hg_sync_fear_convar")
    net.WriteString("hg_fear")
    net.WriteBool(hg_fear:GetBool())
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn", "SyncFearConvar", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        
        local hg_fear = GetConVar("hg_fear")
        
        net.Start("hg_sync_fear_convar")
        net.WriteString("hg_fear")
        net.WriteBool(hg_fear:GetBool())
        net.Send(ply)
    end)
end)

hook.Add("Org Think", "FearSystemToggle", function(owner, org, timeValue)
    if not IsValid(owner) then return end
    
    local hg_fear = GetConVar("hg_fear")
    if not hg_fear or not hg_fear:GetBool() then
        org.fear = 0
        org.fearadd = 0
    end
end)