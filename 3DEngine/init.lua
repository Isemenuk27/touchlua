if ( package.pathinit ) then
    package.path = package.pathinit
end
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

--**********************

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

_LOOPCALLBACK = "Scene.Loop"
_INITCALLBACK = "Scene.Init"
_RAYDIST = sqrt( 24 * 24 * 24 )

require( "screen" )
showscreen()
require( "draw2" )
require( "camera" )
require( "frustum" )
require( "render" )
require( "objects" )
require( "meshload" )
require( "raycast" )
require( "sky" )

if ( not _SKIPMENU ) then
    require( "mainmenu" )
    package.path = "/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;/usr/local/lib/lua/5.3/?.lua;/usr/local/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;../?.lua"
end

local w, h = Scr()
local hw, hh = HScr()

if ( not _SKIPMENU ) then
    local function menuLoop( DT )
        text( round( 1 / DT, 2 ), 20, 20, red )
    end

    while true do
        if ( _SCENETOLOAD ) then
            require( "scenes/" .. _SCENETOLOAD )
            break
        end

        local TimeStart = RealTime()

        clear( black )

        draw.doevents()

        if ( FrameTime > 0 ) then
            menuLoop( FrameTime )
            GUI.Render()
            post()
        else
            exec( "firstmenuframe", w, h )
        end

        FrameTime = RealTime() - TimeStart
    end

end
require( "buttons" )

_Player = createclass( C_PLAYER )
_Player:born()
_Player.ang = vec3( GetCamAng() )
_Player.pos = vec3( GetCamPos() )

do
    _SUN = createclass( C_LIGHT )
    _SUN:born()
    _SUN:setDir( vec3normalize( vec3( 0.015374, -0.928981, 0.369808 ) ) )

    if ( not exec( "sunborn", _SUN ) ) then
        local _AmbientColor = vec3( 248, 212, 171 )
        vec3mul( _AmbientColor, 1 / 255 )
        vec3mul( _AmbientColor, 1 )

        local _SunColor = vec3( 85, 124, 173 )
        vec3mul( _SunColor, 1 / 255 )

        _SUN:setColor( _SunColor, _AmbientColor )
    end
end

local function Loop( CT, DT )

    --[[traceRay( GetCamPos(), GetCamDir(), _RAYDIST, out )
    if ( out.hit ) then
        vec3set( obj.pos, out.pos )
        local x, y = vec3toscreen( pos )
        circle( x, y, 10, white )
    end]]--
    --draw.plane( vec3(0), vec3( 0, .1 * CT, 0), 2, 3, red )

    exec( _LOOPCALLBACK, CT, DT )

    if ( not _NOSTATS ) then
        text( string.NiceSize( memused() ), w - 130, 20, red )
        --text( string.NiceSize( FrameMem ), w - 130, 50, red )

        text( round( 1 / DT, 2 ), 20, 20, red )
        text( vec3tostring( GetCamPos() ), 20, 60, white )
        text( vec3tostring( GetCamDir() ), 20, 100, white )
        text( vec3tostring( GetCamAng() ), 20, 140, white )
    end

end

exec( _INITCALLBACK )

while true do
    local TimeStart = RealTime()
    --local PreFrameMem = memused()

    draw.doevents()

    --clear( black )

    if ( CurTime > 0 ) then
        _Player:move( CurTime, FrameTime )

        drawsky()

        render( CurTime, FrameTime )
        Loop( CurTime, FrameTime )

        ResetKeys()

        GUI.Render()

        post()
    else
        exec( "firstframe" )
    end

    --FrameMem = memused() - PreFrameMem
    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
