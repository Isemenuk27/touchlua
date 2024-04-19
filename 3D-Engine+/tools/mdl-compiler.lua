local tRequirements = {
    "libs/string",
    "libs/table",
    "libs/math",
    "libs/1252xUnicode",
    "libs/stream",
    "libs/vec3",
    "libs/vec2",
}

do
    local sOldPath = package.path
    package.path = ";../?.lua;../../?.lua;../3D-Engine+/?.lua"

    for _, sFileName in ipairs( tRequirements ) do
        local bSuccess, sErrorCode = pcall( require, sFileName )

        if ( not bSuccess ) then
            print( "Failed to load " .. sFileName )
            print( sErrorCode )
            sys.halt()
        end
    end

    package.path = sOldPath
end

local sReadFrom = "../rawdata/models/"
local sWriteTo = "../models/"

local readObj do
    local tUVArray = {}
    local tPointArray = {}
    local tFaceArray = {}

    local function readPoint( sLine )
        local nX, nY, nZ = string.match( sLine, "(%S+)%s+(%S+)%s+(%S+)" )

        local vPoint = vec3( tonumber( nX ), tonumber( nY ), tonumber( nZ ) )

        table.insert( tPointArray, vPoint )
    end

    local function readUV( sLine )
        local nU, nV = string.match( sLine, "(%S+)%s+(%S+)" )
        local vUV = vec2( tonumber( nU ), tonumber( nV ) )

        table.insert( tUVArray, vUV )
    end

    local function readFace( sLine )
        local t = {}

        for sFaceComponent in string.gmatch( sLine, "[^ ]+" ) do
            local nIdPoint, nIdUV, nIdNormal = string.match( sFaceComponent, "(%d+)/(%d+)/(%d+)" )
            table.insert( t, { tonumber( nIdPoint ), tonumber( nIdUV ), tonumber( nIdNormal ) } )
        end

        table.insert( tFaceArray, t )
    end

    local tReadType = {
        ["v"] = readPoint,
        ["vt"] = readUV,
        ["f"] = readFace,
    }

    readObj = function( sContent, cStream )
        tUVArray, tPointArray, tFaceArray = {}, {}, {}

        for sLine in string.lines( sContent ) do
            local sType = string.match( sLine, "[^ ]+" )

            if ( tReadType[sType] ) then
                tReadType[sType]( string.sub( sLine, #sType + 1 ) )
            end
        end

        local tOut = {}

        local nHeaderSize = 3 + 4 * 2 + 1

        local nVertexDataSize = 4 * 5
        local nVertexArraySize = #tPointArray * nVertexDataSize

        -- PrintTable( tFaceArray )

        cStream:Jump( 0 )
        cStream:WriteString( "MDL" ) -- 3 Bytes

        -- Vertex Data
        cStream:WriteUShort( nHeaderSize ) -- 2 Bytes
        cStream:WriteUShort( nHeaderSize + nVertexArraySize ) -- 2 Bytes

        -- Triangle Data
        local nFaceArraySize = 2 * 3 * #tFaceArray
        cStream:WriteUShort( nHeaderSize + nVertexArraySize ) -- 2 Bytes
        cStream:WriteUShort( nHeaderSize + nVertexArraySize + nFaceArraySize ) -- 2 Bytes

        local nAdditionalModelData =
        cStream:WriteUShort( nHeaderSize + nVertexArraySize + nFaceArraySize ) -- 2 Bytes
        cStream:WriteUShort( nHeaderSize + nVertexArraySize + nFaceArraySize + nAdditionalModelData ) -- 2 Bytes

        -- Write vertecies
        for nKey, vPoint in ipairs( tPointArray ) do
            local vUV = tUVArray[nKey]
            --print( vec3tostring( vPoint ), vec2tostring( vUV ) )
            cStream:WriteFloat( vPoint[1] ) -- 4
            cStream:WriteFloat( vPoint[2] ) -- 4
            cStream:WriteFloat( vPoint[3] ) -- 4

            cStream:WriteFloat( vUV[1] ) -- 4
            cStream:WriteFloat( vUV[2] ) -- 4
        end

        -- Write triangles
        for _, tFaceData in ipairs( tFaceArray ) do
            cStream:WriteUShort( tFaceData[1][1] ) -- 2
            cStream:WriteUShort( tFaceData[2][1] ) -- 2
            cStream:WriteUShort( tFaceData[3][1] ) -- 2
        end

        -- Additional data
        do
            cStream:WriteUByte( 1 ) -- Version

            -- Bounding box min/max



        end

        --PrintTable( cStream )

        return cStream
    end
end

local tReadFormatCase = {
    ["obj"] = readObj,
}

local function compile( sFileName, ... )
    local cStream = Stream()
    local cFile = assert( io.open( sReadFrom .. sFileName, "rb" ) )
    local sContent = cFile:read("*a")

    local sFileExtension = string.GetFileExtension( sFileName ):sub(2)

    cFile:close()
    cStream = nil

    return tReadFormatCase[sFileExtension]( sContent, ... )
end

local tRawFiles = sys.dir( sReadFrom )

for _, sFileName in ipairs( tRawFiles ) do
    if ( not string.GetFileExtension( sFileName ) ) then
        goto skip
    end

    local cStreamOut = compile( sFileName, Stream() )

    local cFile = assert( io.open( sWriteTo .. string.StripExtension( sFileName ) .. ".mdl", "wb" ) )
    cStreamOut:WriteToFile( cFile )

    cFile:close()
    print( sFileName, string.NiceSize( ( #cStreamOut + 1 ) * 1024 ) )

    ::skip::
end


