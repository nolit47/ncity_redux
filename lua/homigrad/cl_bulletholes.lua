-- "addons\\homigrad\\lua\\homigrad\\cl_bulletholes.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal

local drawing = false

hg.bulletholes = hg.bulletholes or {}

hook.Add("PostCleanupMap", "cleanupholes", function()
    hg.bulletholes = {}
end)

local rt = GetRenderTarget("bulletholes-testing", ScrW(), ScrH())
local vecHull = Vector(0,0,0)
local coltransparent = Color(0,0,0,0)
local mat = Material("holo/huy-collimator.png")

local hg_bulletholes = GetConVar("hg_bulletholes") or CreateClientConVar("hg_bulletholes", "0", true, false, "0-500, amount of bullet hole effects (r6s-like)", 0, 500)

hook.Add("PreDrawTranslucentRenderables","bulletholes-test",function()
    if hg_bulletholes:GetInt() == 0 then return end
    do return end
     

    if drawing then return end

    local add = 15
    local pen = 5
    local view = render.GetViewSetup()

    local tr = {
        start = view.origin,
        endpos = view.origin + view.angles:Forward() * 200,
        mins = -vecHull,
        maxs = vecHull,
    }

    local tr = util.TraceHull(tr)
    local pos = tr.HitPos
    local len = (view.origin - pos):Length() + add

	render.PushRenderTarget( rt )

	drawing = true

	render.RenderView({
		znear = len,
	})

	drawing = false
	render.PopRenderTarget()

	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
    render.SetStencilFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	render.SetStencilEnable( true )

    for i,tbl in ipairs(hg.bulletholes) do
        if not IsValid(tbl[6]) and not tbl[6]:IsWorld() then continue end
        local pos,dir,pen,hitnormal,pen2,ent = tbl[1],tbl[2],tbl[3],tbl[4],tbl[5],tbl[6]
        local pos,dir = LocalToWorld(pos,dir,ent:GetPos(),ent:GetAngles())
        local _,hitnormal = LocalToWorld(pos,hitnormal,ent:GetPos(),ent:GetAngles())
        dir = dir:Forward()
        hitnormal = hitnormal:Forward()
        local diff = dir:Dot(view.angles:Forward())
        pen2 = math.Clamp(pen2,5,40)
        --if diff < -0.5 then continue end
        render.SetColorMaterial()

        local ea = dir:Angle()
        local norm = hitnormal:Angle()
        
        render.SetStencilReferenceValue( 0 )
        render.SetStencilCompareFunction( STENCIL_EQUAL )
        render.SetStencilPassOperation( STENCIL_INCR )
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.SetStencilFailOperation( STENCIL_KEEP )
        local size = pen2 / 50

        local right,up = norm:Right()*size,norm:Up()*size
        --render.DrawSphere(pos,size,4,4,coltransparent)
        render.DrawQuad(pos-right,pos+right,pos+right/2+up/1.15,pos-right/2+up/1.15)
        render.DrawQuad(pos-right,pos-right/2-up/1.15,pos+right/2-up/1.15,pos+right)
        render.SetStencilReferenceValue( 1 )

        render.SetStencilCompareFunction( STENCIL_EQUAL )
        render.SetStencilPassOperation( STENCIL_INCR )
        render.SetStencilZFailOperation( STENCIL_INCR )
        render.SetStencilFailOperation( STENCIL_KEEP )

        local pos = pos+ea:Forward()*pen
        render.DrawQuad(pos-right,pos+right,pos+right/2+up/1.15,pos-right/2+up/1.15)
        render.DrawQuad(pos-right,pos-right/2-up/1.15,pos+right/2-up/1.15,pos+right)
    end
    
    render.SetStencilReferenceValue( 2 )
	render.SetStencilCompareFunction( STENCIL_EQUAL )

    render.SetStencilFailOperation( STENCIL_KEEP )

	render.DrawTextureToScreen( rt )

    render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_EQUAL )

    render.ClearBuffersObeyStencil(10,10,10,255,false)

	render.SetStencilEnable( false )
end)