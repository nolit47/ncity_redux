local PANEL = {}

local MODE = MODE

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    self:SetCursor("hand")

    self.alpha = 0
    self.Researched = false

    self.anim = 0
end

function PANEL:SetResearch(research, lane, k)
    self:SetSSTooltip(function(tooltip)
        tooltip.name = research.name
        tooltip.desc = ""

        tooltip:SetSize(ScreenScale(33), ScreenScale(7))
    end)

    self.lane = lane
    self.k = k
end

function PANEL:NewVote()
    self.anim = 1

    self:CreateAnimation(1, {
        index = 1,
        target = {
            anim = 0
        },
        easing = "outExpo",
        bIgnoreConfig = true
    })
end

local gray = Color(50, 50, 50)
local gray2 = Color(125, 125, 125)
local black = Color(20, 20, 20)
local scale = Vector(0.2, 0.2, 0)

function PANEL:Paint(w, h)
    surface.SetDrawColor((self:IsHovered() and gray) or black)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(ColorAlpha((self.Unavailable and gray2) or (self.Researched and Color(105, 194, 67)) or color_white, self.alpha))
    surface.DrawOutlinedRect(0, 0, w, h, ScreenScale(1))

    if self.shortname then
        draw.SimpleText(self.shortname, "ZB_ScrappersMedium", w / 2, h / 2, (self.Unavailable and gray2) or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self.tier then
        draw.SimpleText(self.tier, "ZB_SS_MediumSmall", w - ScreenScale(2), h - ScreenScale(2), (self.Unavailable and gray2) or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    self.OldVotes = self.OldVotes or 0
    self.Votes = (MODE.ResearchVotes[self.lane][self.k]["Votes"] and MODE.ResearchVotes[self.lane][self.k]["Votes"][LocalPlayer():Team()]) or 0

    if self.OldVotes != self.Votes then
        self.OldVotes = self.Votes
        self:NewVote()
    end

    if self.Votes > 0 then
        local m = Matrix()

        local x, y = self:GetPos()
        local center = Vector(x + w + ScreenScale(7), y + h / 2)

        m:Translate(center)
        m:Scale(scale * (self.anim + 1))
        m:Translate(-center)

        cam.PushModelMatrix( m )

        DisableClipping(true)
            draw.SimpleText(self.Votes, "ZB_ScrappersHumongous", w + ScreenScale(7), h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        DisableClipping(false)

        cam.PopModelMatrix()
    end
end

function PANEL:OnMousePressed()
    if self.Unavailable then return end

    net.Start("SS_ResearchVote")
        net.WriteString(self.lane)
        net.WriteUInt(self.k, 6)
    net.SendToServer()
end

vgui.Register("ZB_SSResearchSlot", PANEL, "EditablePanel")