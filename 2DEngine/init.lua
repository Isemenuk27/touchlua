package.path = package.path .. ";../?.lua"

require( "libs/table" )
require( "libs/math" )
require( "libs/vec2" )
require( "libs/draw+" )
require( "libs/stack" )
require( "libs/mat2" )
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

require( "screen" )
showscreen()
require( "render" )
require( "menu" )

local w, h = Scr()
local hw, hh = HScr()

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

local function Loop( CT, DT )
    exec( _LOOPCALLBACK, CT, DT )
    text( round( 1 / DT, 2 ), 20, 20, red )
end

while true do
    local TimeStart = RealTime()

    draw.doevents()

    clear( black )

    if ( CurTime > 0 ) then
        Loop( CurTime, FrameTime )
        post()
    else
        exec( "firstframe" )
    end

    FrameTime = RealTime() - TimeStart
    CurTime =
  CurTime + FrameTime
end
