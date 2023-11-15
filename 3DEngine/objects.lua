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

    ins( _OBJS, class.active[entid] )

    return class.active[entid]
end

function removeclass( ent )
    if ( ent.remove ) then
        ent:remove()
    end

    ins( _OBJS, ent.id )

    class.active[ent.id] = nil
    ent = nil
end

_OBJS = {}

local cos, sin, random, rad, pi = math.cos, math.sin, math.random, math.rad, math.pi

local function rand( a, b )
    return random( a * 100, b * 100 ) * .01
end

C_POLY = 1
C_WORLD = 0

do
    local poly = { }

    poly.__index = poly

    function poly:born()
        self.pos = vec3()
        self.ang = vec3()
        self.scl = vec3( 1 )
    end

    function poly:setPos( vec )
        vec3set( self.pos, vec )
    end

    registerclass( C_POLY, poly )
end
