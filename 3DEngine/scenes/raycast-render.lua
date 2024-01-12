if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("3DEngine/init")
end

local vec3add, vec3sub, vec3set, vec3mul, vec3dot = vec3add, vec3sub, vec3set, vec3mul, vec3dot

local maxrecurtion = 2

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "cube.obj" )
obj.scl = vec3( 6, 1, 6 )
obj.ang = vec3( 0, 0, 0 )
obj.pos = vec3( 0, -.5, 0 )
obj.solid = true

for i = 0, 7 do
    local obj = createclass( C_POLY )
    obj:born()
    obj.form = loadobj( "cube.obj" )
    obj.scl = vec3( rand( .1, .4 ) ) -- .3 )
    obj.ang = vec3( rand( -math.pi, math.pi ) )
    obj.pos = vec3( rand( -3, 3 ), rand( .2, 2 ), rand( -3, 3 ) ) -- -.3, 1.4, -.4 )
    obj.solid = true
end

local lamp = createclass( C_LIGHT )
lamp:born()
lamp.power = 2
lamp:setPos( vec3( -2, 6, -2 ) )
lamp.diffuse = vec3mul(
vec3( 205, 140, 126 ),
1 / 255 )
lamp:enable()

local lamp2 = createclass( C_LIGHT )
lamp2:born()
lamp2.power = 1.3
lamp2:setPos( vec3( 3, 2, 2 ) )
lamp2.diffuse = vec3mul(
vec3( 140, 227, 244 ),
1 / 255 )
lamp2:enable()

_SUPRESSRENDER = true
local NextSupRender = 0

vec3set( GetCamPos(), -1.92532, 2.5844 - 1.4, 0.4103 )
vec3set( GetCamAng(), -0.6575, 4.1425, 0 )

if ( _SUPRESSRENDER ) then
    drawsky = function() end
    _NOSTATS = true
end

local out = {}
local pcol = { 1, 1, 1, 1 }

_RAYDIST = 40

local x, y = 0, 0

local w, h = Scr()
local numrayshorizontal = math.floor( w * .5 ) --2 ^ 8

local size = w / numrayshorizontal
local ysize = size * ScrRatio2()

local fillrect, point = draw.fillrect, draw.point
local red = draw.red
local traceRay = traceRay

local DirToLamp = vec3()
local rgb = vec3()

local function tracelight2( q )
    return 0
end

local function tracelight( q )
    local outcol = vec3()
    local i = 0

    for _, light in ipairs( _LIGHTS ) do
        local out2 = {}
        local DirToLamp = vec3()

        vec3set( DirToLamp, light.pos )
        vec3sub( DirToLamp, q )
        local dist = vec3mag( DirToLamp )
        local invdist = 1 / dist
        vec3normalize( DirToLamp )

        traceRay( q, DirToLamp, dist, out2 )

        if ( not out2.hit ) then
            vec3set( rgb, light.diffuse )
            vec3mul( rgb, light.power )
            vec3mul( rgb, invdist )

            vec3add( outcol, rgb )
            local m = .1
            --vec3add( outcol, out.u * m, out.v * m, ( 1 - out.u - out.v ) * m )
            --i = i + 1
        end
    end

    if ( i == 0 ) then
        return outcol
    end

    local inv = 1 --/ i

    return vec3mul( outcol, inv )
end

local function raytrace()
    local _FRUSTUM = CamFrustum()

    for i = 1, numrayshorizontal do
        local a = .5 - ( y / numrayshorizontal )
        local b = .5 - ( x / numrayshorizontal )

        local up = vec3mul( vec3( CamUp() ), _FRUSTUM.farHeight * a )
        local right = vec3mul( vec3( CamRight() ), _FRUSTUM.farWidth * b )

        local dir = vec3add( vec3add( vec3( _FRUSTUM.far[1] ), up ), right )
        vec3sub( dir, GetCamPos() )
        vec3normalize( dir )

        traceRay( GetCamPos(), dir, _RAYDIST, out )

        vec3set( pcol, 0, 0, 0 )

        if ( out.hit ) then
            if ( #_LIGHTS > 0 ) then
                local v = vec3( out.normal )
                vec3mul( v, 0.00001 )
                vec3add( v, out.pos )

                local outcol = tracelight( v )
                vec3add( pcol, outcol )
            else
                local a = 1 - ( out.dist / _RAYDIST )

                vec3add( pcol, out.u, out.v, 1 - out.u - out.v )
                vec3mul( pcol, a )
            end
        end

        --clamp01( pcol

        --vec3normalize( pcol )

        vec3set( pcol, clamp( pcol[1], 0, 1 ), clamp( pcol[2], 0, 1 ), clamp( pcol[3], 0, 1 ) )

        --if ( pcol[1] > 0 ) then
        local sx, sy = x * size, y * ysize

        fillrect( sx, sy, sx + size, sy + ysize, pcol )
        point( sx, sy + size * 2.2, red )
        --end

        x = x + 1

        if ( x == numrayshorizontal ) then
            x = 0
            y = y + 1

            if ( y >= numrayshorizontal ) then
                y = 0
            end
        end
    end
end

local co

local LastAng, LastPos = vec3( GetCamAng() ), vec3( GetCamPos() )

local function Loop( CT, DT )
    --[[if ( not co or not coroutine.resume( co ) ) then
        co = coroutine.create( raytrace )
        assert( coroutine.resume( co ) )
    end]]--
    if ( .0001 < vec3mag( vec3sub( vec3( GetCamPos() ), LastPos ) ) + vec3mag( vec3sub( vec3( GetCamAng() ), LastAng ) ) ) then
        NextSupRender = CT + .4
    end

    vec3set( LastAng, GetCamAng() )
    vec3set( LastPos, GetCamPos() )

    _SUPRESSRENDER = NextSupRender < CT

    if ( _SUPRESSRENDER ) then
        raytrace()
    end
end

if ( _SUPRESSRENDER ) then
    callback( _LOOPCALLBACK, Loop )
end
