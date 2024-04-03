assert( CFile, "file lib should be included first" )
assert( string.ANSI, "ansi lib should be included too" )

local function bitmap()
    return {
        nChannels = 0,
        nHeaderSize = 0,
        nOffetBits = 0,
        nWidth = 0,
        nHeight = 0,
        nBitsPerPixel = 0,
        nSize = 0,
        nCompressionType = 0,
        sMagic = true,
        nImageSize = 0,
        tContent = {},
    }
end

function parseBitmapFile( cFile )
    local tBitmap = bitmap()

    -- Read header
    tBitmap.sMagic = cFile:Read( 2 ) -- Magic numbers
    tBitmap.nSize = cFile:ReadULong() -- The size of the BMP file in bytes
    cFile:ReadUShort() -- Reserved 1
    cFile:ReadUShort() -- Reserved 2

    -- starting address, of the byte where the bitmap image data written
    tBitmap.nOffetBits = cFile:ReadULong()

    -- bitmap information header
    tBitmap.nHeaderSize = cFile:ReadULong() -- The size of this header

    tBitmap.nWidth = cFile:ReadULong()
    tBitmap.nHeight = cFile:ReadULong()

    -- The number of color planes
    cFile:ReadUShort() -- Should be 1, usually

    tBitmap.nBitsPerPixel = cFile:ReadUShort()

    tBitmap.nCompressionType = cFile:ReadULong()
    tBitmap.nImageSize = cFile:ReadULong()

    cFile:ReadULong() -- Dimensions
    cFile:ReadULong() -- For printing, gonna skip

    -- the number of colors in the color palette
    cFile:ReadULong()
    -- the number of important colors used
    cFile:ReadULong()

    tBitmap.nChannels = tBitmap.nBitsPerPixel * .125

    cFile:Tell( "set", 0 )

    for i = 1, tBitmap.nOffetBits do
        cFile:ReadUByte() -- Bitch
    end

    for i = 0, tBitmap.nHeight * tBitmap.nWidth * tBitmap.nChannels - 1 do
        tBitmap.tContent[i] = cFile:ReadUByte()
    end

    return tBitmap
end
