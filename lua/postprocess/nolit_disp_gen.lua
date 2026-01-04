local mat_DisplacementEffect = Material( "effects/shaders/nolit_disp_gen" )

local pp_displacement = CreateClientConVar( "pp_displacement", "0", false, false, "", 0, 1 )
local pp_displacement_horizontal = CreateClientConVar( "pp_displacement_horizontal", "1.0", false, false, "", 0.0, 2.0 )
local pp_displacement_scale = CreateClientConVar( "pp_displacement_scale", "0.15", false, false, "", 0.0, 1.0 )
local pp_displacement_speed = CreateClientConVar( "pp_displacement_speed", "0.5", false, false, "", 0.1, 2.0 )
local pp_displacement_wrap = CreateClientConVar( "pp_displacement_wrap", "0", false, false, "", 0, 1 )

function render.DrawDisplacementEffect(horizontal, scale, speed, wrap)
    render.UpdateScreenEffectTexture()
    local time = RealTime()

    mat_DisplacementEffect:SetFloat("$c0_x", horizontal)
    mat_DisplacementEffect:SetFloat("$c0_y", scale)
    mat_DisplacementEffect:SetFloat("$c0_z", speed)
    mat_DisplacementEffect:SetFloat("$c0_w", wrap)

    mat_DisplacementEffect:SetFloat("$c1_x", time)
    mat_DisplacementEffect:SetFloat("$c1_y", 0.0)
    mat_DisplacementEffect:SetFloat("$c1_z", 0.0)
    mat_DisplacementEffect:SetFloat("$c1_w", 0.0)

    mat_DisplacementEffect:SetFloat("$c2_x", 0.0)
    mat_DisplacementEffect:SetFloat("$c2_y", 0.0)
    mat_DisplacementEffect:SetFloat("$c2_z", 0.0)
    mat_DisplacementEffect:SetFloat("$c2_w", 0.0)

    mat_DisplacementEffect:SetFloat("$c3_x", 0.0)
    mat_DisplacementEffect:SetFloat("$c3_y", 0.0)
    mat_DisplacementEffect:SetFloat("$c3_z", 0.0)
    mat_DisplacementEffect:SetFloat("$c3_w", 0.0)

    render.SetMaterial(mat_DisplacementEffect)
    render.DrawScreenQuad()
end

local function UpdateDisplacementHook()
    if pp_displacement:GetBool() then
        hook.Add("RenderScreenspaceEffects", "displacement_effect_hook", function()
            render.DrawDisplacementEffect(
                pp_displacement_horizontal:GetFloat(),
                pp_displacement_scale:GetFloat(),
                pp_displacement_speed:GetFloat(),
                pp_displacement_wrap:GetBool() and 1.0 or 0.0
            )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "displacement_effect_hook")
    end
end

cvars.AddChangeCallback("pp_displacement", UpdateDisplacementHook, "displacement_callback")
cvars.AddChangeCallback("pp_displacement_horizontal", UpdateDisplacementHook, "displacement_horizontal_callback")
cvars.AddChangeCallback("pp_displacement_scale", UpdateDisplacementHook, "displacement_scale_callback")
cvars.AddChangeCallback("pp_displacement_speed", UpdateDisplacementHook, "displacement_speed_callback")
cvars.AddChangeCallback("pp_displacement_wrap", UpdateDisplacementHook, "displacement_wrap_callback")

list.Set( "PostProcess", "Displacement", {
    icon = "gui/postprocess/displacement.png",
    convar = "pp_displacement",
    category = "#effects_pp",

    cpanel = function( CPanel )
        CPanel:Help( "After Effects-style displacement map effect" )
        CPanel:CheckBox( "Enable", "pp_displacement" )
        CPanel:Help( "" )
        CPanel:NumSlider( "Horizontal Displacement", "pp_displacement_horizontal", 0.0, 2.0, 2 )
        CPanel:Help( "Strength of horizontal displacement using red channel" )
        CPanel:NumSlider( "Displacement Scale", "pp_displacement_scale", 0.0, 1.0, 2 )
        CPanel:Help( "Overall displacement scaling factor" )
        CPanel:NumSlider( "Animation Speed", "pp_displacement_speed", 0.1, 2.0, 1 )
        CPanel:Help( "Speed of displacement animation" )
        CPanel:CheckBox( "Wrap Pixels Around", "pp_displacement_wrap" )
        CPanel:Help( "Enable pixel wrapping at screen edges" )
        CPanel:Help( "" )
        CPanel:Help( "Uses red channel from noise texture as displacement map" )
        CPanel:Help( "Mimics After Effects Displacement Map effect" )
    end
} )

hook.Add("InitPostEntity", "displacement_effect_init", function()
    UpdateDisplacementHook()
end)