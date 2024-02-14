require( "libs/file" )

local sFilename = "!tempfile.txt"

local cFile = File( sFilename, FILE_WRITE )

local tTest = {
    { "ULong", math.floor( 2^32 - 1 ) },
    { "Long", math.floor( -2^32 * .5 + 1 ) },
    { "UShort", math.floor( 2^16 - 1 ) },
    { "Short", math.floor( -2^16 * .5 + 1 ) },
    { "UByte", math.floor( 2^8 - 1 ) },
    { "Byte", math.floor( -2^8 * .5 + 1 ) },
    { "Long", math.random( -2^32 * .5 + 1, 2^32 * .5 - 1 ) },
    { "Float", -2781947.192 },
    { "Float", -123.45 },
    { "Float", 0.045 },
}

for f, v in ipairs( tTest ) do
    local fFunc = cFile[ "Write" .. v[1] ]
    fFunc( cFile, v[2] )
end

cFile:Close()
cFile = File( sFilename, FILE_READ )

for f, v in ipairs( tTest ) do
    local fFunc = cFile[ "Read" .. v[1] ]
    print( v[1], " [", v[2], "]   -> ", fFunc( cFile ) )
end

cFile:Close()
