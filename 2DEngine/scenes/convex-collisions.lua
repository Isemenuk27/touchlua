if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local cos, sin = math.cos, math.sin

local function farthestPoint( vtx, dir )
    local max, index = math.mininteger, o

    for i = 1, #vtx do
        local dot = vec2dot( vtx[i], dir )

        if ( dot > max ) then
            max, index = dot, i
        end
    end

    return vtx[index]
end

local function farthestPointOposite( vtx, dir )
    local max, index = math.maxinteger, 0

    for i = 1, #vtx do
        local dot = vec2dot( vtx[i], dir )

        if ( dot < max ) then
            max, index = dot, i
        end
    end

    return vtx[index]
end

local function supportFunction( vtex1, vtex2, dir )
    return vec2sub( vec2( farthestPoint( vtex1, dir ) ), farthestPointOposite( vtex2, dir ) )
end

local ox, oy = 500, 1000

local function GJK( o1, vtex1, o2, vtex2 )
    local pointsset, l = {}, 1

    for i, q in ipairs( vtex1 ) do
        local p1 = vec2add( vec2( q ), o1 )

        for j, r in ipairs( vtex2 ) do
            local p2 = vec2add( vec2( r ), o2 )
            local p = vec2sub( vec2( p1 ), p2 )

            pointsset[l], l = p, l + 1
            --draw.circle( ox + p[1], oy + p[2], 10, draw.green )
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

local function drawpolygon( t )
    local pos = t.pos
    local v = t.vtex
    local c = t.col or draw.white

    draw.circle( pos, 10, c )

    for i = 1, #v do
        local x, y = pos[1] + v[i][1], pos[2] + v[i][2]
        local j = i%#v+1
        draw.line( x, y, pos[1] + v[j][1], pos[2] + v[j][2], c )
    end
end

local polygons = {}

local rect1 = {
    pos = vec2( .3, .3 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 100 ),
        vec2( 100, -100 ),
        vec2( -100, -100 ),
    },
    col = draw.green
}

table.insert( polygons, rect1 )

table.insert( polygons, {
    pos = vec2( 700, 500 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 0 ),
        vec2( -25, -100 )
    }
} )

table.insert( polygons, {
    pos = vec2( 300, 1200 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 100 ),
        vec2( 100, -100 ),
        vec2( -100, -100 ),
    }
} )

table.insert( polygons, {
    pos = vec2( 700, 1200 ),
    vtex = {
        vec2( -100, 100 ),
        vec2( 100, 100 ),
        vec2( 100, -100 ),
        vec2( -100, -100 ),
    }
} )

local function Loop( CT, DT )
    vec2set( rect1.pos, cursor() )

    for i, poly1 in ipairs( polygons ) do
        for j, poly2 in ipairs( polygons ) do
            if ( poly1 == poly2 ) then
                goto skiptest
            end

            local pointsset = GJK( poly1.pos, poly1.vtex, poly2.pos, poly2.vtex )
            local hull = convexHull( pointsset )

            local coll = true

            for i in ipairs( hull ) do
                local j = (i%#hull)+1
                local n = vec2diff( hull[i], hull[j] )
                n = vec2perp( n )
                local dot = vec2dot( n, hull[i] )

                if ( dot < 0 ) then
                    coll = false
                    break
                end
            end

            if ( coll ) then
                local t, tl = {}, 1

                for i in ipairs( hull ) do
                    local j = (i%#hull)+1
                    local d = vec2projected( hull[i], hull[j], vec2zero )
                    t[tl], tl = d, tl + 1
                    --draw.line( ox, oy, ox + d[1], oy + d[2], draw.pink )
                end

                local mindist, index = math.maxinteger, 1

                for i, d in ipairs( t ) do
                    local l = vec2sqrmag( d )
                    if ( l < mindist ) then
                        mindist = l
                        index = i
                    end
                end

                local d = t[index]
                --draw.line( ox, oy, ox + d[1], oy + d[2], draw.yellow )

                vec2add( poly2.pos, d )
            end

            ::skiptest::
        end
    end

    --[[for i in ipairs( hull ) do
        local x1, y1 = hull[i][1], hull[i][2]
        local j = (i%#hull)+1
        local x2, y2 = hull[j][1], hull[j][2]
        draw.line( ox + x1, oy + y1, ox + x2, oy + y2, coll and draw.red or draw.green )
    end]]

    --[[do
        local p = farthestPoint( hull, vec2( cos( CT ) * 3, sin( CT ) * 3) )
        draw.circle( ox + p[1], oy + p[2], 10, draw.cyan )
    end]]--

    draw.cross( ox, oy, 10 )

    for i, rect in ipairs( polygons ) do
        drawpolygon( rect )
    end
end

callback( _LOOPCALLBACK, Loop )
