if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("3DEngine/init")
end

local emiterpos = vec3( 0, 5, 0 )
local _PARTICLES = {}

local tCubeForm = loadModel( "cube.mdl" )

local function newParticle()
    local obj = createclass( C_POLY )
    obj:born()
    obj.form = table.Copy( tCubeForm )
    obj.scl = vec3( .1 )
    obj.ang = vec3( 0, 0, 0 )
    vec3set( obj.pos, emiterpos )
    vec3add( obj.pos, math.random( -1, 1 ), rand( -2, 2 ), math.random( -1, 1 ) )
    obj.lastpos = vec3( obj.pos )
    obj.solid = false
    obj.radius = .17
    obj.mass = .12
    obj.coef = .466
    obj.vel = vec3( rand( -1, 1 ), -.1, rand( -1, 1 ) )
    obj.acc = vec3( 0 )

    table.insert( _PARTICLES, obj )
end

for i = 1, 20 do
    newParticle()
end

local function reflect( inDirection, inNormal )
    local factor = -2 * vec3dot( inNormal, inDirection )
    return vec3( factor * inNormal[1] + inDirection[1],
    factor * inNormal[2] + inDirection[2],
    factor * inNormal[3] + inDirection[3])
end

local floor = createclass( C_POLY )
floor:born()
floor.form = loadModel( "plane.mdl" )
floor.scl = vec3( 2 )
floor.ang = vec3( math.pi * .4, 0, 0 )
floor.solid = true

local floor = createclass( C_POLY )
floor:born()
floor.form = loadModel( "plane.mdl" )
floor.scl = vec3( 3 )
floor.ang = vec3( math.pi * .6, 0, .2 )
floor.pos = vec3( 1, -1, -2 )
floor.solid = true

vec3set( GetCamPos(), 4, 2.850344 - 1.4, 5 )
vec3set( GetCamAng(), -0.51469, 2.424500, 0 )

local lamp = createclass( C_LIGHT )
lamp:born()
lamp:enable()
lamp.power = 10
lamp:setPos( vec3( 0, 2, 4 ) )
lamp.diffuse = vec3mul( vec3( 240, 187, 117 ), 1 / 255 )

local _ACC, _VEL, _DIR, _ADDACC, _DRAG = vec3(), vec3(), vec3(), vec3(), vec3()
local _TORQUE, _ANGDAMP, _ANGVEL = vec3(), vec3(), vec3()
local out = {}

local function Loop( CT, DT )
    for i, obj in pairs( _PARTICLES ) do
        if ( obj.pos[2] < -2 ) then
            removeclass( obj )
            newParticle()
            _PARTICLES[i] = nil
            obj = nil
            goto skipparticle
        end

        vec3set( _ACC, obj.acc )
        vec3set( _VEL, obj.vel )

        vec3set( _DIR, _VEL )
        vec3normalize( _DIR )

        --**************************
        --Gravity

        vec3set( _ADDACC, 0, -9.81 * obj.mass, 0 )

        --**************************
        -- Drag

        local v = vec3sqrmag( _VEL )
        vec3set( _DRAG, _DIR )

        local A = math.pi * ( obj.radius * obj.radius )
        local DragF = 1.225 * obj.coef * v * A * 0.5

        vec3mul( _DRAG, DragF )
        vec3sub( _ADDACC, _DRAG )

        --**************************
        -- Acceleration

        vec3div( _ADDACC, obj.mass )
        vec3add( _ACC, _ADDACC )
        vec3mul( _ACC, DT )

        vec3set( obj.acc, _ACC )

        --**************************
        -- Velocity

        vec3add( _VEL, _ACC )
        vec3set( obj.vel, _VEL )

        --**************************
        -- Position

        local spd = vec3mag( _VEL )

        vec3mul( _VEL, DT )
        vec3set( obj.lastpos, obj.pos )
        vec3add( obj.pos, _VEL )

        traceRay( obj.lastpos, _DIR, vec3mag( _VEL ), out )

        if ( out.hit ) then
            local newdir = reflect( _DIR, out.normal )
            vec3set( obj.pos, out.pos )
            vec3add( obj.pos, vec3mul( vec3( out.normal ), 0.01 ) )
            vec3set( obj.vel, newdir )
            vec3mul( obj.vel, spd )
        end

        ::skipparticle::
    end
end

callback( _LOOPCALLBACK, Loop )

local function sunedit( sun )
    local dif = vec3( 245, 255, 168 )
    local amb = vec3( 120, 126, 250 )

    sun:setColor( vec3mul( dif, 2 / 255 ), vec3mul( amb, 2 / 255 ) )
end

callback( "sunborn", sunedit )
