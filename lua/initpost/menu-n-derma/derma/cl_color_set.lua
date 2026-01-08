
local PANEL = {}
if not hg.ColorSettings then include("homigrad/cl_color_settings.lua") end
local colorSettings = hg.ColorSettings
local function copyColor(col)
    return Color(col.r, col.g, col.b, col.a)
end
local panelColor = colorSettings:GetColor("ui_background")
local accentColor = colorSettings:GetColor("ui_accent")
local menuBgColor = colorSettings:GetColor("menu_background")

hook.Add("HGColorsUpdated", "HG_ColorMenuTheme", function(id)
    if id == "ui_background" then
        panelColor = colorSettings:GetColor("ui_background")
    elseif id == "ui_accent" then
        accentColor = colorSettings:GetColor("ui_accent")
    elseif id == "menu_background" then
        menuBgColor = colorSettings:GetColor("menu_background")
    end
end)

local function buildGroups(schema)
    local groups = {}
    for _, entry in ipairs(schema) do
        groups[entry.group] = groups[entry.group] or {}
        table.insert(groups[entry.group], entry)
    end
    return groups
end

function PANEL:Init()
    self:SetAlpha(0)
    self:SetSize(ScrW(), ScrH())
    self:SetY(ScrH())
    self:SetX(ScrW() / 2 - self:GetWide() / 2)
    self:SetTitle("")
    self:SetBorder(false)
    self:SetColorBG(copyColor(menuBgColor))
    self:SetBlurStrengh(2)
    self:SetDraggable(false)
    self:ShowCloseButton(true)
    self.Rows = {}

    timer.Simple(0, function()
        if not IsValid(self) then return end
        self:First()
    end)

    self.fDock = vgui.Create("DScrollPanel", self)
    self.fDock:Dock(FILL)
    self:BuildRows()
end

function PANEL:First()
    self:MoveTo(self:GetX(), ScrH() / 2 - self:GetTall() / 2, 0.4, 0, 0.2, function() end)
    self:AlphaTo(255, 0.2, 0.1, nil)
end

function PANEL:BuildRows()
    self.fDock:Clear()
    self.Rows = {}
    local grouped = buildGroups(colorSettings:GetSchema())
    for groupName, entries in SortedPairs(grouped) do
        self:CreateCategory(groupName)
        table.sort(entries, function(a, b) return tostring(a.id) < tostring(b.id) end)
        for _, entry in ipairs(entries) do
            self:AddColorRow(groupName, entry)
        end
    end
end

function PANEL:CreateCategory(name)
    local category = vgui.Create("DLabel", self.fDock)
    category:Dock(TOP)
    category:SetTall(ScreenScale(20))
    category:SetText(name)
    category:SetFont("ZCity_Small")
    category:DockMargin(15, 8, 15, 4)
    self.Rows[name] = self.Rows[name] or {}
end

local function paintRowBackground(self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, panelColor)
    surface.SetDrawColor(accentColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function PANEL:AddColorRow(groupName, entry)
    local row = vgui.Create("DPanel", self.fDock)
    row:Dock(TOP)
    row:SetTall(ScreenScale(26))
    row:DockMargin(15, 2, 15, 2)
    row.Paint = paintRowBackground

    local reset = vgui.Create("DButton", row)
    reset:SetText("Reset")
    reset:SetFont("ZCity_Tiny")
    reset:Dock(RIGHT)
    reset:SetWide(ScreenScale(40))
    reset:DockMargin(4, 4, 10, 4)

    local preview = vgui.Create("DButton", row)
    preview:SetText("")
    preview:Dock(RIGHT)
    preview:SetWide(ScreenScale(26))
    preview:DockMargin(4, 4, 4, 4)
    preview.DoClick = function(btn)
        self:OpenColorMenu(entry, btn)
    end
    preview.Paint = function(_, w, h)
        local clr = colorSettings:GetColor(entry.id)
        surface.SetDrawColor(clr)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local alphaInput = vgui.Create("DNumberWang", row)
    alphaInput:Dock(RIGHT)
    alphaInput:SetWide(ScreenScale(35))
    alphaInput:DockMargin(4, 4, 4, 4)
    alphaInput:SetMin(0)
    alphaInput:SetMax(255)
    alphaInput:SetDecimals(0)
    alphaInput:SetValue(colorSettings:GetColor(entry.id).a or 255)
    function alphaInput:OnValueChanged(val)
        local col = colorSettings:GetColor(entry.id)
        local a = math.Clamp(tonumber(val) or col.a, 0, 255)
        col.a = a
        colorSettings:SetColor(entry.id, col)
    end

    reset.DoClick = function()
        colorSettings:Reset(entry.id)
        local col = colorSettings:GetColor(entry.id)
        alphaInput:SetValue(col.a or 255)
    end

    local label = vgui.Create("DLabel", row)
    label:SetFont("ZCity_Tiny")
    label:SetText(entry.id)-- ЧО ЗА ХУЙНЯ, ЧТО, ОНО НОРМ ЧИТАЕТСЯ ТОК КОГДА Я 3 РАЗ ПОМЕНЯЛ ВСЕ И ВЕРНУЛСЯ ДО ПРОБЛЕМНОГО ВАРИАНТА
    label:SetTextColor(color_white)
    label:Dock(FILL)
    label:DockMargin(10, 0, 10, 0)
    label:SetContentAlignment(4)

    self.Rows[groupName] = self.Rows[groupName] or {}
    table.insert(self.Rows[groupName], row)
end

function PANEL:OpenColorMenu(entry, anchor)
    if IsValid(self.ColorMenu) then
        self.ColorMenu:Remove()
    end
    local menu = DermaMenu()
    self.ColorMenu = menu
    local colorPanel = vgui.Create("DColorCombo", menu)
    colorPanel:SetColor(colorSettings:GetColor(entry.id))
    function colorPanel:OnValueChanged(clr)
        colorSettings:SetColor(entry.id, clr)
    end
    menu:AddPanel(colorPanel)
    menu:AddOption("Reset", function()
        colorSettings:Reset(entry.id)
    end):SetIcon("icon16/arrow_undo.png")
    local x, y = gui.MousePos()
    if IsValid(anchor) then
        x, y = anchor:LocalToScreen(0, anchor:GetTall())
    end
    menu:Open(x, y)
end

vgui.Register("HG_ColorMenu", PANEL, "ZFrame")

concommand.Add("hg_colors", function()
    if IsValid(hg_thx) then
        hg_thx:Close()
        hg_thx = nil
    end
    hg_thx = vgui.Create("HG_ColorMenu")
    hg_thx:MakePopup()
end)

-- нихачу делать новий файл пусть тут будет
