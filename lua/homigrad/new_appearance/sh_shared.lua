-- "addons\\homigrad\\lua\\homigrad\\new_appearance\\sh_shared.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
hg.Appearance = hg.Appearance or {}
hg.PointShop = hg.PointShop or {}
local PLUGIN = hg.PointShop
PLUGIN.Items = PLUGIN.Items or {}

-- Validate function for custom name
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

   if #trimmedName < 2 then
       return true
   end

   local symblos = utf8.len( name )

   for k = 1, symblos do
       if !table.HasValue(allowed, utf8.GetChar(name,k) ) then return true end
   end

   return false
end

hg.Appearance.IsInvalidName = IsInvalidName

-- Random name generator
-- in misc/sh_names.lua
local function GenerateRandomName(iSex)
   local sex = iSex or math.random(1, 2)
   local randomName = hg.Appearance.RandomNames[sex][math.random(1, #hg.Appearance.RandomNames[sex])]
   return randomName
end

hg.Appearance.GenerateRandomName = GenerateRandomName

-- Appearance models

local PlayerModels = {
   [1] = {},
   [2] = {}
}

local function AppAddModel(strName, strMdl, bFemale, tSubmaterialSlots)
    PlayerModels[bFemale and 2 or 1][strName] = {
        mdl = strMdl,
        submatSlots = tSubmaterialSlots,
        sex = bFemale
    }
end

AppAddModel( "Male 01", "models/player/group01/male_01.mdl", false, {main = "models/humans/male/group01/players_sheet"}) -- сделал бы автоматом если бы слоты не отличались...
AppAddModel( "Male 02", "models/player/group01/male_02.mdl", false, {main = "models/humans/male/group01/players_sheet"}) -- забудьте я просто шизик, сделал более удобную штуку
AppAddModel( "Male 03", "models/player/group01/male_03.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 04", "models/player/group01/male_04.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 05", "models/player/group01/male_05.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 06", "models/player/group01/male_06.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 07", "models/player/group01/male_07.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 08", "models/player/group01/male_08.mdl", false, {main = "models/humans/male/group01/players_sheet"})
AppAddModel( "Male 09", "models/player/group01/male_09.mdl", false, {main = "models/humans/male/group01/players_sheet"})

AppAddModel( "Female 01", "models/player/group01/female_01.mdl", true, {main = "models/humans/female/group01/players_sheet"})
AppAddModel( "Female 02", "models/player/group01/female_02.mdl", true, {main = "models/humans/female/group01/players_sheet"})
AppAddModel( "Female 03", "models/player/group01/female_03.mdl", true, {main = "models/humans/female/group01/players_sheet"})
AppAddModel( "Female 04", "models/player/group01/female_04.mdl", true, {main = "models/humans/female/group01/players_sheet"})
AppAddModel( "Female 05", "models/player/group01/female_05.mdl", true, {main = "models/humans/female/group01/players_sheet"})
AppAddModel( "Female 06", "models/player/group01/female_06.mdl", true, {main = "models/humans/female/group01/players_sheet"})

hg.Appearance.PlayerModels = PlayerModels

hg.Appearance.FuckYouModels = {{}, {}}

for name, tbl in pairs(hg.Appearance.PlayerModels[1]) do
    hg.Appearance.FuckYouModels[1][tbl.mdl] = tbl
end

for name, tbl in pairs(hg.Appearance.PlayerModels[2]) do
    hg.Appearance.FuckYouModels[2][tbl.mdl] = tbl
end --fuck you

hg.Appearance.Clothes = {}
hg.Appearance.Clothes[1] = {
    normal = "models/humans/male/group01/normal",
    formal = "models/humans/male/group01/formal",
    plaid = "models/humans/male/group01/plaid",
    striped = "models/humans/male/group01/striped",
    young = "models/humans/male/group01/young",
    cold = "models/humans/male/group01/cold",
    casual = "models/humans/male/group01/casual",
    medic = "models/humans/male/group01/scrubs1_sheet"
}

hg.Appearance.Clothes[2] = {
    normal = "models/humans/female/group01/normal",
    formal = "models/humans/female/group01/formal",
    plaid = "models/humans/female/group01/plaid",
    striped = "models/humans/female/group01/striped",
    young = "models/humans/female/group01/young",
    cold = "models/humans/female/group01/cold",
    casual = "models/humans/female/group01/casual",
    medic = "models/humans/female/group01/scrubs1_shtfe"
}

-- SkeletonTable
hg.Appearance.SkeletonAppearanceTable = {
    AModel = "Male 07",
    AClothes = {main = "normal"},
    AName = "John Z-City", -- JOHN GMOD
    AColor = Color(180,0,0),
    AAttachments = {},
}
-- GetRandomAppearance
function hg.Appearance.GetRandomAppearance()
    local randomAppearance = table.Copy(hg.Appearance.SkeletonAppearanceTable)

    local iSex = math.random(1,2)
    local _, str = table.Random(PlayerModels[iSex])
    randomAppearance.AModel = str

    _,str = table.Random(hg.Appearance.Clothes[iSex])
    randomAppearance.AClothes = {main = str}

    randomAppearance.AName = GenerateRandomName(iSex)

    randomAppearance.AColor = ColorRand(false)

    for i = 1, 1 do
        local data,k = table.Random(hg.Accessories)

        for ii, name in ipairs(randomAppearance.AAttachments) do
            if hg.Accessories[name].placement == data.placement then k = "none" end
        end

        if data.disallowinapperance then k = "none" end
        randomAppearance.AAttachments[i] = k
    end

    return randomAppearance
end
-- Validator
hg.Appearance.ValidateFunctions = {
    AModel = function(str)
        if !isstring(str) then return false end
        if !PlayerModels[1][str] and !PlayerModels[2][str] then return false end

        return true
    end,
    AClothes = function(tbl)
        if table.Count(tbl) > 3 then return false end
        for k, v in ipairs(tbl) do
            if !hg.Appearance.Clothes[1][v] and !hg.Appearance.Clothes[2][v] then return false end
        end

        return true
    end,
    AName = function(str)
        return !IsInvalidName(str)
    end,
    AColor = function(clr)
        --if !IsColor(clr) then return false end

        return true
    end,
    AAttachments = function(tbl)
        if table.Count(tbl) > 5 then return false end
        for k, v in ipairs(tbl) do
            if !hg.Accessories[v] then return false end
        end
        return true
    end
}

local function AppearanceValidater(tblAppearance)
    local VaildFuncs = hg.Appearance.ValidateFunctions
    local bValidAModel = VaildFuncs.AModel(tblAppearance.AModel)
    local bValidAClothes = VaildFuncs.AClothes(tblAppearance.AClothes)
    local bValidAName = VaildFuncs.AName(tblAppearance.AName)
    local bValidAColor = VaildFuncs.AColor(tblAppearance.AColor)
    local bValidAAttachments = VaildFuncs.AAttachments(tblAppearance.AAttachments)
    --print(bValidAModel,bValidAClothes,bValidAName,bValidAColor,bValidAAttachments)
    if bValidAModel and bValidAClothes and bValidAName and bValidAColor and bValidAAttachments then return true end

    return false
end

hg.Appearance.AppearanceValidater = AppearanceValidater

function ThatPlyIsFemale(ply)
    ply.CahceModel = ply.CahceModel or ""
    if ply.CahceModel == ply:GetModel() then return ply.bSex end
    local tSubModels = ply:GetSubModels()
    ply.CahceModel = ply:GetModel()
    for i = 1, #tSubModels do
        local name = tSubModels[ i ][ "name" ]
        if name == "models/m_anm.mdl" then
            ply.bSex = false
            return false
        end

        if name == "models/f_anm.mdl" then
            ply.bSex = true
            return true
        end
    end

    return false
end