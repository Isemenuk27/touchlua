local meshes = {
    loadobj( "osprey.obj" ),
    loadobj( "f16.obj" ),
    loadobj( "apache.obj" ),
    loadobj( "skeleton.obj" ),
}

local meshid = 1

local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "osprey.obj" )
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

    vec3set( obj.ang, 0, math.pi * CT, 0 )
    vec3set( lamp.pos, math.cos( CT ) * 17, math.sin( CT ) * 17, 0 )
end

callback( _LOOPCALLBACK, Loop )
