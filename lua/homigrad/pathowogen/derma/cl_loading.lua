-- "addons\\homigrad\\lua\\homigrad\\pathowogen\\derma\\cl_loading.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local PANEL = {}

local gradient_l = Material("vgui/gradient-l")

local xbars = 17
local ybars = 30

surface.CreateFont("ZB_ProotOSLarge", {
    font = "Blue Screen Personal Use",
    size = ScreenScale(500),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_ProotOSMedium", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_ProotOSAssimilation", {
    font = "Blue Screen Personal Use",
    size = ScreenScale(20),
    extended = true,
    weight = 400,
    antialias = true
})

-- local tbl = vgui.GetAll()

-- for _, v in pairs(tbl) do
--     v:Remove()
-- end

local bluewhite = Color(187, 187, 255)
local bluewhite2 = Color(213, 43, 43)

local sw, sh = ScrW(), ScrH()

function PANEL:Init()
    system.FlashWindow()

    self.progress = 0
    self.alpha = 255
    self.alphagrid = 255

    self.blur = 5

    self.done = false
    self:CreateAnimation(2.5, {
        index = 5,
        target = {
            blur = 0
        },
        easing = "linear",
        bIgnoreConfig = true,
    })

    timer.Simple(2, function()
        self:CreateAnimation(0.5, {
            index = 10,
            target = {
                progress = math.Rand(0.1, 0.5)
            },
            easing = "outQuint",
            bIgnoreConfig = true,
            OnComplete = function()
                self:CreateAnimation(1.5, {
                    index = 11,
                    target = {
                        progress = math.Rand(0.6, 0.9)
                    },
                    easing = "linear",
                    bIgnoreConfig = true,
                    OnComplete = function()
                        self:CreateAnimation(1, {
                            index = 12,
                            target = {
                                progress = 1
                            },
                            easing = "outQuint",
                            bIgnoreConfig = true,
                            OnComplete = function()
                                self:Close()
                            end
                        })
                    end
                })
            end
        })
    end)

    if IsValid(hg.furload) then
        hg.furload:Remove()
    end
    hg.furload = self

    self:SetSize(sw, sh)
	self:RequestFocus()

    sound.PlayFile("sound/zbattle/boot.ogg", "", function()
    end)
end

function PANEL:Close()
    self.done = true
    sound.PlayFile("sound/zbattle/login.wav", "", function()
    end)

    timer.Simple(1, function()
        self:CreateAnimation(1, {
            index = 2,
            target = {
                alpha = 0
            },
            easing = "linear",
            bIgnoreConfig = true,
            Think = function()
                self:SetAlpha(self.alpha)
            end,
            OnComplete = function()
                self:Remove()
            end
        })
    end)

    self:CreateAnimation(1, {
        index = 3,
        target = {
            alphagrid = 0
        },
        easing = "linear",
        bIgnoreConfig = true,
    })
end

local blur = Material("pp/blurscreen")

function PANEL:Paint()
    local BootUpProgress = self.progress

    //grid sweep
	surface.SetDrawColor(0, 0, 0)
	surface.DrawRect(-10, -10, sw + 10, sh + 10)

	surface.SetDrawColor(4, 19, 22, self.alphagrid)

	for i = 1, (ybars + 1) do
		surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
	end

	for i = 1, (xbars + 1) do
		surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
	end

    local text = "Now loading..."
    local trim = 12 + (math.Round(CurTime()) % 3)

    text = string.Left(text, trim)

    local rainbow = HSVToColor(CurTime() * 50 % 360, 0.9, 0.9)

    draw.GlowingText("OwOS", "ZB_ProotOSLarge", sw * 0.5 + ScreenScale(1), sh * 0.4 + ScreenScale(1), ColorAlpha(rainbow, 100), ColorAlpha(rainbow, 10), ColorAlpha(rainbow, 2), TEXT_ALIGN_CENTER)
	draw.GlowingText("OwOS", "ZB_ProotOSLarge", sw * 0.5, sh * 0.4, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 235), ColorAlpha(bluewhite, 10), TEXT_ALIGN_CENTER)
	draw.GlowingText(text, "ZB_ProotOSMedium", sw * 0.46, sh * 0.485, ColorAlpha(bluewhite, 255), ColorAlpha(bluewhite, 50), ColorAlpha(bluewhite, 10))

    surface.SetDrawColor(ColorAlpha(color_black, 100))
	surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2, sh * 0.02)

	surface.SetDrawColor(bluewhite)
	surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	surface.SetDrawColor(149, 121, 214)
	surface.SetMaterial(gradient_l)
	surface.DrawTexturedRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

	surface.SetDrawColor(bluewhite)
	surface.DrawOutlinedRect(sw * 0.4 - 5, sh * 0.52 - 5, sw * 0.2 + 10, sh * 0.02 + 10)


    local amount = self.blur
    surface.SetMaterial(blur)
    surface.SetDrawColor(255, 255, 255, alpha or 255)

    for i = -(passes or 0.2), 1, 0.2 do
        blur:SetFloat("$blur", i * amount)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(0, 0, sw, sh)
    end
end

local tab = {
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
}


hook.Add("RenderScreenspaceEffects", "furload", function()
    if IsValid(hg.furload) then
        tab["$pp_colour_brightness"] = hg.furload.alpha / 255
        DrawColorModify(tab)
    end
end)

vgui.Register("ZB_FurLoading", PANEL, "EditablePanel")