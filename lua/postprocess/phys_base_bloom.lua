local CurGamemode = engine.ActiveGamemode()
if CurGamemode == "nycto" then
local shaderName = "PhysicallyBasedBloom"

local max_iterations = 16

local pp_pbb = CreateClientConVar( "pp_pbb", "0", true, false, "Enable/Disable Physically Based Bloom.", 0, 1 )

--[[local pp_pbb_treshold = CreateClientConVar( "pp_pbb_treshold", "1", true, false, "Physically Based Bloom treshold", 0, 5 )
local pp_pbb_solftreshold = CreateClientConVar( "pp_pbb_solftreshold", "0.1", true, false, "Physically Based Bloom treshold", 0, 1 )
local pp_pbb_tr_intensity = CreateClientConVar( "pp_pbb_tr_intensity", "0.5", true, false, "Physically Based Bloom treshold", 0, 5 )]]

local pp_pbb_debug = CreateClientConVar( "pp_pbb_debug", "0", false, false, "Physically Based Bloom debug.", 0, 1 )
local pp_pbb_r = CreateClientConVar( "pp_pbb_r", "255", true, false, "Physically Based Bloom r.", 0, 255 )
local pp_pbb_g = CreateClientConVar( "pp_pbb_g", "255", true, false, "Physically Based Bloom g.", 0, 255 )
local pp_pbb_b = CreateClientConVar( "pp_pbb_b", "255", true, false, "Physically Based Bloom b.", 0, 255 )
local pp_pbb_colormultiply = CreateClientConVar( "pp_pbb_colormultiply", "2", true, false, "Physically Based Bloom Color Multiply.", 0, 20 )
local pp_pbb_scale_x = CreateClientConVar( "pp_pbb_scale_x", "1", true, false, "Physically Based Bloom Scale x.", 1, 10 )
local pp_pbb_scale_y = CreateClientConVar( "pp_pbb_scale_y", "1", true, false, "Physically Based Bloom Scale y.", 1, 10 )
local pp_pbb_scale_z = CreateClientConVar( "pp_pbb_scale_z", "1", true, false, "Physically Based Bloom Scale z.", 1, 10 )

-- Dirt on lens
--local pp_pbb_dirt = CreateClientConVar( "pp_pbb_dirt", "1", true, false, "Dirt on lens.", 0, 1 )
local pp_pbb_strength = CreateClientConVar( "pp_pbb_strength", "0.15", true, false, "Bloom Strenght.", 0, 0.5 )
local pp_pbb_intensity = CreateClientConVar( "pp_pbb_intensity", "2", true, false, "Dirt Mask Intensity.", 0, 5 )

-- Chromatic aberration
local pp_pbb_chromatic = CreateClientConVar( "pp_pbb_chromatic", "1", true, false, "Chromatic aberration.", 0, 1 )
--local pp_pbb_radius = CreateClientConVar( "pp_pbb_radius", "0.9", true, false, "Chromatic aberration. Below this radius the effect is less visible.", 0, 2 )
--local pp_pbb_offset = CreateClientConVar( "pp_pbb_offset", "1.8", true, false, "Chromatic aberration. Over this radius the effects is maximal.", 0, 2 )
local pp_pbb_power = CreateClientConVar( "pp_pbb_power", "1.5", true, false, "Chromatic aberration. Ower of the chromatic displacement (curve of the 'fvChroma' vector).", 1, 3 )

local pp_pbb_chroma_r = CreateClientConVar( "pp_pbb_chroma_r", "0.05", true, false, "Chromatic aberration R.", -1, 1 )
local pp_pbb_chroma_g = CreateClientConVar( "pp_pbb_chroma_g", "-0.05", true, false, "Chromatic aberration G.", -1, 1 )
local pp_pbb_chroma_b = CreateClientConVar( "pp_pbb_chroma_b", "0", true, false, "Chromatic aberration B.", -1, 1 )

--local pp_pbb_multiply = CreateClientConVar( "pp_pbb_multiply", "1", true, false, "Chromatic aberration multiply.", 0.1, 1 )

local pp_pbb_format = CreateClientConVar( "pp_pbb_format", "0", true, false, "Physically Based Bloom image format. 0: IMAGE_FORMAT_RGB888; 1: IMAGE_FORMAT_RGBA16161616F.", 0, 1 )

/*---------------------------------------------------------------------------
Мы могли бы перерассчитывать семплы при смене разрешения экрана, но так как
размер рендертаргетов нельзя перерегистрировать, лучше просить игрока
перезайти в одиночную игру/на сервер, а блум выключать.
---------------------------------------------------------------------------*/

-- нужно добавить оповещение, если не установлена шейдерная библиотека

local function CalcMaxIterations() 
	for i = 1,max_iterations do
		local s = 2^(i-1)
		local h = ScrH()/s

		if h < 2 then break end
		max_iterations = i
	end
end

CalcMaxIterations()

local pp_pbb_iterations = CreateClientConVar( "pp_pbb_iterations", max_iterations, true, false, "Physically Based Bloom count passes.", 1, max_iterations )

local image_format = pp_pbb_format:GetInt() == 1 and IMAGE_FORMAT_RGBA16161616F or IMAGE_FORMAT_RGB888

local screentexture = render.GetScreenEffectTexture()
local mask_mat = Material("pp/bloom_mask")
local chroma_mat = Material("pp/bloom_chromatic")
local bilinear_mat = Material("pp/bloom_bilinear")
local chromatic_aberration = pp_pbb_chromatic:GetBool()

--local dirt_enabled = pp_pbb_dirt:GetBool()

local rt_emissive = GetRenderTargetEx("_rt_Emissive", ScrW(), ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_NONE,
	bit.bor(4,8,16,256,512),
	CREATERENDERTARGETFLAGS_HDR,
	image_format
)

list.Set( "PostProcess", "#pp_pbb.name", {
	["icon"] = "gui/postprocess/phys_based_bloom.jpg",
	["convar"] = pp_pbb:GetName(),
	["category"] = "#shaders_pp",
	["cpanel"] = function( panel )
		panel:AddControl( "ComboBox", {
			["MenuButton"] = 1,
			["Folder"] = "pbb",
			["Options"] = {
				[ "#preset.default" ] = {
					[ pp_pbb:GetName() ] = pp_pbb:GetDefault(),
					--[ pp_pbb_treshold:GetName() ] = pp_pbb_treshold:GetDefault(),
					[ pp_pbb_debug:GetName() ] = pp_pbb_debug:GetDefault(),
					[ pp_pbb_r:GetName() ] = pp_pbb_r:GetDefault(),
					[ pp_pbb_g:GetName() ] = pp_pbb_g:GetDefault(),
					[ pp_pbb_b:GetName() ] = pp_pbb_b:GetDefault(),
					[ pp_pbb_colormultiply:GetName() ] = pp_pbb_colormultiply:GetDefault(),
					[ pp_pbb_scale_x:GetName() ] = pp_pbb_scale_x:GetDefault(),
					[ pp_pbb_scale_y:GetName() ] = pp_pbb_scale_y:GetDefault(),
					[ pp_pbb_scale_z:GetName() ] = pp_pbb_scale_z:GetDefault(),
					[ pp_pbb_iterations:GetName() ] = pp_pbb_iterations:GetDefault(),
					--[ pp_pbb_dirt:GetName() ] = pp_pbb_dirt:GetDefault(),
					[ pp_pbb_chromatic:GetName() ] = pp_pbb_chromatic:GetDefault(),
					[ pp_pbb_format:GetName() ] = pp_pbb_format:GetDefault(),
					[ pp_pbb_strength:GetName() ] = pp_pbb_strength:GetDefault(),
					[ pp_pbb_intensity:GetName() ] = pp_pbb_intensity:GetDefault(),
					[ pp_pbb_power:GetName() ] = pp_pbb_power:GetDefault(),
					[ pp_pbb_chroma_r:GetName() ] = pp_pbb_chroma_r:GetDefault(),
					[ pp_pbb_chroma_g:GetName() ] = pp_pbb_chroma_g:GetDefault(),
					[ pp_pbb_chroma_b:GetName() ] = pp_pbb_chroma_b:GetDefault(),
					--[ pp_pbb_multiply:GetName() ] = pp_pbb_multiply:GetDefault(),
					--[ pp_pbb_solftreshold:GetName() ] = pp_pbb_solftreshold:GetDefault(),
					--[ pp_pbb_tr_intensity:GetName() ] = pp_pbb_tr_intensity:GetDefault(),
					--[ pp_pbb_intensity:GetName() ] = pp_pbb_intensity:GetDefault(),
				}
			},
			["CVars"] = {
				pp_pbb:GetName(),
				--pp_pbb_treshold:GetName(),
				pp_pbb_debug:GetName(),
				pp_pbb_r:GetName(),
				pp_pbb_g:GetName(),
				pp_pbb_b:GetName(),
				pp_pbb_colormultiply:GetName(),
				pp_pbb_scale_x:GetName(),
				pp_pbb_scale_y:GetName(),
				pp_pbb_scale_z:GetName(),
				pp_pbb_iterations:GetName(),
				--pp_pbb_dirt:GetName(),
				pp_pbb_chromatic:GetName(),
				pp_pbb_format:GetName(),
				pp_pbb_strength:GetName(),
				pp_pbb_intensity:GetName(),
				pp_pbb_power:GetName(),
				pp_pbb_chroma_r:GetName(),
				pp_pbb_chroma_g:GetName(),
				pp_pbb_chroma_b:GetName(),
				--pp_pbb_multiply:GetName(),
				--pp_pbb_solftreshold:GetName(),
				--pp_pbb_tr_intensity:GetName(),
				--pp_pbb_strength:GetName(),
				--pp_pbb_intensity:GetName(),
			}
		} )

		panel:AddControl( "CheckBox", {
			["Label"] = "#pp_pbb.enable",
			["Command"] = pp_pbb:GetName()
		} )

		/*panel:Help( "#pp_pbb.mask_info" )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.treshold",
			["Command"] = pp_pbb_treshold:GetName(),
			["Min"] = tostring( pp_pbb_treshold:GetMin() ),
			["Max"] = tostring( pp_pbb_treshold:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.solftreshold",
			["Command"] = pp_pbb_solftreshold:GetName(),
			["Min"] = tostring( pp_pbb_solftreshold:GetMin() ),
			["Max"] = tostring( pp_pbb_solftreshold:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.tr_intensity",
			["Command"] = pp_pbb_tr_intensity:GetName(),
			["Min"] = tostring( pp_pbb_tr_intensity:GetMin() ),
			["Max"] = tostring( pp_pbb_tr_intensity:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )*/

		panel:AddControl( "CheckBox", {
			["Label"] = "#pp_pbb.debug",
			["Command"] = pp_pbb_debug:GetName()
		} )

		panel:AddControl( "Color", {
			["Label"] = "#pp_pbb.color",
			["red"] = pp_pbb_r:GetName(),
			["green"] = pp_pbb_g:GetName(),
			["blue"] = pp_pbb_b:GetName(),
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.colormultiply",
			["Command"] = pp_pbb_colormultiply:GetName(),
			["Min"] = tostring( pp_pbb_colormultiply:GetMin() ),
			["Max"] = tostring( pp_pbb_colormultiply:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.scale_x",
			["Command"] = pp_pbb_scale_x:GetName(),
			["Min"] = tostring( pp_pbb_scale_x:GetMin() ),
			["Max"] = tostring( pp_pbb_scale_x:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.scale_y",
			["Command"] = pp_pbb_scale_y:GetName(),
			["Min"] = tostring( pp_pbb_scale_y:GetMin() ),
			["Max"] = tostring( pp_pbb_scale_y:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.scale_z",
			["Command"] = pp_pbb_scale_z:GetName(),
			["Min"] = tostring( pp_pbb_scale_z:GetMin() ),
			["Max"] = tostring( pp_pbb_scale_z:GetMax() ),
			["Type"] = "Float",
			--["Help"] = true
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.passes",
			["Command"] = pp_pbb_iterations:GetName(),
			["Min"] = tostring( pp_pbb_iterations:GetMin() ),
			["Max"] = tostring( pp_pbb_iterations:GetMax() ),
			--["Help"] = true
		} )

		--panel:Help( "#pp_pbb.dirt_info" )

		--[[panel:AddControl( "CheckBox", {
			["Label"] = "#pp_pbb.dirt",
			["Command"] = pp_pbb_dirt:GetName()
		} )]]

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.intensity",
			["Command"] = pp_pbb_intensity:GetName(),
			["Min"] = tostring( pp_pbb_intensity:GetMin() ),
			["Max"] = tostring( pp_pbb_intensity:GetMax() ),
			["Type"] = "Float",
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.strength",
			["Command"] = pp_pbb_strength:GetName(),
			["Min"] = tostring( pp_pbb_strength:GetMin() ),
			["Max"] = tostring( pp_pbb_strength:GetMax() ),
			["Type"] = "Float",
		} )

		panel:Help( "#pp_pbb.chromatic_info" )

		panel:AddControl( "CheckBox", {
			["Label"] = "#pp_pbb.chromatic",
			["Command"] = pp_pbb_chromatic:GetName()
		} )

		--[[panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.multiply",
			["Command"] = pp_pbb_multiply:GetName(),
			["Min"] = tostring( pp_pbb_multiply:GetMin() ),
			["Max"] = tostring( pp_pbb_multiply:GetMax() ),
			["Type"] = "Float",
		} )]]

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.chroma_r",
			["Command"] = pp_pbb_chroma_r:GetName(),
			["Min"] = tostring( pp_pbb_chroma_r:GetMin() ),
			["Max"] = tostring( pp_pbb_chroma_r:GetMax() ),
			["Type"] = "Float",
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.chroma_g",
			["Command"] = pp_pbb_chroma_g:GetName(),
			["Min"] = tostring( pp_pbb_chroma_g:GetMin() ),
			["Max"] = tostring( pp_pbb_chroma_g:GetMax() ),
			["Type"] = "Float",
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.chroma_b",
			["Command"] = pp_pbb_chroma_b:GetName(),
			["Min"] = tostring( pp_pbb_chroma_b:GetMin() ),
			["Max"] = tostring( pp_pbb_chroma_b:GetMax() ),
			["Type"] = "Float",
		} )




		--[[panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.radius",
			["Command"] = pp_pbb_radius:GetName(),
			["Min"] = tostring( pp_pbb_radius:GetMin() ),
			["Max"] = tostring( pp_pbb_radius:GetMax() ),
			["Type"] = "Float",
		} )

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.offset",
			["Command"] = pp_pbb_offset:GetName(),
			["Min"] = tostring( pp_pbb_offset:GetMin() ),
			["Max"] = tostring( pp_pbb_offset:GetMax() ),
			["Type"] = "Float",
		} )]]

		panel:AddControl( "Slider", {
			["Label"] = "#pp_pbb.power",
			["Command"] = pp_pbb_power:GetName(),
			["Min"] = tostring( pp_pbb_power:GetMin() ),
			["Max"] = tostring( pp_pbb_power:GetMax() ),
			["Type"] = "Float",
		} )

		panel:Help( "#pp_pbb.formats_info" )
		
		panel:AddControl( "combobox", {
			["Label"] = "#pp_pbb.formats",
			["Command"] = pp_pbb_format:GetName(),
			["Options"] = {
				[ "#pp_pbb.888" ] = {
					[ pp_pbb_format:GetName() ] = "0",
				},
				[ "#pp_pbb.16161616f" ] = {
					[ pp_pbb_format:GetName() ] = "1",
				},
			},
			["CVars"] = {
				pp_pbb_format:GetName(),
			},
			["Help"] = false,
		} )
	end
} )

RT_BLOOM = RT_BLOOM or {}
BLOOM_MATS_DOWN = BLOOM_MATS_DOWN or {}
BLOOM_MATS_UP = BLOOM_MATS_UP or {}

local bloom_mips_count = pp_pbb_iterations:GetInt() or max_iterations
bloom_mips_count = math.Clamp(bloom_mips_count,pp_pbb_iterations:GetMin(),pp_pbb_iterations:GetMax())
local rt_base_name = "_rt_pbb"
local bloom_up = Material("pp/bloom_up")
local bloom_up_keyvalues = bloom_up:GetKeyValues()
bloom_up_keyvalues["flags2"] = nil
bloom_up_keyvalues["flags_defined2"] = nil
bloom_up_keyvalues["flags"] = nil
bloom_up_keyvalues["flags_defined"] = nil

local bloom_down = Material("pp/bloom_down")
local bloom_down_keyvalues = bloom_down:GetKeyValues()
bloom_down_keyvalues["flags2"] = nil
bloom_down_keyvalues["flags_defined2"] = nil
bloom_down_keyvalues["flags"] = nil
bloom_down_keyvalues["flags_defined"] = nil

local bloom_mat_combine = Material("pp/bloom_combine")

local function SetFloatMat(key, value)
	bloom_mat_combine:SetFloat(key, value)
end

local function SetTextureMat(key, value)
	bloom_mat_combine:SetTexture(key, value)
end

local function InitPhysBasedBloom()
	for i = 1,max_iterations do
		local s = 2^(i-1)
		local w = ScrW()/s
		local h = ScrH()/s

		RT_BLOOM[i] = GetRenderTargetEx(rt_base_name..i, w, h,
			RT_SIZE_LITERAL_PICMIP,
			MATERIAL_RT_DEPTH_NONE,
			bit.bor(4,8,16,256,512),
			CREATERENDERTARGETFLAGS_HDR,
			image_format
		)

		local is_first = i == 1

		BLOOM_MATS_DOWN[i] = is_first and Material("pp/bloom_down_first") or CreateMaterial("bloom_down_"..i, "screenspace_general", bloom_down_keyvalues)
		BLOOM_MATS_DOWN[i]:SetTexture( "$basetexture", is_first and rt_emissive or (rt_base_name..i ) )
		BLOOM_MATS_DOWN[i]:SetFloat("$c0_y", 0.25) -- Luminance

		BLOOM_MATS_UP[i] = CreateMaterial("bloom_up_"..i, "screenspace_general", bloom_up_keyvalues)
		BLOOM_MATS_UP[i]:SetTexture( "$basetexture", rt_base_name.. math.max(i-1,0) )

		BLOOM_MATS_UP[i]:SetFloat("$c0_x", pp_pbb_scale_x:GetFloat())
		BLOOM_MATS_UP[i]:SetFloat("$c0_y", pp_pbb_scale_y:GetFloat())
		BLOOM_MATS_UP[i]:SetFloat("$c0_z", pp_pbb_scale_z:GetFloat())
	end

	local _ColorIntensity = Vector(pp_pbb_r:GetFloat(),pp_pbb_g:GetFloat(),pp_pbb_b:GetFloat())/255
	local _ColorMultiply = pp_pbb_colormultiply:GetFloat()

	SetTextureMat("$texture2", RT_BLOOM[1])

	SetFloatMat("$c1_x", _ColorIntensity.x)
	SetFloatMat("$c1_y", _ColorIntensity.y)
	SetFloatMat("$c1_z", _ColorIntensity.z)
	SetFloatMat("$c1_w", _ColorMultiply)
	SetFloatMat("$c3_x", pp_pbb_intensity:GetFloat())
	SetFloatMat("$c2_w", pp_pbb_strength:GetFloat())
	SetFloatMat("$c1_w", pp_pbb_colormultiply:GetFloat())
	SetFloatMat("$c1_x", pp_pbb_r:GetFloat()/255)
	SetFloatMat("$c1_y", pp_pbb_g:GetFloat()/255)
	SetFloatMat("$c1_z", pp_pbb_b:GetFloat()/255)
end

hook.Add("InitPostShaderlib", shaderName, function()
	timer.Simple(0,function()
		InitPhysBasedBloom()
	end)
end)

local function BloomDownSample()
	for i = 1, bloom_mips_count do
		if !BLOOM_MATS_DOWN[i] then continue end -- у некоторых игроков почему-то отсутсвовал материал
		
		local target = RT_BLOOM[i]
		
		render.PushRenderTarget(target)
			render.SetMaterial( BLOOM_MATS_DOWN[i] )
			render.DrawScreenQuad()
		render.PopRenderTarget()

		if RT_BLOOM[i+1] then
			render.CopyTexture( target, RT_BLOOM[i+1] )
		end
	end
end

function BloomUpSample( i )
	render.OverrideBlend( true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD )

	for i = bloom_mips_count,1,-1 do
		local target = RT_BLOOM[i]

		if RT_BLOOM[i-1] then
			render.PushRenderTarget(target)
				render.SetMaterial( BLOOM_MATS_UP[i] )
				render.DrawScreenQuad()
			render.PopRenderTarget()

			render.CopyTexture( RT_BLOOM[i], RT_BLOOM[i-1] )
		end
	end

	render.OverrideBlend( false )
end

local texFilterType = TEXFILTER.ANISOTROPIC

local function PhysicallyBasedBloom()
	render.UpdateScreenEffectTexture()
	render.CopyRenderTargetToTexture(screentexture)

	for i = 1,bloom_mips_count do
		if RT_BLOOM[i] then -- возникали у некоторых ошикби
			render.CopyTexture( rt_emissive, RT_BLOOM[i] )
		end
	end

	render.PushFilterMag( texFilterType )
	render.PushFilterMin( texFilterType )

	BloomDownSample()
	BloomUpSample()

	render.PopFilterMag()
	render.PopFilterMin()

	--[[render.PushRenderTarget(RT_BLOOM[1])
		render.SetMaterial( bilinear_mat )
		render.DrawScreenQuad()
	render.PopRenderTarget()]]

	render.SetMaterial( bloom_mat_combine )
	render.DrawScreenQuad()
end

local function EnableDebugMode()
	hook.Add("HUDPaint", shaderName, function()
		render.DrawTextureToScreenRect(rt_emissive,  ScrW()-ScrW()/3,0, ScrW()/3, ScrH()/3)
	end)
end

local function DisableBloom()
	hook.Remove("PreDrawEffects", shaderName)
	hook.Remove("RenderScreenspaceEffects", shaderName)
	hook.Remove("HUDPaint", shaderName)
	hook.Remove("PreDrawShadows", shaderName)
end

local function NotifyChangeResolution()
	DisableBloom()
	LocalPlayer():ChatPrint( "(Change screen resolution) Retry to "..(game.SinglePlayer() and "map" or "server").." for Physically Based Bloom works again." )
end

hook.Add( "OnScreenSizeChanged", shaderName, function( oldWidth, oldHeight )
	CHANGED_RESOLUTION = true
	NotifyChangeResolution()
end )

local hook_mask = "PreDrawEffects"

local function EnablePhysBasedBloom()
	if CHANGED_RESOLUTION then NotifyChangeResolution() return end

	hook.Add(hook_mask, shaderName, function()
		render.UpdateScreenEffectTexture()
		render.CopyRenderTargetToTexture(screentexture)

		render.PushRenderTarget(rt_emissive)
			render.SetMaterial(mask_mat)
			render.DrawScreenQuad()
		render.PopRenderTarget()

		if chromatic_aberration then
			render.PushRenderTarget(rt_emissive)
				render.SetMaterial(chroma_mat)
				render.DrawScreenQuad()
			render.PopRenderTarget()
		end
	end)

	hook.Add("RenderScreenspaceEffects", shaderName, PhysicallyBasedBloom)

	if pp_pbb_debug:GetBool() then EnableDebugMode() end
end

local function StartPBB()
	if pp_pbb:GetBool() then EnablePhysBasedBloom() end
end

hook.Add("InitPostCSM", shaderName, function()
	hook_mask = "PreDrawShadows"
	hook.Remove("PreDrawEffects", shaderName)
	StartPBB()
end)

StartPBB()

cvars.AddChangeCallback( pp_pbb:GetName(), function( convar_name, _, identifier )
	local enabled = identifier == "1"

	if enabled then
		EnablePhysBasedBloom()
	else
		DisableBloom()
	end
end, shaderName )

--[[cvars.AddChangeCallback( pp_pbb_treshold:GetName(), function( convar_name, _, identifier )
	mask_mat:SetFloat("c0_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_solftreshold:GetName(), function( convar_name, _, identifier )
	mask_mat:SetFloat("c0_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_tr_intensity:GetName(), function( convar_name, _, identifier )
	mask_mat:SetFloat("c0_z", identifier)
end, shaderName )]]

cvars.AddChangeCallback( pp_pbb_debug:GetName(), function( convar_name, _, identifier )
	local enabled = identifier == "1"
	
	if enabled then
		EnableDebugMode()
	else
		hook.Remove("HUDPaint", shaderName)
	end

end, shaderName )

cvars.AddChangeCallback( pp_pbb_r:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c1_x", identifier/255)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_g:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c1_y", identifier/255)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_b:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c1_z", identifier/255)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_colormultiply:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c1_w", identifier)
end, shaderName )

local function SetScaleBloom(key, value)
	for i = 1,bloom_mips_count do
		BLOOM_MATS_UP[i]:SetFloat(key, value)
	end
end

cvars.AddChangeCallback( pp_pbb_scale_x:GetName(), function( convar_name, _, identifier )
	SetScaleBloom("$c0_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_scale_y:GetName(), function( convar_name, _, identifier )
	SetScaleBloom("$c0_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_scale_z:GetName(), function( convar_name, _, identifier )
	SetScaleBloom("$c0_z", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_iterations:GetName(), function( convar_name, _, identifier )
	bloom_mips_count = math.Round(identifier)
end, shaderName )

--[[cvars.AddChangeCallback( pp_pbb_dirt:GetName(), function( convar_name, _, identifier )
	dirt_enabled = identifier == "1"
end, shaderName )]]

cvars.AddChangeCallback( pp_pbb_chromatic:GetName(), function( convar_name, _, identifier )
	chromatic_aberration = identifier == "1"
end, shaderName )

cvars.AddChangeCallback( pp_pbb_strength:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c2_w", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_intensity:GetName(), function( convar_name, _, identifier )
	SetFloatMat("$c3_x", identifier)
end, shaderName )



local function getFinalColor(value, n)
	n = 1 + tonumber(n)/10
	chroma_mat:SetFloat(value, n)
end

cvars.AddChangeCallback( pp_pbb_chroma_r:GetName(), function( convar_name, _, identifier )
	getFinalColor("$c0_x", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_chroma_g:GetName(), function( convar_name, _, identifier )
	getFinalColor("$c0_y", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_chroma_b:GetName(), function( convar_name, _, identifier )
	getFinalColor("$c0_z", identifier)
end, shaderName )

cvars.AddChangeCallback( pp_pbb_power:GetName(), function( convar_name, _, identifier )
	chroma_mat:SetFloat("$c3_x", identifier)
end, shaderName )

local function InitChroma()
	getFinalColor("$c0_x", pp_pbb_chroma_r:GetFloat())
	getFinalColor("$c0_y", pp_pbb_chroma_g:GetFloat())
	getFinalColor("$c0_z", pp_pbb_chroma_g:GetFloat())
	chroma_mat:SetFloat("$c3_x", pp_pbb_power:GetFloat())
end

InitChroma()

/*cvars.AddChangeCallback( pp_pbb_multiply:GetName(), function( convar_name, _, identifier )
	chroma_mat:SetFloat("$c3_y", identifier)
end, shaderName )*/
end