if ( not Inited ) then require( "init" ) return end

local tn = tonumber
local insert = table.insert

local vertexbuffer, form = {}, {}

local function numChars(str, char)
    local count = 0

    for i = 1, #str do
        if string.sub(str, i, i) == char then
            count = count + 1
        end
    end

    return count
end

local function writeVertex( a )
    local v_Vtex = vec3( tn( a[2] ), tn( a[3] ), tn( a[4] ) )
    insert( vertexbuffer, v_Vtex )
end

local function constructFace( a )
    local numslashes = numChars( a[2], "/" )

    if ( sl == 0 ) then --Only vertices
        local p1 = vertexbuffer[tn(a[2])]
        local p2 = vertexbuffer[tn(a[3])]
        local p3 = vertexbuffer[tn(a[4])]

        insert( form, face( p1, p2, p3 ) )
    else
        local pf1 = string.Split( a[2], "/" )
        local pf2 = string.Split( a[3], "/" )
        local pf3 = string.Split( a[4], "/" )

        local p1 = vertexbuffer[tn(pf1[1])]
        local p2 = vertexbuffer[tn(pf2[1])]
        local p3 = vertexbuffer[tn(pf3[1])]

        insert( form, face( p1, p2, p3 ) )
    end
end

local keys = {
    ["v"] = writeVertex,
    ["f"] = constructFace,
}

function loadobj( name )
    local f = io.open ( "mesh/" .. name , "r" )

    form, vertexbuffer = {}, {}

    local vertexbuffer = {}

    for c in f:lines() do
        local a = string.Split( c, " " )

        if ( not keys[ a[1] ] ) then
            goto skipobj
        end

        keys[ a[1] ]( a )

        ::skipobj::
    end

    return form
end

--[[
              ( -1, 1, 1 ) ---------------- (1, 1, 1 )
                         / |             /|
                        /  |    ↑       / |
                       /   |    Y+     /  |
                      /    |          /   |
                     /     |         /    |
      ( -1, 1, -1 ) ----------------/  ( 1, 1, -1 )
                    |      |       |      |
                    |      |    NR |      |
             ( -1, -1, 1 ) --------|------- ( 1, -1, 1
                    |     /        |     /
                WS  |    /         |    /  EA
                    |   /     Y-   |   /
                    |  /      ↓    |  /
                    | /            | /
                    |/             |/
     ( -1, -1, -1 ) ---------------- ( 1, -1, -1 )
                           ST
]]--

_CUBE = {
    vec3( 1, -1, -1 ),
    vec3( -1, -1, -1 ),
    vec3( -1, -1, 1 ),

    vec3( 1, -1, -1 ),
    vec3( -1, -1, 1 ),
    vec3( 1, -1, 1 ), -- Y-

    vec3( -1, 1, -1 ),
    vec3( -1, 1, 1 ),
    vec3( 1, 1, 1 ),

    vec3( -1, 1, -1 ),
    vec3( 1, 1, 1 ),
    vec3( 1, 1, -1 ), --Y+

    vec3( -1, -1, -1 ),
    vec3( -1, 1, -1 ),
    vec3( 1, 1, -1 ),

    vec3( -1, -1, -1 ),
    vec3( 1, 1, -1 ),
    vec3( 1, -1, -1 ), --South

    vec3( 1, -1, 1 ),
    vec3( -1, -1, 1 ),
    vec3( -1, 1, 1 ),

    vec3( 1, -1, 1 ),
    vec3( -1, 1, 1 ),
    vec3( 1, 1, 1 ), --North

    vec3( 1, -1, -1 ),
    vec3( 1, 1, -1 ),
    vec3( 1, 1, 1 ),

    vec3( 1, -1, -1 ),
    vec3( 1, 1, 1 ),
    vec3( 1, -1, 1 ), -- East

    vec3( -1, -1, 1 ),
    vec3( -1, 1, 1 ),
    vec3( -1, 1, -1 ),

    vec3( -1, -1, 1 ),
    vec3( -1, 1, -1 ),
    vec3( -1, -1, -1 ), --West
}

_PLANE = {
    vec3( 1, -1, 0 ),
    vec3( -1, -1, 0 ),
    vec3( -1, 1, 0 ),

    vec3( 1, -1, 0 ),
    vec3( -1, 1, 0 ),
    vec3( 1, 1, 0 ),

    vec3( 0, 1, 0 ),
    vec3( 0, 0, 1 ),
    vec3( 0, -1, 0 ),
}
