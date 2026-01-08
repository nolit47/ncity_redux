util.AddNetworkString("hg_add_equipment")
util.AddNetworkString("hg_drop_equipment")

net.Receive("hg_drop_equipment", function(len, ply)
    local equipment = net.ReadString()

    if not (ply.organism and ply.organism.canmove) then return end

    hg.DropArmor(ply, equipment)
end)

function hg.AddArmor(ply, equipment)
    if not IsValid(ply) then return end
	
	local can = hook.Run("CanEquipArmor", ply, equipment)
	
	if(can == false)then
		return nil
	end
	
    if equipment and istable(equipment) then
        for i,equipment1 in pairs(equipment) do
            hg.AddArmor(ply, equipment1)
        end
        return
    end
    equipment = string.Replace(equipment,"ent_armor_","")
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    for plc, arm in pairs(ply.armors) do
        if not hg.armor[plc] or not hg.armor[plc][arm] or not hg.armor[plc][arm].restricted then continue end
        if table.HasValue(hg.armor[plc][arm].restricted, placement) then
            return false
        end
    end

    if ply.armors[placement] and ply:IsPlayer() then
        if not hg.DropArmor(ply, ply.armors[placement]) then return false end
    end
    
    if hg.armor[placement][equipment].AfterPickup then
        hg.armor[placement][equipment].AfterPickup(ply)
    end

    ply.armors[placement] = equipment
    
    ply:SyncArmor()
    return true
end

function hg.DropArmorForce(ent, equipment)
    if not table.HasValue(ent.armors, equipment) then return false end
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end
    
    if hg.armor[placement][equipment] then
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(ent:GetPos())
        equipmentEnt:SetAngles(ent:GetAngles())

        if ent:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ent:SetNetVar("zableval_masku", false)
        end

        local phys = equipmentEnt:GetPhysicsObject()

        if IsValid(equipmentEnt) then table.RemoveByValue(ent.armors, equipment) end
        
        ent:SyncArmor()
        
        return equipmentEnt
    end
end

function hg.DropArmor(ply, equipment)
    if not table.HasValue(ply.armors, equipment) then return false end
    
    local placement
    for plc, tbl in pairs(hg.armor) do
        placement = tbl[equipment] and tbl[equipment][1] or placement
    end
    
    if hg.armor[placement][equipment].nodrop then return false end

    if not placement then
        print("sh_equipment.lua: no such equipment as: " .. equipment)
        return false
    end

    if IsValid(ply) and ply.DropCD and ply.DropCD > CurTime() then return false end

    if hg.armor[placement][equipment] then
        ply:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
	    ply:ViewPunch(Angle(1,-2,1))
        ply.DropCD = CurTime() + 0.35
        --timer.Simple(0.3,function()
        if not IsValid(ply) then return end
        local equipmentEnt = ents.Create("ent_armor_" .. equipment)
        equipmentEnt:Spawn()
        equipmentEnt:SetPos(ply:EyePos())
        equipmentEnt:SetAngles(ply:EyeAngles())
        
        if placement == "face" and ply:GetNetVar("zableval_masku", false) then
            equipmentEnt.zablevano = true
            ply:SetNetVar("zableval_masku", false)
        end
        
        local phys = equipmentEnt:GetPhysicsObject()
        if IsValid(phys) then phys:SetVelocity(ply:EyeAngles():Forward() * 150) end
        if IsValid(equipmentEnt) then table.RemoveByValue(ply.armors, equipment) end
        ply:SyncArmor()
        --end)
        return true
    end
end
