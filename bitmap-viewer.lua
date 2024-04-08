require( "libs/table" )
require( "libs/string" )
require( "libs/vec3" )
require( "libs/1252xUnicode" )
require( "libs/stream" )
require( "libs/bitmap" )

local bClamp = true -- Clamp color to 0-1, or remap
local bASCII = not true
local bBW = not true --Black and white
local bInvert = not true -- Inverts colors
local vTint = vec3( 1, 1, 1 )

local sPixelASCII = ".,:;'\"^=)]%$HW#" --" `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@"
--"`^\",:;Il!i~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
local nASCIIScrollSpeed = 16

local tFiles = {
    "testBitmap.bmp", -- 1
    "test.bmp", -- 2
    "cat.bmp", -- 3
    "seriousCat.bmp", -- 4
    "sillyCat.bmp", -- 5
    "medic.bmp", -- 6 ( Broken )
    "thatsit.bmp", -- 7 ( Broken )
    "2cats.bmp", -- 8 ( Broken )
    "land3.bmp", -- 9 ( Uses 4 bits per pixel, unsupported )
    "soldier.bmp", -- 10
    "land2.bmp", -- 11
}

local nFile = 2 -- Select file

local cStream = Stream()
local cFile = io.open( "files/" .. tFiles[nFile], "rb" )

cStream:ReadFromFile( cFile )
cFile:close()

local tBitmap = parseBitmap( cStream )

local nImageWidth, nImageHeight = tBitmap.nWidth, tBitmap.nHeight

for i, v in SortedPairs( tBitmap ) do
    printf( "%s : %s", i, v )
end

printf( "Stream Size : %s", cStream:Size() )

local tScreen = {}

local function clamp( a )
    if ( a > 1 ) then
        return 1
    elseif ( a < 0 ) then
        return 0
    end
    return a
end

do
    local nMaxR, nMaxG, nMaxB = 1, 1, 1

    local a = 0
    local nMul = 1 / 255
    local nTimes = nImageWidth * nImageHeight - 1

    for i = 0, nTimes do

        if ( bBW ) then
            tScreen[i] = {
                tBitmap.tContent[a+2] or 0,
                tBitmap.tContent[a+1] or 0,
                tBitmap.tContent[a] or 0
            }

            local nBrightness = ( tScreen[i][1] + tScreen[i][2] + tScreen[i][3] ) / 3
            vec3set( tScreen[i], nBrightness, nBrightness, nBrightness )
            vec3mul( tScreen[i], nMul )

        else
            tScreen[i] = {
                tBitmap.tContent[a+2] or 0,
                tBitmap.tContent[a+1] or 0,
                tBitmap.tContent[a] or 0
            }

            vec3mul( tScreen[i], nMul )
        end

        vec3mul( tScreen[i], vTint )


        nMaxR = ( tScreen[i][1] > nMaxR ) and tScreen[i][1] or nMaxR
        nMaxG = ( tScreen[i][2] > nMaxG ) and tScreen[i][2] or nMaxG
        nMaxB = ( tScreen[i][3] > nMaxB ) and tScreen[i][3] or nMaxB


        if ( bASCII ) then
            local nBrightness = ( tScreen[i][1] + tScreen[i][2] + tScreen[i][3] ) / 3
            tScreen[i][0] = math.floor( nBrightness * ( #sPixelASCII - 1 ) )
        end

        a = a + tBitmap.nChannels
    end

    for i = 0, nTimes do
        if ( bClamp ) then
            vec3set( tScreen[i], clamp( tScreen[i][1] ), clamp( tScreen[i][2] ), clamp( tScreen[i][3] ) )
        else
            vec3mul( tScreen[i], 1 / nMaxR, 1 / nMaxG, 1 / nMaxB )
        end

        if ( bInvert ) then
            vec3set( tScreen[i], 1 - tScreen[i][1], 1 - tScreen[i][2], 1 - tScreen[i][3] )
        end
    end
end

local clear, post = draw.clear, draw.post
local white, black, green, red = draw.white, draw.black, draw.green, draw.red
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

draw.showdrawscreen()
local nScreenWidth, nScreenHeight = draw.getdrawsize()

local nTileSize = nScreenWidth / nImageWidth

local nASCIIOffset = 0
local tPixelColor = { 0, 0, 0, 1 }
local function Loop( CT, DT )
    draw.setfont( "font", nTileSize )
    local nMaxOffset = #sPixelASCII

    for nNum = 0, #tScreen do
        vec3set( tPixelColor, tScreen[nNum] )
        if ( bASCII ) then
            local nX = ( nNum ) % nImageWidth
            local nY = math.floor( nNum / nImageWidth )
            local nTileX, nTileY = ( nTileSize * nX ), ( nTileSize * nImageHeight ) - ( nTileSize * nY )
            local nId = 1 + ( ( tScreen[nNum][0] + nASCIIOffset ) % nMaxOffset )
            text( string.sub( sPixelASCII, nId, nId ), nTileX, nTileY, green )
        else
            local nX = ( nNum ) % nImageWidth
            local nY = math.floor( nNum / nImageWidth )
            local nTileX, nTileY = ( nTileSize * nX ), ( nTileSize * nImageHeight ) - ( nTileSize * nY )
            fillrect( nTileX, nTileY, nTileX + nTileSize, nTileY + nTileSize, tPixelColor )
        end
    end

    local nFontSize = nScreenWidth * .1
    draw.setfont( "font", nFontSize )

    nASCIIOffset = math.floor( CT * nASCIIScrollSpeed ) % nMaxOffset -- ( nASCIIOffset + nASCIIScrollSpeed ) % nMaxOffset
    text( nASCIIOffset, 50, nScreenHeight - nFontSize * 3, white )
    text( math.floor( ( 1 / DT ) * 100 ) * .01, 20, nScreenHeight - nFontSize, white )
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
