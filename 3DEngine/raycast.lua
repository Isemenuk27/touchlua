if ( not Inited ) then require( "init" ) return end

local vec3, vec3sub, vec3dot = vec3, vec3sub, vec3dot
local edge1, edge2, tvec, pvec, qvec = vec3(), vec3(), vec3(), vec3(), vec3()

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

local _HitPoints = {}

local function testmesh( obj, p, d, maxdist )
    for faceid = 1, #obj.form do
        local face = obj.form[faceid]
        local t_verts = face.tformed
        local hit, t, u, v = ray_tri( p, d, t_verts )

        if ( hit and t > 0 and t <= maxdist ) then
            local tb = {
                t, u, v, face
            }

            table.insert( _HitPoints, tb )
        end
    end
end

_Result = vec3()

function traceRay( p, d, dist, out )
    _HitPoints = {}

    local r, t, u, v

    for _, obj in ipairs( _OBJS ) do
        if ( obj.solid ) then
            testmesh( obj, p, d, dist )
        end
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
