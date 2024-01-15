local oline = draw.line
local orect = draw.rect
local otext = draw.text
local ocirc = draw.circle
local white = draw.white

local type, TABLE = type, "table"
local function istable(t)
    return type(t) == TABLE
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
        ox, oy, col = ox[1], oy[2], oy
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
    draw.circle = circ
	le
end
