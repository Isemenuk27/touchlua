require( "libs/table" )
require( "libs/vec3" )
require( "libs/ansi" )
require( "libs/file" )

--[[
local fMap1 = io.open( "map1.bin", "rb" )
local fMap2 = io.open( "map2.bin", "rb" )
local fMap3 = io.open( "map3.bin", "rb" )

local fMap = io.open( "!map.bsp", "wb" )
fMap:write( fMap1:read( "a" ) )
fMap:write( fMap2:read( "a" ) )
fMap:write( fMap3:read( "a" ) )
fMap:flush()
print( fMap ) ]]--

bsp = {}

HEADER_LUMPS = 64
MAX_MAP_VERTS = 65536

LUMP_ENTITIES 						= 0  -- Map entities
LUMP_PLANES 						= 1  -- Plane array
LUMP_TEXDATA						= 2  -- Index to texture names
LUMP_VERTEXES 						= 3  -- Vertex array
LUMP_VISIBILITY 					= 4  -- Compressed visibility bit arrays
LUMP_NODES							= 5  -- BSP tree nodes
LUMP_TEXINFO						= 6  -- Face texture array
LUMP_FACES							= 7  -- Face array
LUMP_LIGHTING 						= 8  -- Lightmap samples
LUMP_OCCLUSION 						= 9	 -- Occlusion polygons and vertices
LUMP_LEAFS 							= 10 -- BSP tree leaf nodes
LUMP_FACEIDS 						= 11 -- Correlates between dfaces and Hammer face IDs. Also used as random seed for detail prop placement.
LUMP_EDGES 							= 12 -- Edge array
LUMP_SURFEDGES 						= 13 -- Index of edges
LUMP_MODELS 						= 14 -- Brush models (geometry of brush entities)
LUMP_WORLDLIGHTS					= 15 -- Internal world lights converted from the entity lump
LUMP_LEAFFACES						= 16 -- Index to faces in each leaf
LUMP_LEAFBRUSHES					= 17 -- Index to brushes in each leaf
LUMP_BRUSHES 						= 18 -- Brush array
LUMP_BRUSHSIDES						= 19 -- Brushside array
LUMP_AREAS							= 20 -- Area array
LUMP_AREAPORTALS					= 21 -- Portals between areas
LUMP_PORTALS 						= 22 -- Polygons defining the boundary between adjacent leaves
LUMP_CLUSTERS						= 23 -- Leaves that are enterable by the player
LUMP_PORTALVERTS					= 24 -- Vertices of portal polygons
LUMP_CLUSTERPORTALS 				= 25 -- Polygons defining the boundary between adjacent clusters
LUMP_DISPINFO 						= 26 -- Displacement surface array
LUMP_ORIGINALFACES 					= 27 -- Brush faces array before splitting
LUMP_PHYSDISP						= 28 -- Displacement physics collision data
LUMP_PHYSCOLLIDE 					= 29 -- Physics collision data
LUMP_VERTNORMALS					= 30 -- Face plane normals
LUMP_VERTNORMALINDICES 				= 31 -- Face plane normal index array
LUMP_DISP_LIGHTMAP_ALPHAS 			= 32 -- Displacement lightmap alphas (unused/empty since Source 2006)
LUMP_DISP_VERTS 					= 33 -- Vertices of displacement surface meshes
LUMP_DISP_LIGHTMAP_SAMPLE_POSITIONS = 34 -- Displacement lightmap sample positions
LUMP_GAME_LUMP						= 35 -- Game-specific data lump
LUMP_LEAFWATERDATA					= 36 -- Data for leaf nodes that are inside water
LUMP_PRIMITIVES						= 37 -- Water polygon data
LUMP_PRIMVERTS						= 38 -- Water polygon vertices
LUMP_PRIMINDICES					= 39 -- Water polygon vertex index array
LUMP_PAKFILE						= 40 -- Embedded uncompressed Zip-format file
LUMP_CLIPPORTALVERTS				= 41 -- Clipped portal polygon vertices
LUMP_CUBEMAPS						= 42 -- env_cubemap location array
LUMP_TEXDATA_STRING_DATA 			= 43 -- Texture name data
LUMP_TEXDATA_STRING_TABLE			= 44 -- Index array into texdata string data
LUMP_OVERLAYS						= 45 -- info_overlay data array
LUMP_LEAFMINDISTTOWATER 			= 46 -- Distance from leaves to water
LUMP_FACE_MACRO_TEXTURE_INFO 		= 47 -- Macro texture info for faces
LUMP_DISP_TRIS						= 48 -- Displacement surface triangles
LUMP_PHYSCOLLIDESURFACE				= 49 -- Terrain surface collision data
LUMP_WATEROVERLAYS					= 50 -- info_overlay's on water faces?
LUMP_LEAF_AMBIENT_INDEX_HDR			= 51 -- Index of LUMP_LEAF_AMBIENT_LIGHTING_HDR
LUMP_LEAF_AMBIENT_INDEX 			= 52 -- Index of LUMP_LEAF_AMBIENT_LIGHTING
LUMP_LIGHTING_HDR					= 53 -- HDR lightmap samples
LUMP_WORLDLIGHTS_HDR 				= 54 -- Internal HDR world lights converted from the entity lump
LUMP_LEAF_AMBIENT_LIGHTING_HDR 		= 55 -- Per-leaf ambient light samples (HDR)
LUMP_LEAF_AMBIENT_LIGHTING 			= 56 -- Per-leaf ambient light samples (LDR)
LUMP_XZIPPAKFILE 					= 57 -- XZip version of pak file for Xbox. Deprecated.
LUMP_FACES_HDR 						= 58 -- HDR maps may have different face data
LUMP_MAP_FLAGS 						= 59 -- Extended level-wide flags. Not present in all levels.
LUMP_OVERLAY_FADES					= 60 -- Fade distances for overlays
LUMP_DISP_MULTIBLEND 				= 63 -- Displacement multiblend info

local readFloat  = CFile.ReadFloat
local readUShort = CFile.ReadUShort
local readShort  = CFile.ReadShort
local readULong  = CFile.ReadULong
local readLong   = CFile.ReadLong
local readUByte  = CFile.ReadUByte
local readByte   = CFile.ReadByte
local readBool   = CFile.ReadBool
local readBit    = CFile.ReadBit
local read   = CFile.Read

bsp.tLumpParse = {
    [LUMP_ENTITIES] = function( fMap, tLump, tLumpData ) -- Map entities
        local sKeyValues = read( fMap, tLumpData[2] - 1 )

        local tLumpSize = #tLump

        print( sKeyValues )
        --[[
        for sEntKV in string.gmatch( sKeyValues, sKeyValuesGmatch ) do
            local tData = sEntKV -- KeyValuesToTable( "_" .. sEntKV )
            tLumpSize = tLumpSize + 1
            tLump[tLumpSize] = tData
        end ]]--
    end,
    [LUMP_VERTEXES] = function( fMap, tLump, tLumpData ) -- Array of points
        local nSize = tLumpData[2] / 12
        for i = 0, nSize - 1 do
            tLump[i] = vec3( readFloat( fMap ), readFloat( fMap ), readFloat( fMap ) )
        end
        return nSize
    end,
    [LUMP_CUBEMAPS] = function( fMap, tLump, tLumpData ) -- env_cubemap location array
        local nSize = tLumpData[2] / 16

        for i = 0, nSize - 1 do
            local vOrigin = vec3( ReadLong( fMap ), ReadLong( fMap ), ReadLong( fMap ) ) --Integer vector
            local nCubemapSize = ReadLong( fMap )

            if ( nCubemapSize < 1 ) then nCubemapSize = 6 end -- default size should be 32x32

            tLump[i] = {
                vOrigin,
                2 ^ ( nCubemapSize - 1 )
            }
        end

        return nSize
    end,
    [LUMP_BRUSHSIDES] = function( fMap, tLump, tLumpData ) -- Brushside array
        local nSize = tLumpData[2] * .125
        for i = 0, nSize - 1 do
            tLump[i] = {
                [1] = readUShort( fMap ), -- planenum, facing out of the leaf
                [2] = readShort( fMap ), -- texture info
                [3] = readShort( fMap ), -- displacement info
                [4] = readShort( fMap ), -- is the side a bevel plane
            }
        end

        return nSize
    end,
}

function bsp.load( sPath )
    local fMap = File( sPath, FILE_READ )
    assert( fMap, "Map couldn't be opened." )
    return fMap
end

local CMap = {} -- Map object
CMap.__index = CMap

local sPathFormat = "maps/%s.bsp"

function CMap.new( sMapName )
    local self = setmetatable( {}, CMap )
    local sPath = sMapName --string.format( sPathFormat, sMapName )
    local fMap = bsp.load( sPath )
    self.sId = fMap:Read( 4 )
    print( "Header:", self.sId )
    self.nBSPVersion = readLong( fMap )
    print( "BSP version:", self.nBSPVersion )
    self.tLump, self.tLumpData = {}, {}

    for i = 0, HEADER_LUMPS - 1 do
        self.tLumpData[i] = {
            [1] = readLong( fMap ), -- offset into file (bytes)
            [2] = readLong( fMap ), -- length of lump (bytes)
            [3] = readLong( fMap ), -- lump format version
            [4] = read( fMap, 4 )   -- lump ident code (empty??)
        }
        self.tLump[i] = {}
    end

    self.nVersion = readLong( fMap )

    print( "Map verion:", self.nVersion )

    self.fMap = fMap

    return self
end

function CMap:loadLumps( ... )
    for _, nLump in ipairs( {...} ) do
        CMap.loadLump( self, nLump )
    end
end

function CMap:loadLump( nLump )
    local tLumpData = self.tLumpData[nLump]
    self.fMap:Seek( tLumpData[1] ) -- use data offset
    local fParse = bsp.tLumpParse[nLump]
    local nResult = fParse( self.fMap, self.tLump[nLump], tLumpData )
    return tLumpData
end

function CMap:getLump( nLump )
    return self.tLump[nLump]
end

function CMap:getLumpData( nLump )
    return self.tLumpData[nLump]
end

function CMap:Close()
    self.fMap:close()
    self.tLump = nil
    self.tLumpData = nil
end

local cMap = CMap.new( "!map.bsp" )
cMap:loadLump( LUMP_VERTEXES )
print( #cMap:getLump( LUMP_VERTEXES ) )
