require( "libs/table" )
require( "libs/string" )
require( "libs/vec3" )
require( "libs/vec2" )
require( "libs/globals" )

require( "libs/mat3" )
require( "libs/draw+" )
require( "libs/draw-textured" )
require( "libs/1252xUnicode" )

require( "libs/stream" )
require( "libs/bitmap" )

local clear, post = draw.clear, draw.post
local white, black, green, red = draw.white, draw.black, draw.green, draw.red

draw.showdrawscreen()
local nScreenWidth, nScreenHeight = draw.getdrawsize()

-- Actual width, actual height, virtual width
draw.initTextured( nScreenWidth, nScreenHeight, 2 ^ 7 )

local mScr = mat3() -- Offset (0,0) to screen center
mat3setTr( mScr, nScreenWidth * .5, nScreenHeight * .5)
draw.setmatrix( mScr )

do
    local cStream = Stream()
    local cFile = io.open( "files/sillyCat.bmp", "rb" )

    cStream:ReadFromFile( cFile )
    cFile:close()

    local tBitmap = parseBitmap( cStream )

    local tTexture = { nWidth = tBitmap.nWidth, nHeight = tBitmap.nHeight }

    local nI = 0

    for i = 0, #tBitmap.tContent, tBitmap.nChannels do
        tTexture[nI] = tBitmap.tContent[i+2] / 255
        tTexture[nI+1] = tBitmap.tContent[i+1] / 255
        tTexture[nI+2] = tBitmap.tContent[i] / 255
        nI = nI + 3
    end

    draw.setTexture( tTexture )
end

local function rotate( nX, nY, nAng )
    return nX * math.cos( nAng ) - nY * math.sin( nAng ), nX * math.sin( nAng ) + nY * math.cos( nAng )
end

local function Loop( nTime, nFrameTime )
    local nScale = 600
    local nUvScale = 1 + ( math.cos( nTime ) * .5 + .5 )

    local nAng = .4 * math.pi * math.sin( nTime * .6 )

    local x0, y0 = rotate( -.5 * nScale, .5 * nScale, nAng )
    local x1, y1 = rotate( .5 * nScale, .5 * nScale, nAng )
    local x2, y2 = rotate( -.5 * nScale, -.5 * nScale, nAng )

    draw.texturedTriangle( x0, y0, x1, y1, x2, y2,
    0, -nUvScale, nUvScale, -nUvScale, 0, 0 )

    local x0, y0 = rotate( .5 * nScale, .5 * nScale, nAng )
    local x1, y1 = rotate( -.5 * nScale, -.5 * nScale, nAng )
    local x2, y2 = rotate( .5 * nScale, -.5 * nScale, nAng )

    draw.texturedTriangle( x0, y0, x1, y1, x2, y2,
    nUvScale, -nUvScale, 0, 0, nUvScale, 0 ) --]]

    local m = draw.popmatrix()
    draw.text( 1 / nFrameTime, 20, 20 )
    draw.pushmatrix( m )
end

while true do
    frameBegin()
    clear( black )
    Loop( curtime(), deltatime() )
    post()
    frameEnd()
end

