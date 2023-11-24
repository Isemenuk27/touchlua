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

    --ins( _OBJS, ent.id )

    class.active[ent.id] = nil
    ent = nil
end

_OBJS, _LIGHTS = {}, {}

local cos, sin, random, rad, pi = math.cos, math.sin, math.random, math.rad, math.pi

local function rand( a, b )
    return random( a * 100, b * 100 ) * .01
end

C_LIGHT = 2
C_POLY = 1
C_WORLD = 0

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
    end

    registerclass( C_LIGHT, lightbulb )
end
