if engine.ActiveGamemode() == "nycto" then
hook.Add("Initialize", "NyctoAmbientOccMain", function()
    if GAMEMODE and GAMEMODE.Name ~= "Nycto" then return end

    CreateClientConVar("nycto_ambient_occlusion",                 0,    true, true, "Enable/disable ambient occlusion")
    CreateClientConVar("nycto_ambient_occlusion_shadows",         0,    true, true, "Enable/disable rendering shadows only")
    CreateClientConVar("nycto_ambient_occlusion_threshold",       0.99, true, true, "Threshold of edge detection")
    CreateClientConVar("nycto_ambient_occlusion_strength",        0.80, true, true, "Strength of shadows")
    CreateClientConVar("nycto_ambient_occlusion_blur_radius",     2.20, true, true, "Radius of shadows blur")
    CreateClientConVar("nycto_ambient_occlusion_blur_passes",     6,    true, true, "Number of shadows blur passes")

    local RenderBuffer = RenderBuffer or GetRenderTarget("AmbientOcclusionBuffer", ScrW(), ScrH(), false)
    local MaterialRenderBuffer = MaterialRenderBuffer or CreateMaterial("AmbientOcclusionScreen", "UnlitGeneric", {
        ['$basetexture'] = RenderBuffer:GetName(),
    })

    local MaterialDepth = MaterialDepth or CreateMaterial("AmbientOcclusionDepth", "UnlitGeneric", {
        ['$basetexture'] = render.GetResolvedFullFrameDepth():GetName(),
    })

    local DepthPass = false

    function DrawAmbientOcclusion(shadows, threshold, strength, radius, passes)
        DepthPass = true

        render.PushRenderTarget(RenderBuffer)
        render.Clear(0, 0, 0, 255)
        render.ClearDepth()

        render.SetLightingMode(2)
        render.RenderView({
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            origin = EyePos(),
            angles = EyeAngles(),
            drawhud = false,
            drawviewmodel = true,
            dopostprocess = false,
            bloomtone = false
        })
        render.SetLightingMode(0)

        if DrawSobel then
            DrawSobel(threshold)
        end

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 45,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        render.BlurRenderTarget(RenderBuffer, radius, radius, passes)

        render.OverrideBlend(true, BLEND_ONE, 2, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)
        render.SetMaterial(MaterialDepth)
        render.DrawScreenQuad()
        render.OverrideBlend(false)

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 1 - strength,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        render.PopRenderTarget()
        DepthPass = nil

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 0.8,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        if not shadows then
            render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_DST_COLOR, BLENDFUNC_ADD, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)
        end

        render.SetMaterial(MaterialRenderBuffer)
        render.DrawScreenQuad()
        render.OverrideBlend(false)

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.02,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })
    end

    hook.Add("RenderScreenspaceEffects", "AmbientOcclusion:RenderScreenspaceEffects", function()
        if GetConVar("nycto_ambient_occlusion"):GetBool() then
            if not render.SupportsPixelShaders_2_0() then return end
            if not GAMEMODE:PostProcessPermitted("bloom") then return end

            DrawAmbientOcclusion(
                GetConVar("nycto_ambient_occlusion_shadows"):GetBool(),
                GetConVar("nycto_ambient_occlusion_threshold"):GetFloat(),
                GetConVar("nycto_ambient_occlusion_strength"):GetFloat(),
                GetConVar("nycto_ambient_occlusion_blur_radius"):GetFloat(),
                GetConVar("nycto_ambient_occlusion_blur_passes"):GetInt()
            )
        end
    end)

    hook.Add("NeedsDepthPass", "AmbientOcclusion:NeedsDepthPass", function()
        if GetConVar("nycto_ambient_occlusion"):GetBool() then
            return DepthPass
        end
    end)

    list.Set("PostProcess", "#ambient_occlusion", {
        icon = "gui/postprocess/ambient_occlusion.png",
        convar = "nycto_ambient_occlusion",
        category = "#shaders_pp",
        cpanel = function(CPanel)
            CPanel:AddControl("Header", { Description = "#ambient_occlusion.description" })

            CPanel:AddControl("CheckBox", {
                Label = "#ambient_occlusion.enable",
                Command = "nycto_ambient_occlusion"
            })

            CPanel:AddControl("ComboBox", {
                Options = {
                    ["#preset.default"] = {
                        nycto_ambient_occlusion_shadows = "0",
                        nycto_ambient_occlusion_threshold = "0.99",
                        nycto_ambient_occlusion_strength = "0.80",
                        nycto_ambient_occlusion_blur_radius = "2.2",
                        nycto_ambient_occlusion_blur_passes = "6"
                    }
                },
                CVars = {
                    nycto_ambient_occlusion_shadows = "0",
                    nycto_ambient_occlusion_threshold = "0.99",
                    nycto_ambient_occlusion_strength = "0.80",
                    nycto_ambient_occlusion_blur_radius = "2.2",
                    nycto_ambient_occlusion_blur_passes = "6"
                },
                Folder = "ambient_occlusion",
                MenuButton = "1"
            })

            CPanel:AddControl("CheckBox", {
                Label = "#ambient_occlusion.shadows",
                Command = "nycto_ambient_occlusion_shadows"
            })

            CPanel:AddControl("Slider", {
                Label = "#ambient_occlusion.threshold",
                Command = "nycto_ambient_occlusion_threshold",
                Type = "Float",
                Min = "0.01",
                Max = "2"
            })

            CPanel:AddControl("Slider", {
                Label = "#ambient_occlusion.strength",
                Command = "nycto_ambient_occlusion_strength",
                Type = "Float",
                Min = "0",
                Max = "1"
            })

            CPanel:AddControl("Slider", {
                Label = "#ambient_occlusion.blur_radius",
                Command = "nycto_ambient_occlusion_blur_radius",
                Type = "Float",
                Min = "0",
                Max = "16"
            })

            CPanel:AddControl("Slider", {
                Label = "#ambient_occlusion.blur_passes",
                Command = "nycto_ambient_occlusion_blur_passes",
                Type = "Integer",
                Min = "0",
                Max = "32"
            })
        end
    })
end)
end