if ( not Inited ) then require( "init" ) return end

local vec3, vec3sub, vec3dot = vec3, vec3sub, vec3dot
local edge1, edge2, tvec, pvec, qvec = vec3(), vec3(), vec3(), vec3(), vec3()
local min, max = math.min, math.max
local EPSILON = 0.0001

local function ray_tri( orig, dir, vert )
    local u, v, t

    --find vectors for two edges sharing vert0
    vec3sub( vec3set( edge1, vert[2] ), vert[1] )
    vec3sub( vec3set( edge2, vert[3] ), vert[1] )

    --begin calculating determinant - also used to calculate U parameter
    vec3cross( dir, edge2, pvec )

    --if determinant is near zero, ray lies in plane of triangle
    local det = vec3dot( edge1, pvec )

    if ( det > EPSILON ) then
        --calculate distance from vert0 to ray origin
        vec3sub( vec3set( tvec, orig ), vert[1] )

        --calculate U parameter and test bounds
        u = vec3dot( tvec, pvec )

        if ( u < 0 or u > det ) then
            return false
        end

        --prepare to test V parameter
        vec3cross( tvec, edge1, qvec )

        --calculate V parameter and test bounds
        v = vec3dot( dir, qvec )

        if ( v < 0 or u + v > det ) then
            return false
        end
    elseif ( det < -EPSILON ) then
        --calculate distance from vert0 to ray origin
        vec3sub( vec3set( tvec, orig ), vert[1] )

        --calculate U parameter and test bounds
        u = vec3dot( tvec, pvec )

        if ( u > 0 or u < det ) then
            return false
        end

        -- prepare to test V parameter
        vec3cross( tvec, edge1, qvec )

        --calculate V parameter and test bounds
        v = vec3dot( dir, qvec )

        if ( v > 0 or u + v < det ) then
            return false
        end
    else
        return false
    end --ray is parallell to the plane of the triangle

    local inv_det = 1 / det

    --calculate t, ray intersects triangle
    t = vec3dot( edge2, qvec ) * inv_det
    u = u * inv_det
    v = v * inv_det

    return true, t, u, v
end

function AABBAABB( min1, max1, min2, max2 )
    return
    ( min1[1] <= max2[1] and max1[1] >= min2[1] ) and
    ( min1[2] <= max2[2] and max1[2] >= min2[2] ) and
    ( min1[3] <= max2[3] and max1[3] >= min2[3] )
end

local _HitPoints = {}

local insert = table.insert

local topoint, closestpoint = vec3(), vec3()

local function backfacecull( p, d, face )
    local diff = vec3sub( vec3( face.tr.og ), p )
    local dot = vec3dot( diff, face.tr.nr )

    --local x, y = vec3toscreen( face.tr.og )
    --draw.fillrect( x - 5, y - 5, x + 5, y +5, draw.red )
    --draw.text( dot, x ,y, draw.white )

    return dot > 0
end

local function sphereculling( p, d, maxdist, face )
    local verts = face.tformed
    local diff = vec3mul( vec3( d ), maxdist )
    local tricenter = face.tr.og

    local r = -1

    for i = 1, 3 do
        local nr = vec3distsqr( verts[i], tricenter )
        if ( nr > r ) then
            r = nr
        end
    end

    vec3set( topoint, tricenter )
    vec3sub( topoint, p )

    local t = vec3dot( topoint, diff ) / vec3sqrmag( diff )

    --if ( t > 0 and t < 1 ) then
    vec3set( closestpoint, diff )
    vec3mul( closestpoint, t )
    vec3add( closestpoint, p )
    --end

    return vec3distsqr( closestpoint, tricenter ) < r
end

local function testmesh( obj, p, d, maxdist )
    for faceid = 1, #obj.form do
        local face = obj.form[faceid]
        local t_verts = face.tformed

        local cull = backfacecull( p, d, face )
        --cull = cull or sphereculling( p, d, maxdist, face )

        if ( cull ) then
            goto skipfacetrace
        end

        local hit, t, u, v = ray_tri( p, d, t_verts )

        if ( hit and t > 0 and t <= maxdist ) then
            local tb = {
                t, u, v, face
            }

            insert( _HitPoints, tb )
        end

        ::skipfacetrace::
    end
end

_Result = vec3()

local function RayAABB( o, n, lb, rt )
    local dx = 1 / n[1]
    local dy = 1 / n[2]
    local dz = 1 / n[3]

    local t1 = ( lb[1] - o[1] ) * dx
    local t2 = ( rt[1] - o[1] ) * dx
    local t3 = ( lb[2] - o[2] ) * dy
    local t4 = ( rt[2] - o[2] ) * dy
    local t5 = ( lb[3] - o[3] ) * dz
    local t6 = ( rt[3] - o[3] ) * dz

    local tmin = max( max( min( t1, t2 ), min( t3, t4 ) ), min( t5, t6 ) )
    local tmax = min( min( max( t1, t2 ), max( t3, t4 ) ), max( t5, t6 ) )

    if ( tmax < 0 ) then
        return false
    end

    if ( tmin > tmax ) then
        return false
    end

    return true
end

function traceRay( p, d, dist, out )
    local rayEnd = vec3add( vec3mul( vec3( d ), dist ), p )
    local raymin, raymax = vec3bbox( p, rayEnd )

    _HitPoints = {}

    local r, t, u, v

    for _, obj in ipairs( _OBJS ) do
        if ( not obj.solid ) then
            goto skiprayobj
        end

        local mn, mx = objaabb( obj )

        if ( not AABBAABB( raymin, raymax, mn, mx ) ) then
            goto skiprayobj
        end

        if ( not RayAABB( p, d, mn, mx ) ) then
            goto skiprayobj
        end

        testmesh( obj, p, d, dist )

        ::skiprayobj::
    end

    local closest
    local num = #_HitPoints

    if ( num == 0 ) then
        out.hit = false
        vec3set( _Result, d )
        vec3mul( _Result, dist )
        vec3add( _Result, p )
        out.pos = _Result
        out.dist = dist
        return false
    elseif( num == 1 ) then
        closest = 1
    else
        closest = nil
        local closestt = math.huge

        for i = 1, num do
            local tt = _HitPoints[i][1]

            if ( tt < closestt ) then
                closestt = tt
                closest = i
            end
        end
    end

    vec3set( _Result, d )
    vec3mul( _Result, _HitPoints[closest][1] )
    vec3add( _Result, p )

    out.hit = true
    out.pos = _Result
    out.u = _HitPoints[closest][2]
    out.v = _HitPoints[closest][3]

    local face = _HitPoints[closest][4]
    local verts = face.tformed

    if ( not out.normal ) then
        out.normal = vec3()
    end

    vec3normal( verts[1], verts[2], verts[3], out.normal )

    out.dist = _HitPoints[closest][1]

    return true
end
