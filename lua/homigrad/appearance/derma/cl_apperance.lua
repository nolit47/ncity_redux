-- yea
local PANEL = {}

local colors = {}
colors.secondary = Color(25,25,25,195)
colors.mainText = Color(255,255,255,255)
colors.secondaryText = Color(45,45,45,125)
colors.selectionBG = Color(45,45,45,225)
colors.highlightText = Color(120,35,35)

function PANEL:SetAppearance( tAppearacne )
    self.Appearance = tAppearacne
end

function PANEL:CallbackAppearance()
    --self.SexSeletors.Male.Selected = self.Appearance.Gender == 1 
    --self.SexSeletors.Female.Selected = self.Appearance.Gender == 2 

    self.BottomPanel:SetText(self.Appearance.Name)
end

function PANEL:PostInit()
    local main = self
    local sizeX, sizeY = ScrW()*1,ScrH()*1
    self:SetSize(sizeX,sizeY)
    self:SetBorder(false)

    self.LeftPanel = vgui.Create("DPanel",self)

    local lPan = self.LeftPanel
    lPan:Dock(LEFT)
    lPan:SetSize(sizeX*0.25,150)
    lPan:DockMargin(5,5,5,5)

    function lPan:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end

    self.RightPanel = vgui.Create("DPanel",self)
    
    local rPan = self.RightPanel
    rPan:Dock(RIGHT)
    rPan:SetSize(sizeX*0.25,150)
    rPan:DockMargin(5,5,5,5)

        --self.SexSeletors = {}
        --local SexPan = vgui.Create("DPanel",rPan)
        --SexPan:Dock( TOP )
        --SexPan:DockMargin( 5,5,5,5 )
        --SexPan:SetSize( 200, ScrH()*0.05 )
--
        --local Male = vgui.Create("DButton",SexPan)
        --Male:Dock( LEFT )
        --Male:SetFont("HomigradFontLarge")
        --Male:SetSize( sizeX*(0.25/2), ScrH()*0.05 )
        --Male:SetText( "Male" )
        --Male.Selected = false
        --self.SexSeletors.Male = Male
--
        --local Female = vgui.Create("DButton",SexPan)
        --Female:Dock( FILL )
        --Female:SetFont("HomigradFontLarge")
        --Female:SetSize( sizeX*(0.25/2), ScrH()*0.05 )
        --Female:SetText( "Female" )
        --Female.Selected = false
        --self.SexSeletors.Female = Female
        --function Female:Paint(w,h)
        --    draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
        --    if self.Selected then
        --        draw.RoundedBox(0,1,1,w-2,h-2,colors.highlightText)
        --    end
        --    
        --    return false
        --end
--
        --function Male:Paint(w,h)
        --    draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
        --    if self.Selected then
        --        draw.RoundedBox(0,1,1,w-2,h-2,colors.highlightText)
        --    end
        --    
        --    return false
        --end
        --function Female:DoClick()
        --    self.Selected = true
        --    Male.Selected = false
        --    main.Appearance.Gender = 2
        --end
--
        --function Male:DoClick()
        --    self.Selected = true
        --    Female.Selected = false
        --    main.Appearance.Gender = 1
        --end
        --SexPan:SetValue( "Sex" )
        --SexPan:AddChoice( "Male" )
        --SexPan:AddChoice( "Female" )
        --SexPan:SetTextColor(color_white)

        local ModelSelector = vgui.Create( "DComboBox", rPan )
        ModelSelector:Dock( TOP )
        ModelSelector:DockMargin( 5,5,5,5 )
        ModelSelector:SetFont("HomigradFontLarge")
        ModelSelector:SetSize( 200, ScrH()*0.05 )
        ModelSelector:SetValue( "Model" )
        ModelSelector:SetTextColor(color_white)
        function ModelSelector:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end

        for k,v in pairs(hg.Apperance.ZCityPlayerModels) do
            ModelSelector:AddChoice(k,v)
        end

        local lbl = vgui.Create("DLabel",rPan)
        lbl:Dock(TOP)
        lbl:DockMargin(15,5,5,5)
        lbl:SetText("Top Wear")
        lbl:SetSize( 200, ScrH()*0.02 )
        lbl:SetFont("HomigradFontMedium")

        local Top = vgui.Create("DComboBox", rPan)
        Top:Dock(TOP)
        Top:DockMargin(5,5,5,5)
        Top:SetFont("HomigradFontLarge")
        Top:SetSize( 200, ScrH()*0.05 )
        Top:SetTextColor(color_white)

        Top:AddChoice("Normal",{
            { 
                [1] = {1,0},
                [2] = {1,0} 
            },
            { 
                [1] = {4,0},
                [2] = {4,0} 
            }
        })
        Top:AddChoice("Large",{
            { 
                [1] = {1,1}, 
                [2] = {1,1} 
            },
            { 
                [1] = {4,0},
                [2] = {4,0} 
            }    
        })
        Top:AddChoice("TShirt",{
        { 
            [1] = {1,3},
            [2] = {1,2} 
        },
        { 
            [1] = {4,1},
            [2] = {4,1} 
        }
        })
        function Top:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end

        local SubMaterialTop = vgui.Create("DComboBox", rPan)
        SubMaterialTop:Dock(TOP)
        SubMaterialTop:DockMargin(5,5,5,5)
        SubMaterialTop:SetFont("HomigradFontLarge")
        SubMaterialTop:SetSize( 200, ScrH()*0.05 )
        SubMaterialTop:SetTextColor(color_white)

        for k,v in pairs(hg.Apperance.Clothes) do
            SubMaterialTop:AddChoice(k,v)
        end

        function SubMaterialTop:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end



        local lbl = vgui.Create("DLabel",rPan)
        lbl:Dock(TOP)
        lbl:DockMargin(15,5,5,5)
        lbl:SetText("Pants")
        lbl:SetSize( 200, ScrH()*0.02 )
        lbl:SetFont("HomigradFontMedium")

        local Pants = vgui.Create("DComboBox", rPan)
        Pants:Dock(TOP)
        Pants:DockMargin(5,5,5,5)
        Pants:SetFont("HomigradFontLarge")
        Pants:SetSize( 200, ScrH()*0.05 )
        Pants:SetTextColor(color_white)

        Pants:AddChoice("Normal",{
            { 
                [1] = {2,0},
                [2] = {2,0} 
            },
        })
        Pants:AddChoice("Wide",{
            { 
                [1] = {2,1}, 
                [2] = {2,1} 
            }   
        })

        function Pants:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end
        
        local SubMaterialPants = vgui.Create("DComboBox", rPan)
        SubMaterialPants:Dock(TOP)
        SubMaterialPants:DockMargin(5,5,5,5)
        SubMaterialPants:SetFont("HomigradFontLarge")
        SubMaterialPants:SetSize( 200, ScrH()*0.05 )
        SubMaterialPants:SetTextColor(color_white)

        for k,v in pairs(hg.Apperance.Clothes) do
            SubMaterialPants:AddChoice(k,v)
        end

        function SubMaterialPants:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end

        local lbl = vgui.Create("DLabel",rPan)
        lbl:Dock(TOP)
        lbl:DockMargin(15,5,5,5)
        lbl:SetText("Boots")
        lbl:SetSize( 200, ScrH()*0.02 )
        lbl:SetFont("HomigradFontMedium")

        local SubMaterialBoots = vgui.Create("DComboBox", rPan)
        SubMaterialBoots:Dock(TOP)
        SubMaterialBoots:DockMargin(5,5,5,5)
        SubMaterialBoots:SetFont("HomigradFontLarge")
        SubMaterialBoots:SetSize( 200, ScrH()*0.05 )
        SubMaterialBoots:SetTextColor(color_white)

        for k,v in pairs(hg.Apperance.Clothes) do
            SubMaterialBoots:AddChoice(k,v)
        end

        function SubMaterialBoots:Paint(w,h)
            draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
            return false
        end

    function rPan:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    

    self.BottomPanel = vgui.Create("DTextEntry",self)

    local bPan = self.BottomPanel
    bPan:Dock(BOTTOM)
    bPan:SetSize(0,sizeY*0.05)
    bPan:DockMargin(5,5,5,5)
    bPan:DockPadding(5,5,5,5)
    bPan:SetFont("HomigradFontLarge")
    bPan:SetTextColor(colors.mainText)
    bPan:SetPlaceholderText("Character Name")
    bPan:SetPlaceholderColor(colors.secondaryText)
    bPan:SetHighlightColor(colors.highlightText)

    function bPan:OnValueChange(str)
        main.Appearance.Name = str
    end

    --function bPan:Paint(w,h)
    --    draw.RoundedBox(0,0,0,w,h,colors.secondary)
    --end

    self.MiddlePanel = vgui.Create("DAdjustableModelPanel",self)
    local mPan = self.MiddlePanel
    mPan:Dock(FILL)
    mPan:SetSize(ScrW()*0.18,100)
    mPan:SetModel( LocalPlayer():GetModel() )
    mPan:DockPadding(5,5,5,5)
    mPan:SetFOV( 11 )
    mPan:SetLookAng( Angle( 15, 180, 0 ) )
    mPan:SetCamPos( Vector( 355, 0, 130 ) )
    mPan:SetDirectionalLight(BOX_LEFT, Color(253, 255, 232))
    mPan:SetDirectionalLight(BOX_RIGHT, Color(253, 255, 232))
    mPan:SetDirectionalLight(BOX_FRONT, Color(253, 255, 232))

    function mPan:LayoutEntity( Entity ) 
        local AppearanceTable = main.Appearance
        Entity.Angles = Entity.Angles or Angle(0,0,0)
        --if not self:IsHovered() then
        --    Entity.Angles = Entity.Angles + Angle(0,0.2,0)
        --end
        Entity:SetNWVector("PlayerColor",Vector(AppearanceTable.Color.r / 255, AppearanceTable.Color.g / 255, AppearanceTable.Color.b / 255))
        --self:SetAmbientLight(Color(AppearanceTable.Color.r, AppearanceTable.Color.g, AppearanceTable.Color.b, 15))
        Entity:SetAngles(Entity.Angles)
        --Entity:SetSubMaterial()
        --Entity:SetSubMaterial(SubMaterials[string.lower(AppearanceTable.Model)],AppearanceTable.ClothesStyle)
        Entity.accessories = AppearanceTable.Attachmets
    end

    function mPan:PostDrawModel(Entity)
        local AppearanceTable = main.Appearance
        if istable(AppearanceTable.Attachmets) then
            for k,attach in ipairs(AppearanceTable.Attachmets) do
                DrawAccesories(Entity, Entity, attach, hg.Accessories[attach],false,true)
            end
        else
        DrawAccesories(Entity, Entity, AppearanceTable.Attachmets, hg.Accessories[AppearanceTable.Attachmets],false,true)
        end
    end

    function mPan.Entity:GetPlayerColor() return Entity:GetNWVector("PlayerColor",Vector(0,0,0)) end

    function ModelSelector:OnSelect(index,value,table)
        mPan:SetModel( table[1] )
        main.Appearance.Model = table[1]
        main.Appearance.Gender = table[2]
    end

    function Top:OnSelect(index,value,table)
        for k,v in ipairs(table) do
            v = v[main.Appearance.Gender]
            mPan.Entity:SetBodygroup(v[1],v[2])
        end
    end

    function SubMaterialTop:OnSelect(index,value,table)
        v = table[main.Appearance.Gender]
        print(hg.Apperance.ZCitySubMaterialsID["Top"][main.Appearance.Gender],v)
        mPan.Entity:SetSubMaterial(hg.Apperance.ZCitySubMaterialsID["Top"][main.Appearance.Gender],v)
    end

    function Pants:OnSelect(index,value,table)
        for k,v in ipairs(table) do
            v = v[main.Appearance.Gender]
            mPan.Entity:SetBodygroup(v[1],v[2])
        end
    end

    function SubMaterialPants:OnSelect(index,value,table)
        v = table[main.Appearance.Gender]
        --print(hg.Apperance.ZCitySubMaterialsID["Pants"][main.Appearance.Gender],v)
        mPan.Entity:SetSubMaterial(hg.Apperance.ZCitySubMaterialsID["Pants"][main.Appearance.Gender],v)
    end

    function SubMaterialBoots:OnSelect(index,value,table)
        v = table[main.Appearance.Gender]
        --print(hg.Apperance.ZCitySubMaterialsID["Pants"][main.Appearance.Gender],v)
        mPan.Entity:SetSubMaterial(hg.Apperance.ZCitySubMaterialsID["Boots"][main.Appearance.Gender],v)
    end
    --function mPan:Paint(w,h)
    --    draw.RoundedBox(5,0,0,w,h,color_white)
    --end
    --self.RightPanel 
    --self.MiddlePanel
    self:CallbackAppearance()
end

vgui.Register( "HG_AppearanceMenu", PANEL, "ZFrame")
-- какое-то полное говно
--if IsValid(zpan) then
--    zpan:Close()
--end
--zpan = vgui.Create("HG_AppearanceMenu")
--zpan:SetSize(ScrW(),ScrH())
--zpan:MakePopup()
--zpan:SetAppearance(GetAppearance())
--zpan:Center()