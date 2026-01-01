local PANEL = {}

local MODE = MODE

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    self:SetCursor("hand")

    self.alpha = 0
    self.capture = 0
    self.map = "gm_construct"
    self.Unavailable = true
end

function PANEL:SetMap(map)
    self.map = map

    local txt = self.map
    txt = string.Explode("_",txt)
    table.remove(txt,1)
    txt[1] = string.upper(string.Left(txt[1],1))..string.sub(txt[1],2)
    txt = table.concat(txt," ")

    self:SetSSTooltip(function(tooltip)
        tooltip.map = true
        tooltip.text = txt
        tooltip.image = self.material
        tooltip.capture = self.capture
        tooltip.building = MODE.Buildings[self.building]
    end)
end

local gray = Color(50, 50, 50)
local black = Color(20, 20, 20)
local gray2 = Color(125, 125, 125)

function PANEL:Paint(w, h)
    if !self.material then
        self.material = Material("maps/thumb/" .. self.map .. ".png", "smooth")
    end

    surface.SetDrawColor((self:IsHovered() and gray) or black)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(ColorAlpha(MODE.CaptureColors[self.capture] or (self.Unavailable and gray2) or color_white, self.alpha))
    surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(1))

    if self.building then
        draw.SimpleText(self.building, "ZB_ScrappersMedium", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("ZB_SSMapSlot", PANEL, "EditablePanel")