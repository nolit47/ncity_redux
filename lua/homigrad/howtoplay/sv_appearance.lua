// Appearance Code -- Надо было вообще давно так сделать
util.AddNetworkString("GetAppearance")

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
        local has_notbuyed_att = false

        for i=1, #Appearance.Attachmets do
            local uid = Appearance.Attachmets[i]
            if PLUGIN.Items[uid] and not ply:PS_HasItem(uid) then
                Appearance.Attachmets[i] = ""
                has_notbuyed_att = true
            end
            if hg.Accessories[uid] and hg.Accessories[uid].disallowinapperance then
                Appearance.Attachmets[i] = ""
                if ply.ChatPrint then ply:ChatPrint("You can't use balaclava, you are not a terrorist.") end
            end
        end

        if has_notbuyed_att then
            if ply.ChatPrint then ply:ChatPrint("Your character had items that weren't bought in the pointshop. Removed.") end
        end
    else
        if PLUGIN.Items[Appearance.Attachmets] and not (!ply:IsPlayer() or ply:IsBot()) and not ply:PS_HasItem(Appearance.Attachmets) then 
            Appearance.Attachmets = ""
            if ply.ChatPrint then ply:ChatPrint("Your character had items that weren't bought in the pointshop. Removed.") end
        end
        if hg.Accessories[Appearance.Attachmets] and hg.Accessories[Appearance.Attachmets].disallowinapperance then
            Appearance.Attachmets = ""
            if ply.ChatPrint then ply:ChatPrint("You can't use balaclava, you are not a terrorist.") end
        end
    end

    ply:SetNetVar("Accessories", Appearance.Attachmets)

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

    ply.CurAppearance = {}
    table.CopyFromTo(Appearance, ply.CurAppearance)
end



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
    end
end

hook.Add("PlayerDeath","setaccessories",function(ply)
    if IsValid(ply.FakeRagdoll) then
        local Appearance = ply.CurAppearance or hg.Apperance.DefaultApperanceTable
        ply.FakeRagdoll:SetNetVar("Accessories", ply:GetNetVar("Accessories"))
        ply:SetNetVar("Accessories","none")
     end
end)

if engine.ActiveGamemode() == "sandbox" then
    hook.Add("PlayerInitialSpawn","SetAppearance",function(ply)
        timer.Simple(0,function()
            ApplyAppearance(ply)
        end)
    end)
    hook.Add("PlayerSpawn","SetAppearance",function(ply)
        if OverrideSpawn then return end
        timer.Simple(0,function()
            ApplyAppearance(ply)
        end)
    end)
end


function GetAppearance(ply) -- Returns appearance table
    if !ply:IsPlayer() or (ply:IsPlayer() and ply:IsBot()) then
        local randApperance = GetRandomAppearance(ply) 
        ply.Appearance = randApperance
       -- ply.CurAppearance = randApperance
    end

    if ply:IsPlayer() and not ply:IsBot() then
        net.Start("GetAppearance")
        net.Send(ply)
    end
end