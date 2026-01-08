hg.Appearance = hg.Appearance or {}
local APmodule = hg.Appearance
local PANEL = {}
if not hg.ColorSettings then include("homigrad/cl_color_settings.lua") end
local colorSettings = hg.ColorSettings
local colors = {}

local function refreshAppearanceColors()
    colors.secondary = colorSettings:GetColor("appearance_secondary")
    colors.mainText = colorSettings:GetColor("appearance_text")
    colors.secondaryText = colorSettings:GetColor("appearance_text_secondary")
    colors.selectionBG = colorSettings:GetColor("appearance_selection")
    colors.highlightText = colorSettings:GetColor("appearance_highlight")
    colors.BG = colorSettings:GetColor("appearance_bg")
    colors.line = colorSettings:GetColor("appearance_line")
end
refreshAppearanceColors()

local appearanceColorIds = {
    appearance_secondary = true, appearance_text = true, appearance_text_secondary = true,
    appearance_selection = true, appearance_highlight = true, appearance_line = true, appearance_bg = true
}

hook.Add("HGColorsUpdated", "HG_AppearanceMenuColorSync", function(id)
    if appearanceColorIds[id] then refreshAppearanceColors() end
end)

local function PlaySafeSound(soundPath)
    if file.Exists("sound/" .. soundPath, "GAME") then
        surface.PlaySound(soundPath)
    else
        surface.PlaySound("buttons/button15.wav")
    end
end

-- Setup menu icons with zoom, rotation, AND skins/bodygroups
local function SetupMenuIcon(ico, accessKey)
    local v = hg.Accessories[accessKey]
    if not v then return end
    
    ico:SetModel(v.model)
    local ent = ico:GetEntity()
    
    -- Apply defined skins/bodygroups to the menu icon
    if v.skin then ent:SetSkin(v.skin) end
    if v.bodygroups then
        for k, val in pairs(v.bodygroups) do ent:SetBodygroup(k, val) end
    end

    local mn, mx = ent:GetModelBounds()
    local size = 0
    size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
    size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
    size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

    ico:SetLookAt((mn + mx) * 0.5)
    ico:SetCamPos((mn + mx) * 0.5 + Vector(size * 0.9, size * 0.9, size * 0.4))
    
    function ico:LayoutEntity(Entity)
        Entity:SetAngles(Angle(0, RealTime() * 60, 0))
    end
end

function PANEL:SetAppearance( tAppearacne ) self.AppearanceTable = tAppearacne end
function PANEL:CallbackAppearance() end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )
    if self.PostInit then self:PostInit() end
end

local sizeX, sizeY = ScrW(), ScrH()
local xbars, ybars = 17, 30
local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")
local sw, sh = ScrW(), ScrH()

function PANEL:Paint(w,h)
    surface.SetDrawColor(colors.BG)
    surface.DrawRect(0, 0, w, h)
    local drawClr = (self.AppearanceTable and self.AppearanceTable.AColor) or colors.line
    surface.SetDrawColor(drawClr.r, drawClr.g, drawClr.b, 60) 

    for i = 1, (ybars + 1) do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end
    for i = 1, (xbars + 1) do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    local border_size = ScreenScale(55)
    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_d) surface.DrawTexturedRect(0, sh - border_size + 1, sw, border_size)
    surface.SetMaterial(gradient_u) surface.DrawTexturedRect(0, 0, sw, border_size)
    surface.SetMaterial(gradient_l) surface.DrawTexturedRect(0, 0, border_size, sh)
    surface.SetMaterial(gradient_r) surface.DrawTexturedRect(sw - border_size, 0, border_size, sh)
end

function PANEL:PostInit()
    local main = self
    self:SetBorder(false)
    self:SetDraggable(false)

    self.AppearanceTable = self.AppearanceTable or hg.Appearance.LoadAppearanceFile("main") or APmodule.GetRandomAppearance()
    self.AppearanceTable.AAccessorySkins = self.AppearanceTable.AAccessorySkins or {}
    self.AppearanceTable.AAccessoryBodygroups = self.AppearanceTable.AAccessoryBodygroups or {}

    local function DynamicButtonPaint(s, w, h)
        local clr = main.AppearanceTable.AColor or colors.secondary
        local alpha = s:IsHovered() and 255 or 200
        draw.RoundedBox(0, 0, 0, w, h, Color(clr.r, clr.g, clr.b, alpha))
        if s:IsHovered() then surface.SetDrawColor(255, 255, 255, 30) surface.DrawRect(0, 0, w, h) end
    end

    local tMdl = APmodule.PlayerModels[1][self.AppearanceTable.AModel] or APmodule.PlayerModels[2][self.AppearanceTable.AModel]
    local viewer = vgui.Create( "DModelPanel", self )
    viewer:SetSize(sizeX / 2.6,sizeY)
    viewer:SetModel( util.IsValidModel( tostring(tMdl.mdl) ) and tostring(tMdl.mdl) or "models/player/group01/female_01.mdl" )
    viewer:SetFOV( 75 )
    viewer:SetCamPos( Vector( 100, 0, 55 ) )
    viewer:Dock(FILL)
    viewer:SetAmbientLight(colors.line)
    viewer.CamPos, viewer.LookAt = Vector(100, 0, 55), Vector(0, 0, 55)
    viewer.TargetCamPos, viewer.TargetLookAt = viewer.CamPos, viewer.LookAt

    function viewer:Think()
        self.CamPos = LerpVector(FrameTime() * 5, self.CamPos, self.TargetCamPos)
        self.LookAt = LerpVector(FrameTime() * 5, self.LookAt, self.TargetLookAt)
        self:SetCamPos(self.CamPos)
        self:SetLookAt(self.LookAt)
    end

    local hoveredAccessor = nil
    local defaultLookAt, defaultCamPos = Vector(0, 0, 55), Vector(100, 0, 55)
    
    local function FocusBone(boneName, factor)
        local ent = viewer.Entity
        if not IsValid(ent) then return end
        local bone = ent:LookupBone(boneName)
        if not bone then return end
        local m = ent:GetBoneMatrix(bone)
        if not m then return end
        local pos = m:GetTranslation()
        local baseDist = (defaultCamPos - defaultLookAt):Length()
        viewer.TargetLookAt = pos
        viewer.TargetCamPos = pos + (defaultCamPos - defaultLookAt):GetNormalized() * (baseDist * (factor or 0.6))
    end
    
    local function OnAccessorHover(accessKey)
        if hoveredAccessor == accessKey then return end
        hoveredAccessor = accessKey
        local acc = hg.Accessories[accessKey]
        if not acc then return end
        if acc.placement == "face" then FocusBone("ValveBiped.Bip01_Head1", 0.30)
        elseif acc.placement == "head" or acc.placement == "ears" then FocusBone("ValveBiped.Bip01_Head1", 0.4) end
    end
    
    local function OnAccessorUnhover()
        hoveredAccessor = nil
        viewer.TargetLookAt, viewer.TargetCamPos = defaultLookAt, defaultCamPos
    end

    local funpos1x, funpos3x
    function viewer:LayoutEntity( Entity )
        local lookX, lookY = input.GetCursorPos()
        lookX, lookY = lookX / sizeX - 0.5, lookY / sizeY - 0.5
        Entity.Angles = Entity.Angles or Angle(0,0,0)
        Entity.Angles = LerpAngle(FrameTime() * 5,Entity.Angles,Angle(lookY * 2,(self.Rotate and -179 or 0) -lookX * 75,0))
        local tbl = main.AppearanceTable
        tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel]

        Entity:SetNWVector("PlayerColor",Vector(tbl.AColor.r / 255, tbl.AColor.g / 255, tbl.AColor.b / 255))
        Entity:SetAngles(Entity.Angles)
        Entity:SetSequence(Entity:LookupSequence("idle_suitcase"))
        if Entity:GetModel() != tMdl.mdl then Entity:SetModel(tMdl.mdl) end

        local mats = Entity:GetMaterials()
        for k, v in pairs(tMdl.submatSlots) do
            local slot = 0
            for i = 1, #mats do if mats[i] == v then slot = i-1 break end end
            Entity:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] )
        end
        if IsValid(Entity) and Entity:LookupBone("ValveBiped.Bip01_Head1") then funpos1x = lookX * 75 funpos3x = -lookX * 75 end
    end

    function viewer:PostDrawModel(Entity)
        local tbl = main.AppearanceTable
        for k,attach in ipairs(tbl.AAttachments) do
            if attach == "none" then continue end
            -- Apply custom skins/bodygroups to the rendered viewer attachments
            local data = hg.Accessories[attach]
            if data then
                local oldSkin = data.skin
                local oldBG = data.bodygroups
                data.skin = tbl.AAccessorySkins[attach] or data.skin
                data.bodygroups = tbl.AAccessoryBodygroups[attach] or data.bodygroups
                DrawAccesories(Entity, Entity, attach, data, false, true)
                data.skin = oldSkin
                data.bodygroups = oldBG
            end
        end
    end

    local upPanel = vgui.Create("DPanel",viewer)
    upPanel:Dock(TOP) upPanel:DockMargin(ScreenScale(164),0,ScreenScale(164),0)
    upPanel:SetSize(1,ScreenScale(15)) upPanel.Paint = DynamicButtonPaint

    local modelSelector = vgui.Create( "DComboBox", upPanel )
    modelSelector:SetSize(ScreenScale(164),ScreenScale(15))
    modelSelector:SetFont("ZCity_Tiny") modelSelector:SetText(main.AppearanceTable.AModel)
    modelSelector:SetTextColor(colors.mainText) modelSelector:Dock(FILL)
    modelSelector:SetContentAlignment(5)
    function modelSelector:OnSelect(i,str) main.AppearanceTable.AModel = str end
    for k, v in pairs(APmodule.PlayerModels[1]) do modelSelector:AddChoice(k) end
    for k, v in pairs(APmodule.PlayerModels[2]) do modelSelector:AddChoice(k) end

    local downPanel = vgui.Create("DPanel",viewer)
    downPanel:Dock(BOTTOM) downPanel:SetSize(1,ScreenScale(15))
    downPanel:DockMargin(ScreenScale(144),0,ScreenScale(144),ScreenScale(12))
    downPanel.Paint = function() end

    local backViewButton = vgui.Create("DButton",downPanel)
    backViewButton:SetSize(ScreenScale(72),ScreenScale(15))
    backViewButton:SetFont("ZCity_Tiny") backViewButton:SetText("Rotate")
    backViewButton:SetTextColor(colors.mainText) backViewButton:Dock(LEFT)
    backViewButton.Paint = DynamicButtonPaint
    function backViewButton:DoClick() viewer.Rotate = not viewer.Rotate PlaySafeSound("buttons/button15.wav") end

    local ApplyButton = vgui.Create("DButton",downPanel)
    ApplyButton:SetSize(ScreenScale(72),ScreenScale(15))
    ApplyButton:SetFont("ZCity_Tiny") ApplyButton:SetText("Apply")
    ApplyButton:SetTextColor(colors.secondaryText) ApplyButton:Dock(RIGHT)
    function ApplyButton:DoClick()
        hg.Appearance.CreateAppearanceFile("main",main.AppearanceTable)
        net.Start("OnlyGet_Appearance") net.WriteTable(main.AppearanceTable) net.SendToServer()
        PlaySafeSound("buttons/button15.wav") main:Close()
    end
    function ApplyButton:Paint(w,h) draw.RoundedBox(0,0,0,w,h,colors.selectionBG) end

    local NameEntry = vgui.Create("DTextEntry",downPanel)
    NameEntry:SetSize(ScreenScale(164),ScreenScale(15))
    NameEntry:SetFont("ZCity_Tiny") NameEntry:SetText(main.AppearanceTable.AName or "")
    NameEntry:SetTextColor(colors.mainText) NameEntry:Dock(FILL)
    function NameEntry:OnChange() main.AppearanceTable.AName = self:GetValue() PlaySafeSound("common/talk.wav") end

    -- Accessory Buttons
    local function CreateAccessoryButton(txt, index, filter, posFactor, yOffset)
        local btn = vgui.Create("DButton",viewer)
        btn:SetSize(ScreenScale(100),ScreenScale(16))
        btn:SetFont("ZCity_Tiny") btn:SetText(txt)
        btn:SetTextColor(colors.mainText) btn.Paint = DynamicButtonPaint
        function btn:Think()
            if funpos1x then 
                local side = (posFactor > 0.5) and funpos3x or funpos1x
                btn:SetPos(sizeX * posFactor + side, sizeY * 0.2 + ScreenScale(yOffset)) 
            end
        end
        function btn:DoClick()
            local menu = DermaMenu()
            menu:AddOption("None", function() main.AppearanceTable.AAttachments[index] = "none" PlaySafeSound("buttons/button15.wav") end):SetIcon("icon16/cross.png")
            for k, v in pairs(hg.Accessories) do
                if not filter(v) then continue end
                local ico = vgui.Create("DModelPanel", menu)
                ico:SetSize(ScreenScale(64), ScreenScale(48))
                SetupMenuIcon(ico, k)
                ico.Accessor = k
                function ico:OnCursorEntered() OnAccessorHover(self.Accessor) end
                function ico:OnCursorExited() OnAccessorUnhover() end
                function ico:DoClick()
                    main.AppearanceTable.AAttachments[index] = self.Accessor
                    menu:Remove() PlaySafeSound("buttons/button15.wav")
                end
                menu:AddPanel(ico)
            end
            menu:Open()
        end
    end

    CreateAccessoryButton("Hats/Hair", 1, function(v) return v.placement == "head" or v.placement == "ears" end, 0.2, 0)
    CreateAccessoryButton("Masks/Beards", 4, function(v) return v.placement == "face2" end, 0.2, 32)
    CreateAccessoryButton("Glasses", 2, function(v) return v.placement == "face" end, 0.2, 64)
    CreateAccessoryButton("Body Attachment", 3, function(v) return v.placement == "torso" or v.placement == "spine" end, 0.65, 0)
    CreateAccessoryButton("Body Attachment 2", 5, function(v) return v.placement == "hand" end, 0.65, 96)

    local bodyMatSelector = vgui.Create("DButton",viewer)
    bodyMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    bodyMatSelector:SetFont("ZCity_Tiny") bodyMatSelector:SetText("Clothes")
    bodyMatSelector.Paint = DynamicButtonPaint
    function bodyMatSelector:Think() if funpos3x then bodyMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(32)) end end
    function bodyMatSelector:DoClick()
        local menu = DermaMenu()
        for k, v in pairs(hg.Appearance.Clothes[1]) do
            menu:AddOption(k,function() main.AppearanceTable.AClothes.main = k PlaySafeSound("buttons/button15.wav") end)
        end
        local colorSelector = vgui.Create("DColorCombo",menu)
        function colorSelector:OnValueChanged(clr) main.AppearanceTable.AColor = clr end
        colorSelector:SetColor(main.AppearanceTable.AColor)
        menu:AddPanel(colorSelector)
        menu:Open()
    end

    local attSkinSelector = vgui.Create("DButton",viewer)
    attSkinSelector:SetSize(ScreenScale(100),ScreenScale(16))
    attSkinSelector:SetFont("ZCity_Tiny") attSkinSelector:SetText("Attachment skins")
    attSkinSelector.Paint = DynamicButtonPaint
    function attSkinSelector:Think() if funpos3x then attSkinSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(64)) end end
    function attSkinSelector:DoClick()
        local menu = DermaMenu()
        for _, accessor in ipairs(main.AppearanceTable.AAttachments or {}) do
            if accessor and accessor ~= "none" and hg.Accessories[accessor] then
                local sub = menu:AddSubMenu(string.NiceName(accessor))
                local probe = ClientsideModel(hg.Accessories[accessor].model or "")
                local skins = IsValid(probe) and math.max(probe:SkinCount() - 1, 0) or 0
                if IsValid(probe) then probe:Remove() end
                for i = 0, skins do
                    sub:AddOption("Skin " .. i, function() main.AppearanceTable.AAccessorySkins[accessor] = i PlaySafeSound("buttons/button15.wav") end)
                end
            end
        end
        menu:Open()
    end

    self:CallbackAppearance()
end

vgui.Register( "HG_AppearanceMenu", PANEL, "ZFrame")

concommand.Add("hg_appearance_menu",function()
    hg.PointShop:SendNET( "SendPointShopVars", nil, function( data )
        if IsValid(zpan) then zpan:Close() end
        zpan = vgui.Create("HG_AppearanceMenu")
        zpan:SetSize(sizeX,sizeY)
        zpan:SetPos(0, 0)
        zpan:MakePopup()
    end)
end)