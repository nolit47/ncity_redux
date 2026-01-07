hg = hg or {}
hg.Apperance = hg.Apperance or {}

local RandomNames = {
    [1] = { -- MaleNames
        "Mike",
        "Dave",
        "Michel",
        "John",
        "Fred",
        "Michiel",
        "Steven",
        "Sergio",
        "Joel",
        "Samuel",
        "Larry",
        "Sean",
        "Thomas",
        "Jose",
        "Bobby",
        "Richard",
        "Andrew",
        "Alexandr",
        "David", -- legacy ends
        "Michael",
        "Daniel",
        "Matthew",
        "Anthony",
        "Mark",
        "Paul",
        "Kevin",
        "Brian",
        "George",
        "Edward",
        "Ronald",
        "Timothy",
        "Jason",
        "Jeffrey",
        "Ryan",
        "Jacob",
        "Nathan",
        "Adam",
        "Luke",
        "Noah",
        "Ethan",
        "Logan",
        "Aaron",
        "Victor",
        "Max",
        "Leo",
        "Oscar",
        "Henry",
        "Ivan",
        "Dmitry",
        "Sergey",
        "Nikolai",
        "Vladimir",
        "Oleg",
        "Roman",
        "Artem"
    },

    [2] = { -- FemaleNames
        "Denise",
        "Joyce",
        "Jane",
        "Sara",
        "Emily",
        "Charlotte",
        "Cathy",
        "Ruth",
        "Julia",
        "Tanya",
        "Wanda",
        "Elizabeth",
        "Nicole",
        "Stacey",
        "Mary",
        "Anna",
        "Diana", -- legacy ends
        "Emma",
        "Olivia",
        "Sophia",
        "Isabella",
        "Amelia",
        "Mia",
        "Evelyn",
        "Abigail",
        "Harper",
        "Ella",
        "Avery",
        "Lily",
        "Hannah",
        "Natalie",
        "Victoria",
        "Lucy",
        "Zoe",
        "Chloe",
        "Grace",
        "Madison",
        "Alexis",
        "Samantha",
        "Rebecca",
        "Vanessa",
        "Laura",
        "Angela",
        "Kristina",
        "Irina",
        "Elena",
        "Anastasia",
        "Marina",
        "Yulia"
    }
}
hg.Apperance.RandomNames = RandomNames

local PlayerModels = {
    [1] = {},
    [2] = {}
}
for i = 1, 9 do
    table.insert(PlayerModels[1],"models/player/group01/male_0"..i..".mdl")
end
for i = 1, 6 do
    table.insert(PlayerModels[2],"models/player/group01/female_0"..i..".mdl")
end

hg.Apperance.PlayerModels = PlayerModels

local SubMaterials = {
    -- Male
    ["models/player/group01/male_01.mdl"] = 3,
    ["models/player/group01/male_02.mdl"] = 2,
    ["models/player/group01/male_03.mdl"] = 4,
    ["models/player/group01/male_04.mdl"] = 4,
    ["models/player/group01/male_05.mdl"] = 4,
    ["models/player/group01/male_06.mdl"] = 0,
    ["models/player/group01/male_07.mdl"] = 4,
    ["models/player/group01/male_08.mdl"] = 0,
    ["models/player/group01/male_09.mdl"] = 2,
    -- FEMKI
    ["models/player/group01/female_01.mdl"] = 2,
    ["models/player/group01/female_02.mdl"] = 3,
    ["models/player/group01/female_03.mdl"] = 3,
    ["models/player/group01/female_04.mdl"] = 1,
    ["models/player/group01/female_05.mdl"] = 2,
    ["models/player/group01/female_06.mdl"] = 4
}

hg.Apperance.SubMaterials = SubMaterials

local ClothesStyles = {
    ["normal"] = { [1] = "models/humans/male/group01/normal", [2] = "models/humans/female/group01/normal" },
    ["formal"] = { [1] = "models/humans/male/group01/formal", [2] = "models/humans/female/group01/formal" },
    ["plaid"] = { [1] = "models/humans/male/group01/plaid", [2] = "models/humans/female/group01/plaid" },
    ["striped"] = { [1] = "models/humans/male/group01/striped", [2] = "models/humans/female/group01/striped" },
    ["young"] = { [1] = "models/humans/male/group01/young", [2] = "models/humans/female/group01/young" },
    ["cold"] = { [1] = "models/humans/male/group01/cold", [2] = "models/humans/female/group01/cold" },
    ["casual"] = { [1] = "models/humans/male/group01/casual", [2] = "models/humans/female/group01/casual" }
}

hg.Apperance.ClothesStyles = ClothesStyles

local AllowClothesTexture = {
    "models/humans/male/group01/normal", "models/humans/female/group01/normal",
    "models/humans/male/group01/formal", "models/humans/female/group01/formal",
    "models/humans/male/group01/plaid", "models/humans/female/group01/plaid",
    "models/humans/male/group01/striped", "models/humans/female/group01/striped",
    "models/humans/male/group01/young", "models/humans/female/group01/young",
    "models/humans/male/group01/cold", "models/humans/female/group01/cold",
    "models/humans/male/group01/casual", "models/humans/female/group01/casual"
}

hg.Apperance.AllowClothesTexture = AllowClothesTexture

local ClothesStylesRandoms = {
    [1] = { [1] = "models/humans/male/group01/normal", [2] = "models/humans/female/group01/normal" },
    [2] = { [1] = "models/humans/male/group01/formal", [2] = "models/humans/female/group01/formal" },
    [3] = { [1] = "models/humans/male/group01/plaid", [2] = "models/humans/female/group01/plaid" },
    [4] = { [1] = "models/humans/male/group01/striped", [2] = "models/humans/female/group01/striped" },
    [5] = { [1] = "models/humans/male/group01/young", [2] = "models/humans/female/group01/young" },
    [6] = { [1] = "models/humans/male/group01/cold", [2] = "models/humans/female/group01/cold" },
    [7] = { [1] = "models/humans/male/group01/casual", [2] = "models/humans/female/group01/casual" }
}

hg.Apperance.ClothesStylesRandoms = ClothesStylesRandoms

local HMCDTransfer = {
        -- Male
        ["male01"] = {"models/player/group01/male_01.mdl", 1},
        ["male02"] = {"models/player/group01/male_02.mdl", 1},
        ["male03"] = {"models/player/group01/male_03.mdl", 1},
        ["male04"] = {"models/player/group01/male_04.mdl", 1},
        ["male05"] = {"models/player/group01/male_05.mdl", 1},
        ["male06"] = {"models/player/group01/male_06.mdl", 1},
        ["male07"] = {"models/player/group01/male_07.mdl", 1},
        ["male08"] = {"models/player/group01/male_08.mdl", 1},
        ["male09"] = {"models/player/group01/male_09.mdl", 1},
        -- FEMKI
        ["female01"] = {"models/player/group01/female_01.mdl", 2},
        ["female02"] = {"models/player/group01/female_02.mdl", 2},
        ["female03"] = {"models/player/group01/female_03.mdl", 2},
        ["female04"] = {"models/player/group01/female_04.mdl", 2},
        ["female05"] = {"models/player/group01/female_05.mdl", 2},
        ["female06"] = {"models/player/group01/female_06.mdl", 2}
}

hg.Apperance.HMCDTransfer = HMCDTransfer

local DefaultApperanceTable = {
    Gender = 0, --  (1) = male or (2) = female  / FUCK YOU IF YOU WANNA BE NI...
    Name = "", -- Player CustomName...
    Model = "", -- GMODModel?
    Color = Color(255,255,255),
    ClothesStyle = "",  -- "normal" = Standard GMOD
    Attachmets = "" -- Таблица внешней одежды по типу шапки и так далее... -- Потом! -- Таблицу потом? Фурри мальчик садсалат???
}

hg.Apperance.DefaultApperanceTable = DefaultApperanceTable
function plyrandomByIndex(ply,min,max,num)
    local num = num or 0
    local rand = 1
    rand = math.random(min,max)
    return rand
end

function GetEmptyAppearance(ply)
    local Appearance = DefaultApperanceTable

    Appearance["Gender"] = 1
    Appearance["Name"] = ""
    --print(Appearance["Name"], Appearance["Gender"])
    Appearance["Model"] = "models/player/group01/male_01.mdl"
    Appearance["Color"] = Color(255,255,255)
    Appearance["ClothesStyle"] = ""
    Appearance["Attachmets"] = ""
    return Appearance
end

function GetRandomAppearance(ply, gender)
    local Appearance = DefaultApperanceTable

    Appearance["Gender"] = gender or plyrandomByIndex(ply,1,2,2)
    Appearance["Name"] = RandomNames[Appearance["Gender"]][plyrandomByIndex(ply,1,#RandomNames[Appearance["Gender"]],3)]
    --print(Appearance["Name"], Appearance["Gender"])
    Appearance["Model"] = PlayerModels[Appearance["Gender"]][plyrandomByIndex(ply,1,#PlayerModels[Appearance["Gender"]],4)]
    Appearance["Color"] = Color(plyrandomByIndex(ply,0,255,9),plyrandomByIndex(ply,0,255,8),plyrandomByIndex(ply,0,255,7))
    Appearance["ClothesStyle"] = ClothesStylesRandoms[ plyrandomByIndex(ply,1,#ClothesStylesRandoms, 5) ][Appearance["Gender"]]
    Appearance["Attachmets"] = table.GetKeys(hg.Accessories)[plyrandomByIndex(ply,1,#table.GetKeys(hg.Accessories), 6)] -- потом
    return Appearance
end

if CLIENT then
    function SetAppearance(ply, appearance)
        if not CLIENT then return end
        if not file.Exists("zcity","DATA") then file.CreateDir("zcity/") end
    
        file.Write("zcity/appearance.json",util.TableToJSON(appearance))
        net.Start("GetAppearance")
            net.WriteTable( GetAppearance(LocalPlayer()) or GetRandomAppearance(LocalPlayer()) )
        net.SendToServer()
    end

    net.Receive("GetAppearance",function() -- CLIENT 
        net.Start("GetAppearance")
            net.WriteTable( GetAppearance(LocalPlayer()) )
        net.SendToServer()
    end)
    local randomAppearance = ConVarExists("hg_random_appearance") and GetConVar("hg_random_appearance") or CreateConVar("hg_random_appearance","0",{FCVAR_USERINFO,FCVAR_ARCHIVE},"sets random appearance every round",0,1)
    function GetAppearance(ply) -- Returns appearance table
        if CLIENT then
            if file.Exists( "zcity/appearance.json", "DATA" ) and not randomAppearance:GetBool() then return util.JSONToTable( file.Read("zcity/appearance.json","DATA") ) end
                return GetRandomAppearance(ply)
        end
    end
end

local FemPlayerModels = {
}
for i = 1, 6 do
	table.insert(FemPlayerModels,"models/player/group01/female_0" .. i .. ".mdl")
end

for i = 1, 6 do
    table.insert(FemPlayerModels,"models/monolithservers/mpd/female_0" .. i .. "_2.mdl")
end

for i = 1, 6 do
    table.insert(FemPlayerModels,"models/monolithservers/mpd/female_0" .. i .. ".mdl")
end

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

-- Appearance MENU
if CLIENT then
    local gradient_d = Material("vgui/gradient-d")
    local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
    local red = Color(150,0,0)

    BlurBackground = BlurBackground or hg.DrawBlur

    local function AppearanceMenu()
        Dynamic = 0
        local AppearanceTable = GetAppearance()

        local BaseFrame = vgui.Create( "ZFrame" )
        BaseFrame:SetSize( 500, 600 )
        BaseFrame:Center()
        BaseFrame:SetTitle( "Appearance Menu" ) 
        BaseFrame:SetVisible( false ) 
        BaseFrame:SetDraggable( false ) 
        BaseFrame:ShowCloseButton( true ) 
        BaseFrame:MakePopup()
        function BaseFrame:Paint( w, h )
            draw.RoundedBox( 0, 2.5, 2.5, w-5, h-5, Color( 0, 0, 0, 140) )
            surface.SetDrawColor(AppearanceTable.Color.r, AppearanceTable.Color.g, AppearanceTable.Color.b, 100)
            surface.SetMaterial(gradient_d)
            surface.DrawTexturedRect( 0, 0, w, h )
            BlurBackground(BaseFrame)
            surface.SetDrawColor( 255, 0, 0, 128)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        local PlayerModelPanel = vgui.Create( "DPanel", BaseFrame )
        PlayerModelPanel:Dock( LEFT )
        PlayerModelPanel:SetSize(300,450)
        PlayerModelPanel:DockMargin(2.5,0,0,5)
        function PlayerModelPanel:Paint( w, h )
            --surface.SetDrawColor(AppearanceTable.Color.r, AppearanceTable.Color.g, AppearanceTable.Color.b, 40)
            --surface.SetMaterial(gradient_d)
            --surface.DrawTexturedRect( 0, 0, w, h )
        end

        local PlayerModel = vgui.Create( "DAdjustableModelPanel", PlayerModelPanel )
        PlayerModel:SetSize(280,580)
        PlayerModel:SetModel( util.IsValidModel( AppearanceTable.Model ) and AppearanceTable.Model or LocalPlayer():GetModel() )
        PlayerModel:SetFOV( 35 )
        PlayerModel:SetLookAng( Angle( 15, 180, 0 ) )
        PlayerModel:SetCamPos( Vector( 55, 0, 55 ) )
       -- PlayerModel:SetDirectionalLight(BOX_LEFT, Color(56, 56, 56))
        --PlayerModel:SetDirectionalLight(BOX_FRONT, Color(78, 78, 78))
        function PlayerModel:LayoutEntity( Entity ) 
            Entity.Angles = Entity.Angles or Angle(0,0,0)
            if self:IsHovered() then
                --Entity.Angles = Entity.Angles + Angle(0,0.5,0)
            end
            Entity:SetNWVector("PlayerColor",Vector(AppearanceTable.Color.r / 255, AppearanceTable.Color.g / 255, AppearanceTable.Color.b / 255))
            --self:SetAmbientLight(Color(AppearanceTable.Color.r, AppearanceTable.Color.g, AppearanceTable.Color.b, 15))
            Entity:SetAngles(Entity.Angles)
            Entity:SetSubMaterial()
            Entity:SetSubMaterial(SubMaterials[string.lower(AppearanceTable.Model)],AppearanceTable.ClothesStyle)
            Entity.accessories = AppearanceTable.Attachmets
        end

        function PlayerModel:PostDrawModel(Entity)
            if istable(AppearanceTable.Attachmets) then
                for k,attach in ipairs(AppearanceTable.Attachmets) do
                    DrawAccesories(Entity, Entity, attach, hg.Accessories[attach],false,true)
                end
            else
            DrawAccesories(Entity, Entity, AppearanceTable.Attachmets, hg.Accessories[AppearanceTable.Attachmets],false,true)
            end
        end

        function PlayerModel.Entity:GetPlayerColor() return end

        local BasePanel = vgui.Create( "DPanel", BaseFrame )
        BasePanel:Dock( RIGHT )
        BasePanel:SetSize(190,450)
        BasePanel:DockMargin(0,0,2.5,5)
        function BasePanel:Paint( w, h )
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 5, 2, 0 )
        Label:SetText("Name:")
        Label:SetTextColor(color_white)

        local TextEntry = vgui.Create( "DTextEntry", BasePanel ) -- create the form as a child of frame
        TextEntry:Dock( TOP )
        TextEntry:SetSize(200,30)
        TextEntry:DockMargin( 2, 5, 2, 0 )
        TextEntry:SetValue(AppearanceTable.Name)
        TextEntry.OnChange = function( self )
            AppearanceTable.Name = self:GetValue()	-- print the textentry text as a chat message
        end
        function TextEntry:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
            draw.SimpleText(self:GetValue(),"DermaDefault", 7.5, h / 2, color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 5, 2, 0 )
        Label:SetText("Sex:")
        Label:SetTextColor(color_white)

        local GenderSelector = vgui.Create( "DComboBox", BasePanel )
        GenderSelector:Dock( TOP )
        GenderSelector:DockMargin( 2,5,2,0 )
        GenderSelector:SetSize( 200, 30 )
        GenderSelector:SetValue( ( ( AppearanceTable.Gender == 1 and "Male" ) or ( AppearanceTable.Gender == 2 and "Female" ) ) or "Male")
        GenderSelector:AddChoice( "Male" )
        GenderSelector:AddChoice( "Female" )
        GenderSelector:SetTextColor(color_white)
        function GenderSelector:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 5, 2, 0 )
        Label:SetText("Model:")
        Label:SetTextColor(color_white)

        local ModelSelector = vgui.Create( "DComboBox", BasePanel )
        ModelSelector:Dock( TOP )
        ModelSelector:DockMargin( 2,5,2,0 )
        ModelSelector:SetSize( 200, 30 )
        ModelSelector:SetTextColor(color_white)
        ModelSelector:SetValue( AppearanceTable.Model )
        for k, v in ipairs(PlayerModels[AppearanceTable.Gender]) do
            ModelSelector:AddChoice( v )
        end
        function ModelSelector:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        ModelSelector.OnSelect = function( self, index, value )
            PlayerModel:SetModel(value)
            AppearanceTable.Model = value
        end
        local Style = "normal"
        GenderSelector.OnSelect = function( self, index, value )
            PlayerModel:SetModel(index == 1 and "models/player/group01/male_01.mdl" or index == 2 and "models/player/group01/female_01.mdl")
            ModelSelector:Clear()
            ModelSelector:SetValue( index == 1 and "models/player/group01/male_01.mdl" or index == 2 and "models/player/group01/female_01.mdl" )
            AppearanceTable.Gender = index
            AppearanceTable.Model = index == 1 and "models/player/group01/male_01.mdl" or index == 2 and "models/player/group01/female_01.mdl"
            --print(Style)
            AppearanceTable.ClothesStyle = ClothesStyles[Style or "normal"][index]
            for k, v in ipairs(PlayerModels[index]) do
                ModelSelector:AddChoice( v )
            end
        end

        local Mixer = vgui.Create("DColorMixer", BasePanel)
        Mixer:Dock(TOP)	
        Mixer:SetPalette(false)	
        Mixer:SetSize(0,100)
        Mixer:DockMargin( 5,5,5,0 )
        Mixer:SetAlphaBar(false)
        Mixer:SetWangs(false)
        Mixer:SetColor(AppearanceTable.Color)
        function Mixer:ValueChanged(value)
            AppearanceTable.Color = value
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 2.5, 2, 0 )
        Label:SetText("Clothes:")
        Label:SetTextColor(color_white)

        local ColthesStyle = vgui.Create( "DComboBox", BasePanel )
        ColthesStyle:Dock( TOP )
        ColthesStyle:DockMargin( 2,5,2,0 )
        ColthesStyle:SetSize( 200, 30 )
        ColthesStyle:SetTextColor(color_white)
        for k, v in pairs(ClothesStyles) do
            ColthesStyle:AddChoice( k )
        end
        ColthesStyle:SetValue( "normal" )
        ColthesStyle.OnSelect = function( self, index, value )
            Style = value
            AppearanceTable.ClothesStyle = ClothesStyles[value][AppearanceTable.Gender]
        end
        function ColthesStyle:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end
        -- attach

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 1, 2, 0 )
        Label:SetText("Attachment 1:")
        Label:SetTextColor(color_white)

        local Attachments = vgui.Create( "DComboBox", BasePanel )
        Attachments:Dock( TOP )
        Attachments:DockMargin( 2,5,2,0 )
        Attachments:SetSize( 200, 30 )
        Attachments:SetTextColor(color_white)
        for k, v in pairs(hg.Accessories) do
            if v.disallowinapperance then continue end
            if v.placement ~= "head" then continue end
            --if not acces.bPointShop then continue end
            if v.bPointShop and not LocalPlayer():PS_HasItem(k) then continue end
            Attachments:AddChoice( k )
        end
        Attachments:AddChoice( "none" )
        Attachments:SetValue( (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets[1]) or "none" )
        Attachments.OnSelect = function( self, index, value )
            AppearanceTable.Attachmets = (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets) or {"none"}
            AppearanceTable.Attachmets[1] = value
        end
        function Attachments:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 1, 2, 0 )
        Label:SetText("Attachment 2:")
        Label:SetTextColor(color_white)

        local Attachments = vgui.Create( "DComboBox", BasePanel )
        Attachments:Dock( TOP )
        Attachments:DockMargin( 2,5,2,0 )
        Attachments:SetSize( 200, 30 )
        Attachments:SetTextColor(color_white)
        for k, v in pairs(hg.Accessories) do
            if v.disallowinapperance then continue end
            if v.placement ~= "face" then continue end
            if v.bPointShop and not LocalPlayer():PS_HasItem(k) then continue end
            Attachments:AddChoice( k )
        end
        Attachments:AddChoice( "none" )
        Attachments:SetValue( (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets[2]) or "none" )
        Attachments.OnSelect = function( self, index, value )
            AppearanceTable.Attachmets = (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets) or {"none"}
            AppearanceTable.Attachmets[2] = value
        end
        function Attachments:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        local Label = vgui.Create( "DLabel", BasePanel )
        Label:Dock( TOP )
        Label:SetSize(200,15)
        Label:DockMargin( 10, 1, 2, 0 )
        Label:SetText("Attachment 3:")
        Label:SetTextColor(color_white)

        local Attachments = vgui.Create( "DComboBox", BasePanel )
        Attachments:Dock( TOP )
        Attachments:DockMargin( 2,5,2,0 )
        Attachments:SetSize( 200, 30 )
        Attachments:SetTextColor(color_white)
        for k, v in pairs(hg.Accessories) do
            if v.disallowinapperance then continue end
            if v.placement ~= "spine" and v.placement ~= "torso" then continue end
            if v.bPointShop and not LocalPlayer():PS_HasItem(k) then continue end
            Attachments:AddChoice( k )
        end
        Attachments:AddChoice( "none" )
        Attachments:SetValue( (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets[3]) or "none" )
        Attachments.OnSelect = function( self, index, value )
            AppearanceTable.Attachmets = (istable(AppearanceTable.Attachmets) and AppearanceTable.Attachmets) or {"none"}
            AppearanceTable.Attachmets[3] = value
        end
        function Attachments:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        -- apply
        local ApplyButton = vgui.Create( "DButton", BasePanel )
        ApplyButton:Dock( BOTTOM )
        ApplyButton:DockMargin( 2,5,2,5 )
        ApplyButton:SetSize( 250, 30 )
        ApplyButton:SetTextColor(color_white)
        ApplyButton:SetText("Set Appearance")
        ApplyButton.DoClick = function()
            local trimmedName = string.Trim(AppearanceTable.Name)
        
            if trimmedName == "" then
                LocalPlayer():ChatPrint("Name can't be empty!")
                return
            end
        

            if string.find(trimmedName, "ㅤ") then
                LocalPlayer():ChatPrint("Name can't contain special characters!")
                return
            end
        

            if #trimmedName < 2 then
                LocalPlayer():ChatPrint("Name must be at least 2 characters long!")
                return
            end
        
            SetAppearance(LocalPlayer(), AppearanceTable)  
            BaseFrame:Close()
            LocalPlayer():ChatPrint("Appearance successfully changed!")
        end
        
        
        function ApplyButton:Paint( w, h )
            self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
            draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
            surface.SetDrawColor( color_black)
            surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        end

        --if file.Exists("homicide_identity.txt","DATA") then
        --    local RawData = string.Split(file.Read("homicide_identity.txt","DATA"),"\n")
        --    local ApplyHMCDButton = vgui.Create( "DButton", BasePanel )
        --    ApplyHMCDButton:Dock( BOTTOM )
        --    ApplyHMCDButton:DockMargin( 2,5,2,0 )
        --    ApplyHMCDButton:SetSize( 250, 30 )
        --    ApplyHMCDButton:SetTextColor(color_white)
        --    ApplyHMCDButton:SetText("Try to transfer" .. ( ( #RawData == 7 and " Cat's HMCD " ) or " HMCD " ) .. "Appearance")
        --    function ApplyHMCDButton:Paint( w, h )
        --        self.a = Lerp(0.1,self.a or 100,self:IsHovered() and 255 or 150)
        --        draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,self.a))
        --        surface.SetDrawColor( color_black)
        --        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
        --    end
        --    ApplyHMCDButton.DoClick = function()
        --        if #RawData == 10 then
        --            local DatName = string.Replace(RawData[1],"_"," ")
        --            --LocalPlayer():ConCommand("homicide_identity "..DatName.." "..RawData[2].." "..RawData[3].." "..RawData[4].." "..RawData[5].." "..RawData[6].." "..RawData[7].." "..RawData[8].." "..RawData[9].." "..DatAccessory)
        --            AppearanceTable = DefaultApperanceTable
        --            AppearanceTable.Name = DatName
        --            AppearanceTable.Gender = HMCDTransfer[RawData[2]][2]
        --            AppearanceTable.Model = HMCDTransfer[RawData[2]][1]
        --            AppearanceTable.Color = Color( RawData[3] * 255, RawData[4] * 255, RawData[5] * 255 )
        --            AppearanceTable.ClothesStyle = ClothesStyles[RawData[9]][AppearanceTable.Gender]
        --            SetAppearance(LocalPlayer(), AppearanceTable)
        --            BaseFrame:Close()
        --            LocalPlayer():ChatPrint("Transfer HMCD Appearance successfully!")
        --        elseif #RawData == 7 then
        --            local DatName = string.Replace(RawData[1],"_"," ")
        --            --LocalPlayer():ConCommand("homicide_identity "..DatName.." "..RawData[2].." "..RawData[3].." "..RawData[4].." "..RawData[5].." "..RawData[6].." "..RawData[7].." "..RawData[8].." "..RawData[9].." "..DatAccessory)
        --            AppearanceTable = DefaultApperanceTable
        --            AppearanceTable.Name = DatName
        --            AppearanceTable.Gender = HMCDTransfer[RawData[2]][2]
        --            AppearanceTable.Model = HMCDTransfer[RawData[2]][1]
        --            AppearanceTable.Color = Color( RawData[3] * 255, RawData[4] * 255, RawData[5] * 255 )
        --            AppearanceTable.ClothesStyle = ClothesStyles[RawData[6]][AppearanceTable.Gender]
        --            AppearanceTable.Attachmets = 
        --            SetAppearance(LocalPlayer(), AppearanceTable)
        --            BaseFrame:Close()
        --            LocalPlayer():ChatPrint("Transfer Cat's HMCD Appearance successfully!")
        --        else
        --            BaseFrame:Close()
        --            LocalPlayer():ChatPrint("Transfer Appearance failed :(")
        --        end
        --    end
        --end
        BaseFrame:SlideDown(0.5)
    end
    hg.PointShop = hg.PointShop or {}
    concommand.Add( "hg_appearance_menu", function( ply, cmd, args )
        hg.PointShop:SendNET( "SendPointShopVars", nil, function( data )
            AppearanceMenu()
        end)
    end )
end

local ZCityPlayerModels = {
    -- Male
    ["Male 01"] = {"models/player/zcity/male_01.mdl", 1},
    ["Male 02"] = {"models/player/zcity/male_02.mdl", 1},
    ["Male 03"] = {"models/player/zcity/male_03.mdl", 1},
    ["Male 04"] = {"models/player/zcity/male_04.mdl", 1},
    ["Male 05"] = {"models/player/zcity/male_05.mdl", 1},
    ["Male 06"] = {"models/player/zcity/male_06.mdl", 1},
    ["Male 07"] = {"models/player/zcity/male_07.mdl", 1},
    ["Male 08"] = {"models/player/zcity/male_08.mdl", 1},
    ["Male 09"] = {"models/player/zcity/male_09.mdl", 1},
    -- FEMKI
    ["Female 01"] = {"models/player/zcity/female_01.mdl", 2},
    ["Female 02"] = {"models/player/zcity/female_02.mdl", 2},
    ["Female 03"] = {"models/player/zcity/female_03.mdl", 2},
    ["Female 04"] = {"models/player/zcity/female_04.mdl", 2},
    ["Female 05"] = {"models/player/zcity/female_05.mdl", 2},
    ["Female 06"] = {"models/player/zcity/female_06.mdl", 2}
}

hg.Apperance.ZCityPlayerModels = ZCityPlayerModels

local Clothes = {
    ["Normal"] = { [1] = "models/humans/male/group01/normal", [2] = "models/humans/female/group01/normal" },
    ["Formal"] = { [1] = "models/humans/male/group01/formal", [2] = "models/humans/female/group01/formal" },
    ["Plaid"] = { [1] = "models/humans/male/group01/plaid", [2] = "models/humans/female/group01/plaid" },
    ["Striped"] = { [1] = "models/humans/male/group01/striped", [2] = "models/humans/female/group01/striped" },
    ["Young"] = { [1] = "models/humans/male/group01/young", [2] = "models/humans/female/group01/young" },
    ["Cold"] = { [1] = "models/humans/male/group01/cold", [2] = "models/humans/female/group01/cold" },
    ["Casual"] = { [1] = "models/humans/male/group01/casual", [2] = "models/humans/female/group01/casual" }
}

hg.Apperance.Clothes = Clothes

local ZCitySubMaterialsID = {
    ["Top"] = {[1] = 4, [2] = 4},
    ["Pants"] = {[1] = 5, [2] = 5},
    ["Boots"] = {[1] = 6, [2] = 6}
}
hg.Apperance.ZCitySubMaterialsID = ZCitySubMaterialsID

hg.Apperance.ZCityTops = {
	["Normal"] = {
		{ 
			[1] = {1,0},
			[2] = {1,0} 
		},
		{ 
			[1] = {4,0},
			[2] = {4,0} 
		}
	},
	["Large"] = {
		{ 
			[1] = {1,1}, 
			[2] = {1,1} 
		},
		{ 
			[1] = {4,0},
			[2] = {4,0} 
		}
	},
	["TShirt"] = {
		{ 
			[1] = {1,3},
			[2] = {1,2} 
		},
		{ 
			[1] = {4,1},
			[2] = {4,1} 
		}
	},
}

hg.Apperance.ZCityPants = {
	["Normal"] = {
		{ 
			[1] = {2,0},
			[2] = {2,0} 
		},
	},
	["Wide"] = {
		{ 
			[1] = {2,1}, 
			[2] = {2,1} 
		},
	},
}