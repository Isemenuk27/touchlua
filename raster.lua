-- Still requires draw lib =(

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

local nVR = w / h
local nVW = 2 ^ 7
local nVH = nVW / nVR

function scr( mx, my )
    return nVW * ( mx or 1 ), nVH * ( my or mx or 1 )
end

render = {
    col = {1,1,1,1}
}

local nWm, nHm = w / nVW, h / nVH

local function map( x, y )
    local nSX, nSY = x * nWm, y * nHm
    return nSX, nSY, nSX + nWm, nSY + nHm
end

local function rnd( x, y )
    math.randomseed( x + y )
    return math.random( 0, 1000 ) * .001
end

local fillrect = draw.fillrect

local function pixel( x, y )
    local x1, y1, x2, y2 = map( x, y )

    if ( x1 > w or x2 < 0 ) then
        return
    end

    if ( y1 > h or y2 < 0 ) then
        return
    end

    fillrect( x1, y1, x2, y2, render.col )
end

local int, abs = math.floor, math.abs

local function line( x0, y0, x1, y1 )
    x0, y0, x1, y1 = int( x0 ), int( y0 ), int( x1 ), int( y1 )
    local dx, sx =  abs( x1-x0 ), x0 < x1 and 1 or -1
    local dy, sy = -abs( y1-y0 ), y0 < y1 and 1 or -1
    local err, e2 = dx + dy, true

    local a = y1 * y0
    render.col[1], render.col[2], render.col[3] = 1, rnd(a,0), rnd(a,0)

    while ( true ) do
        pixel( x0, y0 )

        if ( x0 == x1 and y0 == y1 ) then
            break
        end

        e2 = 2 * err

        if ( e2 >= dy ) then
            err = err + dy
            x0 = x0 + sx
        end
        if ( e2 <= dx ) then
            err = err + dx
            y0 = y0 + sy
        end
    end
end

local function polyBottomFlat( x0, y0, x1, y1, x2, y2 )
    local nSlope1 = (x1 - x0) / (y1 - y0)
    local nSlope2 = (x2 - x0) / (y2 - y0)

    local nX1, nX2 = x0, x0

    for nY = y0, y2, 1 do
        line( nX1, nY, nX2, nY )
        nX1, nX2 = nX1 + nSlope1, nX2 + nSlope2
    end
end

local function polyTopFlat( x0, y0, x1, y1, x2, y2 )
    local nSlope1 = (x2 - x0) / (y2 - y0)
    local nSlope2 = (x2 - x1) / (y2 - y1)

    local nX1, nX2 = x2, x2

    for nY = y2, y0, -1 do
        line( nX1, nY, nX2, nY )
        nX1, nX2 = nX1 - nSlope1, nX2 - nSlope2
    end
end

local function polygon( x0, y0, x1, y1, x2, y2 )
    x0, y0, x1, y1, x2, y2 = int( x0 ), int( y0 ), int( x1 ), int( y1 ), int( x2 ), int( y2 )

    if ( y0 > y1 ) then
        x0, y0, x1, y1 = x1, y1, x0, y0
    end

    if ( y0 > y2 ) then
        x0, y0, x2, y2 = x2, y2, x0, y0
    end

    if ( y1 > y2 ) then
        x1, y1, x2, y2 = x2, y2, x1, y1
    end

    if ( y1 == y2 ) then
        return polyBottomFlat( x0, y0, x1, y1, x2, y2 )
    elseif ( y0 == y1 ) then
        return polyTopFlat( x0, y0, x1, y1, x2, y2 )
    end

    local nSlope = (x2 - x0) / (y2 - y0)
    local x3 = x0 + nSlope * ( y1 - y0 )

    --y3 == y1

    polyBottomFlat( x0, y0, x1, y1, x3, y1 )
    polyTopFlat( x1, y1, x3, y1, x2, y2 )
end

local function triangle( x1, y1, x2, y2, x3, y3 )
    line( x1, y1, x2, y2 )
    line( x2, y2, x3, y3 )
    line( x3, y3, x1, y1 )
end

local function Loop( CT, DT )
    local nOx, nOy = scr( .5 )
    local nR = scr( .5 )

    --polygon( nOx, nOy - nR, nOx + nR, nOy, nOx - nR, nOy )
    --polygon( nOx - nR, nOy, nOx + nR, nOy, nOx, nOy + nR )

    local t = {}

    for i = 0, math.pi, math.pi / 3 do
        i = CT * .5 + i
        local nX, nY = math.cos( i ) * nR, math.sin( i ) * nR
        table.insert( t, nOx + nX )
        table.insert( t, nOy + nY )
    end

    --render.col = draw.green
    polygon( table.unpack( t ) )

    --render.col = draw.red
    --triangle( table.unpack( t ) )

    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

while true do
    local TimeStart = RealTime()

    clear( black )

    if ( CurTime > 0 ) then
        Loop( CurTime, FrameTime )
        post()
    end

    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
