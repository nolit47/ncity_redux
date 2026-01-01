local PANEL = {}

local MODE = MODE

local sw, sh = ScrW(), ScrH()

local SlotSize = ScreenScale(20)

function PANEL:Init()
    self:SetSize(sw, sh)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    gui.EnableScreenClicker(true)

    if IsValid(zb.SSMap) then
        zb.SSMap:Remove()
    end

    zb.SSMap = self

    self.grid = self:Add("ZB_SSGrid")
    self.grid:SetSize(sw, sh)

    self.alpha = 255

    self.MainPanel = self:Add("ZB_SSMain")
    self.MainPanel:Dock(FILL)
    self.MainPanel.Parent = self

    self.Players = self:Add("ZB_SSPlayers")
    self.Players:SetSize(sw, sh)

    for _, ply in player.Iterator() do
        self.Players:AddPlayer(ply, ply:Team())
    end

    self.MainPanel.Slots = self.Slots

    self.LastBorder = sw * 2

    self.Phases = {
        [0] = self.SetupIntermission,
        [1] = self.SetupResearch,
        [2] = self.SetupMapSlots
    }

    self:SetPhase(0)
end

function PANEL:SetPhase(phase)
    self.phase = phase

    if IsValid(self.CurrentPhase) then
        self.CurrentPhase:Remove()
    end

    self.CurrentPhase = self.Phases[phase](self)
end

local red = Color(255, 0, 0, 100)
local blue = Color(0, 0, 255, 100)

function PANEL:SetupIntermission()
    self.grid:FadeColor(0, 0, 0, 0)

    self.IntermissionPanel = self:Add("EditablePanel")
    self.IntermissionPanel:SetSize(sw, sh)

    self.IntermissionPanel.Chromatic = 3

    self.IntermissionPanel.Paint = function()
        draw.SimpleText("Street", "ZB_ScrappersLarge", sw / 2 + self.IntermissionPanel.Chromatic, sh / 2 - ScreenScale(10), red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Street", "ZB_ScrappersLarge", sw / 2 - self.IntermissionPanel.Chromatic, sh / 2 - ScreenScale(10), blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Street", "ZB_ScrappersLarge", sw / 2, sh / 2 - ScreenScale(10), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText("Sweep", "ZB_ScrappersLarge", sw / 2 + self.IntermissionPanel.Chromatic, sh / 2 + ScreenScale(10), red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Sweep", "ZB_ScrappersLarge", sw / 2 - self.IntermissionPanel.Chromatic, sh / 2 + ScreenScale(10), blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Sweep", "ZB_ScrappersLarge", sw / 2, sh / 2 + ScreenScale(10), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self:CreateAnimation(6, {
        index = 1,
        target = {
            LastBorder = 0
        },
        easing = "outExpo",
        bIgnoreConfig = true
    })

    return self.IntermissionPanel
end

function PANEL:SetupResearch()
    self.grid:FadeColor(0, 66, 113, 5)

    self.Research = {}

    self.ResearchSlots = self:Add("EditablePanel")
    self.ResearchSlots:SetSize(sw, sh)

    local i = -1

    for lane, research in pairs(MODE.Research) do
        local ResearchCount = table.Count(MODE.Research)

        i = i + 1

        self.Research[lane] = {}

        for k, v in ipairs(research) do
            local slot = self.ResearchSlots:Add("ZB_SSResearchSlot")
            slot.alpha = self.alpha
            slot:SetSize(SlotSize, SlotSize)

            slot:SetPos(sw / 2 + (i * ScreenScale(50)) - ((ResearchCount * ScreenScale(50)) / 2.5), sh / 2 + ((ScreenScaleH(40) * k) - (ScreenScaleH(40) * 3) / 1.33)) --i hate this

            slot.shortname = research.shortname
            slot.tier = k

            local behind = MODE.Research[lane][k - 1]

            if behind and !behind.Researched then
                slot.Unavailable = true
            end

            slot:SetResearch(v, lane, k)

            self.Research[lane][k] = slot
        end
    end

    return self.ResearchSlots
end

function PANEL:SetupMapSlots()
    self.grid:FadeColor(0, 0, 0)

    local LaneAmount = #MODE.MapSlots
    self.Slots = {}

    self.MapSlots = self:Add("EditablePanel")
    self.MapSlots:SetSize(sw, sh)

    for lane, maps in ipairs(MODE.MapSlots) do
        local MapCount = #maps

        self.Slots[lane] = {}

        for k, map in ipairs(maps) do
            if map == NULL then
                self.Slots[lane][k] = NULL
                continue
            end

            local slot = self.MapSlots:Add("ZB_SSMapSlot")
            slot.alpha = self.alpha
            slot:SetSize(SlotSize, SlotSize)
            slot:SetPos(sw / 2 - (MapCount / 2 - k) * ScreenScale(50) - ScreenScale(35), ScreenScaleH(55) * lane) --i hate this

            slot.capture = map.captured or 2
            slot.building = map.building

            local LookAbove = MODE.MapSlots[lane - 1] or {}
            local LookBelow = MODE.MapSlots[lane + 1] or {} -- i hate ni-

            for k2, v2 in ipairs(LookAbove) do

                if !((k2 - 1) == k or (k2 + 1 ) == k or (k2 == k)) then continue end

                if v2.captured == LocalPlayer():Team() then
                    slot.Unavailable = false
                    break
                end
            end

            for k2, v2 in ipairs(LookBelow) do

                if !((k2 - 1) == k or (k2 + 1 ) == k or (k2 == k)) then continue end

                if v2.captured == LocalPlayer():Team() then
                    slot.Unavailable = false
                    break
                end
            end

            slot:SetMap(map.map)

            self.Slots[lane][k] = slot
        end
    end

    return self.MapSlots
end

vgui.Register("ZB_SSMap", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
end

function PANEL:Paint(w, h)
    if IsValid(self.Parent.MapSlots) then --connect the dots (optimize this, probably caching?)
        for k, v in ipairs(self.Parent.Slots) do
            local LookAhead = self.Parent.Slots[k + 1]

            for k2, v2 in ipairs(v) do
                if LookAhead then
                    for k3, v3 in ipairs(LookAhead) do
                        if #v < #LookAhead then
                            if ((k2 + 1) != k3) and k2 != k3 then continue end
                        elseif #v > #LookAhead then
                            if ((k2 - 1) != k3) and k2 != k3 then continue end
                        end

                        if v2 == NULL or v3 == NULL then continue end

                        surface.SetDrawColor(255, 255, 255, self.Parent.alpha)
                        surface.DrawLine(v2:GetX() + (SlotSize / 2), v2:GetY() + (SlotSize / 2), v3:GetX() + (SlotSize / 2), v3:GetY() + (SlotSize / 2))
                    end
                end
            end
        end
    end

    if IsValid(self.Parent.ResearchSlots) then
        for k, v in pairs(self.Parent.Research) do
            for k2, v2 in ipairs(v) do
                local LookAhead = self.Parent.Research[k][k2 + 1]

                if IsValid(LookAhead) then
                    surface.SetDrawColor(255, 255, 255, self.Parent.alpha)
                    surface.DrawLine(v2:GetX() + (SlotSize / 2), v2:GetY() + (SlotSize / 2), LookAhead:GetX() + (SlotSize / 2), LookAhead:GetY() + (SlotSize / 2))
                end
            end
        end
    end

    if self.Parent.CurrentResearch then
        local name = MODE.Research[self.Parent.CurrentResearch.lane][self.Parent.CurrentResearch.slot].name
        local needed = MODE.Research[self.Parent.CurrentResearch.lane][self.Parent.CurrentResearch.slot].points
        local current = self.Parent.CurrentResearch.Invested

        draw.SimpleText(name .. ": " .. current .. "/" .. needed, "ZB_ScrappersMedium", sw * 0.2, sh - ScreenScale(10), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("ZB_SSMain", PANEL, "EditablePanel")

local gradient_d = Material("vgui/gradient-d")
local gradient_u = Material("vgui/gradient-u")
local gradient_l = Material("vgui/gradient-l")
local gradient_r = Material("vgui/gradient-r")

hook.Add("DrawOverlay", "Fade_Effect", function()
    if !IsValid(zb.SSMap) then return end

    local border_size = zb.SSMap.LastBorder or 0

    draw.SimpleText(MODE.Phases[zb.SSMap.phase], "ZB_ScrappersMediumLarge", sw / 2, sh - ScreenScale(8), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    if border_size != 0 then
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

    surface.SetTextColor(255, 255, 255, 20)
    surface.SetFont("ZB_ScrappersMedium")
    surface.SetTextPos(sw - ScreenScale(69), ScreenScale(1))
    surface.DrawText("Street Sweep v0.1")
end)