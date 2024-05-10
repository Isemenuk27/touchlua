if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

require( "libs/spring" )

local function Init()
    local cam = mat3()
    local s = ScrW( 1 )
    mat3setSc( cam, s, s )
    mat3setTr( cam, s * .5, s * .5 )
    draw.setmatrix( cam )
end

local nAX, nAY, nVX, nVY = 0, 0, 0, 0

local nDamping, nHalflife = .3, .4

local function Loop( nTime, nDeltaTime )
    local nBX, nBY = vec2unpack( cursor.pos3() )

    --nAX = spring.exact( nAX, nBX, nDamping, nDeltaTime )
    --nAY = spring.exact( nAY, nBY, nDamping, nDeltaTime )

    --nAX = spring.exponential( nAX, nBX, nDamping, nDeltaTime )
    --nAY = spring.exponential( nAY, nBY, nDamping, nDeltaTime )

    nAX, nVX = spring.exactRatio( nAX, nVX, nBX, 0, nDamping, nHalflife, nDeltaTime )
    nAY, nVY = spring.exactRatio( nAY, nVY, nBY, 0, nDamping, nHalflife, nDeltaTime )

    draw.cross( nAX, nAY, .04 )
    draw.box( nBX-.04, nBY - .04, .08, .08, draw.red )
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
