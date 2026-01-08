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
    appearance_secondary = true,
    appearance_text = true,
    appearance_text_secondary = true,
    appearance_selection = true,
    appearance_highlight = true,
    appearance_line = true,
    appearance_bg = true
}

hook.Add("HGColorsUpdated", "HG_AppearanceMenuColorSync", function(id)
    if appearanceColorIds[id] then
        refreshAppearanceColors()
    end
end)


local function PlaySafeSound(soundPath)
    if file.Exists("sound/" .. soundPath, "GAME") then
        surface.PlaySound(soundPath)
    else
        surface.PlaySound("buttons/button15.wav")
    end
end

function PANEL:SetAppearance( tAppearacne )
    self.AppearanceTable = tAppearacne
end

function PANEL:CallbackAppearance()

end

function PANEL:First( ply )
    self:SetY(self:GetY() + self:GetTall())
    self:MoveTo(self:GetX(), self:GetY() - self:GetTall(), 0.4, 0, 0.2, function() end)
    self:AlphaTo( 255, 0.2, 0.1, nil )

    if self.PostInit then
        self:PostInit()
    end
end

local sizeX, sizeY = ScrW() * 1, ScrH() * 1

local xbars = 17
local ybars = 30

local xbars2 = 0
local ybars2 = 0

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")

local sw, sh = ScrW(), ScrH()

function PANEL:Paint(w,h)
    surface.SetDrawColor(colors.BG)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(colors.line)

    for i = 1, (ybars + 1) do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end

    for i = 1, (xbars + 1) do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    local border_size = ScreenScale(55)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_d)
    surface.DrawTexturedRect(0, sh - border_size + 1, sw, border_size)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_u)
    surface.DrawTexturedRect(0, 0, sw, border_size)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect(0, 0, border_size, sh)

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(gradient_r)
    surface.DrawTexturedRect(sw - border_size, 0, border_size, sh)
end

function PANEL:PostInit()
    local main = self
    self:SetBorder(false)
    self:SetDraggable(false)

    self.AppearanceTable = self.AppearanceTable or hg.Appearance.LoadAppearanceFile("main") or APmodule.GetRandomAppearance()
    self.AppearanceTable.AAccessorySkins = self.AppearanceTable.AAccessorySkins or {}
    self.AppearanceTable.AAccessoryBodygroups = self.AppearanceTable.AAccessoryBodygroups or {}

    local tMdl = APmodule.PlayerModels[1][self.AppearanceTable.AModel] or APmodule.PlayerModels[2][self.AppearanceTable.AModel]
    --print(tMdl.mdl)
    local viewer = vgui.Create( "DModelPanel", self )
    viewer:SetSize(sizeX / 2.6,sizeY)
    viewer:SetModel( util.IsValidModel( tostring(tMdl.mdl) ) and tostring(tMdl.mdl) or "models/player/group01/female_01.mdl" )
    viewer:SetFOV( 75 )
    viewer:SetLookAng( Angle( 11, 180, 0 ) )
    viewer:SetCamPos( Vector( 100, 0, 55 ) )
    viewer:SetDirectionalLight(BOX_RIGHT, colors.line)
    viewer:SetDirectionalLight(BOX_LEFT, Color(125, 155, 255))
    viewer:SetDirectionalLight(BOX_FRONT, Color(160, 160, 160))
    viewer:SetDirectionalLight(BOX_BACK, Color(0, 0, 0))
    viewer:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    viewer:SetDirectionalLight(BOX_BOTTOM, Color(0, 0, 0))
    viewer:Dock(FILL)
    viewer:SetAmbientLight(colors.line)
    viewer.CamPos = viewer:GetCamPos() or Vector(100, 0, 55)
    viewer.LookAt = Vector(0, 0, 55)
    viewer.TargetCamPos = viewer.CamPos
    viewer.TargetLookAt = viewer.LookAt
    function viewer:Think()
        self.CamPos = LerpVector(FrameTime() * 5, self.CamPos, self.TargetCamPos)
        self.LookAt = LerpVector(FrameTime() * 5, self.LookAt, self.TargetLookAt)
        self:SetCamPos(self.CamPos)
        self:SetLookAt(self.LookAt)
    end
    -- ensure preview always uses current overrides
    viewer.Entity.AccessorySkins = self.AppearanceTable.AAccessorySkins
    viewer.Entity.AccessoryBodygroups = self.AppearanceTable.AAccessoryBodygroups
    local hoveredAccessor = nil
    local defaultLookAt = Vector(0, 0, 55)
    local defaultCamPos = Vector(100, 0, 55)
    
    local function FocusBone(boneName, factor)
        local ent = viewer.Entity
        if not IsValid(ent) then return end
        local bone = ent:LookupBone(boneName)
        if not bone then return end
        local m = ent:GetBoneMatrix(bone)
        if not m then return end
        local pos = m:GetTranslation()
        local baseDist = (defaultCamPos - defaultLookAt):Length()
        local newDist = baseDist * (factor or 0.6)
        local dir = (defaultCamPos - defaultLookAt):GetNormalized()
        viewer.TargetLookAt = pos
        viewer.TargetCamPos = pos + dir * newDist
    end
    
    local function SetFocusForPlacement(accessKey)
        local acc = hg.Accessories[accessKey]
        if not acc then return end
        local place = acc.placement
        if place == "face" then
            FocusBone("ValveBiped.Bip01_Head1", 0.30)
        elseif place == "head" or place == "ears" then
            local ent = viewer.Entity
            if not IsValid(ent) then return end
            local idx = ent:LookupBone("ValveBiped.Bip01_Head1")
            if not idx then return end
            local m = ent:GetBoneMatrix(idx)
            if not m then return end
            local pos = m:GetTranslation()
            pos[3] = pos[3] + 5
            local baseDist = (defaultCamPos - defaultLookAt):Length()
            local dir = (defaultCamPos - defaultLookAt):GetNormalized()
            viewer.TargetLookAt = pos
            viewer.TargetCamPos = pos + dir * (baseDist * 0.4)
        end
    end
    
    local function OnAccessorHover(accessKey)
        if hoveredAccessor == accessKey then return end
        hoveredAccessor = accessKey
        SetFocusForPlacement(accessKey)
    end
    
    local function OnAccessorUnhover()
        if not hoveredAccessor then return end
        hoveredAccessor = nil
        viewer.TargetLookAt = defaultLookAt
        viewer.TargetCamPos = defaultCamPos
    end
    local funpos1x
    local funpos3x
    function viewer:LayoutEntity( Entity )
        local lookX, lookY = input.GetCursorPos()
        lookX = lookX / sizeX - 0.5
        lookY = lookY / sizeY - 0.5
        Entity.Angles = Entity.Angles or Angle(0,0,0)
        Entity.Angles = LerpAngle(FrameTime() * 5,Entity.Angles,Angle(lookY * 2,(self.Rotate and -179 or 0) -lookX * 75,0))
        local tbl = main.AppearanceTable
        tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel]

        Entity:SetNWVector("PlayerColor",Vector(tbl.AColor.r / 255, tbl.AColor.g / 255, tbl.AColor.b / 255))
        Entity:SetAngles(Entity.Angles)
        Entity:SetSequence(Entity:LookupSequence("idle_suitcase"))
        Entity:SetSubMaterial()
        if Entity:GetModel() != tMdl.mdl then
            Entity:SetModel(tMdl.mdl)
            self:SetModel(tMdl.mdl)
        end
        --print(tMdl.mdl)

        local mats = Entity:GetMaterials()
        for k, v in pairs(tMdl.submatSlots) do
            local slot = 1
            for i = 1, #mats do
                if mats[i] == v then slot = i-1 break end
            end
            Entity:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] )
        end
        if IsValid(Entity) and Entity:LookupBone("ValveBiped.Bip01_Head1") then
            funpos1x = lookX * 75
            funpos3x = -lookX * 75
        end
    end

    function viewer:PostDrawModel(Entity)
        local tbl = main.AppearanceTable

        for k,attach in ipairs(tbl.AAttachments) do
            DrawAccesories(Entity, Entity, attach, hg.Accessories[attach],false,true)
        end
        Entity:SetupBones()
    end

    function viewer.Entity:GetPlayerColor() return end

    function viewer:PaintOver(w,h)
        --surface.SetDrawColor(colors.highlightText)
        --surface.DrawOutlinedRect(0,0,w,h,1)
    end

    local upPanel = vgui.Create("DPanel",viewer)
    upPanel:Dock(TOP)
    upPanel:DockMargin(ScreenScale(164),0,ScreenScale(164),0)
    upPanel:SetSize(1,ScreenScale(15))
    function upPanel:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end

    local modelSelector = vgui.Create( "DComboBox", upPanel )
    modelSelector:SetSize(ScreenScale(164),ScreenScale(15))
    modelSelector:SetFont("ZCity_Tiny")
    modelSelector:SetText(main.AppearanceTable.AModel)
    modelSelector:SetTextColor(colors.mainText)
    modelSelector:Dock(FILL)
    modelSelector:SetContentAlignment(5)
    function modelSelector:OnSelect(i,str)
        main.AppearanceTable.AModel = str
    end

    for k, v in pairs(APmodule.PlayerModels[1]) do
        modelSelector:AddChoice(k)
    end

    for k, v in pairs(APmodule.PlayerModels[2]) do
        modelSelector:AddChoice(k)
    end

    local downPanel = vgui.Create("DPanel",viewer)
    downPanel:Dock(BOTTOM)
    downPanel:SetSize(1,ScreenScale(15))
    downPanel:DockMargin(ScreenScale(144),0,ScreenScale(144),ScreenScale(12))
    function downPanel:Paint(w,h)
        --draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end

    local backViewButton = vgui.Create("DButton",downPanel)
    backViewButton:SetSize(ScreenScale(72),ScreenScale(15))
    backViewButton:SetFont("ZCity_Tiny")
    backViewButton:SetText("Rotate")
    backViewButton:SetTextColor(colors.mainText)
    backViewButton:Dock(LEFT)
    function backViewButton:DoClick()
        viewer.Rotate = not viewer.Rotate
        PlaySafeSound("buttons/button15.wav")
    end
    function backViewButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end


    local ApplyButton = vgui.Create("DButton",downPanel)
    ApplyButton:SetSize(ScreenScale(72),ScreenScale(15))
    ApplyButton:SetFont("ZCity_Tiny")
    ApplyButton:SetText("Apply")
    ApplyButton:SetTextColor(colors.secondaryText)
    ApplyButton:Dock(RIGHT)
    function ApplyButton:DoClick()
        hg.Appearance.CreateAppearanceFile("main",main.AppearanceTable)

        net.Start("OnlyGet_Appearance")
            net.WriteTable(main.AppearanceTable)
        net.SendToServer()

        PlaySafeSound("buttons/button15.wav")
        main:Close()
    end

    function ApplyButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.selectionBG)
    end

    local NameEntry = vgui.Create("DTextEntry",downPanel)
    NameEntry:SetSize(ScreenScale(164),ScreenScale(15))
    NameEntry:SetFont("ZCity_Tiny")
    NameEntry:SetText(main.AppearanceTable.AName)
    NameEntry:SetTextColor(colors.mainText)
    NameEntry:Dock(FILL)
    NameEntry:SetContentAlignment(5)
    function NameEntry:OnChange()
        main.AppearanceTable.AName = self:GetValue()
    end

    local hatSelector = vgui.Create("DButton",viewer)
    hatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    hatSelector:SetFont("ZCity_Tiny")
    hatSelector:SetText("Hats and haircuts")
    hatSelector:SetTextColor(colors.mainText)
    function hatSelector:Think()
        if funpos1x then
            hatSelector:SetPos(sizeX * 0.2 + funpos1x, sizeY * 0.2)
        end
    end

    function hatSelector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    --hatSelector:SetPos(sizeX * 0.2, sizeY * 0.2)
    function hatSelector:DoClick()
        hatSelectMenu = DermaMenu()
        for k, v in pairs(hg.Accessories) do
            if v.placement != "head" and v.placement != "ears" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop then continue end
            local ico = vgui.Create("DModelPanel",hatSelectMenu)
            ico:SetSize(ScreenScale(64),ScreenScale(48))
            ico:SetModel(v.model)
            ico.Accessor = k
            ico:SetTooltip(string.NiceName(k))
            function ico:LayoutEntity() end
            ico:SetFOV(50)
            local mn, mx = ico.Entity:GetModelBounds()
            local center = (mn + mx) / 2
            ico:SetLookAt(center)
            ico:SetCamPos(center + Vector(30, 15, 15))
            if v.skin then ico.Entity:SetSkin(v.skin) end
            if v.bodygroups then ico.Entity:SetBodyGroups(v.bodygroups) end
            function ico:OnCursorEntered()
                OnAccessorHover(self.Accessor)
                main.AppearanceTable.AAttachments[1] = self.Accessor
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            
            function ico:OnCursorExited()
                OnAccessorUnhover()
                main.AppearanceTable.AAttachments[1] = "none"
            end
            
            function ico:DoClick()
                main.AppearanceTable.AAttachments[1] = self.Accessor
                hatSelectMenu:Remove()
                PlaySafeSound("buttons/button15.wav")
                viewer.TargetLookAt = defaultLookAt
                viewer.TargetCamPos = defaultCamPos
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            hatSelectMenu:AddPanel(ico)
        end
        local ico = vgui.Create("SpawnIcon",hatSelectMenu)
        ico:SetTooltip("none")
        ico.Accessor = "none"
        function ico:DoClick()
            main.AppearanceTable.AAttachments[1] = self.Accessor
            hatSelectMenu:Remove()
            surface.PlaySound("nxserv/item_hat_pickup_loud.wav")
        end
        hatSelectMenu:AddPanel(ico)
        hatSelectMenu:Open()
    end

    local faceSelector = vgui.Create("DButton",viewer)
    faceSelector:SetSize(ScreenScale(100),ScreenScale(16))
    faceSelector:SetFont("ZCity_Tiny")
    faceSelector:SetText("Glasses")
    faceSelector:SetTextColor(colors.mainText)
    function faceSelector:Think()
        if funpos1x then
            faceSelector:SetPos(sizeX * 0.2 + funpos1x, sizeY * 0.2 + ScreenScale(64))
        end
    end
    function faceSelector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    function faceSelector:DoClick()
        faceSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Accessories) do
            if v.placement != "face" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop then continue end
            local ico = vgui.Create("DModelPanel",faceSelectorMenu)
            ico:SetSize(ScreenScale(64),ScreenScale(48))
            ico:SetModel(v.model)
            ico.Accessor = k
            ico:SetTooltip(string.NiceName(k))
            function ico:LayoutEntity() end
            ico:SetFOV(50)
            local mn, mx = ico.Entity:GetModelBounds()
            local center = (mn + mx) / 2
            ico:SetLookAt(center)
            ico:SetCamPos(center + Vector(30, 15, 15))
            if v.skin then ico.Entity:SetSkin(v.skin) end
            if v.bodygroups then ico.Entity:SetBodyGroups(v.bodygroups) end
            function ico:OnCursorEntered()
                OnAccessorHover(self.Accessor)
                main.AppearanceTable.AAttachments[2] = self.Accessor
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            
            function ico:OnCursorExited()
                OnAccessorUnhover()
                main.AppearanceTable.AAttachments[2] = "none"
            end
            
            function ico:DoClick()
                main.AppearanceTable.AAttachments[2] = self.Accessor
                faceSelectorMenu:Remove()
                PlaySafeSound("buttons/button15.wav")
                viewer.TargetLookAt = defaultLookAt
                viewer.TargetCamPos = defaultCamPos
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            faceSelectorMenu:AddPanel(ico)
        end
        local ico = vgui.Create("SpawnIcon",faceSelectorMenu)
        ico:SetTooltip("none")
        ico.Accessor = "none"
        function ico:DoClick()
            main.AppearanceTable.AAttachments[2] = self.Accessor
            faceSelectorMenu:Remove()
            surface.PlaySound("nxserv/item_hat_pickup_loud.wav")
        end
        faceSelectorMenu:AddPanel(ico)
        faceSelectorMenu:Open()
    end
     local face2Selector = vgui.Create("DButton",viewer)
    face2Selector:SetSize(ScreenScale(100),ScreenScale(16))
    face2Selector:SetFont("ZCity_Tiny")
    face2Selector:SetText("Masks and bears")
    face2Selector:SetTextColor(colors.mainText)
    function face2Selector:Think()
        if funpos1x then
            face2Selector:SetPos(sizeX * 0.2 + funpos1x, sizeY * 0.2 + ScreenScale(32))
        end
    end
    function face2Selector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    
    function face2Selector:DoClick()
        face2SelectorMenu = DermaMenu()
        for k, v in pairs(hg.Accessories) do
            if v.placement != "face2" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop then continue end
            local ico = vgui.Create("DModelPanel",face2SelectorMenu)
            ico:SetSize(ScreenScale(64),ScreenScale(48))
            ico:SetModel(v.model)
            ico.Accessor = k
            ico:SetTooltip(string.NiceName(k))
            function ico:LayoutEntity() end
            ico:SetFOV(50)
            local mn, mx = ico.Entity:GetModelBounds()
            local center = (mn + mx) / 2
            ico:SetLookAt(center)
            ico:SetCamPos(center + Vector(30, 15, 15))
            if v.skin then ico.Entity:SetSkin(v.skin) end
            if v.bodygroups then ico.Entity:SetBodyGroups(v.bodygroups) end
            function ico:OnCursorEntered()
                OnAccessorHover(self.Accessor)
                main.AppearanceTable.AAttachments[4] = self.Accessor
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            
            function ico:OnCursorExited()
                OnAccessorUnhover()
                main.AppearanceTable.AAttachments[4] = "none"
            end
            
            function ico:DoClick()
                main.AppearanceTable.AAttachments[4] = self.Accessor
                face2SelectorMenu:Remove()
                PlaySafeSound("buttons/button15.wav")
                viewer.TargetLookAt = defaultLookAt
                viewer.TargetCamPos = defaultCamPos
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            face2SelectorMenu:AddPanel(ico)
        end
        local ico = vgui.Create("SpawnIcon",face2SelectorMenu)
        ico:SetTooltip("none")
        ico.Accessor = "none"
        function ico:DoClick()
            main.AppearanceTable.AAttachments[4] = self.Accessor
            face2SelectorMenu:Remove()
            surface.PlaySound("nxserv/item_hat_pickup_loud.wav")
        end
        face2SelectorMenu:AddPanel(ico)
        face2SelectorMenu:Open()
    end

        local body2Selector = vgui.Create("DButton",viewer)
    body2Selector:SetSize(ScreenScale(100),ScreenScale(16))
    body2Selector:SetFont("ZCity_Tiny")
    body2Selector:SetText("Body attachment 2")
    body2Selector:SetTextColor(colors.mainText)
    
    function body2Selector:Think()
        if funpos3x then
            body2Selector:SetPos(sizeX * 2 - funpos3x, sizeY * 0.2) -- в позиции x умножение на 2 тк ломаются на кулаккаааааах (я их убрал тоисть)
        end
    end
    function body2Selector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    body2Selector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function body2Selector:DoClick()
        body2SelectorMenu = DermaMenu()
        for k, v in pairs(hg.Accessories) do
            if v.placement != "hand" then continue end
            if not lply:PS_HasItem(k) and v.bPointShop then continue end
            local ico = vgui.Create("DModelPanel",body2SelectorMenu)
            ico:SetSize(ScreenScale(64),ScreenScale(48))
            ico:SetModel(v.model)
            ico.Accessor = k
            ico:SetTooltip(string.NiceName(k))
            function ico:LayoutEntity() end
            ico:SetFOV(50)
            local mn, mx = ico.Entity:GetModelBounds()
            local center = (mn + mx) / 2
            ico:SetLookAt(center)
            ico:SetCamPos(center + Vector(30, 15, 15))
            if v.skin then ico.Entity:SetSkin(v.skin) end
            if v.bodygroups then ico.Entity:SetBodyGroups(v.bodygroups) end
            function ico:OnCursorEntered()
                OnAccessorHover(self.Accessor)
                main.AppearanceTable.AAttachments[5] = self.Accessor
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            
            function ico:OnCursorExited()
                OnAccessorUnhover()
                main.AppearanceTable.AAttachments[5] = "none"
            end
            
            function ico:DoClick()
                main.AppearanceTable.AAttachments[5] = self.Accessor
                body2SelectorMenu:Remove()
                PlaySafeSound("buttons/button15.wav")
                viewer.TargetLookAt = defaultLookAt
                viewer.TargetCamPos = defaultCamPos
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            body2SelectorMenu:AddPanel(ico)
        end
        local ico = vgui.Create("SpawnIcon",body2SelectorMenu)
        ico:SetTooltip("none")
        ico.Accessor = "none"
        function ico:DoClick()
            main.AppearanceTable.AAttachments[5] = self.Accessor
            body2SelectorMenu:Remove()
            surface.PlaySound("nxserv/item_hat_pickup_loud.wav")
        end
        body2SelectorMenu:AddPanel(ico)
        body2SelectorMenu:Open()
    end

    local bodySelector = vgui.Create("DButton",viewer)
    bodySelector:SetSize(ScreenScale(100),ScreenScale(16))
    bodySelector:SetFont("ZCity_Tiny")
    bodySelector:SetText("Body attachment")
    bodySelector:SetTextColor(colors.mainText)
    function bodySelector:Think()
        if funpos3x then
            bodySelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2)
        end
    end
    function bodySelector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    bodySelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function bodySelector:DoClick()
        bodySelectorMenu = DermaMenu()
        for k, v in pairs(hg.Accessories) do
            if v.placement != "torso" and v.placement != "spine" then continue end
            local ico = vgui.Create("DModelPanel",bodySelectorMenu)
            ico:SetSize(ScreenScale(64),ScreenScale(48))
            ico:SetModel(v.model)
            ico.Accessor = k
            ico:SetTooltip(string.NiceName(k))
            function ico:LayoutEntity() end
            ico:SetFOV(50)
            local mn, mx = ico.Entity:GetModelBounds()
            local center = (mn + mx) / 2
            ico:SetLookAt(center)
            ico:SetCamPos(center + Vector(30, 15, 15))
            if v.skin then ico.Entity:SetSkin(v.skin) end
            if v.bodygroups then ico.Entity:SetBodyGroups(v.bodygroups) end
            function ico:OnCursorEntered()
                OnAccessorHover(self.Accessor)
                main.AppearanceTable.AAttachments[3] = self.Accessor
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            
            function ico:OnCursorExited()
                OnAccessorUnhover()
                main.AppearanceTable.AAttachments[3] = "none"
            end
            
            function ico:DoClick()
                main.AppearanceTable.AAttachments[3] = self.Accessor
                bodySelectorMenu:Remove()
                PlaySafeSound("buttons/button15.wav")
                viewer.TargetLookAt = defaultLookAt
                viewer.TargetCamPos = defaultCamPos
                viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
            end
            bodySelectorMenu:AddPanel(ico)
        end
        local ico = vgui.Create("SpawnIcon",bodySelectorMenu)
        ico:SetTooltip("none")
        ico.Accessor = "none"
        function ico:DoClick()
            main.AppearanceTable.AAttachments[3] = self.Accessor
            bodySelectorMenu:Remove()
            PlaySafeSound("buttons/button15.wav")
        end
        bodySelectorMenu:AddPanel(ico)
        bodySelectorMenu:Open()
    end

    local bodyMatSelector = vgui.Create("DButton",viewer)
    bodyMatSelector:SetSize(ScreenScale(100),ScreenScale(16))
    bodyMatSelector:SetFont("ZCity_Tiny")
    bodyMatSelector:SetText("Clothes")
    bodyMatSelector:SetTextColor(colors.mainText)
    function bodyMatSelector:Think()
        if funpos3x then
            bodyMatSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(32))
        end
    end
    function bodyMatSelector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
     bodyMatSelector:SetPos(sizeX * 0.7, sizeY * 0.5)
    function bodyMatSelector:DoClick()
        bodyMatSelectorMenu = DermaMenu()
        for k, v in pairs(hg.Appearance.Clothes[1]) do
            bodyMatSelectorMenu:AddOption(k,function()
                main.AppearanceTable.AClothes.main = k
            end)
        end
        local colorSelector = vgui.Create("DColorCombo",bodyMatSelectorMenu)
        function colorSelector:OnValueChanged(clr)
            main.AppearanceTable.AColor = clr
        end
        colorSelector:SetColor(main.AppearanceTable.AColor)
        bodyMatSelectorMenu:AddPanel(colorSelector)
        bodyMatSelectorMenu:Open()
    end

    local attSkinSelector = vgui.Create("DButton",viewer)
    attSkinSelector:SetSize(ScreenScale(100),ScreenScale(16))
    attSkinSelector:SetFont("ZCity_Tiny")
    attSkinSelector:SetText("Attachment skins")
    attSkinSelector:SetTextColor(colors.mainText)
    function attSkinSelector:Think()
        if funpos3x then
            attSkinSelector:SetPos(sizeX * 0.65 - funpos3x, sizeY * 0.2 + ScreenScale(64))
        end
    end
    function attSkinSelector:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,colors.secondary)
    end
    function attSkinSelector:DoClick()
        local menu = DermaMenu()
        for _, accessor in ipairs(main.AppearanceTable.AAttachments or {}) do
            if accessor and accessor ~= "none" and hg.Accessories[accessor] then
                local sub = menu:AddSubMenu(string.NiceName(accessor))
                local probe = ClientsideModel(hg.Accessories[accessor].model or hg.Accessories[accessor].femmodel or "")
                local skins = 0
                if IsValid(probe) then skins = math.max((probe:SkinCount() or 1) - 1, 0) probe:Remove() end
                if skins <= 0 then
                    sub:AddOption("No skins", function() end):SetIcon("icon16/ban.png")
                else
                    for i = 0, skins do
                        local opt = sub:AddOption("Skin " .. i, function()
                            main.AppearanceTable.AAccessorySkins[accessor] = i
                            -- live preview in viewer
                            viewer.Entity.AccessorySkins = main.AppearanceTable.AAccessorySkins
                        end)
                        if main.AppearanceTable.AAccessorySkins[accessor] == i then
                            opt:SetIcon("icon16/tick.png")
                        end
                    end
                end

                local bsub = sub:AddSubMenu("Bodygroups")
                local probeBG = ClientsideModel(hg.Accessories[accessor].model or hg.Accessories[accessor].femmodel or "")
                if not IsValid(probeBG) then
                    bsub:AddOption("No bodygroups", function() end):SetIcon("icon16/ban.png")
                else
                    local groups = probeBG:GetBodyGroups() or {}
                    for _, g in ipairs(groups) do
                        local gmenu = bsub:AddSubMenu((g.name or ("Group " .. g.id)))
                        local max = (g.num or 1) - 1
                        for val = 0, math.max(max, 0) do
                            local opt2 = gmenu:AddOption(tostring(val), function()
                                main.AppearanceTable.AAccessoryBodygroups[accessor] = main.AppearanceTable.AAccessoryBodygroups[accessor] or {}
                                main.AppearanceTable.AAccessoryBodygroups[accessor][g.id] = val
                                viewer.Entity.AccessoryBodygroups = main.AppearanceTable.AAccessoryBodygroups
                            end)
                            if main.AppearanceTable.AAccessoryBodygroups[accessor] and main.AppearanceTable.AAccessoryBodygroups[accessor][g.id] == val then
                                opt2:SetIcon("icon16/tick.png")
                            end
                        end
                    end
                    probeBG:Remove()
                end
            end
        end
        menu:Open()
    end
    --backViewButton:

    self:CallbackAppearance()
end

vgui.Register( "HG_AppearanceMenu", PANEL, "ZFrame")

concommand.Add("hg_appearance_menu",function()
    hg.PointShop:SendNET( "SendPointShopVars", nil, function( data )
        if IsValid(zpan) then
            zpan:Close()
        end
        zpan = vgui.Create("HG_AppearanceMenu")
        zpan:SetSize(sizeX,sizeY)
        zpan:SetPos()
        zpan:MakePopup()
    end)
end)