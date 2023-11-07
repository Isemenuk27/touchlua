assert( callback, "missing callback lib" )

local exec = exec
local mx, my, mh = 0, 0, false

function draw.touchbegan( t )
    exec( "touch.start", t )

    if ( t.id == 1 ) then
        mx, my = t.x, t.y
        mh = true
    end
end

function draw.touchmoved( t )
    exec( "touch.move", t )

    if ( t.id == 1 ) then
        mx, my = t.x, t.y
    end
end

function draw.touchended( t )
    exec( "touch.end", t )

    if ( t.id == 1 ) then
        mx, my = t.x, t.y
        mh = false
    end
end

function cursor()
    return mx, my
end

function cursordown()
    retu
rn mh
end
