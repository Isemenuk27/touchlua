local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi = math.sqrt, math.random, math.pi

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

draw.showdrawscreen()
local w, h = draw.getdrawsize()
local hw, hh = w  * .5, h * .5

local function Loop( CT, DT )

    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

local function mouseMove( t )
    mx, my = t.x, t.y
end

draw.touchbegan = mouseMove
draw.touchmoved = mouseMove

while true do
    local TimeStart = RealTime()
    draw.doevents()

    clear( black )

    if ( CurTime > 0 ) then
        Loop( CurTime, FrameTime )
        post()
    end

    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
