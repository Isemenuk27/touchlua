local drawline = draw.line
local drawrect = draw.rect
local drawtext = draw.text
local drawcirc = draw.circle
local white = draw.white

local oline, orect, otext, ocirc

local type, TABLE = type, "table"

local function istable(t)
    return type(t) == TABLE
end

if ( draw.getmatrix ) then
    oline = function( a, b, c, d, col )
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            a, b = mat3mulxy( m, a, b )
            c, d = mat3mulxy( m, c, d )
        end

        drawline( a, b, c, d, col )
    end

    orect = function( a, b, c, d, col )
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            a, b = mat3mulxy( m, a, b )
            c, d = mat3mulxy( m, c, d )
        end

        drawrect( a, b, c, d, col )
    end

    otext = function( t, a, b, col )
        for i = draw.matstackl, 1, -1 do
            a, b = mat3mulxy( draw.getmatrix( i ), a, b )
        end

        drawtext( t, a, b, col )
    end

    ocirc = function( a, b, r, col )
        for i = draw.matstackl, 1, -1 do
            a, b = mat3mulxy( draw.getmatrix( i ), a, b )
        end

        drawcirc( a, b, r, col )
    end
else
    oline, orect, otext, ocirc = draw.line, draw.rect, draw.text, draw.circle
end

local function line( x1, y1, x2, y2, col )
    if ( istable( x1 ) ) then
        x1, y1, x2, y2, col = x1[1], x1[2], y1[1], y1[2], x2
    end
    return oline( x1, y1, x2, y2, col or white )
end

local function cross( ox, oy, s, col )
    if ( istable( ox ) ) then
        ox, oy, s, col = ox[1], ox[2], oy, s
    end
    line( ox - s, oy, ox + s, oy, col )
    line( ox, oy - s, ox, oy + s, col )
end

local function text( str, ox, oy, col )
    if ( istable( ox ) ) then
        ox, oy, col = ox[1], ox[2], oy
    end
    return otext( str, ox, oy, col or white )
end

local function circle( ox, oy, r, col )
    if ( istable( ox ) ) then
        ox, oy, r, col = ox[1], ox[2], oy, r
    end
    return ocirc( ox, oy, r, col or white )
end

do
    draw.line = line
    draw.cross = cross
    draw.text = text
    draw.circle = circle
end
