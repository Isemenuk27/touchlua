if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local function Init()
    local cam = mat3()
    local s = ScrW()
    mat3setSc( cam, s, s )
    mat3setTr( cam, 0, 1 * s )
    draw.setmatrix( cam )
end

local function lerp( f, a, b )
    return a + ( b - a ) * f
end

local tSplineCol = { 0, 0, 0, 0 }
local function drawspline( x1, y1, x2, y2, x3, y3, nStep, tCol, tCol2 )
    local lx, ly = x1, y1
    local dx1, dy1 = x3 - x1, y3 - y1
    local dx2, dy2 = x3 - x2, y3 - y2

    for i = 1, 4 do
        tSplineCol[i] = tCol[i]
    end

    for i = 0, 1, nStep do
        local j = 1 - i

        local px, py = lerp( i, x1, x2 ), lerp( i, y1, y2 )

        local cx1 = lerp( j, px, lerp( i, x1, x3 ) )
        local cy1 = lerp( j, py, lerp( i, y1, y3 ) )

        local cx2 = lerp( i, px, lerp( i, x2, x3 ) )
        local cy2 = lerp( i, py, lerp( i, y2, y3 ) )

        local x = lerp( i, cx1, cx2 )
        local y = lerp( i, cy1, cy2 )

        if ( tCol2 ) then
            for k = 1, 4 do
                tSplineCol[k] = lerp( i, tCol[k], tCol2[k] )
            end
        end

        draw.line( lx, ly, x, y, tSplineCol )
        lx, ly = x, y
    end
end

function draw.spline( x1, y1, x2, y2, x3, y3, nStep, tCol, tCol2 )
    if ( istable( x1 ) ) then
        x1, y1, x2, y2, x3, y3, nStep, tCol, tCol2 = x1[1], x1[2], y1[1], y1[2], x2[1], x2[2], y2, x3, y3
    end
    drawspline( x1, y1, x2, y2, x3, y3, nStep, tCol, tCol2 )
end

local c = { 0, 1, 0, 1 }
local c2 = { 0, 0, 1, 1 }

local function Loop( CT, DT )
    local x, y = .8, -.3
    local x1, y1 = .2, -.5
    local x2, y2 = .8, .6

    x2, y2 = vec2unpack( cursor.pos3() )

    draw.cross( x, y, .05, c )
    draw.cross( x1, y1, .03, draw.red )
    draw.cross( x2, y2, .03, draw.yellow )
    draw.spline( x1, y1, x2, y2, x, y, .01, c, c2 )
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
