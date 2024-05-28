if ( not bInitialized ) then require( "init" ) return end

local floor, abs = math.floor, math.abs
local fillrect = draw._fillrect or draw.fillrect

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

--************************************

local tDepth = {}
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

local nWM0, nHM0, nWM1, nHM1, nWidth
local bFlipDepth = true

--Width of screen, Height, New "visual" width
function draw.initTextured( nW, nH, nVW )
    nWidth = nW
    bFlipDepth = not bFlipDepth
    nWM0, nHM0 = nW / nVW, nH / ( nVW * ( nH / nW ) )
    nWM1, nHM1 = 1 / nWM0, 1 / nHM0

    for k, _ in pairs( tDepth ) do
        tDepth[k] = 0
    end
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

local tC = { 0, 0, 0, 1 }

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

    local nUA, nVA, nWA, nUB, nVB, nWB =
    nU2, nV2, nW2, nU2, nV2, nW2

    for nY = nY2, nY0, -nStep do
        local nRY0, nRY1 = nY * nHM0, ( nY + 1 ) * nHM0
        local nDiffX = nX1 - nX0

        local nDU, nDV, nDW = nUA - nUB, nVA - nVB, nWA - nWB

        local nF = 1 / ( nDiffX < 0 and -nDiffX or nDiffX )
        local nSU, nSV, nSW =
        ( nUA - nUB ) * nF,
        ( nVA - nVB ) * nF,
        ( nWA - nWB ) * nF

        local nU, nV, nW = nUA, nVA, nWA

        for nX = floor( nX0 ), floor( nX1 ), ( nDiffX < 0 and -1 or 1 ) do
            local nIndex = nX + nY * nWidth
            local nD = tDepth[nIndex] or 0

            --[[ if ( bFlipDepth and
            ( ( nD >= 0 ) or ( nW > -nD ) ) or
            ( ( nD <= 0 ) or ( nW > nD ) )
            ) then ]]
            --if ( bFlipDepth and ( -nW < -( tDepth[nIndex] or 0 ) )
            --or ( nW > ( tDepth[nIndex] or 0 ) ) ) then
            if ( nW > ( tDepth[nIndex] or 0 ) ) then
                local nFirstIndex = ( ( floor( ( nU / nW ) * nTextureWidth ) % nTextureWidth ) +
                ( ( floor( ( nV / nW ) * nTextureHeight ) % nTextureHeight ) * nTextureWidth ) ) * 3

                tC[1], tC[2], tC[3] = tDrawTexture[nFirstIndex] or 1, tDrawTexture[nFirstIndex+1] or 1, tDrawTexture[nFirstIndex+2] or 1

                fillrect( nX * nWM0, nRY0, ( nX + 1 ) * nWM0, nRY1, tC )
                tDepth[nIndex] = nW
            end

            nU, nV, nW = nU - nSU, nV - nSV, nW - nSW
        end

        nUA, nVA, nWA, nUB, nVB, nWB =
        nUA + nSU0, nVA + nSV0, nWA + nSW0,
        nUB + nSU1, nVB + nSV1, nWB + nSW1
        nX0, nX1 = nX0 - nStep0, nX1 - nStep1
    end
end

local function uvCoords( nX0, nY0, nX1, nY1, nX2, nY2, nX, nY )
    local nD = 1 / ( ( nY1 - nY2 ) * ( nX0 - nX2 ) + ( nX2 - nX1 ) * ( nY0 - nY2 ) )
    local nU, nV = ( ( nY1 - nY2 ) * ( nX - nX2 ) + ( nX2 - nX1 ) * ( nY - nY2 ) ) * nD,
    ( ( nY2 - nY0 ) * ( nX - nX2 ) + ( nX0 - nX2 ) * ( nY - nY2 ) ) * nD
    return nU, nV, 1 - nU - nV
end

function draw.texturedTriangle(
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

    triFlat( 1,
    nX1, nY1, nU1, nV1, nW1,
    nX3, nY3, nU3, nV3, nW3,
    nX2, nY2, nU2, nV2, nW2 )

    triFlat( -1,
    nX1, nY1, nU1, nV1, nW1,
    nX3, nY3, nU3, nV3, nW3,
    nX0, nY0, nU0, nV0, nW0 )
end
