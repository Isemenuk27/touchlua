local floor, abs = math.floor, math.abs

local function clamp( a, n, m )
    if ( a > m ) then
        return m
    end
    if ( a < n ) then
        return n
    end
    return a
end

local function sign( a )
    return a < 0 and -1 or 1
end

local function rgbset( rgb, r, g, b )
    rgb[1], rgb[2], rgb[3] = r, g, b
end

--************************************

local nX0, nY0, nX1, nY1, nX2, nY2 = 0, 0, 0, 0, 0, 0
local nU0, nV0, nU1, nV1, nU2, nV2 = 0, 0, 0, 0, 0, 0

local nScrW, nScrH = 0, 0
local nScrRatio = 0
local nVisW, nVisH = 0
local nWMul, nHMul = 0, 0
local nScreenToVisW, nScreenToVisH = 0, 0

local tDrawTexture = false
local nTextureWidth, nTextureHeight = 0, 0

local tDrawColor = { 1, 1, 1, 1 }

function draw.setTexture( tTexture )
    tDrawTexture = tTexture
    nTextureWidth, nTextureHeight = tTexture.nWidth, tTexture.nHeight
end

function draw.getTexture()
    return tDrawTexture
end

--Width of screen, Height, New "visual" width
function draw.initTextured( nW, nH, nVW )
    nScrW, nScrH = nW, nH
    nScrRatio = nW / nH
    nVisW, nVisH = nVW, nVW * ( nH / nW )
    nWMul, nHMul = nW / nVisW, nH / nVisH

    nScreenToVisW = 1 / nWMul
    nScreenToVisH = 1 / nWMul
end

-- Maps lowres to screen
local function mapToScreen( nX, nY )
    local nScreenX, nScreenY = nX * nWMul, nY * nHMul
    return nScreenX, nScreenY, nScreenX + nWMul, nScreenY + nHMul
end

-- lerps color by uvw
local function interp( u, v, w, colorA, colorB, colorC )
    local nRed = u * colorA[1] + v * colorB[1] + w * colorC[1]
    local nGreen = u * colorA[2] + v * colorB[2] + w * colorC[2]
    local nBlue = u * colorA[3] + v * colorB[3] + w * colorC[3]

    return clamp( nRed, 0, 1 ), clamp( nGreen, 0, 1 ), clamp( nBlue, 0, 1 )
end

-- return uvw coordinates of point on a triangle
local function uvCoords( x0, y0, x1, y1, x2, y2, x, y )
    local invd = 1 / ( ( y1 - y2 ) * ( x0 - x2 ) + ( x2 - x1 ) * ( y0 - y2 ) )
    local u = ( ( y1 - y2 ) * ( x - x2 ) + ( x2 - x1 ) * ( y - y2 ) ) * invd
    local v = ( ( y2 - y0 ) * ( x - x2 ) + ( x0 - x2 ) * ( y - y2 ) ) * invd
    return u, v, 1 - u - v
end

local getTextureColor do
    local nX, nY, nFirstIndex, nOX, nOY = 0, 0, 0, 0, 0
    getTextureColor = function( nU, nV, nW )
        nX = floor( ( nU0 * nU + nU1 * nV + nU2 * nW ) * nTextureWidth ) % nTextureWidth
        nY = floor( ( nV0 * nU + nV1 * nV + nV2 * nW ) * nTextureHeight ) % nTextureHeight

        nFirstIndex = ( nX + ( nY * nTextureWidth ) ) * 3

        return tDrawTexture[nFirstIndex], tDrawTexture[nFirstIndex+1], tDrawTexture[nFirstIndex+2]
    end
end

local pixel do
    --local fillrect = draw.fillrect
    local nU, nV, nW = 0, 0, 0, 0
    local x1, y1, x2, y2 = 0, 0, 0, 0

    pixel = function( nX, nY )
        x1, y1, x2, y2 = mapToScreen( nX, nY )

        nU, nV, nW = uvCoords( nX0, nY0, nX1, nY1, nX2, nY2, nX, nY )
        rgbset( tDrawColor, getTextureColor( nU, nV, nW ) )

        draw.fillrect( x1, y1, x2, y2, tDrawColor )
    end
end

local function lineHorizontal( x0, y0, x1, y1 )
    for x = x0, x1, sign( x1 - x0 ) do
        pixel( x, y0 )
    end
end

local function lineVertical( x0, y0, x1, y1 )
    for y = y0, y1, sign( y1 - y0 ) do
        pixel( x0, y )
    end
end

local function line( nX0, nY0, nX1, nY1 )
    local x0, y0, x1, y1 = floor( nX0 ), floor( nY0 ), floor( nX1 ), floor( nY1 )

    if ( y0 == y1 ) then
        return lineHorizontal( x0, y0, x1, y1 )
    elseif ( x0 == x1 ) then
        return lineHorizontal( x0, y0, x1, y1 )
    end

    local dx, sx =  abs( x1-x0 ), x0 < x1 and 1 or -1
    local dy, sy = -abs( y1-y0 ), y0 < y1 and 1 or -1
    local err, e2 = dx + dy, true

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

local function triBottomFlat( x0, y0, x1, y1, x2, y2 )
    local nSlope1 = (x1 - x0) / (y1 - y0)
    local nSlope2 = (x2 - x0) / (y2 - y0)

    local nX1, nX2 = x0, x0

    for nY = y0, y2, 1 do
        line( nX1, nY, nX2, nY )
        nX1, nX2 = nX1 + nSlope1, nX2 + nSlope2
    end
end

local function triTopFlat( x0, y0, x1, y1, x2, y2 )
    local nSlope1 = (x2 - x0) / (y2 - y0)
    local nSlope2 = (x2 - x1) / (y2 - y1)

    local nX1, nX2 = x2, x2

    for nY = y2, y0, -1 do
        line( nX1, nY, nX2, nY )
        nX1, nX2 = nX1 - nSlope1, nX2 - nSlope2
    end
end

do
    local nTX0, nTY0, nTX1, nTY1, nTX2, nTY2 = 0, 0, 0, 0, 0, 0

    function draw.texturedTriangle( x0, y0, x1, y1, x2, y2, u0, v0, u1, v1, u2, v2 )
        nX0, nY0, nX1, nY1, nX2, nY2 = floor( x0 * nScreenToVisW ), floor( y0 * nScreenToVisH ), floor( x1 * nScreenToVisW ), floor( y1 * nScreenToVisH ), floor( x2 * nScreenToVisW ), floor( y2 * nScreenToVisH )
        nU0, nV0, nU1, nV1, nU2, nV2 = u0, v0, u1, v1, u2, v2

        nTX0, nTY0, nTX1, nTY1, nTX2, nTY2 = nX0, nY0, nX1, nY1, nX2, nY2

        if ( nTY0 > nTY1 ) then
            nTX0, nTY0, nTX1, nTY1 = nTX1, nTY1, nTX0, nTY0
        end

        if ( nTY0 > nTY2 ) then
            nTX0, nTY0, nTX2, nTY2 = nTX2, nTY2, nTX0, nTY0
        end

        if ( nTY1 > nTY2 ) then
            nTX1, nTY1, nTX2, nTY2 = nTX2, nTY2, nTX1, nTY1
        end

        if ( nTY1 == nTY2 ) then
            return triBottomFlat( nTX0, nTY0, nTX1, nTY1, nTX2, nTY2 )
        elseif ( nTY0 == nTY1 ) then
            return triTopFlat( nTX0, nTY0, nTX1, nTY1, nTX2, nTY2 )
        end

        local nSlope = (nTX2 - nTX0) / (nTY2 - nTY0)
        local nTX3 = nTX0 + nSlope * ( nTY1 - nTY0 )

        triBottomFlat( nTX0, nTY0, nTX1, nTY1, nTX3, nTY1 )
        triTopFlat( nTX1, nTY1, nTX3, nTY1, nTX2, nTY2 )
    end
end
