local mat_DitherEffect = Material( "effects/shaders/nolit_dither" )

local pp_dither = CreateClientConVar( "pp_dither", "0", false, false, "", 0, 1 )
local pp_dither_contrast = CreateClientConVar( "pp_dither_contrast", "0.25", false, false, "", 0.0, 1.0 )
local pp_dither_scale = CreateClientConVar( "pp_dither_scale", "2.0", false, false, "", 1.0, 10.0 )

function render.DrawDitherEffect(contrast, scale)
    render.UpdateScreenEffectTexture()

    mat_DitherEffect:SetFloat("$c0_x", contrast)
    mat_DitherEffect:SetFloat("$c0_y", scale)
    mat_DitherEffect:SetFloat("$c0_z", 0.0)
    mat_DitherEffect:SetFloat("$c0_w", 0.0)

    mat_DitherEffect:SetFloat("$c1_x", 0.0)
    mat_DitherEffect:SetFloat("$c1_y", 0.0)
    mat_DitherEffect:SetFloat("$c1_z", 0.0)
    mat_DitherEffect:SetFloat("$c1_w", 0.0)

    mat_DitherEffect:SetFloat("$c2_x", 0.0)
    mat_DitherEffect:SetFloat("$c2_y", 0.0)
    mat_DitherEffect:SetFloat("$c2_z", 0.0)
    mat_DitherEffect:SetFloat("$c2_w", 0.0)

    mat_DitherEffect:SetFloat("$c3_x", 0.0)
    mat_DitherEffect:SetFloat("$c3_y", 0.0)
    mat_DitherEffect:SetFloat("$c3_z", 0.0)
    mat_DitherEffect:SetFloat("$c3_w", 0.0)

    render.SetMaterial(mat_DitherEffect)
    render.DrawScreenQuad()
end

local function UpdateDitherHook()
    if pp_dither:GetBool() then
        hook.Add("RenderScreenspaceEffects", "dither_effect_hook", function()
            render.DrawDitherEffect(
                pp_dither_contrast:GetFloat(),
                pp_dither_scale:GetFloat()
            )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "dither_effect_hook")
    end
end

cvars.AddChangeCallback("pp_dither", UpdateDitherHook, "dither_callback")
cvars.AddChangeCallback("pp_dither_contrast", UpdateDitherHook, "dither_contrast_callback")
cvars.AddChangeCallback("pp_dither_scale", UpdateDitherHook, "dither_scale_callback")

list.Set( "PostProcess", "Dither", {
    icon = "",
    convar = "pp_dither",
    category = "#effects_pp",

    cpanel = function( CPanel )
        CPanel:CheckBox( "Enable", "pp_dither" )
        CPanel:Help( "" )
        CPanel:NumSlider( "Contrast Boost", "pp_dither_contrast", 0.0, 1.0, 2 )
        CPanel:Help( "Enhances contrast before dithering" )
        CPanel:NumSlider( "Dither Scale", "pp_dither_scale", 1.0, 10.0, 1 )
        CPanel:Help( "Number of color levels per channel" )
    end
} )

hook.Add("InitPostEntity", "dither_effect_init", function()
    UpdateDitherHook()
end)