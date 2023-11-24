package.path = package.path .. ";../?.lua"
require( "libs/table" )
require( "libs/math" )
require( "libs/vec2" )
require( "libs/vec3" )
require( "libs/stack" )
require( "libs/mat4" )
require( "libs/callback" )
require( "libs/cursor" )
require( "libs/2dgui" )
require( "libs/string" )

Inited = 1

local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
FrameMem, FrameTime, CurTime, RealTime = 0, 0, 0, sys.gettime
local sqrt, random, pi, hpi = math.sqrt, math.random, math.pi, math.pi * .5

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local function circle2( r, col, x, y )
    circle( x, y, r, col )
end

function memused()
    return collectgarbage('count') * 1024
end

require( "screen" )
showscreen()
require( "draw2" )
require( "camera" )
require( "frustum" )
require( "render" )
require( "buttons" )
require( "objects" )
require( "meshload" )

local w, h = Scr()
local hw, hh = HScr()

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "axis.obj" )
obj.scl = vec3( 1 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 20000
lamp:setPos( vec3( 0, 20, -130 ) )
lamp:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )
lamp.diffuse = vec3mul( vec3( 255, 0, 0 ), 1 / 255 )

_SUN = createclass( C_LIGHT )
_SUN:born()
_SUN:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )

local _SunColor = vec3( 85, 124, 173 )
vec3mul( _SunColor, 1 / 255 )

local _AmbientColor = vec3( 248, 212, 171 )
vec3mul( _AmbientColor, 1 / 255 )
vec3mul( _AmbientColor, 1 )

_SUN:setColor( _SunColor, _AmbientColor )

local function smooth( x )
    return  0.5 * (1 - cos( 2 * pi * x) )
end

local skynum = 4

local skys = {
    { { 4 / 255, 0, 68 / 255 },
    { 37 / 255, 161 / 255, 170 / 255 }, },

    { { 31 / 255, 54 / 255, 76 / 255 },
    { 168 / 255, 105 / 255, 0 / 255 }, },

    { vec3mul( vec3( 248, 212, 171 ), 1 / 255 ),
    vec3mul( vec3( 85, 124, 173 ), 1 / 255 ), },

    { vec3mul( vec3(108), 1 / 255 ),
    vec3mul( vec3(89), 1 / 255 ) },
}

local skycol1, skycol2, skydiff

if ( skys[skynum] ) then
    skycol1 = skys[skynum][1]
    skycol2 = skys[skynum][2]
    skydiff = { skycol2[1] - skycol1[1], skycol2[2] - skycol1[2], skycol2[3] - skycol1[3] }
end

local sky = { 1, 0, 1, 1 }

local function drawsky()
    if ( not skycol1 ) then
        return clear( black )
    end

    local step = h / 10
    local b = h / step

    for i = 0, b do
        local c = smooth( .5 * ( ( ( GetCamDir()[2] + 1 ) * .5 ) + (i/b) ) )

        for j = 1, 3 do
            sky[j] = skycol1[j] + ( skydiff[j] * c )
        end

        local y = step * i

        fillrect( 0, y, w, y + step, sky )
    end
end

local function Loop( CT, DT )
    --draw.plane( vec3(0), vec3( 0, .1 * CT, 0), 2, 3, red )
    text( string.NiceSize( memused() ), w - 130, 20, red )
    text( string.NiceSize( FrameMem ), w - 130, 50, red )

    text( round( 1 / DT, 2 ), 20, 20, red )
    text( vec3tostring( GetCamPos() ), 20, 60, white )
    text( vec3tostring( GetCamDir() ), 20, 100, white )
end

while true do
    local TimeStart = RealTime()
    local PreFrameMem = memused()

    draw.doevents()

    --clear( sky or black )

    if ( CurTime > 0 ) then
        drawsky()
        render()
        Loop( CurTime, FrameTime )
        GUI.Render()

        post()
    else
        exec( "firstframe" )
    end

    FrameMem = memused() - PreFrameMem
    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
