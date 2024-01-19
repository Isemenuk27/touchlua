if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local rectform = {
    vec2( -.5, .5 ),
    vec2( .5, .5 ),
    vec2( .5, -.5 ),
    vec2( -.5, -.5 )
}

local circform = {}
local sides = 8
local steps = math.tau / sides
for i = 1, sides do
    local j = i * steps
    circform[i] = vec2mul( vec2( math.cos( j ), math.sin( j ) ), .5 )
end

local Ent, ground

local function Init()
    local cam = mat3()
    local s = ScrW()
    local sc = s * .5
    mat3setSc( cam, sc, sc )
    mat3setTr( cam, sc * .5, sc ) -- s * .5, s * .5)
    draw.setmatrix( cam )

    Ent = phys.new( circform )
    vec2set( Ent.scl, vec2( .1 ) )
    vec2set( Ent.pos, vec2( .5 ) )
    Ent.coef = 1
    Ent.ang = .1

    ground = phys.new( rectform )
    vec2set( ground.pos, .5, 1.5 )
    vec2set( ground.scl, 4, .1 )
    phys.freeze( ground, true )
end

local mat = mat3()

local function Loop( CT, DT )

    phys.tick( CT, DT )

    --Ent.ang = CT % math.tau

    local a = sign( .5 - Ent.pos[1] )

    --ground.ang = ( ground.ang - DT * a ) % math.tau

    local s = math.cos( CT )

    mat3setSc( mat, s, s )


    --[[draw.pushmatrix( mat )
    draw.cross( 0, 0, .1 )
    draw.cross( .5, .5, .1 )
    draw.cross( 1, 1, .1 )
    draw.cross( 0, 1, .1 )
    draw.cross( 1, 0, .1 )
    draw.popmatrix()]]

    --draw.cross( 0, 1 * ScrRatio(), .1 )
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
