NO2DGUI = false

if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local radius = .3
local m = .8
local xstep, ystep = .01 * m, .012 * m
local x, y = .5, .5

local function moveball()
    x = x + xstep
    y = y + ystep
end

local function checkcollisions()
    if x+radius > 1 then
        xstep = - xstep
    end

    if x-radius < 0 then
        xstep = - xstep
    end

    if y+radius > ScrRatio() then
        ystep = -ystep
    end

    if y-radius < 0 then
        ystep = - ystep
    end
end

local mCam

local function Init()
    mCam = mat3()
    local S = ScrW()
    mat3setSc( mCam, S, S )
    mat3setTr( mCam, 0, 0 * S )
    draw.setmatrix( mCam )
end

callback( "Init", Init )

local col = { 1, 1, 1, 1 }
local function randColor()
    col[1] = math.random( 0, 100 ) * .01
    col[2] = math.random( 0, 100 ) * .01
    col[3] = math.random( 0, 100 ) * .01
end

local function checkpress()
    if ( not cursor.isPressed() ) then return end
    local p = vec2( x, y )
    local vCursor = cursor.pos3()
    local dist = vec2dist( p, vCursor )

    if ( dist < radius ) then
        randColor()
    end
end

local function Loop( CT, DT )
    checkcollisions()
    moveball()
    checkpress()
    draw.meshcircle( x, y, radius, col, 16 )
end

callback( _LOOPCALLBACK, Loop )
