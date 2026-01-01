local PANEL = {}

local MODE = MODE

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    self:SetSize(ScreenScale(75), ScreenScale(21))

    self:SetDrawOnTop(true)
	self:SetMouseInputEnabled(false)
end

function PANEL:Think()
    local x, y = gui.MousePos()

    self:SetPos(x + ScreenScale(4), y + ScreenScale(4))
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(20, 20, 20, 235)
    surface.DrawRect(0, 0, w, h)

    if self.image then
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(self.image)
        surface.DrawTexturedRect(0, 0, ScreenScale(20), ScreenScale(20))
    end

    if self.map then
        draw.SimpleText(self.text, "ZB_SS_MediumSmall", ScreenScale(22), 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText((self.capture == 0 and "Захвачено синими") or (self.capture == 1 and "Захвачено красными") or "Никем не захвачено", "ZB_SS_MediumSmall", ScreenScale(22), ScreenScale(7), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText(self.building or "Ничего не построено", "ZB_SS_MediumSmall", ScreenScale(22), ScreenScale(14), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    else
        draw.SimpleText(self.name, "ZB_SS_MediumSmall", ScreenScale(1), 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

vgui.Register("ZB_SSTooltip", PANEL, "EditablePanel")

PANEL = FindMetaTable("Panel")

function PANEL:SetSSTooltip(callback)
    self:SetMouseInputEnabled(true)
    self.SSTooltip = callback
end

do
    local SS_ChangeTooltip = ChangeTooltip
    local SS_RemoveTooltip = RemoveTooltip
    local tooltip

    function ChangeTooltip(panel, ...)
        if (!panel.SSTooltip) then
            return SS_ChangeTooltip(panel, ...)
        end

        RemoveTooltip()

        timer.Create("SS_Tooltip", 0.1, 1, function()
            if (!IsValid(panel) or lastHover != panel) then
                return
            end

            tooltip = vgui.Create("ZB_SSTooltip")
            panel.SSTooltip(tooltip)
        end)

        lastHover = panel
    end

    function RemoveTooltip()
        if (IsValid(tooltip)) then
            tooltip:Remove()
            tooltip = nil
        end

        timer.Remove("SS_Tooltip")
        lastHover = nil

        return SS_RemoveTooltip()
    end
end