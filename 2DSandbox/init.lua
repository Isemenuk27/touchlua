package.path = package.path .. ";../?.lua"
require( "libs/math" )
require( "libs/mat2" )
require( "libs/vec2" )
require( "libs/table" )
require( "libs/callback" )
require( "libs/cursor" )

Inited = 1

linehud = draw.line

require( "screen" )
require( "render" )
showscreen()
require( "phys" )
require( "class" )

local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red
local doevents = draw.doevents

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi = math.sqrt, math.random, math.pi

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local w, h = Scr()
local hw, hh = HScr()

local obj = createclass( C_POLY )
obj:born()
obj:setPos( vec2( 0 ) )

local fps, fpsi = {}, 0

for i = 0, 60 do
    fps[i] = 0
end

local function Loop( CT, DT )
    fpsi = ( fpsi + 1 ) % 60
    fps[fpsi] = 1 / DT

    for i = 0, 60 do
        linehud( w * .8 + i, 60, w * .8 +i, 60 + fps[i], red )
    end

    text( round( 1 / DT, 2 ), 20, 20, red )
end

while true do
    local TimeStart = RealTime()

    doevents()

    clear( black )
    --fillrect( 0, 0, w, h, black )

    text( "events - " .. TimeStart - RealTime(), 20, 60, red )

    local RStart = RealTime()
    if ( CurTime > 0 ) then
        simphysic( CurTime, FrameTime )
        Loop( CurTime, FrameTime )

        text( "render - " .. RStart - RealTime(), 20, 80, red )

        post()
    end

    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
