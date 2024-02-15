if ( not Inited ) then require( "init" ) return end

local tn = tonumber
local insert = table.insert

local vertexbuffer, form = {}, {}
local radius = 0
local maxx, maxy, maxz = math.mininteger, math.mininteger, math.mininteger
local minx, miny, minz = math.maxinteger, math.maxinteger, math.maxinteger

local function numChars(str, char)
    local count = 0

    for i = 1, #str do
        if string.sub(str, i, i) == char then
            count = count + 1
        end
    end

    return count
end

local max, min = math.max, math.min

local function writeVertex( a )
    local v_Vtex = vec3( tn( a[2] ), tn( a[3] ), tn( a[4] ) )
    insert( vertexbuffer, v_Vtex )

    maxx = max( v_Vtex[1], maxx )
    maxy = max( v_Vtex[2], maxy )
    maxz = max( v_Vtex[3], maxz )

    minx = min( v_Vtex[1], minx )
    miny = min( v_Vtex[2], miny )
    minz = min( v_Vtex[3], minz )

    radius = max( vec3mag( v_Vtex ), radius )
end

local function constructFace( a )
    local numslashes = numChars( a[2], "/" )

    if ( sl == 0 ) then --Only vertices
        local p1 = vertexbuffer[tn(a[2])]
        local p2 = vertexbuffer[tn(a[3])]
        local p3 = vertexbuffer[tn(a[4])]

        insert( form, face( p1, p2, p3 ) )

        if ( a[5] ) then
            local p1 = vertexbuffer[tn(a[4])]
            local p2 = vertexbuffer[tn(a[5])]
            local p3 = vertexbuffer[tn(a[2])]
            insert( form, face( p1, p2, p3 ) )
        end
    else
        local pf1 = string.Split( a[2], "/" )
        local pf2 = string.Split( a[3], "/" )
        local pf3 = string.Split( a[4], "/" )

        local p1 = vertexbuffer[tn(pf1[1])]
        local p2 = vertexbuffer[tn(pf2[1])]
        local p3 = vertexbuffer[tn(pf3[1])]

        insert( form, face( p1, p2, p3 ) )

        if ( a[5] ) then
            local pf4 = string.Split( a[5], "/" )
            local p1 = vertexbuffer[tn(pf3[1])]
            local p2 = vertexbuffer[tn(pf4[1])]
            local p3 = vertexbuffer[tn(pf1[1])]
            insert( form, face( p1, p2, p3 ) )
        end
    end
end

local keys = {
    ["v"] = writeVertex,
    ["f"] = constructFace,
}

function loadModel( name )
    local cFile = File( "models/" .. name, FILE_READ )

    if ( not cFile:Valid() ) then
        cFile = File( "../3DEngine/models/" .. name, FILE_READ )
    end

    if ( not cFile:Valid() ) then
        cFile = File( name, FILE_READ )
    end

    if ( not cFile:Valid() ) then
        cFile = File( "../models/" .. name, FILE_READ )
    end

    form, vertexbuffer = {}, {}

    local sHeader = cFile:Read( 3 )
    local nVersion = cFile:ReadUShort()
    --local nRadius = cFile:ReadFloat()

    local tLump = {}

    for i = 1, 3 do
        tLump[i] = {
            cFile:ReadUShort(), -- offset
            cFile:ReadUShort(), -- size
        }
    end

    --print( sHeader, nVersion )
    --PrintTable( tLump )

    -- Read Vertex Array
    cFile:Seek( tLump[1][1] )
    for _ = 1, tLump[1][2] / 12 do
        local A, B, C = cFile:ReadFloat(), cFile:ReadFloat(), cFile:ReadFloat()
        --print( A, B, C )
        vertexbuffer[#vertexbuffer + 1] = vec3( A, B, C )
    end

    -- Construct face
    cFile:Seek( tLump[2][1] )
    for _ = 1, tLump[2][2] / 6 do
        local A, B, C = cFile:ReadUShort(), cFile:ReadUShort(), cFile:ReadUShort()
        --print( A, B, C, vertexbuffer[A], vertexbuffer[B], vertexbuffer[C] )
        local tFace = face( vertexbuffer[A], vertexbuffer[B], vertexbuffer[C] )
        insert( form, tFace )
    end

    -- Model Data
    cFile:Seek( tLump[3][1] )

    do
        local minx, miny, minz = cFile:ReadFloat(), cFile:ReadFloat(), cFile:ReadFloat()
        local maxx, maxy, maxz = cFile:ReadFloat(), cFile:ReadFloat(), cFile:ReadFloat()
        local nRadius = cFile:ReadFloat()
        -- 4 * 7 Bytes

        form.radius = nRadius
        form.rawoobb = { vec3( minx, miny, minz ), vec3( maxx, maxy, maxz ) }
        form.oobb = { vec3( form.rawoobb[1] ), vec3( form.rawoobb[2] ) }
        local min, max = vec3( form.oobb[1] ), vec3( form.oobb[2] )

        form.rawpoints = {
            vec3( min[1], max[2], min[3] ),
            vec3( max[1], max[2], min[3] ),
            vec3( max[1], min[2], min[3] ),
            vec3( min[1], min[2], min[3] ),

            vec3( min[1], max[2], max[3] ),
            vec3( max[1], max[2], max[3] ),
            vec3( max[1], min[2], max[3] ),
            vec3( min[1], min[2], max[3] ),
        }

        form.oobbpoints = {
            vec3( ),
            vec3( ),
            vec3( ),
            vec3( ),
            vec3( ),
            vec3( ),
            vec3( ),
            vec3( )
        }
    end

    return form
end

function loadobj( name )
    local f = io.open( "mesh/" .. name , "r" )

    if ( not f ) then
        f = io.open( "../3DEngine/mesh/" .. name , "r" )
    end

    if ( not f ) then
        f = io.open( name , "r" )
    end

    if ( not f ) then
        f = io.open( "../mesh/" .. name , "r" )
    end

    local bIsObj = string.GetFileExtension( name ) == ".obj"

    form, vertexbuffer = {}, {}
    radius = 0
    maxx, maxy, maxz = math.mininteger, math.mininteger, math.mininteger
    minx, miny, minz = math.maxinteger, math.maxinteger, math.maxinteger

    local vertexbuffer = {}

    for c in f:lines() do
        local a = string.Split( c, " " )

        if ( not keys[ a[1] ] ) then
            goto skipobj
        end

        keys[ a[1] ]( a )

        ::skipobj::
    end

    form.radius = radius
    form.rawoobb = { vec3( minx, miny, minz ), vec3( maxx, maxy, maxz ) }
    form.oobb = { vec3(form.rawoobb[1]), vec3(form.rawoobb[2]) }

    local min, max = vec3( form.oobb[1] ), vec3( form.oobb[2] )

    form.rawpoints = {
        vec3( min[1], max[2], min[3] ),
        vec3( max[1], max[2], min[3] ),
        vec3( max[1], min[2], min[3] ),
        vec3( min[1], min[2], min[3] ),

        vec3( min[1], max[2], max[3] ),
        vec3( max[1], max[2], max[3] ),
        vec3( max[1], min[2], max[3] ),
        vec3( min[1], min[2], max[3] ),
    }

    form.oobbpoints = {
        vec3( ),
        vec3( ),
        vec3( ),
        vec3( ),
        vec3( ),
        vec3( ),
        vec3( ),
        vec3( )
    }

    return form
end
