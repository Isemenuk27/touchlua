assert( CStream, "Stream lib should be included first" )

local function bitmap()
    return {
        nChannels = 0,
        nHeaderSize = 0,
        nOffetBits = 0,
        nWidth = 0,
        nHeight = 0,
        nRowSize = 0,
        nRowWidth = 0,
        nBitsPerPixel = 0,
        nPixelArraySize = 0,
        nSize = 0,
        nCompressionType = 0,
        sMagic = true,
        nImageSize = 0,
        nNumPixels = 0,
        tContent = {},
    }
end

function parseBitmap( cStream )
    local tBitmap = bitmap()

    cStream:Jump( 0 )

    -- Read header
    tBitmap.sMagic = cStream:ReadUByte() + cStream:ReadUByte() -- Magic numbers
    tBitmap.nSize = cStream:ReadUInt() -- The size of the BMP file in bytes
    cStream:ReadUInt() -- Reserved 1
    --cStream:ReadUInt() -- Reserved 2

    -- starting address, of the byte where the bitmap image data written
    tBitmap.nOffetBits = cStream:ReadUInt()

    -- bitmap information header
    tBitmap.nHeaderSize = cStream:ReadUInt() -- The size of this header

    tBitmap.nWidth = cStream:ReadUInt()
    tBitmap.nHeight = cStream:ReadUInt()

    -- The number of color planes
    cStream:ReadUShort() -- Should be 1, usually

    tBitmap.nBitsPerPixel = cStream:ReadUShort()
    tBitmap.nChannels = tBitmap.nBitsPerPixel == 32 and 4 or 3

    tBitmap.nRowSize = 4 * math.ceil( ( tBitmap.nBitsPerPixel * tBitmap.nWidth ) / 32 )
    tBitmap.nRowWidth = tBitmap.nRowSize / tBitmap.nChannels
    tBitmap.nFakeRowPixels = tBitmap.nRowWidth - tBitmap.nWidth
    tBitmap.nPixelArraySize = tBitmap.nRowSize * math.abs( tBitmap.nHeight )

    tBitmap.nCompressionType = cStream:ReadUInt()
    tBitmap.nImageSize = cStream:ReadUInt()

    cStream:ReadUInt() -- Dimensions
    cStream:ReadUInt() -- For printing, gonna skip

    -- the number of colors in the color palette
    cStream:ReadUInt()
    -- the number of important colors used
    cStream:ReadUInt()

    cStream:Jump( tBitmap.nOffetBits )

    local i = 0

    local nEndPos = tBitmap.nOffetBits + tBitmap.nPixelArraySize
    for _, nByte in cStream:Iterator( tBitmap.nOffetBits, nEndPos ) do
        tBitmap.tContent[i] = nByte
        i = i + 1
    end

    tBitmap.nNumPixels = tBitmap.nPixelArraySize / tBitmap.nChannels

    return tBitmap
end

