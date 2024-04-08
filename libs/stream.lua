assert( translateUnicodeTo1252, "1252xUnicode lib is required!" )

local sErrorNoFile = "Invalid file."
local sErrorOOB = "Trying to read out for bounds"

CStream = {}
CStream.__index = CStream

function Stream()
    local cStream = {
        tData = {},
        nPointer = 0,
    }

    setmetatable( cStream, CStream )
    return cStream
end

--[[================================]]--

-- https://stackoverflow.com/questions/29856166/lua-read-one-utf-8-character-from-file#29857160
local function readUTF8Char( cFile )
    local c1 = cFile:read(1)
    local ctr, c = -1, math.max( c1:byte(), 128 )
    repeat
        ctr = ctr + 1
        c = (c - 128)*2
    until c < 128
    return ( ( ctr == 0 ) and c1 or ( c1 .. cFile:read( ctr ) ) )
end

function CStream:ReadFromFile( cFile )
    assert( cFile, sErrorNoFile )

    local nEnd = cFile:seek( "end" )
    cFile:seek( "set", 0 )

    local nPointer = self.nPointer

    while ( cFile:seek() < nEnd ) do
        local sChar = readUTF8Char( cFile )
        local nCode = utf8.codepoint( sChar )
        self:WriteNoJump( translateUnicodeTo1252( nCode ) or nCode, nPointer )
        nPointer = nPointer + 1
    end

    self.nPointer = nPointer

    return self
end

--[[================================]]--

function CStream:WriteToFile( cFile )
    assert( cFile, sErrorNoFile )

    for _, nByte in self:Iterator() do
        --cFile:write( nByte )
        cFile:write( string.char( nByte ) )
    end
end

--[[================================]]--

function CStream:Write( nByte, nPoint )
    self.tData[nPoint or self.nPointer] = nByte
    if ( not nPoint ) then
        self.nPointer = self.nPointer + 1
    end
end

function CStream:WriteNoJump( nByte, nPoint )
    self.tData[nPoint or self.nPointer] = nByte
end

--[[================================]]--

function CStream:Read()
    self.nPointer = self.nPointer + 1
    return self.tData[self.nPointer - 1]
end

function CStream:ReadNoJump( nBytes )
    return table.unpack( self.tData, self.nPointer, self.nPointer + ( nBytes or 0 ) )
end

--[[================================]]--

function CStream:JumpEnd( nOffset )
    self.nPointer = #self.tData - nOffset
end

function CStream:Jump( nPoint )
    self.nPointer = nPoint
end

function CStream:Hop( nOffset )
    self.nPointer = self.nPointer + nOffset
end

function CStream:InBounds( nPoint )
    nPoint = nPoint or self.nPointer
    return ( nPoint > #self.tData and nPoint < 0 )
end

function CStream:Size()
    return #self.tData + 1
end

function CStream:Tell()
    return self.nPointer
end

--[[================================]]--

function CStream:Iterator( nFrom, nTo, nDir )
    nFrom = nFrom or 0
    nTo = nTo or #self.tData
    nDir = nDir or 1
    local nPoint = nDir > 0 and nFrom or nTo

    return function( ... )
        local nCurPoint = nPoint

        if ( nCurPoint > nTo or nCurPoint < nFrom ) then
            return
        end

        nOut = self.tData[nPoint]
        nPoint = nCurPoint + nDir
        return nCurPoint, nOut
    end, nil, nil
end

--[[================================]]--

local function signed( nValue, nBits )
    local nLastBit = 2 ^ ( nBits * 8 - 1 )

    if ( nValue >= nLastBit ) then
        nValue = nValue - nLastBit * 2
    end

    return nValue, nBits
end

local function unsigned( nValue, nBits )
    if ( nValue < 0 ) then
        nValue = nValue + 2 ^ ( nBits * 8 )
    end
    return nValue, nBits
end

--[[================================]]--

local function writeValue( cFile, nValue, nBits )
    for i = 0, nBits - 1 do
        local nByte = ( nValue >> ( i * 8 ) ) & 0xFF
        cFile:Write( nByte )
    end

    return nBits
end

local function writeSignedValue( cFile, nValue, nBits )
    return writeValue( cFile, unsigned( nValue, nBits ), nBits )
end -- Like that!

-- Unsigned

function CStream:WriteUByte( nByte )
    return writeValue( self, nByte, 1 )
end

function CStream:WriteUShort( nValue )
    return writeValue( self, nValue, 2 )
end

function CStream:WriteUInt( nValue )
    return writeValue( self, nValue, 4 )
end

-- Signed

function CStream:WriteByte( nByte )
    return writeSignedValue( self, nByte, 1 )
end

function CStream:WriteUShort( nValue )
    return writeSignedValue( self, nValue, 2 )
end

function CStream:WriteUInt( nValue )
    return writeSignedValue( self, nValue, 4 )
end

CStream.WriteData = writeValue
CStream.WriteSignedData = writeSignedValue

--[[================================]]--

local function readValue( cFile, nBits )
    local nOut = 0

    for i = 0, nBits - 1 do
        nOut = nOut + ( assert( cFile:Read(), sErrorOOB ) << ( i * 8 ) )
    end

    return nOut, nBits
end

local function readSignedValue( cFile, nBits )
    return signed( readValue( cFile, nBits ) )
end

-- Unsigned

function CStream:ReadUByte( nByte )
    return readValue( self, 1 )
end

function CStream:ReadUShort( nValue )
    return readValue( self, 2 )
end

function CStream:ReadUInt( nValue )
    return readValue( self, 4 )
end

-- Signed

function CStream:ReadByte( nByte )
    return readSignedValue( self, 1 )
end

function CStream:ReadShort( nValue )
    return readSignedValue( self, 2 )
end

function CStream:ReadInt( nValue )
    return readSignedValue( self, 4 )
end

CStream.ReadData = readValue
CStream.ReadSignedData = readSignedValue

--[[================================]]--

local function actualExponent( nVal )
    return nVal - 127
end

local nInvM = 1 / 0x800000
local function actualMantissa( nVal )
    return 1 + ( nVal * nInvM )
end

function CStream:ReadFloat()
    local nNum, nBits = readValue( self, 4 )
    local nSign = ( nNum & 0x80000000 == 0x80000000 ) and -1 or 1
    local nExpo = ( nNum & 0x7F800000 ) >> 23
    local nMant = nNum & 0x7FFFFF

    local nRes =  actualMantissa( nMant ) * ( 2 ^ actualExponent( nExpo ) )
    return nSign * nRes, nBits
end

function CStream:WriteFloat( nNumber )
    return self:WriteUInt( string.unpack( "I", string.pack( "<f", nNumber ) ) )
end

--[[================================]]--
