local mat_DistortionEffect = Material( "effects/shaders/nolit_wobble" )

local pp_distortion = CreateClientConVar( "pp_distortion", "0", false, false, "", 0, 1 )
local pp_distortion_speed = CreateClientConVar( "pp_distortion_speed", "1.0", false, false, "", 0.1, 5.0 )
local pp_distortion_intensity = CreateClientConVar( "pp_distortion_intensity", "0.02", false, false, "", 0.0, 0.1 )
local pp_distortion_frequency = CreateClientConVar( "pp_distortion_frequency", "10.0", false, false, "", 1.0, 50.0 )
local pp_distortion_time_x = CreateClientConVar( "pp_distortion_time_x", "6.0", false, false, "", 1.0, 20.0 )
local pp_distortion_time_y = CreateClientConVar( "pp_distortion_time_y", "7.0", false, false, "", 1.0, 20.0 )
local pp_distortion_scale = CreateClientConVar( "pp_distortion_scale", "0.8", false, false, "", 0.1, 2.0 )
local pp_distortion_offset = CreateClientConVar( "pp_distortion_offset", "0.1", false, false, "", 0.0, 0.5 )

function render.DrawDistortionEffect(speed, intensity, frequency, timeX, timeY, scale, offset)
    render.UpdateScreenEffectTexture()
    local time = RealTime() * speed

    mat_DistortionEffect:SetFloat("$c0_x", time)
    mat_DistortionEffect:SetFloat("$c0_y", intensity)
    mat_DistortionEffect:SetFloat("$c0_z", frequency)
    mat_DistortionEffect:SetFloat("$c0_w", scale)

    mat_DistortionEffect:SetFloat("$c1_x", timeX)
    mat_DistortionEffect:SetFloat("$c1_y", timeY)
    mat_DistortionEffect:SetFloat("$c1_z", offset)
    mat_DistortionEffect:SetFloat("$c1_w", 0.0)

    mat_DistortionEffect:SetFloat("$c2_x", 0.0)
    mat_DistortionEffect:SetFloat("$c2_y", 0.0)
    mat_DistortionEffect:SetFloat("$c2_z", 0.0)
    mat_DistortionEffect:SetFloat("$c2_w", 0.0)

    mat_DistortionEffect:SetFloat("$c3_x", 0.0)
    mat_DistortionEffect:SetFloat("$c3_y", 0.0)
    mat_DistortionEffect:SetFloat("$c3_z", 0.0)
    mat_DistortionEffect:SetFloat("$c3_w", 0.0)

    render.SetMaterial(mat_DistortionEffect)
    render.DrawScreenQuad()
end

local function UpdateDistortionHook()
    if pp_distortion:GetBool() then
        hook.Add("RenderScreenspaceEffects", "distortion_effect_hook", function()
            render.DrawDistortionEffect(
                pp_distortion_speed:GetFloat(),
                pp_distortion_intensity:GetFloat(),
                pp_distortion_frequency:GetFloat(),
                pp_distortion_time_x:GetFloat(),
                pp_distortion_time_y:GetFloat(),
                pp_distortion_scale:GetFloat(),
                pp_distortion_offset:GetFloat()
            )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "distortion_effect_hook")
    end
end

cvars.AddChangeCallback("pp_distortion", UpdateDistortionHook, "distortion_callback")
cvars.AddChangeCallback("pp_distortion_speed", UpdateDistortionHook, "distortion_speed_callback")
cvars.AddChangeCallback("pp_distortion_intensity", UpdateDistortionHook, "distortion_intensity_callback")
cvars.AddChangeCallback("pp_distortion_frequency", UpdateDistortionHook, "distortion_frequency_callback")
cvars.AddChangeCallback("pp_distortion_time_x", UpdateDistortionHook, "distortion_time_x_callback")
cvars.AddChangeCallback("pp_distortion_time_y", UpdateDistortionHook, "distortion_time_y_callback")
cvars.AddChangeCallback("pp_distortion_scale", UpdateDistortionHook, "distortion_scale_callback")
cvars.AddChangeCallback("pp_distortion_offset", UpdateDistortionHook, "distortion_offset_callback")

list.Set( "PostProcess", "Distortion", {
    icon = "gui/postprocess/distortion.png",
    convar = "pp_distortion",
    category = "#effects_pp",

    cpanel = function( CPanel )
        CPanel:Help( "Animated wave distortion effect" )
        CPanel:CheckBox( "Enable", "pp_distortion" )
        CPanel:Help( "" )
        CPanel:Help( "Animation Controls:" )
        CPanel:NumSlider( "Animation Speed", "pp_distortion_speed", 0.1, 5.0, 2 )
        CPanel:Help( "Controls overall animation speed" )
        CPanel:NumSlider( "Distortion Intensity", "pp_distortion_intensity", 0.0, 0.1, 3 )
        CPanel:Help( "Strength of the wave distortion" )
        CPanel:Help( "" )
        CPanel:Help( "Wave Properties:" )
        CPanel:NumSlider( "Wave Frequency", "pp_distortion_frequency", 1.0, 50.0, 1 )
        CPanel:Help( "Frequency of the distortion waves" )
        CPanel:NumSlider( "X-Axis Time Multiplier", "pp_distortion_time_x", 1.0, 20.0, 1 )
        CPanel:Help( "Time multiplier for horizontal wave motion" )
        CPanel:NumSlider( "Y-Axis Time Multiplier", "pp_distortion_time_y", 1.0, 20.0, 1 )
        CPanel:Help( "Time multiplier for vertical wave motion" )
        CPanel:Help( "" )
        CPanel:Help( "Display Settings:" )
        CPanel:NumSlider( "UV Scale", "pp_distortion_scale", 0.1, 2.0, 2 )
        CPanel:Help( "Scale factor for texture coordinates (0.8 = 80% of screen)" )
        CPanel:NumSlider( "UV Offset", "pp_distortion_offset", 0.0, 0.5, 2 )
        CPanel:Help( "Offset for texture coordinates (centers the effect)" )
        CPanel:Help( "" )
        CPanel:Help( "Creates animated wave distortion using cosine functions" )
        CPanel:Help( "Adjust time multipliers for different wave patterns" )
        CPanel:Help( "Higher frequency creates more detailed waves" )
    end
} )

hook.Add("InitPostEntity", "distortion_effect_init", function()
    UpdateDistortionHook()
end)
