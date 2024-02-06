local drawline = draw.line
local drawrect = draw.rect
local drawfillrect = draw.fillrect
local drawtext = draw.text
local drawcirc = draw.circle
local drawftri = draw.filltriangle
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

    ofillrect = function( a, b, c, d, col )
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            a, b = mat3mulxy( m, a, b )
            c, d = mat3mulxy( m, c, d )
        end

        drawfillrect( a, b, c, d, col )
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

    oftri = function( ax, ay, bx, by, cx, cy, col )
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            ax, ay = mat3mulxy( m, ax, ay )
            bx, by = mat3mulxy( m, bx, by )
            cx, cy = mat3mulxy( m, cx, cy )
        end
        drawftri( ax, ay, bx, by, cx, cy, col )
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

local function filltri( ax, ay, bx, by, cx, cy, col )
    if ( istable( ox ) ) then
        ax, ay, bx, by, cx, cy, col = ax[1], ax[2], ay[1], ay[2], bx[1], bx[2], by
    end
    oftri( ax, ay, bx, by, cx, cy, col or white )
end

local function meshcirc( x, y, r, c, s )
    if ( istable( x ) ) then
        x, y, r, c, s = x[1], x[2], y, r, c
    end

    local st = math.tau / s
    for i = 1, s do
        local j = ( i + 1 ) % s
        local ax, ay = x + math.cos( i * st ) * r, y + math.sin( i * st ) * r
        local bx, by = x + math.cos( j * st ) * r, y + math.sin( j * st ) * r
        filltri( x, y, ax, ay, bx, by, c )
    end
end

local function rect( x1, y1, x2, y2, col )
    if ( istable( x1 ) ) then
        x1, y1, x2, y2, col = x1[1], x1[2], y1[1], y1[2], x2
    end
    return orect( x1, y1, x2, y2, col or white )
end

local function fillrect( x1, y1, x2, y2, col )
    if ( istable( x1 ) ) then
        x1, y1, x2, y2, col = x1[1], x1[2], y1[1], y1[2], x2
    end
    return ofillrect( x1, y1, x2, y2, col or white )
end

local function box( x, y, w, h, col )
    if ( istable( x ) ) then
        if ( istable( y ) ) then
            x, y, w, h, col = x[1], x[2], y, w, h
        else
            x, y, w, h, col = x[1], x[2], y[1], y[2], w
        end
    end
    return orect( x, y, x + w, y + h, col or white )
end

local function boxcenter( x, y, w, h, col )
    if ( istable( x ) ) then
        if ( istable( y ) ) then
            x, y, w, h, col = x[1], x[2], y[1], y[2], w
        else
            x, y, w, h, col = x[1], x[2], y, w, h
        end
    end
    local hw, hh = w * .5, h * .5
    return orect( x - hw, y - hw, x + hw, y + hh, col or white )
end

local function fillbox( x, y, w, h, col )
    if ( istable( x ) ) then
        if ( istable( y ) ) then
            x, y, w, h, col = x[1], x[2], y, w, h
        else
            x, y, w, h, col = x[1], x[2], y[1], y[2], w
        end
    end
    return ofillrect( x, y, x + w, y + h, col or white )
end

local function fillboxcenter( x, y, w, h, col )
    if ( istable( x ) ) then
        if ( istable( y ) ) then
            x, y, w, h, col = x[1], x[2], y[1], y[2], w
        else
            x, y, w, h, col = x[1], x[2], y, w, h
        end
    end
    local hw, hh = w * .5, h * .5
    return ofillrect( x - hw, y - hw, x + hw, y + hh, col or white )
end

TEXT_TOP = 0
TEXT_MIDDLE = -1
TEXT_BOTTOM = -2
TEXT_RIGHT = 0
TEXT_LEFT = -2

local sDefaultFont, nDefaultSize = "Arial", 10
local setFont, getTextSize = draw.setfont, draw.gettextsize

local function ftext( sText, nX, nY, nXA, nYA, tCol, nSize, sFont )
    if ( istable( nX ) ) then
        nX, nY, nXA, nYA, tCol, nSize, sFont = nX[1], nX[2], nY, nXA, nYA, tCol, nSize, sFont
    end
    setFont( sFont or sDefaultFont, nSize or nDefaultSize )

    local nW, nH = getTextSize( sText )
    local nHW, nHH = nW * .5, nH * .5
    local nDX, nDY = nX + nHW * nXA, nY - nHH * nYA
    draw.text( sText, nDX, nDY, tCol )
end

local sFormat = "[^\n]+"
local function lines( sStr )
    return string.gmatch( sStr, sFormat )
end

local function etext( sText, nX, nY, nXA, nYA, tCol, nSize, sFont )
    setFont( sFont or sDefaultFont, nSize or nDefaultSize )
    local _, nLH = getTextSize( sText )
    local i = 1
    for sLine in lines( sText ) do
        i = i + 1
        local nW, nH = getTextSize( sLine )
        local nHW, nHH = nW * .5, nH * .5
        local nDX, nDY = nX + nHW * nXA, nY - nHH * nYA
        draw.text( sLine, nDX, nDY + nLH * i, tCol )
    end
end

local nMagic = math.pi -- fits nice
function draw.nicesize( sText, nW, nH )
    local nM, nR = 0, 0
    for sLine in lines( sText ) do
        local nL = #sLine
        if ( nM < nL ) then
            nM = nL
        end
        nR = nR + 1
    end
    return nMagic * math.min( nW / nM, nH / nR )
end

do
    draw.line = line
    draw.cross = cross
    draw.rect = rect
    draw.fillrect = fillrect
    draw.box = box
    draw.fillbox = fillbox
    draw.boxcenter = boxcenter
    draw.fillboxcenter = fillboxcenter
    draw.text = text
    draw.circle = circle
    draw.filltriangle = filltri
    draw.meshcircle = meshcirc
    draw.ftext = ftext
    draw.etext = etext
end
