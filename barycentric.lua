local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi = math.sqrt, math.random, math.pi

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

draw.showdrawscreen()
local w, h = draw.getdrawsize()
--draw.setantialias( true )

local hw, hh = w  * .5, h * .5
local mx, my = 0, 0

local A = { w * .1, h * .08 }
local B = { w * .7, h * .4 }
local C = { w * .4, h * .7 }

local colorA = { 1, 1, 1 }
local colorB = { .1, .1, .1 }
local colorC = { 0.5, 0.5, 0.5 }

local function randc()
    for i = 1, 3 do
        colorA[i] = math.random( 0, 100 ) * .01
    end

    for i = 1, 3 do
        colorB[i] = math.random( 0, 100 ) * .01
    end

    for i = 1, 3 do
        colorC[i] = math.random( 0, 100 ) * .01
    end
end

local color = { 1, 1, 1, 1 }

local function interp( u, v, w, colorA, colorB, colorC)
    local r = u * colorA[1] + v * colorB[1] + w * colorC[1]
    local g = u * colorA[2] + v * colorB[2] + w * colorC[2]
    local b = u * colorA[3] + v * colorB[3] + w * colorC[3]

    color[1] = r
    color[2] = g
    color[3] = b
end

local function coords( A, B, C, x, y )
    local d = (B[2] - C[2]) * (A[1] - C[1]) + (C[1] - B[1]) * (A[2] - C[2])
    local u = ((B[2] - C[2]) * (x - C[1]) + (C[1] - B[1]) * (y - C[2])) / d
    local v = ((C[2] - A[2]) * (x - C[1]) + (A[1] - C[1]) * (y - C[2])) / d

    return u, v, 1 - u - v
end

local minx = math.min(A[1], B[1], C[1])
local maxx = math.max(A[1], B[1], C[1])

local miny = math.min(A[2], B[2], C[2])
local maxy = math.max(A[2], B[2], C[2])
local point = draw.point

local function Loop( CT, DT )
    randc()

    for x = minx, maxx do
        for y = miny, maxy do
            local u, v, w = coords(A, B, C, x, y )

            if u >= 0 and v >= 0 and w >= 0 then
                interp( u, v, w, colorA, colorB, colorC)

                point( x, y, color )
            end
        end
    end

    text( DT, 20, 20, white )
end

while true do
    local TimeStart = RealTime()

    clear( black )

    if ( CurTime > 0 ) then
        Loop( CurTime, FrameTime )
        post()
    end

    FrameTime = RealTime() - TimeStart
    CurTime 
= CurTime + FrameTime
end
