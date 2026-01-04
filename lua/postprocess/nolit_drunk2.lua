
local mat_DynamicZoom = Material( "effects/shaders/nolit_drunk2" )

local pp_drunkard = CreateClientConVar( "pp_drunkard", "0", false, false, "Enable DrunkEffect", 0, 1 )
local pp_drunkard_speed = CreateClientConVar( "pp_drunkard_speed", "1.0", false, false, "anim speed", 0.1, 3.0 )
local pp_drunkard_intensity = CreateClientConVar( "pp_drunkard_intensity", "1.0", false, false, "zoom intensity", 0.0, 2.0 )
local pp_drunkard_vignette = CreateClientConVar( "pp_drunkard_vignette", "1.0", false, false, "vignette intensity", 0.0, 2.0 )
local pp_drunkard_mouse = CreateClientConVar( "pp_drunkard_mouse", "0", false, false, "enable mouse interaction (obsolete)", 0, 1 )

function render.DrawDynamicZoom(speed, intensity, vignette, mouseInteraction)
    render.UpdateScreenEffectTexture()
    local time = RealTime() * speed
    mat_DynamicZoom:SetFloat("$c0_x", time)

    if mouseInteraction then
        local scrW, scrH = ScrW(), ScrH()
        local mx, my = gui.MouseX(), gui.MouseY()
        local mousePressed = input.IsMouseDown(MOUSE_LEFT) and 1 or 0
        
        mat_DynamicZoom:SetFloat("$c0_y", mx / scrW)
        mat_DynamicZoom:SetFloat("$c0_z", my / scrH)
        mat_DynamicZoom:SetFloat("$c0_w", mousePressed)
    else
        mat_DynamicZoom:SetFloat("$c0_y", 0.5)
        mat_DynamicZoom:SetFloat("$c0_z", 0.5)
        mat_DynamicZoom:SetFloat("$c0_w", 0)
    end

    mat_DynamicZoom:SetFloat("$c1_x", speed)
    mat_DynamicZoom:SetFloat("$c2_x", intensity)
    mat_DynamicZoom:SetFloat("$c2_y", vignette)
    
    render.SetMaterial(mat_DynamicZoom)
    render.DrawScreenQuad()
end

local function UpdateZoomHook()
    if pp_drunkard:GetBool() then
        hook.Add("RenderScreenspaceEffects", "dynamic_zoom_hook", function()
            render.DrawDynamicZoom(
                pp_drunkard_speed:GetFloat(),
                pp_drunkard_intensity:GetFloat(),
                pp_drunkard_vignette:GetFloat(),
                pp_drunkard_mouse:GetBool()
            )
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "dynamic_zoom_hook")
    end
end

cvars.AddChangeCallback("pp_drunkard", UpdateZoomHook, "drunkard_callback")
cvars.AddChangeCallback("pp_drunkard_speed", UpdateZoomHook, "drunkard_speed_callback")
cvars.AddChangeCallback("pp_drunkard_intensity", UpdateZoomHook, "drunkard_intensity_callback")
cvars.AddChangeCallback("pp_drunkard_vignette", UpdateZoomHook, "drunkard_vignette_callback")
cvars.AddChangeCallback("pp_drunkard_mouse", UpdateZoomHook, "drunkard_mouse_callback")

list.Set( "PostProcess", "Drunk", {

    icon = "",
    convar = "pp_drunkard",
    category = "#effects_pp",

    cpanel = function( CPanel )
    end

} )
hook.Add("InitPostEntity", "dynamic_zoom_init", function()
    UpdateZoomHook()
end)