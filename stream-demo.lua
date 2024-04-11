require( "libs/1252xUnicode" )
require( "libs/stream" )
require( "libs/string" )

print( "Stream Demo" )

local tTest = {
    60, 1,
    -60, -1,
    255, 1,
    256, 2,
    -128, -2,
    128, -2,
    16789, 2,
    -2147483648, -4,
    1234.5678, 4,
    -826711.13, 4,
    0.00023, 4,
} -- value, num bits ( minus = signed )
-- floats detected automatically

local tCompare = { {}, {} }

local sFileName = "!TestFile.bin"

local cFile = assert( io.open( sFileName, "wb" ) )

local cStream = Stream()

print( "\nWrite to file" )

for i = 1, #tTest, 2 do
    local nValue, nBits = tTest[i], tTest[i+1]

    if ( nValue ~= math.floor( nValue ) ) then
        cStream:WriteFloat( nValue )
    else
        if ( nBits < 0 ) then
            cStream:WriteSignedData( nValue, -nBits )
        else
            cStream:WriteData( nValue, nBits )
        end
    end

    table.insert( tCompare[1], nValue )

    printf( "%f %s", nValue, ( ( nBits < 0 ) and " (Signed)" or "" ) )
end

cStream:WriteToFile( cFile )
cFile:close()

print( "\nRead from file" )

local cFile = assert( io.open( sFileName, "rb" ) )
local cStream = Stream()
cStream:ReadFromFile( cFile )
cStream:Jump( 0 )

for i = 1, #tTest, 2 do
    local nVal, nBits = tTest[i], tTest[i+1]

    if ( nVal ~= math.floor( nVal ) ) then
        nVal = cStream:ReadFloat()
    else
        if ( nBits < 0 ) then
            nVal = cStream:ReadSignedData( -nBits )
        else
            nVal = cStream:ReadData( nBits )
        end
    end

    table.insert( tCompare[2], nVal )
    print( nVal )
end

print( "\nComparing..." )

for i = 1, #tCompare[2] do
    local nV1, nV2 = tCompare[1][i], tCompare[2][i]
    printf( "\n%f / %f\ndiff:%f", nV1, nV2, nV1 - nV2 )
end

return
