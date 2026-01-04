-- Radial Blur Post Process Effect for Garry's Mod
-- Place this file in: garrysmod/addons/radial_blur/lua/autorun/client/cl_radial_blur.lua

local mat_RadialBlur = Material( "effects/shaders/radial_blur" )

local pp_radialblur = CreateClientConVar( "pp_radialblur", "0", false, false, "Enable radial blur", 0, 1 )
local pp_radialblur_minblur = CreateClientConVar( "pp_radialblur_minblur", "0", false, false, "Minimum blur amount", 0, 0.1 )
local pp_radialblur_maxblur = CreateClientConVar( "pp_radialblur_maxblur", "0.02", false, false, "Maximum blur amount", 0, 0.1 )
local pp_radialblur_speed = CreateClientConVar( "pp_radialblur_speed", "2", false, false, "Animation speed", 0.1, 10 )

cvars.AddChangeCallback("pp_radialblur", function(cvar, old, new)
    if pp_radialblur:GetBool() then

        hook.Add("RenderScreenspaceEffects", "radialblur_hook", function()
            render.UpdateScreenEffectTexture()
            mat_RadialBlur:SetFloat("$c0_x", pp_radialblur_minblur:GetFloat() )
            mat_RadialBlur:SetFloat("$c0_y", pp_radialblur_maxblur:GetFloat() )
            mat_RadialBlur:SetFloat("$c0_z", pp_radialblur_speed:GetFloat() )
            mat_RadialBlur:SetFloat("$c0_w", CurTime() )
            render.SetMaterial(mat_RadialBlur)
            render.DrawScreenQuad()
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "radialblur_hook")
    end
end, "radialblur_callback")

list.Set( "PostProcess", "Radial Blur", {

	icon = "gui/postprocess/radialblur.png",
	convar = "pp_radialblur",
	category = "#effects_pp",

	cpanel = function( CPanel )

		CPanel:Help( "Creates an animated radial blur effect that pulses from the center of the screen." )
		CPanel:CheckBox( "Enable", "pp_radialblur" )

        CPanel:NumSlider( "Min Blur", "pp_radialblur_minblur", 0, 0.1, 4 )
        CPanel:NumSlider( "Max Blur", "pp_radialblur_maxblur", 0, 0.1, 4 )
        CPanel:NumSlider( "Speed", "pp_radialblur_speed", 0.1, 10, 2 )

	end

} )