require( "libs/ansi" )
require( "libs/file" )

local sFilename = "read2-test.txt"

local nNum = 126
local tTest = {
    { "Long2", -62596 },
    { "Long2", 62596 },
    { "ULong2", 962596 },
    { "UShort2", 1596 },
    { "Short2", -1596 },
    { "Bool2", false },

    { "Float2", 1.863 },
    { "Float2", -1.863 },
    { "Float2", math.pi },

    { "Long", nNum },
    { "Long", -nNum },
    { "ULong", nNum },

    { "Short", nNum },
    { "Short", -nNum },
    { "UShort", nNum },

    { "UByte", nNum },
    { "Byte", nNum },
    { "Byte", -nNum },

    { "Float", -123.45 },
    { "Float", 0.00045 },
    { "Float", math.pi },
}

local cFile = File( sFilename, FILE_WRITE )

for f, v in ipairs( tTest ) do
    local fFunc = cFile[ "Write" .. v[1] ]
    local nWrite = fFunc( cFile, v[2] )
    print( string.format( "Write %s -> %s", v[1], nWrite ) )
    cFile:Write( "\n" )
end

cFile:Close()

local sFormat = "\n%s\nGot %s, expected %s"
local cFile = File( sFilename, FILE_READ )

for f, v in ipairs( tTest ) do
    local fFunc = cFile[ "Read" .. v[1] ]
    local nRead = fFunc( cFile )
    cFile:Read(1)
    local sOut = string.format( sFormat, v[1], nRead, v[2] )
    print( sOut )
end

cFile:Close()

