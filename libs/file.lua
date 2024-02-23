CFile = {}
CFile.__index = CFile

-----------------[[
-- (Write/Read)(U)Type(X/2)
-- WriteUShort Writes unsigned 2 byte value in ANSI
-- WriteLong2 Writes signed int value as UTF8?
-- WriteUByteX Writes unsigned byte value as hex
-- Write returns string writenData, file fileWriten
--
-- Read usually returns number or bool value
--
-- ANSI mode requires ANSI lib (libs/ansi.lua)
-----------------]]

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

local invm = 1 / 0x800000
local function actualMantissa( nVal )
    return 1 + ( nVal * invm )
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

-- ************* Short *****************

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

-- Hex
function CFile:WriteUShortX( nNumber )
    local sData = toHex( nNumber, 16 )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteShortX( nNumber )
    local sData = toHex( nNumber + ( 2^16 * .5 ), 16 )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadUShortX()
    local sVal = self.IOFile:read( 4 )
    return tonumber( sVal, 16 )
end

function CFile:ReadShortX()
    local sVal = self.IOFile:read( 4 )
    return tonumber( sVal, 16 ) - ( 2^16 * .5 )
end

-- Normal
function CFile:WriteUShort2( nNumber )
    local sData = codeShort( nNumber )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteShort2( nNumber )
    local sData = codeShort( nNumber + ( 2^16 * .5 ) )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadUShort2()
    local sVal = self.IOFile:read( 2 )
    return parseShort( sVal )
end

function CFile:ReadShort2()
    local sVal = self.IOFile:read( 2 )
    return parseShort( sVal ) - ( 2^16 * .5 )
end

-- ************* Float *******************

function CFile:ReadFloat2()
    local nExponent = string.byte( self.IOFile:read( 1 ) )
    local sMantissaSign = self.IOFile:read( 3 )
    local nMantissa, bSign = parseMantissa( sMantissaSign )

    local nM = bSign and -1 or 1
    return nM * actualMantissa( nMantissa ) * ( 2 ^ actualExponent( nExponent ) )
end

function CFile:WriteFloat2( nNumber )
    local bSign, nExponent, nMantissa = floatDecompose( nNumber )
    local sData = string.char( nExponent ) .. codeMantissaAndSign( nMantissa, bSign )
    return sData, self.IOFile:write( sData )
end

-- ************* Long *****************

-- Hex
function CFile:WriteULongX( nNumber )
    local sData = toHex( nNumber, 32 )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteLongX( nNumber )
    local sData = toHex( nNumber + ( 2^32 * .5 ), 32 )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadULongX()
    local sVal = self.IOFile:read( 8 )
    return tonumber( sVal, 16 )
end

function CFile:ReadLongX()
    local sVal = self.IOFile:read( 8 )
    return tonumber( sVal, 16 ) - ( 2^32 * .5 )
end

-- Normal
function CFile:WriteULong2( nNumber )
    local sData = codeLong( nNumber )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteLong2( nNumber )
    local sData = codeLong( nNumber + ( 2^32 * .5 ) )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadULong2()
    local sVal = self.IOFile:read( 4 )
    return parseLong( sVal )
end

function CFile:ReadLong2()
    local sVal = self.IOFile:read( 4 )
    return parseLong( sVal ) - ( 2^32 * .5 )
end

-- ************* Bit *****************

-- Hex
function CFile:WriteBitX( bBool )
    local sData = toHex( nBool and 1 or 0, 1 )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadBitX()
    return tonumber( self.IOFile:read( 1 ), 16 ) == 1
end

-- Normal
function CFile:WriteBit2( bBool )
    local sData = string.char( nBool and 1 or 0 )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadBit2()
    return string.byte( self.IOFile:read( 1 ) ) == 1
end

-- ************* Byte *****************

-- Hex
function CFile:WriteUByteX( nNumber )
    local sData = toHex( nNumber, 8 )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteByteX( nNumber )
    local sData = toHex( nNumber + ( 2^8 * .5 ), 8 )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadUByteX()
    local sVal = self.IOFile:read( 2 )
    return tonumber( sVal, 16 )
end

function CFile:ReadByteX()
    local sVal = self.IOFile:read( 2 )
    return tonumber( sVal, 16 ) - ( 2^8 * .5 )
end

-- Normal
function CFile:WriteUByte2( nNumber )
    local sData = string.char( nNumber )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteByte2( nNumber )
    local sData = string.char( nNumber + ( 2^8 * .5 ) )
    return sData, self.IOFile:write( sData )
end

function CFile:ReadUByte2( nNumber )
    return string.byte( self.IOFile:read( 1 ) )
end

function CFile:ReadByte2( nNumber )
    return string.byte( self.IOFile:read( 1 ) ) - ( 2^8 * .5 )
end

-- **********************************
--   Compatible with c++ file io

local function codeNumber2( nNumber, nBits )
    local sOut = ""

    for i = 0, nBits - 1 do
        local sRes = ( nNumber >> ( i * 8 ) ) & 0xFF
        sOut = sOut .. string.ANSI( sRes )
    end

    return sOut
end

local function readNumber2( cFile, nBits )
    local nOut = 0

    for i = 0, nBits do
        local nByte = cFile:ReadUByte2()
        local n = nByte << ( i * 8 )
        nOut = nOut + n
    end

    return nOut
end

--***********************************
--              Byte

function CFile:ReadUByte()
    local sData = self.IOFile:read( 1 )

    local nByte = string.byte( sData )

    if ( nByte < 0x80 ) then
        return nByte
    end

    local sData2 = self.IOFile:read( 1 )
    local nByte2 = string.byte( sData2 )

    if ( nByte == 226 ) then
        local sData3 = self.IOFile:read( 1 )
        local nByte3 = string.byte( sData3 )

        return string.bytesToANSI( nByte, nByte2, nByte3 )
    end

    return string.bytesToANSI( nByte, nByte2 )
end

function CFile:ReadByte()
    local n = self:ReadUShort()
    local nOut = n & 0xFF

    if ( n & 0x80 == 0x80 ) then
        nOut = nOut - 0xFF - 1
    end

    return nOut
end

function CFile:WriteUByte( nNumber )
    local sData = codeNumber2( nNumber, 1 )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteByte( nNumber )
    local sData = codeNumber2( nNumber, 1 )
    return sData, self.IOFile:write( sData )
end

--***********************************
--              Short

function CFile:ReadUShort()
    return readNumber2( self, 1 )
end

function CFile:ReadShort()
    local n = self:ReadUShort()
    local nOut = n & 0xFFFF

    if ( n & 0x8000 == 0x8000 ) then
        nOut = nOut - 0xFFFF - 1
    end

    return nOut
end

function CFile:WriteShort( nNumber )
    local sData = codeNumber2( nNumber, 2 )
    return sData, self.IOFile:write( sData )
end

function CFile:WriteUShort( nNumber )
    local sData = codeNumber2( nNumber, 2 )
    return sData, self.IOFile:write( sData )
end

--***********************************
--              Long

function CFile:ReadULong()
    return readNumber2( self, 3 )
end

function CFile:ReadLong()
    local n = self:ReadULong()
    local nOut = n & 0xFFFFFFFF

    if ( n & 0x80000000 == 0x80000000 ) then
        nOut = nOut - 0xFFFFFFFF - 1
    end

    return nOut
end

function CFile:WriteLong( nNumber )
    return self:WriteULong( nNumber )
end

function CFile:WriteULong( nNumber )
    local sData = codeNumber2( nNumber, 4 )
    return sData, self.IOFile:write( sData )
end

--***********************************
--              Bool

function CFile:ReadBool()
    return self:ReadUByte() == 1
end

function CFile:ReadBit()
    return self:ReadUByte()
end

function CFile:WriteBit( nBit )
    local nData = ( nBit > 0 ) and 1 or 0
    return self:WriteUByte( nData )
end

function CFile:WriteBool( bBool )
    local nData = codeNumber2( bBool and 1 or 0, 0 )
    return self:WriteUByte( nData )
end

--***********************************
--              Float

local function actualExponent( nVal )
    return nVal - 127
end

local invm = 1 / 0x800000
local function actualMantissa( nVal )
    return 1 + ( nVal * invm )
end

function CFile:ReadFloat()
    local nNum = self:ReadULong()
    local nSign = ( nNum & 0x80000000 == 0x80000000 ) and -1 or 1
    local nExpo = ( nNum & 0x7F800000 ) >> 23
    local nMant = nNum & 0x7FFFFF

    --[[ print( "nSign", nSign )
    print( "nExpo", nExpo, "\n", bin( nExpo ) )
    print( "nMant", nMant, "\n", bin( nMant ) ) ]]--

    local nRes =  actualMantissa( nMant ) * ( 2 ^ actualExponent( nExpo ) )
    return nSign * nRes
end

function CFile:WriteFloat( nNumber )
    local nBytes = string.pack( "<f", nNumber )
    local nBits = string.unpack( "I", nBytes )
    return self:WriteULong( nBits )
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


function CFile:Seek( nOffset, sBasePos )
    return self.IOFile:seek( sBasePos or "set", nOffset )
end

function CFile:Valid()
    return self.IOFile ~= nil
end

-- **********************************

function File( sPath, sMode )
    local cFile = setmetatable( {
        IOFile = io.open( sPath, sMode )
    }, CFile )

    return cFile
end
