local mat_hcvdist = Material( "effects/shaders/nolit_hcv_dist" )

local pp_hcvdist = CreateClientConVar( "pp_hcvdist", "0", false, false, "enable", 0, 1 )
local pp_hcvdist_scale = CreateClientConVar( "pp_hcvdist_scale", "0.005", false, false, "intensity", 0, 0.1 )
local pp_hcvdist_speed = CreateClientConVar( "pp_hcvdist_speed", "1", false, false, "animspeed", 0.1, 10 )
local pp_hcvdist_hfreq = CreateClientConVar( "pp_hcvdist_hfreq", "1", false, false, "horizontal freq", 0.1, 5 )
local pp_hcvdist_vfreq = CreateClientConVar( "pp_hcvdist_vfreq", "0.75", false, false, "vertical freq", 0.1, 5 )

cvars.AddChangeCallback("pp_hcvdist", function(cvar, old, new)
    if pp_hcvdist:GetBool() then

        hook.Add("RenderScreenspaceEffects", "hcvdist_hook", function()
            render.UpdateScreenEffectTexture()
            
            -- Set shader parameters
            mat_hcvdist:SetFloat("$c0_x", pp_hcvdist_scale:GetFloat() )
            mat_hcvdist:SetFloat("$c0_y", CurTime() * pp_hcvdist_speed:GetFloat() )
            mat_hcvdist:SetFloat("$c0_z", pp_hcvdist_hfreq:GetFloat() )
            mat_hcvdist:SetFloat("$c0_w", pp_hcvdist_vfreq:GetFloat() )
            
            render.SetMaterial(mat_hcvdist)
            render.DrawScreenQuad()
        end)

    else
        hook.Remove("RenderScreenspaceEffects", "hcvdist_hook")
    end
end, "hcvdist_callback")

list.Set( "PostProcess", "HCV Distortion", {

    icon = "gui/postprocess/hcvdist.png",
    convar = "pp_hcvdist",
    category = "#effects_pp",

    cpanel = function( CPanel )

        CPanel:Help( "some hcv shader i fouund its really cool huh" )
        CPanel:CheckBox( "Enable", "pp_hcvdist" )

        CPanel:NumSlider( "Dist Scale", "pp_hcvdist_scale", 0, 0.1, 4 )
        CPanel:NumSlider( "Anim Speed", "pp_hcvdist_speed", 0.1, 10, 2 )
        CPanel:NumSlider( "Horizontal freq", "pp_hcvdist_hfreq", 0.1, 5, 2 )
        CPanel:NumSlider( "Vertical freq", "pp_hcvdist_vfreq", 0.1, 5, 2 )

    end

} )