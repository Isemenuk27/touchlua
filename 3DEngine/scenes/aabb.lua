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
obj.form = loadModel( "f16.mdl" )
obj.scl = vec3( 1 )
obj.ang = vec3( 0, 0, 0 )
obj.solid = true

local obj2 = createclass( C_POLY )
obj2:born()
obj2.form = loadModel( "cube.mdl" )
obj2.scl = vec3( 1 )

vec3set( GetCamPos(), 1.4629, 3.8762 - 1.4, 9.1 )
vec3set( GetCamAng(), -0.35, 3, 0 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 200
lamp:setPos( vec3( 0, 2, 4 ) )
lamp:setDir( vec3normalize( vec3( -0.015374, 0.928981, -0.369808 ) ) )
lamp.diffuse = vec3mul( vec3( 255, 0, 0 ), 1 / 255 )

local max, min = math.max, math.min

local function Loop( CT, DT )

    vec3add( obj.ang, 0, DT * math.pi * .1, 0 )

    local min, max = objaabb( obj )

    drawaabb( min, max )

    local min2, max2 = objaabb( obj2 )

    local col = AABBAABB( min, max, min2, max2 ) and draw.red or draw.blue

    drawaabb( min2, max2, col )

    vec3set( obj2.pos, 0, 2 + 2 * math.cos( CT ), 0 )
    vec3set( lamp.pos, math.cos( CT ) * 17, math.sin( CT ) * 17, 0 )
end

callback( _LOOPCALLBACK, Loop )
