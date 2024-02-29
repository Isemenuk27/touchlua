assert( callback, "missing callback lib" )

local exec = exec
local mx, my, mh = 0, 0, false
local dx, dy = 0, 0

function draw.touchbegan( t )
    exec( "touch.start", t )

    if ( t.id == 1 ) then
        dx, dy = 0, 0
        mx, my = t.x, t.y
        mh = true
    end
end

function draw.touchmoved( t )
    exec( "touch.move", t )

    if ( t.id == 1 ) then
        dx, dy = t.x - mx, t.y - my
        mx, my = t.x, t.y
    end
end

function draw.touchended( t )
    exec( "touch.end", t )

    if ( t.id == 1 ) then
        dx, dy = 0, 0
        mx, my = t.x, t.y
        mh = false
    end
end

function cursor()
    return mx, my
end

function cursorv()
    return vec2( mx, my )
end

function cursordown()
    return mh
end

function cursordeltax()
    return dx
end

function cursordeltay()
    return dy
end

function cursordelta()
    return vec2( dx, dy )
end

function cursorcleardelta()
    dx = 0
    dy = 0
end
