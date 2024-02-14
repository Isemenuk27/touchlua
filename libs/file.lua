local CFile = {}
CFile.__index = CFile

local tHex = {
    [1] = "%01X",
    [8] = "%02X",
    [16] = "%04X",
    [32] = "%08X"
}

local function toHex( nNumber, nBits )
    return string.format( tHex[nBits], nNumber )
end

local sDot = "."
local f, I = "f", "I"

FILE_WRITE, FILE_READ = "wb", "rb"

-- **********************************

--[[
32bit number 11111111 11111111 11111111 11111111
4 bytes

loop though them starting at 0

right shift number to ( byte * bits )
AND ( & ) return if number is in value
2 & 11 ( 8 + 2 + 1 ), returns 2
3 & 11 ( 8 + 2 + 1 ), returns 0
so if current number not in value ( 255 )
then its 0, or it returns itself
lastly convert it in char and save in file

for i = 0, 3 do
    local sRes = ( nNumber >> ( i * 8 ) ) & 0xFF
    sOut = sOut .. string.char( sRes )
end
]]

-- ************* Float IEEE 754 *****************
-- Sign  Exponent  Mantissa  23-bits
-- 1     11111111  11111111 11111111 1111111

local function floatDecompose( nVal )
    local nBytes = string.pack( f, nVal )
    local nBits = string.unpack( I, nBytes )

    local nSign = ( nBits >> 31 ) & 0x01
    local nExponent = ( nBits >> 23 ) & 0xFF
    local nMantissa = nBits & 0x7FFFFF -- 23 bits

    return nSign == 1, nExponent, nMantissa
end

local function codeMantissaAndSign( nVal, bVal )
    local sOut = ""

    if ( bVal ) then
        nVal = nVal | 0x800000 -- 2^23
    end

    for i = 0, 2 do
        local sRes = ( nVal >> ( i * 8 ) ) & 0xFF
        sOut = sOut .. string.char( sRes )
    end

    return sOut
end

local function parseMantissa( sVal )
    local nOut, i = 0, 0

    for c in string.gmatch( sVal, sDot ) do
        nOut = nOut + ( string.byte( c ) << ( i * 8 ) )
        i = i + 1
    end

    local bSign = nOut & 0x800000 == 0x800000 -- 2^23
    nOut = nOut & 0x7FFFFF -- 2^23 - 1

    return nOut, bSign
end

local function actualExponent( nVal )
    return nVal - 127
end

local function actualMantissa( nVal )
    return 1 + ( nVal / 0x800000 )
end

local function codeNumber( nNumber, nBits )
    local sOut = ""

    for i = 0, nBits - 1 do
        local sRes = ( nNumber >> ( i * 8 ) ) & 0xFF
        sOut = sOut .. string.char( sRes )
    end

    return sOut
end

-- ************************************
-- Long

local function parseLong( sVal )
    local nOut, i = 0, 0
    for c in string.gmatch( sVal, sDot ) do
        nOut = nOut + ( string.byte( c ) << ( i * 8 ) )
        i = i + 1
    end
    return nOut
end

local function codeLong( nNumber )
    return codeNumber( nNumber, 4 )
end

-- ************************************
-- Short

local function parseShort( sVal )
    local nOut, i = 0, 0
    for c in string.gmatch( sVal, sDot ) do
        nOut = nOut + ( string.byte( c ) << ( i * 8 ) )
        i = i + 1
    end
    return nOut
end

local function codeShort( nNumber )
    return codeNumber( nNumber, 2 )
end

function CFile:ReadFloat()
    local nExponent = string.byte( self.IOFile:read( 1 ) )
    local sMantissaSign = self.IOFile:read( 3 )
    local nMantissa, bSign = parseMantissa( sMantissaSign )

    local nM = bSign and -1 or 1
    return nM * actualMantissa( nMantissa ) * ( 2 ^ actualExponent( nExponent ) )
end

function CFile:WriteFloat( nNumber )
    local bSign, nExponent, nMantissa = floatDecompose( nNumber )
    self.IOFile:write( string.char( nExponent ) )
    return self.IOFile:write( codeMantissaAndSign( nMantissa, bSign ) )
end

-- ************* Long *****************

function CFile:WriteULongX( nNumber )
    self.IOFile:write( toHex( nNumber, 32 ) )
end

function CFile:WriteLongX( nNumber )
    self.IOFile:write( toHex( nNumber + ( 2^32 * .5 ), 32 ) )
end

function CFile:WriteULong( nNumber )
    self.IOFile:write( codeLong( nNumber ) )
end

function CFile:WriteLong( nNumber )
    self.IOFile:write( codeLong( nNumber + ( 2^32 * .5 ) ) )
end

function CFile:ReadULongX()
    local sVal = self.IOFile:read( 8 )
    return tonumber( sVal, 16 )
end

function CFile:ReadLongX()
    local sVal = self.IOFile:read( 8 )
    return tonumber( sVal, 16 ) - ( 2^32 * .5 )
end

function CFile:ReadULong()
    local sVal = self.IOFile:read( 4 )
    return parseLong( sVal )
end

function CFile:ReadLong()
    local sVal = self.IOFile:read( 4 )
    return parseLong( sVal ) - ( 2^32 * .5 )
end

-- ************* Bit *****************

function CFile:WriteBitX( bBool )
    self.IOFile:write( toHex( nBool and 1 or 0, 1 ) )
end

function CFile:WriteBit( bBool )
    self.IOFile:write( string.char( nBool and 1 or 0 ) )
end

function CFile:ReadBitX()
    return tonumber( self.IOFile:read( 1 ), 16 ) == 1
end

function CFile:ReadBit()
    return string.byte( self.IOFile:read( 1 ) ) == 1
end

-- ************* Short *****************

function CFile:WriteUShortX( nNumber )
    self.IOFile:write( toHex( nNumber, 16 ) )
end

function CFile:WriteShortX( nNumber )
    self.IOFile:write( toHex( nNumber + ( 2^16 * .5 ), 16 ) )
end

function CFile:WriteUShort( nNumber )
    self.IOFile:write( codeShort( nNumber ) )
end

function CFile:WriteShort( nNumber )
    self.IOFile:write( codeShort( nNumber + ( 2^16 * .5 ) ) )
end

function CFile:ReadUShortX()
    local sVal = self.IOFile:read( 4 )
    return tonumber( sVal, 16 )
end

function CFile:ReadShortX()
    local sVal = self.IOFile:read( 4 )
    return tonumber( sVal, 16 ) - ( 2^16 * .5 )
end

function CFile:ReadUShort()
    local sVal = self.IOFile:read( 2 )
    return parseShort( sVal )
end

function CFile:ReadShort()
    local sVal = self.IOFile:read( 2 )
    return parseShort( sVal ) - ( 2^16 * .5 )
end

-- ************* Byte *****************

function CFile:WriteUByteX( nNumber )
    self.IOFile:write( toHex( nNumber, 8 ) )
end

function CFile:WriteByteX( nNumber )
    self.IOFile:write( toHex( nNumber + ( 2^8 * .5 ), 8 ) )
end

function CFile:WriteUByte( nNumber )
    self.IOFile:write( string.char( nNumber ) )
end

function CFile:WriteByte( nNumber )
    self.IOFile:write( string.char( nNumber + ( 2^8 * .5 ) ) )
end

function CFile:ReadUByteX()
    local sVal = self.IOFile:read( 2 )
    return tonumber( sVal, 16 )
end

function CFile:ReadByteX()
    local sVal = self.IOFile:read( 2 )
    return tonumber( sVal, 16 ) - ( 2^8 * .5 )
end

function CFile:ReadUByte( nNumber )
    return string.byte( self.IOFile:read( 1 ) )
end

function CFile:ReadByte( nNumber )
    return string.byte( self.IOFile:read( 1 ) ) - ( 2^8 * .5 )
end

-- **********************************

function CFile:Close()
    self.IOFile:close()
end

function CFile:Write( ... )
    return self.IOFile:write( ... )
end

function CFile:Read( ... )
    return self.IOFile:read( ... )
end

function CFile:Seek( ... )
    return self.IOFile:seek( ... )
end

-- **********************************

function File( sPath, sMode )
    local cFile = setmetatable( {
        IOFile = io.open( sPath, sMode )
    }, CFile )

    return cFile
end
