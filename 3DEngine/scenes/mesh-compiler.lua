if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("3DEngine/init")
end

--[[
-- Model data stored in 3 lumps
1 - vertex points array
2 - face vertexId array
3 - aabb bbox and radius of model

lump stored as 2 unsigned shorts
1 - offset starting from the beginning of the file
2 - size of lump
]]

local tNames = {
    "cube",
    "axis",
    "apache",
    "f16",
    "skeleton",
    "osprey",
    "table",
    "plane",
}
local nVersion = 1

local tn = tonumber

local tVertex, nVertexLen = {}, 0
local tFace, nFaceLen = {}, 0
local nRadius = 0
local nMaxX, nMaxY, nMaxZ = math.mininteger, math.mininteger, math.mininteger
local nMinX, nMinY, nMinZ = math.maxinteger, math.maxinteger, math.maxinteger
local max, min = math.max, math.min

local function writeVertex( a )
    local vVtex = vec3( tn( a[2] ), tn( a[3] ), tn( a[4] ) )
    nVertexLen = nVertexLen + 1
    tVertex[nVertexLen] = vVtex

    nMaxX = max( vVtex[1], nMaxX )
    nMaxY = max( vVtex[2], nMaxY )
    nMaxZ = max( vVtex[3], nMaxZ )

    nMinX = min( vVtex[1], nMinX )
    nMinY = min( vVtex[2], nMinY )
    nMinZ = min( vVtex[3], nMinZ )

    nRadius = max( vec3mag( vVtex ), nRadius )
end

local function insertFace( v1, v2, v3 )
    nFaceLen = nFaceLen + 1
    tFace[nFaceLen] = { v1, v2, v3 }
end

local function constructFace( a )
    local bHaveSlash = string.find( a[2], "/" ) ~= nil

    if ( not bHaveSlash ) then --Only vertices
        local p1 = tn(a[2])
        local p2 = tn(a[3])
        local p3 = tn(a[4])

        insertFace( p1, p2, p3 )

        if ( a[5] ) then
            local p1 = tn(a[4])
            local p2 = tn(a[5])
            local p3 = tn(a[2])

            insertFace( p1, p2, p3 )
        end
    else
        local pf1 = string.Split( a[2], "/" )
        local pf2 = string.Split( a[3], "/" )
        local pf3 = string.Split( a[4], "/" )

        local p1 = tn(pf1[1])
        local p2 = tn(pf2[1])
        local p3 = tn(pf3[1])

        insertFace( p1, p2, p3 )

        if ( a[5] ) then
            local pf4 = string.Split( a[5], "/" )
            local p1 = tn(pf3[1])
            local p2 = tn(pf4[1])
            local p3 = tn(pf1[1])

            insertFace( p1, p2, p3 )
        end
    end
end

local function constructFaceArray( a )
    local bHaveSlash = string.find( a[2], "/" ) ~= nil

    if ( not bHaveSlash ) then --Only vertices

        insertFace( tn(a[2]), tn(a[3]), tn(a[4]) )

        if ( a[5] ) then
            insertFace( tn(a[4]), tn(a[5]), tn(a[2]) )
        end
    else
        local pf1 = string.Split( a[2], "/" )
        local pf2 = string.Split( a[3], "/" )
        local pf3 = string.Split( a[4], "/" )

        insertFace( tn(pf1[1]), tn(pf2[1]), tn(pf3[1]) )

        if ( a[5] ) then
            local pf4 = string.Split( a[5], "/" )

            insertFace( tn(pf3[1]), tn(pf4[1]), tn(pf1[1]) )
        end
    end
end

local tKeys = {
    ["v"] = writeVertex,
    ["f"] = constructFaceArray, --constructFace,
}

local function loadMesh( cObj )
    tVertex, nVertexLen = {}, 0
    tFace, nFaceLen = {}, 0

    for sLine in string.gmatch( cObj:Read( "a" ), "[^\n]+" ) do
        local tValues = string.Split( sLine, " " )

        local sPrefix = tValues[1]

        if ( not tKeys[sPrefix] ) then
            goto skipobj
        end

        tKeys[sPrefix](tValues)

        ::skipobj::
    end

    return tFace, tVertex
end

local function compileModel( name )
    local sObjInput = string.format( "../mesh/%s.obj", name )
    local cObj = File( sObjInput, "r" )
    local cMesh = File( "../models/" .. name .. ".mdl", FILE_WRITE )
    local cTemp = File( "../mesh/compile.temp", FILE_WRITE )

    nRadius = 0
    nMaxX, nMaxY, nMaxZ = math.mininteger, math.mininteger, math.mininteger
    nMinX, nMinY, nMinZ = math.maxinteger, math.maxinteger, math.maxinteger
    local tFace, tVertex = loadMesh( cObj )

    cMesh:Write( "MDL" ) -- Header
    cMesh:WriteUShort( nVersion ) -- Version

    local nOffsetBytes, nBytes = 5, 0
    local nLumpOffset = 3 * 4

    for _, vVtex in ipairs( tVertex ) do
        cTemp:WriteFloat( vVtex[1] )
        cTemp:WriteFloat( vVtex[2] )
        cTemp:WriteFloat( vVtex[3] )
        nBytes = nBytes + 4 * 3
    end

    cMesh:WriteUShort( nLumpOffset + nOffsetBytes ) -- offset
    cMesh:WriteUShort( nBytes ) -- size
    nOffsetBytes, nBytes = nOffsetBytes + nBytes, 0

    for _, t in ipairs( tFace ) do
        cTemp:WriteUShort( t[1] )
        cTemp:WriteUShort( t[2] )
        cTemp:WriteUShort( t[3] )
        nBytes = nBytes + 2 * 3
    end

    cMesh:WriteUShort( nLumpOffset + nOffsetBytes ) -- offset
    cMesh:WriteUShort( nBytes ) -- size
    nOffsetBytes, nBytes = nOffsetBytes + nBytes, 0

    -- Model data
    cTemp:WriteFloat( nMinX )
    cTemp:WriteFloat( nMinY )
    cTemp:WriteFloat( nMinZ )

    cTemp:WriteFloat( nMaxX )
    cTemp:WriteFloat( nMaxY )
    cTemp:WriteFloat( nMaxZ )

    cTemp:WriteFloat( nRadius )
    nBytes = 7 * 4

    cMesh:WriteUShort( nLumpOffset + nOffsetBytes ) -- offset
    cMesh:WriteUShort( nBytes ) -- size
    nOffsetBytes, nBytes = nOffsetBytes + nBytes, 0

    cTemp:Close()
    cTemp = File( "../mesh/compile.temp", "r" )
    cMesh:Write( cTemp:Read( "a" ) )

    print( name .. " model compiled. Version:", nVersion )
    print( "Vertex Count:", nVertexLen, " Face Count:", nFaceLen )
    cObj:Close()
    cMesh:Close()

    local cObj = File( "../mesh/" .. name .. ".obj", FILE_READ )
    local cMesh = File( "../models/" .. name .. ".mdl", FILE_READ )
    local nSize1 = #cObj:Read( "a" )
    local nSize2 = #cMesh:Read( "a" )

    print( "Old File Length: ", nSize1 )
    print( "New File Length: ", nSize2 )
    print( round( 100 * ( nSize1 / nSize2 ), 3 ), "%" )
    print( string.NiceSize( nSize2 ) )

    print("\n\n")
end

for i, name in ipairs( tNames ) do
    compileModel( name )
end

assert( false, "end" )
