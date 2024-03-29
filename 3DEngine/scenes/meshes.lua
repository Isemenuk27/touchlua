if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("3DEngine/init")
end

local meshes = {
    loadModel( "osprey.mdl" ),
    loadModel( "f16.mdl" ),
    loadModel( "apache.mdl" ),
    loadModel( "skeleton.mdl" ),
}

local meshid = 1

local obj = createclass( C_POLY )
obj:born()
obj.form = loadModel( "osprey.mdl" )
obj.scl = vec3( 1 )
obj.ang = vec3( 0, 0, 0 )
obj.solid = true

vec3set( GetCamPos(), 1.4629, 3.8762 - 1.4, 9.1 )
vec3set( GetCamAng(), -0.35, 3, 0 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 200
lamp:setPos( vec3( 0, 2, 4 ) )
lamp:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )
lamp.diffuse = vec3mul( vec3( 255, 0, 0 ), 1 / 255 )

local nextChange = 2

local function Loop( CT, DT )

    if ( nextChange < CT ) then
        nextChange = nextChange + 2
        meshid = (meshid%#meshes) + 1
        obj.form = meshes[meshid]
    end

    vec3set( obj.ang, 0, math.pi * CT * .2, 0 )
    vec3set( lamp.pos, math.cos( CT ) * 17, math.sin( CT ) * 17, 0 )
end

callback( _LOOPCALLBACK, Loop )
