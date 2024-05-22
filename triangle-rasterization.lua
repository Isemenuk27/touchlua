require( "libs/table" )
require( "libs/string" )
require( "libs/vec3" )
require( "libs/vec2" )
require( "libs/globals" )
require( "libs/math" )

local fillrect = draw.fillrect

require( "libs/mat3" )
require( "libs/draw+" )
require( "libs/draw-textured" )
require( "libs/1252xUnicode" )
require( "libs/callback" )
require( "libs/screen" )
require( "libs/cursor+" )

require( "libs/stream" )
require( "libs/bitmap" )

local clear, post = draw.clear, draw.post
local white, black, green, red = draw.white, draw.black, draw.green, draw.red

showscreen()

local nW, nH = Scr()
local nVW = 2 ^ 6
local nWM0, nHM0 = nW / nVW, nH / ( nVW * ( nH / nW ) )
local nWM1, nHM1 = 1 / nWM0, 1 / nHM0

local function clamp( x )
    return x > 1 and 1 or x < 0 and 0 or x
end

local tC = { 1, 0, 0, 1 }
local floor, abs = math.floor, math.abs

local function triFlat( nStep,
    nX0, nY0, nU0, nV0, nW0,
    nX1, nY1, nU1, nV1, nW1,
    nX2, nY2, nU2, nV2, nW2 )

    local nStep0, nStep1, nDiff, nX0, nX1 =
    ( ( nX2 - nX0 ) / ( nY2 - nY0 ) ) * nStep,
    ( ( nX2 - nX1 ) / ( nY2 - nY1 ) ) * nStep,
    nY2 - nY0, nX2, nX2

    local nDU0, nDV0, nDW0, nDU1, nDV1, nDW1 =
    nU0 - nU2, nV0 - nV2, nW0 - nW2,
    nU1 - nU2, nV1 - nV2, nW1 - nW2

    local nF = 1 / ( nDiff < 0 and -nDiff or nDiff )
    local nSU0, nSV0, nSW0, nSU1, nSV1, nSW1 =
    ( nU0 - nU2 ) * nF, ( nV0 - nV2 ) * nF, ( nW0 - nW2 ) * nF,
    ( nU1 - nU2 ) * nF, ( nV1 - nV2 ) * nF, ( nW1 - nW2 ) * nF

    local nU0, nV0, nW0, nU1, nV1, nW1 =
    nU2, nV2, nW2, nU2, nV2, nW2

    for nY = nY2, nY0, -nStep do
        local nRY0, nRY1 = nY * nHM0, ( nY + 1 ) * nHM0
        local nDiffX = nX1 - nX0

        local nDU, nDV, nDW = nU0 - nU1, nV0 - nV1, nW0 - nW1

        local nF = 1 / ( nDiffX < 0 and -nDiffX or nDiffX )
        local nSU, nSV, nSW =
        ( nU0 - nU1 ) * nF,
        ( nV0 - nV1 ) * nF,
        ( nW0 - nW1 ) * nF

        local nU, nV, nW = nU0, nV0, nW0

        for nX = floor( nX0 ), floor( nX1 ), ( nDiffX < 0 and -1 or 1 ) do
            tC[1] = clamp( nU )
            tC[2] = clamp( nV )
            tC[3] = clamp( nW )

            fillrect( nX * nWM0, nRY0, ( nX + 1 ) * nWM0, nRY1, tC )
            nU, nV, nW = nU - nSU, nV - nSV, nW - nSW
        end

        nU0, nV0, nW0, nU1, nV1, nW1 =
        nU0 + nSU0, nV0 + nSV0, nW0 + nSW0,
        nU1 + nSU1, nV1 + nSV1, nW1 + nSW1
        nX0, nX1 = nX0 - nStep0, nX1 - nStep1
    end
end

local function uvCoords( nX0, nY0, nX1, nY1, nX2, nY2, nX, nY )
    local nD = 1 / ( ( nY1 - nY2 ) * ( nX0 - nX2 ) + ( nX2 - nX1 ) * ( nY0 - nY2 ) )
    local nU, nV = ( ( nY1 - nY2 ) * ( nX - nX2 ) + ( nX2 - nX1 ) * ( nY - nY2 ) ) * nD,
    ( ( nY2 - nY0 ) * ( nX - nX2 ) + ( nX0 - nX2 ) * ( nY - nY2 ) ) * nD
    return nU, nV, 1 - nU - nV
end

local function tri(
    nX0, nY0, nU0, nV0, nW0,
    nX1, nY1, nU1, nV1, nW1,
    nX2, nY2, nU2, nV2, nW2 )

    nX0, nY0, nX1, nY1, nX2, nY2 = floor( nX0 * nWM1 ), floor( nY0 * nHM1 ), floor( nX1 * nWM1 ), floor( nY1 * nHM1 ), floor( nX2 * nWM1 ), floor( nY2 * nHM1 )

    if ( nY0 > nY1 ) then
        nX0, nY0, nX1, nY1 = nX1, nY1, nX0, nY0
        nU0, nV0, nW0, nU1, nV1, nW1 =
        nU1, nV1, nW1, nU0, nV0, nW0
    end

    if ( nY0 > nY2 ) then
        nX0, nY0, nX2, nY2 = nX2, nY2, nX0, nY0
        nU0, nV0, nW0, nU2, nV2, nW2 =
        nU2, nV2, nW2, nU0, nV0, nW0
    end

    if ( nY1 > nY2 ) then
        nX1, nY1, nX2, nY2 = nX2, nY2, nX1, nY1
        nU1, nV1, nW1, nU2, nV2, nW2 =
        nU2, nV2, nW2, nU1, nV1, nW1
    end

    if ( nY1 == nY2 ) then
        triFlat( -1,
        nX2, nY2, nU2, nV2, nW2,
        nX1, nY1, nU1, nV1, nW1,
        nX0, nY0, nU0, nV0, nW0 )
        return
    elseif ( nY0 == nY1 ) then
        triFlat( 1,
        nX0, nY0, nU0, nV0, nW0,
        nX1, nY1, nU1, nV1, nW1,
        nX2, nY2, nU2, nV2, nW2 )
        return
    end

    local nSlope = ( nX2 - nX0 ) / ( nY2 - nY0 )
    local nX3, nY3 = math.floor( nX0 + nSlope * ( nY1 - nY0 ) ), nY1

    local _, _, nF = uvCoords( nX0, nY0, nX1, nY1, nX2, nY2, nX3, nY3 )
    local nU3, nV3, nW3 =
    nU0 - ( nU0 - nU2 ) * nF,
    nV0 - ( nV0 - nV2 ) * nF,
    nW0 - ( nW0 - nW2 ) * nF

    --local sF = "%d. (%.02f;%.02f;%.02f)"
    --draw.text( string.format( sF, 3, nU3, nV3, nW3 ), nX3 * nM0, nY3 * nM0 )
    --draw.cross( nX3 * nM0, nY3 * nM0, 30 )

    triFlat( 1,
    nX1, nY1, nU1, nV1, nW1,
    nX3, nY3, nU3, nV3, nW3,
    nX2, nY2, nU2, nV2, nW2 )

    triFlat( -1,
    nX1, nY1, nU1, nV1, nW1,
    nX3, nY3, nU3, nV3, nW3,
    nX0, nY0, nU0, nV0, nW0 )

    --draw.text( string.format( sF, 0, nU0, nV0, nW0 ), nX0 * nM0, nY0 * nM0 )
    --draw.text( string.format( sF, 1, nU1, nV1, nW1 ), nX1 * nM0, nY1 * nM0 )
    --draw.text( string.format( sF, 2, nU2, nV2, nW2 ), nX2 * nM0, nY2 * nM0 )

    --draw.triangle( nX0 * nM0, nY0 * nM0, nX1 * nM0, nY1 * nM0, nX2 * nM0, nY2 * nM0, draw.white )
end

local function transform( nX, nY, nAng, nOX, nOY, nS )
    return nOX + nX * nS * math.cos( nAng ) - nY * nS * math.sin( nAng ), nOY + nX * nS * math.sin( nAng ) + nY * nS * math.cos( nAng )
end

local function Loop( nTime, nFrameTime )
    local nOX, nOY = Scr( .5 )
    local nAng = ( cursor.pos()[2] / ScrH() ) * 3 * math.pi + math.pi--nTime * .2 * math.pi
    local nS = 700

    local nX0, nY0 = transform( -.5, .5, nAng, nOX, nOY, nS )
    local nX1, nY1 = transform( .5, .5, nAng, nOX, nOY, nS )
    local nX2, nY2 = transform( -.5, -.5, nAng, nOX, nOY, nS )
    local nX3, nY3 = transform( .5, -.5, nAng, nOX, nOY, nS )

    local nU0, nV0, nW0, nU1, nV1, nW1, nU2, nV2, nW2, nU3, nV3, nW3 =
    0, 0, 0,
    1, 0, 0,
    1, 1, 0,
    0, 1, 0

    tri(
    nX1, nY1, nU1, nV1, nW1,
    nX2, nY2, nU2, nV2, nW2,
    nX3, nY3, nU3, nV3, nW3 )

    tri(
    nX0, nY0, nU0, nV0, nW0,
    nX1, nY1, nU1, nV1, nW1,
    nX2, nY2, nU2, nV2, nW2 )

    --draw.triangle( nX0, nY0, nX1, nY1, nX2, nY2, draw.white )

    draw.text( 1 / nFrameTime, 20, 20 )
end

while true do
    frameBegin()
    draw.doevents()
    clear( black )
    Loop( curtime(), deltatime() )
    post()
    frameEnd()
end

