if ( not bInitialized ) then require( "init" ) return end

mdl = {
    tCache = {}
}

local sReadFrom = "models/"
local nLumps = 3

function mdl.get( sFileName )
    return mdl.tCache[sFileName]
end

function mdl.load( sFileName )
    if ( mdl.tCache[sFileName] ) then
        return false
    end

    local cStream = Stream()
    local cFile = assert( io.open( sReadFrom .. sFileName, "rb" ) )
    cStream:ReadFromFile( cFile )
    cFile:close()

    cStream:Jump( 0 )

    local bIsMDL = cStream:ReadString( 3 ) == "MDL"

    local tModelLump, tModelData = {}, {}

    for i = 0, nLumps - 1 do
        local nOff = cStream:ReadUShort()
        local nSize = cStream:ReadUShort()
        tModelLump[i] = {
            [1] = nOff, -- Start index
            [2] = nSize,
        }
    end

    cStream:Jump( tModelLump[0][1] )

    for _ = 1, tModelLump[0][2] / ( 4 * 5 ) do
        local i = #tModelData

        -- XYZ
        tModelData[i+1] = cStream:ReadFloat()
        tModelData[i+2] = cStream:ReadFloat()
        tModelData[i+3] = cStream:ReadFloat()

        -- UV
        tModelData[i+4] = cStream:ReadFloat()
        tModelData[i+5] = cStream:ReadFloat()
    end

    cStream:Jump( tModelLump[1][1] )

    for _ = 1, tModelLump[1][2] / ( 2 * 3 ) do
        local i = #tModelData

        tModelData[i+1] = cStream:ReadUShort()
        tModelData[i+2] = cStream:ReadUShort()
        tModelData[i+3] = cStream:ReadUShort()
    end

    cStream:Jump( tModelLump[2][1] )

    do
        tModelData.nVersion = cStream:ReadUByte()

        local nX, nY, nZ = 0, 0, 0

        nX = cStream:ReadFloat()
        nY = cStream:ReadFloat()
        nZ = cStream:ReadFloat()

        tModelData.vAABBMin = vec3( nX, nY, nZ )

        nX = cStream:ReadFloat()
        nY = cStream:ReadFloat()
        nZ = cStream:ReadFloat()

        tModelData.vAABBMax = vec3( nX, nY, nZ )

        tModelData.nRadius = cStream:ReadFloat()
    end

    mdl.tCache[sFileName] = tModelData

    return cStream:Size()
end
