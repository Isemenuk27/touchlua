local docspath = sys.docspath

function sys.docspath( ... )
    print( "docspath" )
    print( ... )

    return docspath( ... )
end

print( sys.docspath() )

require( "libs/ansi" )
require( "libs/file" )

local function toHex( nNumber )
    return string.format( "%X", nNumber )
end

local intbin = {
    ["0"] = "000", ["1"] = "001", ["2"] = "010", ["3"] = "011",
    ["4"] = "100", ["5"] = "101", ["6"] = "110", ["7"] = "111"
}

function bin( int )
    local str = string.gsub( string.format( "%06o", int ), "(.)", function ( d ) return intbin[ d ] .. "|" end )
    return str
end

local sFilename = "read3-test.txt"

local cFile = File( sFilename, FILE_READ )

local sData, nI = true, 0

--while ( sData ~= nil ) do

local n = 0
local res = 0

for nI = 0, 1 do
    sData = cFile:Read( 1 )
    local nByte = string.toANSI( sData ) --string.byte( sData )

    print( string.toANSI( sData ) )

    local nData = nByte << ( nI * 8 )
    print( toHex( nByte ), " | ", nByte, " | ", nData )
    print( bin( nByte ) )
    print()
    res = res + nData
end

print()
print()

print( res )
print( bin( res ) ) --65510
print( bin( 65510 ) )

cFile:Close()
