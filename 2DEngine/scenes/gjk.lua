if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local cos, sin = math.cos, math.sin

local ox, oy = 500, 1000

local function GJK( o1, vtex1, o2, vtex2 )
    local l1, l2 = #vtex1, #vtex2

    local pointsset = {}
    local l = 1

    for i, q in ipairs( vtex1 ) do
        local p1 = vec2( q )
        vec2add( p1, o1 )

        for j, r in ipairs( vtex2 ) do
            local p2 = vec2( r )
            vec2add( p2, o2 )

            local p = vec2sub( vec2( p1 ), p2 )

            pointsset[l] = p
            l = l + 1
            draw.circle( ox + p[1], oy + p[2], 10, draw.green )
        end
    end

    return pointsset
end

local function orientation( p, q, r )
    local val = ( q[2] - p[2] ) * ( r[1] - q[1] ) - ( q[1] - p[1] ) * ( r[2] - q[2] )

    if ( val == 0 ) then return 0 end -- collinear
    return (val > 0) and 1 or 2 -- clock or counterclock wise
end

local function convexHull( points )
    local n = #points

    local hull = {}
    local lh = 1

    local l = 1

    for i = 1, n do
        if ( points[i][1] < points[l][1] ) then
            l = i
        end
    end

    local p, q = l, 0

    repeat
        hull[lh] = points[p]
        lh = lh + 1
        q = ( p % n ) + 1

        for i = 1, n do
            -- If i is more counterclockwise than current q, then
            if ( orientation( points[p], points[i], points[q] ) == 2 ) then
                q = i
            end
        end

        p = q
    until( p == l )  -- While we don't come to first point

    return hull
end

local function farthestPoint( vtx, dir )
    local max = math.mininteger
    local index = 0

    for i = 1, #vtx do
        local dot = vec2dot( vtx[i], dir )

        if ( dot > max ) then
            max = dot
            index = i
        end
    end

    return vtx[index]
end

local function drawrect( t )
    local pos = t.pos
    local v = t.vtex
    local c = t.col or draw.white

    draw.circle( pos, 10, c )

    for i = 1, #v do
        local x, y = pos[1] + v[i][1], pos[2] + v[i][2]
        draw.line( x, y,
        pos[1] + v[i%#v+1][1], pos[2] + v[i%#v+1][2], c )
    end
    -- draw.rect( pos[1] - hw, pos[2] - hh, pos[1] + hw, pos[2] + hh, t.col )
end

local rect1 = {
    pos = vec2( .3, .3 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 100 ),
        vec2( 100, -100 ),
        vec2( -100, -100 ),
    },
    col = draw.white
}

local rect2 = {
    pos = vec2( 700, 500 ),
    vtex = { }
}

do
    local sides = 3
    local step = math.pi * 2 / sides
    for i = 1, sides do
        local r = 80
        local x = math.cos( i * step ) * r
        local y = math.sin( i * step ) * r
        table.insert( rect2.vtex, vec2( x, y ) )
    end
end

local rect3 = {
    pos = vec2( 0, 0 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 100 ),
        vec2( 100, -100 ),
        vec2( -100, -100 ),
    },
    col = draw.green
}

local function Loop( CT, DT )
    vec2set( rect1.pos, cursor() )
    drawrect( rect1 )
    drawrect( rect2 )

    local pointsset = GJK( rect1.pos, rect1.vtex, rect2.pos, rect2.vtex )
    --[[
    local pointsset = {}

    for i in ipairs( rect2.vtex ) do
        local p1 = vec2( rect2.pos )
        vec2add( p1, rect2.vtex[i] )

        local p2 = vec2( farthestPoint( rect1.vtex, rect2.vtex[i] ) )
        vec2sub( p2, rect1.pos )

        local p = vec2add( vec2( p1 ), p2 )

        table.insert( pointsset, p )
        draw.circle( ox + p[1], oy + p[2], 10, draw.green )

        --[[for j in ipairs( rect1.vtex ) do
            local p2 = vec2( rect1.vtex[j] )
            vec2sub( p2, rect1.pos )

            local p = vec2add( vec2( p1 ), p2 )

            table.insert( pointsset, p )
            --draw.circle( ox + p[1], oy + p[2], 10, draw.green )
        end

end ]]

    local hull = convexHull( pointsset )

    local coll = true

    for i in ipairs( hull ) do
        local j = (i%#hull)+1
        local n = vec2normalto( hull[i], hull[j] )
        n = vec2perp( n )
        local dot = vec2dot( n, hull[i] )

        if ( dot < 0 ) then
            coll = false
            break
        end
    end

    for i in ipairs( hull ) do
        local x1, y1 = hull[i][1], hull[i][2]
        local j = (i%#hull)+1
        local x2, y2 = hull[j][1], hull[j][2]
        draw.line( ox + x1, oy + y1, ox + x2, oy + y2, coll and draw.red or draw.green )
    end

    do
        local p = farthestPoint( hull, vec2( cos( CT ) * 3, sin( CT ) * 3) )
        draw.circle( ox + p[1], oy + p[2], 10, draw.cyan )
    end

    draw.cross( ox, oy, 10 )
end

callback( _LOOPCALLBACK, Loop )
