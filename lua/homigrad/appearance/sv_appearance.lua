// Appearance Code -- Надо было вообще давно так сделать
util.AddNetworkString("GetAppearance")
util.AddNetworkString("Get_Appearance")
util.AddNetworkString("OnlyGet_Appearance")

local allowed = {
    ' ',
    'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я',
    'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', 'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
}
local function IsInvalidName(name)
    local trimmedName = string.Trim(name)
    
    if trimmedName == "" then
        return true
    end

    --if string.find(trimmedName, "ㅤ") then
        --return true
    --end

    if #trimmedName < 2 then
        return true
    end
    
    local symblos = utf8.len( name )

    for k=1, symblos do
        if !table.HasValue(allowed, utf8.GetChar(name,k) ) then return true end
    end

    return false
end



local function GenerateRandomName(ply)
    local gender = math.random(1, 2) 
    local randomName = hg.Apperance.RandomNames[gender][math.random(1, #hg.Apperance.RandomNames[gender])]
    return randomName
end
hg.PointShop = hg.PointShop or {}
local PLUGIN = hg.PointShop

function ApplyAppearance(ply, appearance)
    GetAppearance(ply)

    local Appearance = appearance or ply.Appearance or GetRandomAppearance(ply)
    local currentName = Appearance.Name

    if IsInvalidName(currentName) then
        local randomName = GenerateRandomName(ply)
        ply:SetNWString("PlayerName", randomName)
        if ply.ChatPrint then ply:ChatPrint("You have an invalid name in appearance, changing to: " .. randomName) end
        Appearance.Name = randomName
    else
        ply:SetNWString("PlayerName", currentName)
    end

    if Appearance.СlothesStyle and not Appearance.ClothesStyle then
        Appearance.ClothesStyle = Appearance.СlothesStyle
    end 

    if  istable(Appearance.Gender) or
        istable(Appearance.Model) or 
        istable(Appearance.ClothesStyle) or 
        not table.HasValue(hg.Apperance.PlayerModels[Appearance.Gender],string.lower(Appearance.Model)) or 
        not table.HasValue(hg.Apperance.AllowClothesTexture,string.lower(Appearance.ClothesStyle)) then 
            ply:ChatPrint("zcity/appearance.json have invalid variables.. Seting random Appearance") 
            Appearance = GetRandomAppearance(ply)
    end

    ply:SetModel(Appearance.Model)
    if ply.SetPlayerColor then 
        ply:SetPlayerColor(Vector(Appearance.Color.r / 255,Appearance.Color.g / 255,Appearance.Color.b / 255))
    else
        ply:SetNWVector("PlayerColor",Vector(Appearance.Color.r / 255,Appearance.Color.g / 255,Appearance.Color.b / 255))
    end

    ply:SetSubMaterial()
    ply:SetSubMaterial(hg.Apperance.SubMaterials[string.lower(Appearance.Model)], Appearance.ClothesStyle)
    ply:SetNWString("PlayerName",Appearance.Name)


    if istable(Appearance.Attachmets) then
        for i=1, #Appearance.Attachmets do
            local uid = Appearance.Attachmets[i]
        end
    else
        local uid = Appearance.Attachmets
    end

    ply:SetNetVar("Accessories", Appearance.Attachmets)

    local gender = Appearance.Gender or 1
    if Appearance.ABGroups and hg.Apperance and hg.Apperance.ZCityTops then
        local preset = hg.Apperance.ZCityTops[Appearance.ABGroups.Top or "Normal"]
        if preset then
            for _, pair in ipairs(preset) do
                local p = pair[gender]
                if p then ply:SetBodygroup(p[1], p[2]) end
            end
        end
    end
    if Appearance.ABGroups and hg.Apperance and hg.Apperance.ZCityPants then
        local preset = hg.Apperance.ZCityPants[Appearance.ABGroups.Pants or "Normal"]
        if preset then
            for _, pair in ipairs(preset) do
                local p = pair[gender]
                if p then ply:SetBodygroup(p[1], p[2]) end
            end
        end
    end
    -- не применяем ASubMats, чтобы не затирать материал кожи/одежды

    ply.CurAppearance = {}
    table.CopyFromTo(Appearance, ply.CurAppearance)
end

--[[
    local DefaultApperanceTable = {
        Gender = 0, --  (1) = male or (2) = female  / FUCK YOU IF YOU WANNA BE NI...
        Name = "", -- Player CustomName...
        Model = "", -- GMODModel?
        Color = Color(255,255,255),
        ClothesStyle = "",  -- "normal" = Standard GMOD
        Attachmets = "" -- Таблица внешней одежды по типу шапки и так далее... -- Потом! -- Таблицу потом? Фурри мальчик садсалат???
    }
]]

function ApplyForceAppearance(ply, appearance)
    GetAppearance(ply)

    local Appearance = appearance or ply.Appearance or GetRandomAppearance(ply)
    local currentName = Appearance.Name

    ply:SetNWString("PlayerName", currentName)

    if Appearance.СlothesStyle and not Appearance.ClothesStyle then
        Appearance.ClothesStyle = Appearance.СlothesStyle
    end 

    ply:SetModel(Appearance.Model)
    if ply.SetPlayerColor then 
        ply:SetPlayerColor(Vector(Appearance.Color.r / 255,Appearance.Color.g / 255,Appearance.Color.b / 255))
    else
        ply:SetNWVector("PlayerColor",Vector(Appearance.Color.r / 255,Appearance.Color.g / 255,Appearance.Color.b / 255))
    end

    ply:SetSubMaterial()
    if Appearance.ClothesStyle then
        ply:SetSubMaterial(hg.Apperance.SubMaterials[string.lower(Appearance.Model)], Appearance.ClothesStyle)
    end
    ply:SetNWString("PlayerName",Appearance.Name)
    ply:SetNetVar("Accessories", Appearance.Attachmets)

    local gender = Appearance.Gender or 1
    if Appearance.ABGroups and hg.Apperance and hg.Apperance.ZCityTops then
        local preset = hg.Apperance.ZCityTops[Appearance.ABGroups.Top or "Normal"]
        if preset then
            for _, pair in ipairs(preset) do
                local p = pair[gender]
                if p then ply:SetBodygroup(p[1], p[2]) end
            end
        end
    end
    if Appearance.ABGroups and hg.Apperance and hg.Apperance.ZCityPants then
        local preset = hg.Apperance.ZCityPants[Appearance.ABGroups.Pants or "Normal"]
        if preset then
            for _, pair in ipairs(preset) do
                local p = pair[gender]
                if p then ply:SetBodygroup(p[1], p[2]) end
            end
        end
    end
    -- не применяем ASubMats, чтобы не затирать материал кожи/одежды

    ply.CurAppearance = {}
    table.CopyFromTo(Appearance, ply.CurAppearance)
end

local function ConvertNewAppearanceToOld(tbl)
    if not istable(tbl) then return nil end
    local modelName = tbl.AModel
    local pm = hg.Appearance and hg.Appearance.PlayerModels or {}
    local meta = (pm[1] and pm[1][modelName]) or (pm[2] and pm[2][modelName])
    local model = meta and meta.mdl or modelName
    local gender = meta and (meta.sex and 2 or 1) or 1
    local clothesKey = tbl.AClothes and tbl.AClothes.main or nil
    local clothesPath
    if clothesKey and hg.Appearance and hg.Appearance.Clothes and hg.Appearance.Clothes[gender] then
        clothesPath = hg.Appearance.Clothes[gender][clothesKey]
    end
    local name = tbl.AName or ""
    local color = tbl.AColor or Color(255,255,255)
    local attaches = tbl.AAttachments or {}
    local abgroups = tbl.ABGroups or {}
    local asubmats = tbl.ASubMats or {}
    local out = {
        Gender = gender,
        Name = name,
        Model = model,
        Color = color,
        ClothesStyle = clothesPath,
        Attachmets = attaches,
        ABGroups = abgroups,
        ASubMats = asubmats,
        AAccessorySkins = tbl.AAccessorySkins or {},
        AAccessoryBodygroups = tbl.AAccessoryBodygroups or {}
    }
    return out
end

net.Receive("OnlyGet_Appearance", function(len, ply)
    local tbl = net.ReadTable() or {}
    local converted = ConvertNewAppearanceToOld(tbl)
    if converted then
        if engine.ActiveGamemode() ~= "sandbox" then
            ply.Appearance = converted
            return
        end
        ApplyForceAppearance(ply, converted)
        -- propagate accessory overrides for clientside rendering
        if converted.AAccessorySkins then
            ply:SetNetVar("AccessorySkins", converted.AAccessorySkins)
        end
        if converted.AAccessoryBodygroups then
            ply:SetNetVar("AccessoryBodygroups", converted.AAccessoryBodygroups)
        end
    end
end)

net.Receive("Get_Appearance", function(len, ply)
    local tbl = net.ReadTable() or {}
    local isRandom = net.ReadBool() or false
    local toUse = tbl
    if isRandom then
        toUse = hg.Appearance and hg.Appearance.GetRandomAppearance and hg.Appearance.GetRandomAppearance() or {}
    end
    local converted = ConvertNewAppearanceToOld(toUse)
    if converted then
        if engine.ActiveGamemode() ~= "sandbox" then
            ply.Appearance = converted
            return
        end
        ApplyAppearance(ply, converted)
        if converted.AAccessorySkins then
            ply:SetNetVar("AccessorySkins", converted.AAccessorySkins)
        end
        if converted.AAccessoryBodygroups then
            ply:SetNetVar("AccessoryBodygroups", converted.AAccessoryBodygroups)
        end
    end
end)



--воскрешение джоела
--[[local ply = Player(38)
local ent = ply:GetEyeTrace().Entity
local joel = ply.CurAppearance
if IsValid(ent) then
    ent.Appearance = joel
    ApplyAppearance(ent)
    for i,ply in RandomPairs(player.GetAll()) do
        if not ply:Alive() then
            ply:Spawn()
            hg.Fake(ply,ent)
        end
    end
end--]]

--[[
local ply = Player(38)
local tr = ply:GetEyeTrace()
local ent = ents.Create('prop_ragdoll')
ent:SetModel('models/Humans/group01/Female_04.mdl')
ent:SetPos(tr.HitPos)
ent:Spawn()
ApplyAppearance(ent)
ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
hg.organism.Add(ent)
hg.organism.Clear(ent.organism)
--]]
-- Player(4):SetNetVar("Accessories", {"aviators","fedora"})

net.Receive("GetAppearance",function(len, ply) -- SERVER
    ply.Appearance = net.ReadTable()

    ply.Appearance.Attachmets = istable(ply.Appearance.Attachmets) and ply.Appearance.Attachmets or {ply.Appearance.Attachmets}

    local tbl = {}
    for i, app in pairs(ply.Appearance.Attachmets) do
        if #tbl > 3 and ply.ChatPrint then ply:ChatPrint("[GLOBAL]: "..ply:Name().." is a transgender!") break end -- оставим 3 чтобы прикольно было
        if table.HasValue(tbl, app) then continue end --ply:ChatPrint("So gay...") мне эту парашу каждый респавн пишет даже когда у меня нету нихера
        if !hg.Accessories[app] and ply.ChatPrint then ply:ChatPrint("You like kissing boys, don't you?") continue end
        tbl[#tbl + 1] = app
    end

    ply.Appearance.Attachmets = tbl
end)

function ApplyAppearanceRagdoll(ent, ply)
    if (IsValid(ent) or IsValid(ply)) then
        --GetAppearance(ply)
        local Appearance = ply.CurAppearance or hg.Apperance.DefaultApperanceTable
        --PrintTable(ply.Appearance)
        --PrintTable(Appearance)
       -- ent:SetSubMaterial()
        --ent:SetSubMaterial(SubMaterials[Appearance.Model],Appearance.ClothesStyle)
        ent:SetNWString("PlayerName",ply:GetNWString("PlayerName", "unknown"))
        ent:SetNetVar("Accessories", ply:GetNetVar("Accessories", "none"))
        -- sync accessory overrides to ragdoll as well
        ent:SetNetVar("AccessorySkins", ply:GetNetVar("AccessorySkins", {}))
        ent:SetNetVar("AccessoryBodygroups", ply:GetNetVar("AccessoryBodygroups", {}))
    end
end

hook.Add("PlayerDeath","setaccessories",function(ply)
    if IsValid(ply.FakeRagdoll) then
        local Appearance = ply.CurAppearance or hg.Apperance.DefaultApperanceTable
        ply.FakeRagdoll:SetNetVar("Accessories", ply:GetNetVar("Accessories"))
        ply.FakeRagdoll:SetNetVar("AccessorySkins", ply:GetNetVar("AccessorySkins", {}))
        ply.FakeRagdoll:SetNetVar("AccessoryBodygroups", ply:GetNetVar("AccessoryBodygroups", {}))
    end
end)

if engine.ActiveGamemode() == "sandbox" then
	hook.Add("PlayerInitialSpawn","SetAppearance",function(ply)
		timer.Simple(0,function()
			ApplyAppearance(ply)
		end)
	end)
	hook.Add("PlayerSetModel","KeepAppearancePreset",function(ply)
		ply._nextAppearanceApply = ply._nextAppearanceApply or 0
		if ply._nextAppearanceApply > CurTime() then return end
		ply._nextAppearanceApply = CurTime() + 0.25
		local app = ply.CurAppearance or ply.Appearance
		if app then
			timer.Simple(0,function()
				if not IsValid(ply) then return end
				ApplyForceAppearance(ply, app)
			end)
		else
			GetAppearance(ply)
			timer.Simple(0.1,function()
				if not IsValid(ply) then return end
				if ply.Appearance then
					ApplyForceAppearance(ply, ply.Appearance)
				end
			end)
		end
	end)
end


function GetAppearance(ply) -- Returns appearance table
	if !ply:IsPlayer() or (ply:IsPlayer() and ply:IsBot()) then
		local randApperance = GetRandomAppearance(ply) 
		ply.Appearance = randApperance
	end

	if ply:IsPlayer() and not ply:IsBot() then
		ply._nextAppearanceRequest = ply._nextAppearanceRequest or 0
		if ply._nextAppearanceRequest > CurTime() then return end
		ply._nextAppearanceRequest = CurTime() + 1.5
		net.Start("GetAppearance")
		net.Send(ply)
	end
end