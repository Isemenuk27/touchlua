package.path = package.path .. ";../?.lua"
require( "libs/table" )
require( "libs/math" )
require( "libs/vec2" )
require( "libs/vec3" )
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
FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi, hpi = math.sqrt, math.random, math.pi, math.pi * .5

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local function circle2( r, col, x, y )
    circle( x, y, r, col )
end

require( "screen" )
showscreen()
require( "camera" )
require( "render" )
require( "buttons" )
require( "objects" )
require( "meshload" )

local w, h = Scr()
local hw, hh = HScr()

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "axis.obj" )
obj.scl = vec3( 1/8 )

local function Loop( CT, DT )
    text( round( 1 / DT, 2 ), 20, 20, red )
end

while true do
    local TimeStart = RealTime()
    draw.doevents()

    clear( black )

    if ( CurTime > 0 ) then
        render()
        Loop( CurTime, FrameTime )
        GUI.Render()
        post()
    else
        exec( "firstframe" )
    end

    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
