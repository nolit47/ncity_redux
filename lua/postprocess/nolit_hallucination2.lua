local mat_RingsEffect = Material( "effects/shaders/nolit_hallucination" )

local pp_rings = CreateClientConVar( "pp_rings", "0", false, false, "Enable Rings Effect", 0, 1 )
local pp_rings_speed = CreateClientConVar( "pp_rings_speed", "1.0", false, false, "animation speed", 0.1, 5.0 )
local pp_rings_count = CreateClientConVar( "pp_rings_count", "45.0", false, false, "number of rings", 10.0, 100.0 )
local pp_rings_velocity = CreateClientConVar( "pp_rings_velocity", "91.0", false, false, "ring movement speed", 10.0, 200.0 )
local pp_rings_border = CreateClientConVar( "pp_rings_border", "0.003", false, false, "ring border smoothness", 0.001, 0.02 )
local pp_rings_modulation = CreateClientConVar( "pp_rings_modulation", "60.0", false, false, "ring count modulation", 0.0, 120.0 )
local pp_rings_displacement = CreateClientConVar( "pp_rings_displacement", "0.05", false, false, "texture displacement strength", 0.0, 0.2 )
local pp_rings_mix = CreateClientConVar( "pp_rings_mix", "0.3", false, false, "effect blend amount", 0.0, 1.0 )

function render.DrawRingsEffect(speed, ringCount, velocity, border, modulation, displacement, mixAmount)
    render.UpdateScreenEffectTexture()
    local time = RealTime() * speed

    mat_RingsEffect:SetFloat("$c0_x", ringCount)
    mat_RingsEffect:SetFloat("$c0_y", velocity)
    mat_RingsEffect:SetFloat("$c0_z", border)
    mat_RingsEffect:SetFloat("$c0_w", speed)

    mat_RingsEffect:SetFloat("$c1_x", 0.35)
    mat_RingsEffect:SetFloat("$c1_y", modulation)
    mat_RingsEffect:SetFloat("$c1_z", 0.951)
    mat_RingsEffect:SetFloat("$c1_w", 0.0085)

    mat_RingsEffect:SetFloat("$c2_x", displacement)
    mat_RingsEffect:SetFloat("$c2_y", 0.01)
    mat_RingsEffect:SetFloat("$c2_z", mixAmount)
    mat_RingsEffect:SetFloat("$c2_w", 0.0)

    mat_RingsEffect:SetFloat("$c3_x", time)
    mat_RingsEffect:SetFloat("$c3_y", 0.0)
    mat_RingsEffect:SetFloat("$c3_z", 0.0)
    mat_RingsEffect:SetFloat("$c3_w", 0.0)

    render.SetMaterial(mat_RingsEffect)
    render.DrawScreenQuad()
end

local function UpdateRingsHook()
    if pp_rings:GetBool() then
        hook.Add("RenderScreenspaceEffects", "rings_effect_hook", function()
            render.DrawRingsEffect(
                pp_rings_speed:GetFloat(),
                pp_rings_count:GetFloat(),
                pp_rings_velocity:GetFloat(),
                pp_rings_border:GetFloat(),
                pp_rings_modulation:GetFloat(),
                pp_rings_displacement:GetFloat(),
                pp_rings_mix:GetFloat()
            )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "rings_effect_hook")
    end
end

cvars.AddChangeCallback("pp_rings", UpdateRingsHook, "rings_callback")
cvars.AddChangeCallback("pp_rings_speed", UpdateRingsHook, "rings_speed_callback")
cvars.AddChangeCallback("pp_rings_count", UpdateRingsHook, "rings_count_callback")
cvars.AddChangeCallback("pp_rings_velocity", UpdateRingsHook, "rings_velocity_callback")
cvars.AddChangeCallback("pp_rings_border", UpdateRingsHook, "rings_border_callback")
cvars.AddChangeCallback("pp_rings_modulation", UpdateRingsHook, "rings_modulation_callback")
cvars.AddChangeCallback("pp_rings_displacement", UpdateRingsHook, "rings_displacement_callback")
cvars.AddChangeCallback("pp_rings_mix", UpdateRingsHook, "rings_mix_callback")

list.Set( "PostProcess", "Rings", {

    icon = "gui/postprocess/rings.png",
    convar = "pp_rings",
    category = "#effects_pp",

    cpanel = function( CPanel )
    end

} )

hook.Add("InitPostEntity", "rings_effect_init", function()
    UpdateRingsHook()
end)
