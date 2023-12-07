local sunpos = vec3( -.1, 3, -1.2 )
local suncolor = vec3( .9, .8, .9 )
local vec3add, vec3sub, vec3set, vec3mul, vec3dot = vec3add, vec3sub, vec3set, vec3mul, vec3dot

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "sphere.obj" )
obj.scl = vec3( .2 )
obj.ang = vec3( 0, 0, 0 )
obj.pos = vec3add( vec3(sunpos), 0, .4, 0 )
obj.solid = true

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "skeleton.obj" )
obj.scl = vec3( 1.8 )
obj.ang = vec3( 0, math.pi, 0 )
obj.pos = vec3( -1, -2.06, 0 )
obj.solid = true

_SUPRESSRENDER = true
_NOSTATS = true

vec3set( GetCamPos(), 5.10623, 2.60166 - 1.4, 3.0783 )
vec3set( GetCamAng(), -0.3, 2.2016, 0 )

drawsky = function() end

local out = {}
local pcol = { 1, 1, 1, 1 }

_RAYDIST = 8

local x, y = 0, 0

local w, h = Scr()
local numrayshorizontal = 200

local size = w / numrayshorizontal
local ysize = size * ScrRatio2()

local fillrect, point = draw.fillrect, draw.point
local red = draw.red
local traceRay = traceRay

local function raytrace()
    local _FRUSTUM = CamFrustum()

    while true do
        coroutine.yield()

        for i = 1, numrayshorizontal do
            local a = .5 - ( y / numrayshorizontal )
            local b = .5 - ( x / numrayshorizontal )

            local up = vec3mul( vec3( CamUp() ), _FRUSTUM.farHeight * a )
            local right = vec3mul( vec3( CamRight() ), _FRUSTUM.farWidth * b )

            local dir = vec3add( vec3add( vec3( _FRUSTUM.far[1] ), up ), right )
            vec3sub( dir, GetCamPos() )
            vec3normalize( dir )

            traceRay( GetCamPos(), dir, _RAYDIST, out )

            if ( out.hit ) then
                vec3set( dir, sunpos )
                vec3sub( dir, out.pos )
                vec3normalize( dir )

                vec3set( pcol, 1 + vec3dot( out.normal, dir ) * .5 )

                local np = vec3( out.normal )
                vec3mul( np, .1 )
                vec3add( np, out.pos )

                traceRay( np, dir, _RAYDIST, out )

                if ( out.hit ) then
                    vec3mul( pcol, .5 )
                end
            else
                vec3set( pcol, 0 )
            end

            --vec3set( pcol, out.dist / _RAYDIST )
            vec3add( pcol, ( 1 - ( out.dist / _RAYDIST) ) * .2 )
            clamp01( pcol )

            if ( pcol[1] > 0 ) then
                local sx, sy = x * size, y * ysize

                fillrect( sx, sy, sx + size, sy + ysize, pcol )
                point( sx, sy + size * 2.2, red )
            end
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
end

local co

local function Loop( CT, DT )
    if ( not co or not coroutine.resume( co ) ) then
        co = coroutine.create( raytrace )
        assert( coroutine.resume( co ) )
    end
end

callback( _LOOPCALLBACK, Loop )
