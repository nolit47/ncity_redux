local EFFECT = {}

EFFECT.enabled = CreateClientConVar("pp_nyctonightmare_enable", "0", false, false)
EFFECT.pixelation = CreateClientConVar("pp_nyctonightmare_pixelation", "320", true, false)
EFFECT.intensity = CreateClientConVar("pp_nyctonightmare_intensity", "1", true, false)

local mat_nyctonightmare = Material("effects/shaders/nolit_nycto")

function EFFECT.SetupShader()
    local pixelation = math.max(64, EFFECT.pixelation:GetFloat())
    local intensity = math.Clamp(EFFECT.intensity:GetFloat(), 0, 1)
    mat_nyctonightmare:SetFloat("$c0_x", pixelation)
    mat_nyctonightmare:SetFloat("$c0_y", pixelation * (ScrH() / ScrW()))
    mat_nyctonightmare:SetFloat("$c0_z", intensity)
end

function EFFECT.RenderScreenspace()
    if not EFFECT.enabled:GetBool() then return end
    EFFECT.SetupShader()
    render.CopyRenderTargetToTexture(render.GetScreenEffectTexture())
    cam.Start2D()
        surface.SetMaterial(mat_nyctonightmare)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    cam.End2D()
end

hook.Add("RenderScreenspaceEffects", "nyctonightmarePosterize", EFFECT.RenderScreenspace)

concommand.Add("pp_nyctonightmare_toggle", function()
    local current = EFFECT.enabled:GetBool()
    EFFECT.enabled:SetBool(not current)
end)

concommand.Add("pp_nyctonightmare_preset_low", function()
    EFFECT.pixelation:SetFloat(160)
    EFFECT.intensity:SetFloat(1)
end)

concommand.Add("pp_nyctonightmare_preset_medium", function()
    EFFECT.pixelation:SetFloat(320)
    EFFECT.intensity:SetFloat(1)
end)

concommand.Add("pp_nyctonightmare_preset_high", function()
    EFFECT.pixelation:SetFloat(640)
    EFFECT.intensity:SetFloat(1)
end)