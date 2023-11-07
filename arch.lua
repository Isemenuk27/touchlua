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

local R90 = rad( 90 )
local mx, my = 0, 0

local div = 10
local step = 10

local function arch( x, y, rot, ang, r1, r2, steps )
    local step = ang / steps

    local px1, py1, px2, py2

    rot = rot - ang * .5
    ang = ang * 2

    do
        local a = rad( rot )
        local cosang = cos( a )
        local sinang = sin( a )
        local x1 = x + cosang * r1
        local y1 = y + sinang * r1
        local x2 = x + cosang * r2
        local y2 = y + sinang * r2

        px1, py1, px2, py2 = x1, y1, x2, y2
    end

    for i = 0, steps do
        local a = rad( rot + i * step )
        local cosang = cos( a )
        local sinang = sin( a )
        local x1 = x + cosang * r1
        local y1 = y + sinang * r1
        local x2 = x + cosang * r2
        local y2 = y + sinang * r2

        draw.filltriangle( px1, py1, px2, py2, x1, y1, white )
        draw.filltriangle( x2, y2, x1, y1, px2, py2, white )

        px1, py1, px2, py2 = x1, y1, x2, y2
    end
end

local function segmentedArch( x, y, ang, step, div, r1, r2, smooth )
    local archang = ang / div
    for i = 0, div - 1 do
        local a = rad ( archang * i )
        arch( x, y, i * archang, archang - step, r1, r2, smooth )
    end
end

local function sign( a )
    if a > 0 then
        return 1
    end

    if a < 0 then
        return -1
    end

    return 0
end

local function Loop( CT, DT )
    div = floor( sin( CT ) * 10 + 11 )
    local cx, cy = hw, hh
    local mang = atan( my - cy, mx - cx )

    text( deg( mang ), 30, 40, white )
    text( sign( mx - cx ) .. "   " .. sign( my - cy ), 30, 80, white )

    --local x, y = hw + cos( mang ) * step, hh + sin( mang ) * step
    --arch( x, y, deg( mang ), 30, 150, 300, 20 )

    segmentedArch( cx, cy, 360, step, div, 150, 200, 20 )
    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

function mouseMove( t )
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
