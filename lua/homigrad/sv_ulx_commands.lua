
local function ensureOrg(ply)
    return IsValid(ply) and ply.organism
end


local function apply_modes(ply)
    if not IsValid(ply) or not ply.organism then return end
    local org = ply.organism

    if ply.__hg_godzcity then
        org.__godzcity = true
        org.bleedingmul = 0
        org.blood = math.max(org.blood or 0, 10000)
        org.godmode = true
        if ply.GodEnable then ply:GodEnable() end
    end

    if ply.__hg_boss then
        org.__bossMode = true
        org.blood = math.max(org.blood or 5000, 9000)
        org.bleedingmul = math.min(org.bleedingmul or 1, 0.2)
    end
end


local function ulx_boss(calling_ply, target_plys)
    for _, target_ply in ipairs(target_plys) do
        if not ensureOrg(target_ply) then continue end

        local org = target_ply.organism
        if target_ply.__hg_boss then
            if ULib and ULib.tsayError then ULib.tsayError(calling_ply, (IsValid(target_ply) and target_ply:Nick() or "Игрок") .. ": уже BOSS-режим активен", true) end
            continue
        end
        org.__bossMode = true
        target_ply.__hg_boss = true

      
        org.blood = math.max(org.blood or 5000, 9000) 
        org.bleedingmul = math.min(org.bleedingmul or 1, 0.2)

      
        if target_ply:Alive() then
            target_ply:SetHealth(math.max(target_ply:Health(), 150))
            target_ply:SetMaxHealth(math.max(target_ply:GetMaxHealth(), 150))
        end

        ulx.fancyLogAdmin(calling_ply, "#A включил BOSS-режим для #T", target_plys)
    end
end


local function ulx_godzcity(calling_ply, target_plys)
    for _, target_ply in ipairs(target_plys) do
        if not ensureOrg(target_ply) then continue end

        local org = target_ply.organism

        if target_ply.__hg_godzcity then
            if ULib and ULib.tsayError then ULib.tsayError(calling_ply, (IsValid(target_ply) and target_ply:Nick() or "Игрок") .. ": уже GODZCITY активен", true) end
            continue
        end

        org.__godzcity = true
        target_ply.__hg_godzcity = true
        org.bleedingmul = 0 
        org.blood = 10000
        org.godmode = true

        
        if target_ply.GodEnable then target_ply:GodEnable() end

        ulx.fancyLogAdmin(calling_ply, "#A включил GODZCITY для #T", target_plys)
    end
end


local function clear_modes(ply)
    if not ensureOrg(ply) then return end
    local org = ply.organism
    org.__bossMode = nil
    org.__godzcity = nil
    if org.superfighter then org.superfighter = false end
    org.fakeChance = nil
    org.bleedingmul = org.bleedingmul or 1
    if ply.GodDisable then ply:GodDisable() end
end


hook.Add("PreTraceOrganBulletDamage", "ulx_boss_reduce_trace_damage", function(org, boneMul, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
    if org and org.__bossMode and hook_info and hook_info.dmg then
        hook_info.dmg = hook_info.dmg * 0.35 
        return
    end
    if org and org.__godzcity and hook_info then
        hook_info.restricted = true 
    end
end)


hook.Add("PreHomigradDamageBulletBleedAdd", "ulx_boss_reduce_bleed", function(ply, org, dmgInfo, hitgroup, harm, hitBoxs, inputHole, hook_info)
    if org and org.__bossMode and hook_info and hook_info.bleed then
        hook_info.bleed = hook_info.bleed * 0.25
        return
    end
    if org and org.__godzcity and hook_info then
        hook_info.restricted = true 
    end
end)


local function register_ulx_cmds()
    if not ulx or not ULib or not ulx.command then return false end
    if _G.__hg_ulx_cmds_registered then return true end

    local cmd_boss = ulx.command("Organism", "ulx boss", ulx_boss, "!boss")
    cmd_boss:addParam{ type = ULib.cmds.PlayersArg }
    cmd_boss:defaultAccess(ULib.ACCESS_SUPERADMIN)
    cmd_boss:help("Сделать игрока очень крепким (много крови, кости/оглушение трудно пробить)")

    local cmd_godz = ulx.command("Organism", "ulx godzcity", ulx_godzcity, "!godzcity")
    cmd_godz:addParam{ type = ULib.cmds.PlayersArg }
    cmd_godz:defaultAccess(ULib.ACCESS_SUPERADMIN)
    cmd_godz:help("Полная защита от костей/оглушения и смерти от кровотечения")


    local function ulx_unboss(caller, targets)
        for _,ply in ipairs(targets) do
            if not ensureOrg(ply) then continue end
            ply.__hg_boss = nil
            if ply.organism then ply.organism.__bossMode = nil end
        end
        ulx.fancyLogAdmin(caller, "#A снял BOSS-режим с #T", targets)
    end

    local function ulx_ungodzcity(caller, targets)
        for _,ply in ipairs(targets) do
            if not ensureOrg(ply) then continue end
            ply.__hg_godzcity = nil
            if ply.organism then
                ply.organism.__godzcity = nil
                ply.organism.godmode = nil
                ply.organism.bleedingmul = 1
            end
            if ply.GodDisable then ply:GodDisable() end
        end
        ulx.fancyLogAdmin(caller, "#A снял GODZCITY с #T", targets)
    end

    local cmd_unboss = ulx.command("Organism", "ulx unboss", ulx_unboss, "!unboss")
    cmd_unboss:addParam{ type = ULib.cmds.PlayersArg }
    cmd_unboss:defaultAccess(ULib.ACCESS_SUPERADMIN)
    cmd_unboss:help("Снять режим BOSS")

    local cmd_ungodz = ulx.command("Organism", "ulx ungodzcity", ulx_ungodzcity, "!ungodzcity")
    cmd_ungodz:addParam{ type = ULib.cmds.PlayersArg }
    cmd_ungodz:defaultAccess(ULib.ACCESS_SUPERADMIN)
    cmd_ungodz:help("Снять режим GODZCITY")

    _G.__hg_ulx_cmds_registered = true
    return true
end

if not register_ulx_cmds() then
    hook.Add("Initialize", "hg_register_ulx_cmds", function()
        timer.Simple(1, register_ulx_cmds)
    end)
    hook.Add("OnGamemodeLoaded", "hg_register_ulx_cmds_gm", function()
        timer.Simple(1, register_ulx_cmds)
    end)
    timer.Create("hg_register_ulx_cmds_retry", 2, 10, function()
        if register_ulx_cmds() then timer.Remove("hg_register_ulx_cmds_retry") end
    end)
end


hook.Add("Org Clear", "hg_ulx_reapply_modes_orgclear", function(org)
    local ply = IsValid(org.owner) and org.owner:IsPlayer() and org.owner or nil
    if not ply then return end
    timer.Simple(0, function() apply_modes(ply) end)
end)

hook.Add("Player Spawn", "hg_ulx_reapply_modes_spawn", function(ply)
    timer.Simple(0, function() apply_modes(ply) end)
end)

hook.Add("Player Getup", "hg_ulx_reapply_modes_getup", function(ply)
    timer.Simple(0, function() apply_modes(ply) end)
end)


timer.Create("hg_ulx_modes_maintenance", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.__hg_boss or ply.__hg_godzcity then
            apply_modes(ply)
        end
    end
end)


hook.Add("EntityTakeDamage", "hg_ulx_godzcity_nodmg", function(ent, dmg)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    if ent.__hg_godzcity then
        dmg:ScaleDamage(0)
        return true
    end
end)


hook.Add("PlayerDeath", "hg_ulx_godzcity_nodeath", function(ply)
    if ply.__hg_godzcity then
        timer.Simple(0, function()
            if not IsValid(ply) then return end
            ply:Spawn()
            apply_modes(ply)
        end)
    end
end)

hook.Add("PlayerEnteredVehicle", "hg_ulx_reapply_modes_vehicle_enter", function(ply, veh, role)
    timer.Simple(0, function() apply_modes(ply) end)
    
    if not IsValid(ply) then return end
    local tid = "hg_ulx_vehicle_maint_" .. ply:EntIndex()
    timer.Create(tid, 0.1, 50, function()
        if not IsValid(ply) then timer.Remove(tid) return end
        apply_modes(ply)
        if not ply:InVehicle() then timer.Remove(tid) end
    end)
end)

hook.Add("PlayerLeaveVehicle", "hg_ulx_reapply_modes_vehicle_exit", function(ply, veh)
    timer.Simple(0, function() apply_modes(ply) end)
    if not IsValid(ply) then return end
    timer.Remove("hg_ulx_vehicle_maint_" .. ply:EntIndex())
end)


hook.Add("Think", "hg_ulx_modes_tick", function()
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end
        if not (ply.__hg_boss or ply.__hg_godzcity) then continue end

        local inGlideState = ply:InVehicle() or IsValid(ply.FakeRagdoll)
        if inGlideState then
            apply_modes(ply)
        end
    end
end)