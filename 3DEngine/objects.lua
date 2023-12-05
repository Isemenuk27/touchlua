if ( not Inited ) then require( "init" ) return end

local class = { list = {}, amn = 0, active = {} }
local ins, del = table.insert, table.remove
function registerclass( id, t )
    assert( not class.list[id] )

    class.list[id] = t
    class.amn = class.amn + 1
end

function createclass( id )
    assert( class.list[id] )
    local entid = #_OBJS + 1
    class.active[entid] = setmetatable( {}, class.list[id] )
    class.active[entid].id = entid

    return class.active[entid]
end

function removeclass( ent )
    if ( ent.remove ) then
        ent:remove()
    end

    table.RemoveByValue( _OBJS, ent )

    class.active[ent.id] = nil
    ent = nil
end

_OBJS, _LIGHTS, _PLAYERS = {}, {}, {}

local cos, sin, random, rad, pi = math.cos, math.sin, math.random, math.rad, math.pi

local function rand( a, b )
    return random( a * 100, b * 100 ) * .01
end

C_PLAYER = 3
C_LIGHT = 2
C_POLY = 1
C_WORLD = 0

do
    local ply = {}

    ply.__index = ply

    function ply:born()
        ins( _PLAYERS, self )

        self.acc = vec3()
        self.vel = vec3(0, 9.81, 0)
        self.pos = vec3( 0, 1.4, 0 )
        self.ang = vec3()
        self.scl = vec3( 1 )

        self.mass = 4
        self.radius = 1
        self.coef = 0.466

        self.noclip = not false
    end

    local _FORWARD, _RIGHT = vec3(), vec3()
    local t_trace = {}
    local _ADDACC, _ACC, _VEL, _DRAG, _DIR = vec3(), vec3(), vec3(), vec3(), vec3()
    local down = vec3( 0, -1, 0 )

    local b_IsOnGroundLast

    function ply:move( CT, DT )
        local DesiredDir2D = Joystick()

        if ( not self.noclip ) then
            traceRay( GetCamPos(), down, 1, t_trace )
            local b_IsOnGround = t_trace.hit

            --************************************


            --if ( b_IsOnGroundLast ~= b_IsOnGround ) then
            --    vec3set( _ACC, 0, 0, 0 )
            --    vec3set( _VEL, 0, 0, 0 )
            --else
            vec3set( _ACC, self.acc )
            vec3set( _VEL, self.vel )
            --end

            --vec3set( _ADDACC, vector_origin )

            vec3set( _DIR, _VEL )
            vec3normalize( _DIR )

            --**************************
            --Gravity

            vec3set( _ADDACC, 0, b_IsOnGround and 0 or ( -9.81 * self.mass ), 0 )

            if ( not b_IsOnGround ) then
                --vec3add( _ADDACC, 0, 9.81 * self.mass, 0 )
            else
                if ( IsKeyDown( IN_JUMP ) ) then
                    vec3add( _ADDACC, 0, self.mass * 9.81, 0 )
                end
            end

            --**************************
            -- Drag

            local v = vec3magsqr( _VEL )
            vec3set( _DRAG, _DIR )

            local A = pi * ( self.radius * self.radius )
            local DragF = 1.225 * self.coef * v * A * 0.5

            vec3mul( _DRAG, DragF )
            vec3sub( _ADDACC, _DRAG )

            --**************************
            -- Acceleration

            vec3div( _ADDACC, self.mass )
            vec3add( _ACC, _ADDACC )
            vec3mul( _ACC, DT )

            vec3set( self.acc, _ACC )

            --**************************
            -- Velocity

            vec3add( _VEL, _ACC )
            vec3set( self.vel, _VEL )

            --**************************
            -- Position

            vec3mul( _VEL, DT )
            vec3add( self.pos, _VEL )

        else
            if ( IsKeyDown( IN_JUMP ) ) then
                vec3add( self.pos, 0, DT, 0 )
            end
            if ( IsKeyDown( IN_DUCK ) ) then
                vec3sub( self.pos, 0, DT, 0 )
            end
        end

        if ( vec2sqrmag( DesiredDir2D ) > 0 ) then
            if ( self.noclip ) then
                vec3set( _FORWARD, GetCamDir() )
                vec3set( _RIGHT, CamRight() )
                vec3mul( _FORWARD, DesiredDir2D[2] )
                vec3mul( _RIGHT, DesiredDir2D[1] * ( CamLefthanded() and -1 or 1 ) )

                local _OFFSET = vec3add( _FORWARD, _RIGHT )

                vec3normalize( _OFFSET )

                vec3mul( _OFFSET, DT )
                vec3mul( _OFFSET, CamMoveScale() )

                vec3add( self.pos, _OFFSET )
            else
                vec3set( _FORWARD, GetCamDir() )
                _FORWARD[2] = 0
                vec3set( _RIGHT, CamRight() )
                _RIGHT[2] = 0
                vec3mul( _FORWARD, DesiredDir2D[2] )
                vec3mul( _RIGHT, DesiredDir2D[1] * ( CamLefthanded() and -1 or 1 ) )

                local _OFFSET = vec3add( _FORWARD, _RIGHT )

                vec3normalize( _OFFSET )

                vec3mul( _OFFSET, FrameTime )
                vec3mul( _OFFSET, CamMoveScale() )

                vec3add( self.pos, _OFFSET )
            end
        end

        vec3add( vec3set( GetCamPos(), self.pos ), 0, 1.4, 0 )
    end

    registerclass( C_PLAYER, ply )
end

do
    local poly = { }

    poly.__index = poly

    function poly:born()
        ins( _OBJS, self )

        self.pos = vec3()
        self.ang = vec3()
        self.scl = vec3( 1 )
    end

    function poly:setPos( vec )
        vec3set( self.pos, vec )
    end

    registerclass( C_POLY, poly )
end

do
    local lightbulb = {}

    lightbulb.__index = lightbulb

    function lightbulb:born()
        self.pos = vec3()
        self.dir = vec3()
        self.power = 0
        self.diffuse = vec3(1)
        self.ambient = vec3(0)
        self.diff = vec3(1)
        self.maxradius = 600
    end

    function lightbulb:enable()
        ins( _LIGHTS, self )
    end

    function lightbulb:setColor( dif, amb )
        vec3set( self.diffuse, dif )
        vec3set( self.ambient, amb )

        vec3set( self.diff, dif )
        vec3sub( self.diff, amb )
    end

    function lightbulb:setPos( vec )
        vec3set( self.pos, vec )
    end

    function lightbulb:setDir( vec )
        vec3set( self.dir, vec )
        vec3normalize( self.dir )
    end

    registerclass( C_LIGHT, lightbulb )
end
