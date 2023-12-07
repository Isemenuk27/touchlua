local obj = createclass( C_POLY )
obj:born()
obj.form = loadobj( "axis.obj" )
obj.scl = vec3( 1/10 )

local obj2 = createclass( C_POLY )
obj2:born()
obj2.form = loadobj( "cube.obj" )
obj2.scl = vec3( 1/3 )
obj2.ang = vec3( 0, 0, 0 )


--mat4worldtolocal
--mat4localtoworld

local function Loop( CT, DT )
    vec3set( obj.ang, 0, ( CT * .2 * math.pi ) % ( math.pi * 2 ) , 0 )

    local pos, ang = mat4localtoworld( obj.pos, obj.ang, vec3( 1, 0, 0 ), vec3( 0, 0, math.pi * .25 ) )
    vec3set( obj2.pos, pos )
    vec3set( obj2.ang, ang )
end

callback( _LOOPCALLBACK, Loop )
