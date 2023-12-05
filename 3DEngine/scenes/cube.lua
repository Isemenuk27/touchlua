local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "cube.obj" )
obj.scl = vec3( 1 )
obj.ang = vec3( 0, 0, 0 )
obj.solid = true

vec3set( GetCamPos(), 4, 2.850344 - 1.4, 5 )
vec3set( GetCamAng(), -0.51469, 2.424500, 0 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 200
lamp:setPos( vec3( 0, 2, 4 ) )
lamp:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )
lamp.diffuse = vec3mul( vec3( 255, 0, 0 ), 1 / 255 )

local function Loop( CT, DT )
    vec3set( lamp.pos, math.cos( CT ) * 17, math.sin( CT ) * 17, 0 )

    vec3add( obj.ang, 0, .25 * DT * math.pi, 0 )
end

callback( _LOOPCALLBACK, Loop )

local function sunedit( sun )
    local dif = vec3( 85, 124, 78 )
    local amb = vec3( 37, 120, 31 )

    sun:setColor( vec3mul( dif, 1 / 255 ), vec3mul( amb, 1 / 255 ) )
end

callback( "sunborn", sunedit )
