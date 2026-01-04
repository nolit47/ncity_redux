local mat_liquidshit = Material("effects/shaders/nolit_overdose")
local pp_fracture_fluid = CreateClientConVar("pp_fracture_fluid", "0", false, false, "Enable Fracture-Fluid Dynamics Effect", 0, 1)
local pp_fracture_strength = CreateClientConVar("pp_fracture_strength", "1.0", false, false, "Fracture deformation strength", 0.0, 5.0)
local pp_fracture_damping = CreateClientConVar("pp_fracture_damping", "0.9", false, false, "Fracture damping", 0.5, 1.0)
local pp_fracture_advection = CreateClientConVar("pp_fracture_advection", "2.0", false, false, "Advection scale", 0.1, 5.0)
local pp_fracture_noise = CreateClientConVar("pp_fracture_noise", "0.5", false, false, "Noise scale", 0.0, 1.0)
local pp_fluid_viscosity = CreateClientConVar("pp_fluid_viscosity", "0.2", false, false, "Fluid viscosity", 0.0, 1.0)
local pp_fluid_diffusion = CreateClientConVar("pp_fluid_diffusion", "0.1", false, false, "Fluid diffusion", 0.0, 1.0)
local pp_fluid_vorticity = CreateClientConVar("pp_fluid_vorticity", "0.5", false, false, "Fluid vorticity", 0.0, 2.0)
local pp_disp_contrast = CreateClientConVar("pp_disp_contrast", "0.5", false, false, "Display contrast", 0.0, 1.0)
local pp_disp_aberration = CreateClientConVar("pp_disp_aberration", "0.1", false, false, "Chromatic aberration", 0.0, 1.0)
local pp_disp_brightness = CreateClientConVar("pp_disp_brightness", "1.0", false, false, "Brightness", 0.5, 2.0)
local pp_disp_saturation = CreateClientConVar("pp_disp_saturation", "1.0", false, false, "Saturation", 0.0, 2.0)
local pp_disp_quality = CreateClientConVar("pp_disp_quality", "0.5", false, false, "Quality level", 0.0, 1.0)
local pp_system_reset = CreateClientConVar("pp_system_reset", "0", false, false, "Reset simulation", 0, 1)
local pp_system_timestep = CreateClientConVar("pp_system_timestep", "0.1", false, false, "Simulation timestep", 0.01, 0.5)
local pp_mouse_interact = CreateClientConVar("pp_mouse_interact", "1", false, false, "Enable mouse interaction", 0, 1)
local pp_mouse_scale = CreateClientConVar("pp_mouse_scale", "1.0", false, false, "Mouse interaction strength", 0.1, 5.0)
-- to whoever that is reading this, i can officialy say that, this shader is not working
-- thank you for your attention
function render.Drawliquidshit()
    render.UpdateScreenEffectTexture()
    local frameCount = FrameNumber()
    local mousePressed = input.IsMouseDown(MOUSE_LEFT) and pp_mouse_interact:GetBool() and 1 or 0
    local mouseX, mouseY = input.GetCursorPos()
    local scrW, scrH = ScrW(), ScrH()
    mouseX = mouseX / scrW
    mouseY = mouseY / scrH
    
    mat_liquidshit:SetFloat("$c0_x", 3)
    mat_liquidshit:SetFloat("$c0_y", pp_system_timestep:GetFloat())
    mat_liquidshit:SetFloat("$c0_z", frameCount)
    mat_liquidshit:SetFloat("$c0_w", mousePressed)
    mat_liquidshit:SetFloat("$c1_x", mouseX)
    mat_liquidshit:SetFloat("$c1_y", mouseY)
    mat_liquidshit:SetFloat("$c1_z", pp_system_reset:GetBool() and 1 or 0)
    mat_liquidshit:SetFloat("$c1_w", pp_mouse_scale:GetFloat())
    mat_liquidshit:SetFloat("$c2_x", pp_fluid_viscosity:GetFloat())
    mat_liquidshit:SetFloat("$c2_y", pp_fluid_diffusion:GetFloat())
    mat_liquidshit:SetFloat("$c2_z", pp_fluid_vorticity:GetFloat())
    mat_liquidshit:SetFloat("$c2_w", pp_disp_quality:GetFloat())
    mat_liquidshit:SetFloat("$c3_x", pp_fracture_strength:GetFloat())
    mat_liquidshit:SetFloat("$c3_y", pp_fracture_damping:GetFloat())
    mat_liquidshit:SetFloat("$c3_z", pp_fracture_advection:GetFloat())
    mat_liquidshit:SetFloat("$c3_w", pp_fracture_noise:GetFloat())
    mat_liquidshit:SetFloat("$c4_x", pp_disp_contrast:GetFloat())
    mat_liquidshit:SetFloat("$c4_y", pp_disp_aberration:GetFloat())
    mat_liquidshit:SetFloat("$c4_z", pp_disp_brightness:GetFloat())
    mat_liquidshit:SetFloat("$c4_w", pp_disp_saturation:GetFloat())
    
    render.SetMaterial(mat_liquidshit)
    render.DrawScreenQuad()

    if pp_system_reset:GetBool() then
        RunConsoleCommand("pp_system_reset", "0")
    end
end

local function UpdateFractureFluidHook()
    if pp_fracture_fluid:GetBool() then
        hook.Add("RenderScreenspaceEffects", "fracture_fluid_effect_hook", function()
            render.Drawliquidshit()
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "fracture_fluid_effect_hook")
    end
end

cvars.AddChangeCallback("pp_fracture_fluid", UpdateFractureFluidHook, "fracture_fluid_callback")
cvars.AddChangeCallback("pp_fracture_strength", UpdateFractureFluidHook, "fracture_strength_callback")
cvars.AddChangeCallback("pp_fracture_damping", UpdateFractureFluidHook, "fracture_damping_callback")
cvars.AddChangeCallback("pp_fracture_advection", UpdateFractureFluidHook, "fracture_advection_callback")
cvars.AddChangeCallback("pp_fracture_noise", UpdateFractureFluidHook, "fracture_noise_callback")
cvars.AddChangeCallback("pp_fluid_viscosity", UpdateFractureFluidHook, "fluid_viscosity_callback")
cvars.AddChangeCallback("pp_fluid_diffusion", UpdateFractureFluidHook, "fluid_diffusion_callback")
cvars.AddChangeCallback("pp_fluid_vorticity", UpdateFractureFluidHook, "fluid_vorticity_callback")
cvars.AddChangeCallback("pp_disp_contrast", UpdateFractureFluidHook, "disp_contrast_callback")
cvars.AddChangeCallback("pp_disp_aberration", UpdateFractureFluidHook, "disp_aberration_callback")
cvars.AddChangeCallback("pp_disp_brightness", UpdateFractureFluidHook, "disp_brightness_callback")
cvars.AddChangeCallback("pp_disp_saturation", UpdateFractureFluidHook, "disp_saturation_callback")
cvars.AddChangeCallback("pp_disp_quality", UpdateFractureFluidHook, "disp_quality_callback")
cvars.AddChangeCallback("pp_system_reset", UpdateFractureFluidHook, "system_reset_callback")
cvars.AddChangeCallback("pp_system_timestep", UpdateFractureFluidHook, "system_timestep_callback")
cvars.AddChangeCallback("pp_mouse_interact", UpdateFractureFluidHook, "mouse_interact_callback")
cvars.AddChangeCallback("pp_mouse_scale", UpdateFractureFluidHook, "mouse_scale_callback")

list.Set("PostProcess", "Fracture-Fluid Dynamics", {
    icon = "gui/postprocess/fracture_fluid.png",
    convar = "pp_fracture_fluid",
    category = "#effects_pp",
    
    cpanel = function(CPanel)
    end
})

hook.Add("InitPostEntity", "fracture_fluid_effect_init", function()
    UpdateFractureFluidHook()
end)