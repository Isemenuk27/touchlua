require( "libs/vec2" )
require( "libs/math" )
require( "libs/table" )

--***********************
-- Localize

local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi = math.sqrt, math.random, math.pi

local fillrect, text = draw.fillrect, draw.text
local oline, ocircle = draw.line, draw.circle

local insert = table.insert

draw.showdrawscreen()
local w, h = draw.getdrawsize()
local hw, hh = w  * .5, h * .5

local gray = { .7, .7, .7, .5 }

--***********************
-- Draw functions

local function triangle( A, B, C, col )
    draw.filltriangle( A[1], A[2], B[1], B[2], C[1], C[2], col or white )
end

local function line( A, B, col )
    oline( A[1], A[2], B[1], B[2], col or white )
end

local function cross( A, size, col )
    oline( A[1] - size, A[2], A[1] + size, A[2], col or white )
    oline( A[1], A[2] - size, A[1], A[2] + size, col or white )
end

local function circle( A, rad, col )
    ocircle( A[1], A[2], rad, col or white )
end

local function vtext( t, A, col )
    text( t, A[1], A[2], col or white )
end

--***********************
-- generate set of points

local _POINTS = {}

for i = 1, 24 do
    insert( _POINTS, vec2( random( 0, w ), random( 0, h ) ) )
end

--***********************
-- Clockwise sorting

local function less( a, b, center )
    if (a[1] - center[1] >= 0 and b[1] - center[1] < 0) then
        return true
    end

    if (a[1] - center[1] < 0 and b[1] - center[1] >= 0) then
        return false
    end

    if (a[1] - center[1] == 0 and b[1] - center[1] == 0) then
        if (a[2] - center[2] >= 0 or b[2] - center[2] >= 0) then
            return a[2] > b[2]
        end
        return b[2] > a[2]
    end

    local det = (a[1] - center[1]) * (b[2] - center[2]) - (b[1] - center[1]) * (a[2] - center[2])

    if ( det < 0 ) then
        return true
    end

    if ( det > 0 ) then
        return false
    end

    local d1 = (a[1] - center[1]) * (a[1] - center[1]) + (a[2] - center[2]) * (a[2] - center[2])
    local d2 = (b[1] - center[1]) * (b[1] - center[1]) + (b[2] - center[2]) * (b[2] - center[2])

    return d1 > d2
end

local tablesort = table.sort

local sum = vec2()

local function sortfunc(a, b)
    return less( b, a, sum )
end

local function sortPointsClockwise(l)
    vec2set( sum, 0, 0 )

    for i, v in ipairs( l ) do
        vec2add( sum, v )
    end

    vec2mul( sum, 1 / #l ) -- same as division but faster

    tablesort( l, sortfunc )

    --[[ this lines of code puts 1st point in most top-left corner of shape
    local n = 1

    for i, v in ipairs( l ) do
        if ( v[1] < l[n][1] ) then
            n = i
        end
    end

    for i = 1, n do
        table.shiftLeft(l)
    end ]]--

    return l
end

--***********************
-- main loop

local function Loop( CT, DT )
    sortPointsClockwise( _POINTS )

    local center = vec2()

    for num, obj in ipairs( _POINTS ) do
        circle( obj, 10, red )
        vec2add( center, obj )
        draw.lineto( obj[1], obj[2], green )
    end

    vec2mul( center, 1 / #_POINTS )

    local tris = {}

    for i = 1, #_POINTS do
        local A = _POINTS[i]
        local B = _POINTS[(i%#_POINTS)+1]

        insert( tris, { A, B, center } )
    end

    for _, tri in ipairs( tris ) do
        triangle( tri[1], tri[2], tri[3], gray )
    end

    cross( center, 10, red )

    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

local cpoint = nil
local csor = vec2()

local function mouseTouch( t )
    for num, obj in ipairs( _POINTS ) do
        vec2set( csor, t.x, t.y )
        if ( vec2distsqr( obj, csor ) < ( 50 * 50 ) ) then
            cpoint = obj
        end
    end
end

local function mouseMoved( t )
    if ( cpoint ) then
        vec2set( cpoint, t.x, t.y )
    end
end

local function mouseEnd( t )
    cpoint = nil
end

draw.touchbegan = mouseTouch
draw.touchmoved = mouseMoved
draw.touchended = mouseEnd

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
