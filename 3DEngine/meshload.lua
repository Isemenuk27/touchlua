if ( not Inited ) then require( "init" ) return end

local tn = tonumber
local insert = table.insert

function loadobj( name )
    local f = io.open ( "mesh/" .. name , "r" )

    local form = {}

    local vertexbuffer = {}

    for c in f:lines() do
        local a = string.Split( c, " " )

        if ( a[1] == "v" ) then
            local v = vec3( tn( a[2] ), tn( a[3] ), tn( a[4] ) )
            vertexbuffer[ #vertexbuffer + 1 ] = v
        elseif ( a[1] == "f" ) then
            for i = 2, 4 do
                insert( form, vertexbuffer[ tn( a[i] ) ] )
            end
        end
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
