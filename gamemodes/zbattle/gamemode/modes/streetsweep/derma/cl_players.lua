local PANEL = {}

local MODE = MODE

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    self.blue = self:Add("EditablePanel")
    self.blue:SetSize(ScreenScale(100), sh - ScreenScale(10))

    self.red = self:Add("EditablePanel")
    self.red:SetPos(sw - ScreenScale(100), 0)
    self.red:SetSize(ScreenScale(100), sh - ScreenScale(10))
end

function PANEL:AddPlayer(ply, plyteam)
    local panel

    if plyteam == 0 then
        panel = self.blue:Add("ZB_SSPlayerInternal")
    else
        panel = self.red:Add("ZB_SSPlayerInternal")
    end

    panel.ply = ply
    panel.plyteam = plyteam
    panel:Dock(BOTTOM)
end

function PANEL:Paint(w, h)
end

vgui.Register("ZB_SSPlayers", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
    self:SetTall(ScreenScale(10))

    self.NewX = 0
end

function PANEL:Close()
    if self.IsClosing then return end

    self.IsClosing = true

    self:CreateAnimation(1, {
        index = 1,
        target = {
            NewX = -ScreenScale(105)
        },
        easing = "inOutExpo",
        bIgnoreConfig = true,
        OnComplete = function()
            self:Remove()
        end
    })
end

function PANEL:Paint(w, h)
    if !IsValid(self.ply) then
        self:Close()
    end

    self.name = self.name or self.ply:Name()
    self.plyteam = self.plyteam or self.ply:Team()

    draw.SimpleText(self.name, "ZB_ScrappersMedium", self.NewX + ((self.plyteam == 1 and w - ScreenScale(5)) or ScreenScale(5)) + ScreenScale(0.5), ScreenScale(0.5), color_black, (self.plyteam == 1 and TEXT_ALIGN_RIGHT) or TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(self.name, "ZB_ScrappersMedium", self.NewX + ((self.plyteam == 1 and w - ScreenScale(5)) or ScreenScale(5)), 0, (self.plyteam == 1 and Color(255, 0, 0)) or Color(0, 0, 255), (self.plyteam == 1 and TEXT_ALIGN_RIGHT) or TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register("ZB_SSPlayerInternal", PANEL, "EditablePanel")