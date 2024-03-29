if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("3DEngine/init")
end

local obj = createclass( C_POLY )
obj:born()
obj.form = loadModel( "axis.mdl" )
obj.scl = vec3( 1/10 )

local obj2 = createclass( C_POLY )
obj2:born()
obj2.form = loadModel( "cube.mdl" )
obj2.scl = vec3( 1/3 )
obj2.ang = vec3( 0, 0, 0 )


--mat4worldtolocal
--mat4localtoworld

local function Loop( CT, DT )
    vec3set( obj.ang, 0, ( CT * .2 * math.pi ) % ( math.pi * 2 ) , 0 )

    local pos, ang = mat4localtoworld( obj.pos, obj.ang, vec3( 2, 0, 0 ), vec3( 0, 0, 0 ) )
    table.shiftRight( ang, 1 )
    vec3set( obj2.pos, pos )
    vec3mul( ang, -1 )
    vec3set( obj2.ang, ang )
end

callback( _LOOPCALLBACK, Loop )
