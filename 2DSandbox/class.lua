if ( not Inited ) then require( "init" ) return end

local class = { list = {}, amn = 0, active = {} }

function registerclass( id, t )
    assert( not class.list[id] )

    class.list[id] = t
    class.amn = class.amn + 1
end

function createclass( id )
    assert( class.list[id] )
    local entid = #class.active + 1
    class.active[entid] = setmetatable( {}, class.list[id] )
    class.active[entid].id = entid
    return class.active[entid]
end

function removeclass( ent )
    if ( ent.remove ) then
        ent:remove()
    end
    class.active[ent.id] = nil
    ent = nil
end

local cos, sin, random, rad, pi = math.cos, math.sin, math.random, math.rad, math.pi

local function rand( a, b )
    return random( a * 100, b * 100 ) * .01
end

C_POLY = 1
C_WORLD = 0

do
    local poly = { }

    poly.__index = poly

    local form = {
        -1, -1,
        -1, 1,
        0, 1.5,
        1, 1,
        2, 0,
        1, -1
    }

    local s = ( math.pi * 2 ) / 16

    for i = 1, 16 do
        local x, y = math.cos( i * s ), math.sin( i * s )
        x = x + rand( -.02, .02 )
        y = y + rand( -.03, .03 )
        table.insert( form, x )
        table.insert( form, y )

        --form[i] = { x, y }
    end

    function poly:born()
        self.form = form
        self.rig = phys.rigid( form )
    end

    function poly:setPos( vec )
        vec2set( self.rig.pos, vec )
    end

    registerclass( C_POLY, poly )
end
