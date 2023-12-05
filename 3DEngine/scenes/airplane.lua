local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "airplane.obj" )
obj.scl = vec3( 1/60 )
obj.ang = vec3( 0, 0, 0 )
obj.solid = true

vec3set( GetCamPos(), 6.248255, 2.850344 - 1.4, 21.90943 )
vec3set( GetCamAng(), -0.51469, 2.824500, 0 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 200
lamp:setPos( vec3( 0, 2, 4 ) )
lamp:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )
lamp.diffuse = vec3mul( vec3( 255, 0, 0 ), 1 / 255 )

local function Loop( CT, DT )
    vec3set( lamp.pos, math.cos( CT ) * 17, math.sin( CT ) * 17, 0 )
end

callback( _LOOPCALLBACK, Loop )
