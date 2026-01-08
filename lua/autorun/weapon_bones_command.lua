-- Console command to display bone indices for current weapon's WorldModelReal
-- Usage: weapon_bones in console

concommand.Add("weapon_bones", function(ply, cmd, args)
    -- Check if player is valid
    if not IsValid(ply) then
        print("Command must be run by a valid player")
        return
    end
    
    -- Get the player's active weapon
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then
        print("No active weapon found")
        return
    end
    
    -- Check if weapon has WorldModelReal defined
    if not weapon.WorldModelReal or weapon.WorldModelReal == "" then
        print("Current weapon has no WorldModelReal defined")
        print("Weapon: " .. (weapon.PrintName or weapon:GetClass()))
        return
    end
    
    print("=== Bone indices for weapon: " .. (weapon.PrintName or weapon:GetClass()) .. " ===")
    print("WorldModelReal: " .. weapon.WorldModelReal)
    print("")
    
    -- Create temporary entity to get bone info
    local tempEnt = ents.Create("prop_physics")
    if not IsValid(tempEnt) then
        print("Failed to create temporary entity")
        return
    end
    
    -- Set the model and spawn temporarily
    tempEnt:SetModel(weapon.WorldModelReal)
    tempEnt:SetPos(Vector(0, 0, 0)) -- Position doesn't matter for bone info
    tempEnt:SetAngles(Angle(0, 0, 0))
    tempEnt:Spawn()
    
    -- Get bone count
    local boneCount = tempEnt:GetBoneCount()
    
    if boneCount == 0 then
        print("No bones found in model")
    else
        print("Found " .. boneCount .. " bones:")
        print("Index | Bone Name")
        print("------|----------")
        
        -- Loop through all bones and print their info
        for i = 0, boneCount - 1 do
            local boneName = tempEnt:GetBoneName(i)
            print(string.format("%5d | %s", i, boneName or "Unknown"))
        end
    end
    
    -- Clean up the temporary entity
    tempEnt:Remove()
    
    print("")
    print("=== End of bone list ===")
end, nil, "Display bone indices for current weapon's WorldModelReal model")