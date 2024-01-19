if ( not Inited ) then require( "init" ) return end

phys = {
    gravity = vec2( 0, 9.81 ),
    airdensity = 1.225,
    objectbuffer = {},
    objbufferlen = 0,
    debugcol = { .7, .7, .7, 1 },
}

function phys.new( form )
    local pobj = {
        pos = vec2(),
        ang = 0,
        vel = vec2(),
        scl = vec2(1),
        acc = vec2(),
        vtex = form,
        vtex_t = {},
        frozen = false,
        elasticity = .5,
        coef = 1,
        mass = 10,
        radius = phys.maxradius( form )
    }

    for i = 1, #pobj.vtex do
        pobj.vtex_t[i] = vec2()
    end

    phys.objbufferlen = phys.objbufferlen + 1
    phys.objectbuffer[phys.objbufferlen] = pobj

    return pobj
end

function phys.applyforce( pobj, vec )
    vec2add( pobj.vel, vec )
end

function phys.freeze( pobj, state )
    pobj.frozen = state
    if ( pobj.frozen ) then
        vec2set( pobj.vel, 0, 0 )
    end
end

function phys.remove( pobj )
    for i = 1, phys.objbufferlen do
        local o = phys.objectbuffer[i]
        if ( pobj == o ) then goto physremoveskip end
        phys.objbufferlen = phys.objbufferlen - 1
        table.remove( phys.objectbuffer, i )
        do return true end
        ::physremoveskip::
    end
    return false
end

function phys.maxradius( vtex ) --Return furthest point to center
    local max, index = math.mininteger, 1
    for i, p in ipairs( vtex ) do
        local d = vec2sqrmag( p )
        if ( d > max ) then
            max, index = d, i
        end
    end
    return max, vtex[index] -- number, vec2
end

function phys.minradius( vtex ) --Return closest point to center
    local min, index = math.maxinteger, 1
    for i, p in ipairs( vtex ) do
        local d = vec2sqrmag( p )
        if ( d > min ) then
            min, index = d, i
        end
    end
    return min, vtex[index] -- number, vec2
end

function phys.furthestpoint( vtex, dir ) -- Return furthest point in direction
    local max, index = math.mininteger, 1

    for i, p in ipairs( vtex ) do
        local dot = vec2dot( p, dir )

        if ( dot > max ) then
            max, index = dot, i
        end
    end

    return vtx[index], max -- vec2, number
end

function phys.furthestpointOposite( vtex, dir ) -- Same as furthestpoint( ..., -dir )
    local min, index = math.maxinteger, 1

    for i, p in ipairs( vtex ) do
        local dot = vec2dot( p, dir )

        if ( dot < min ) then
            min, index = dot, i
        end
    end

    return vtx[index], min -- vec2, number
end

function phys.minkowskiSum( o1, vtex1, o2, vtex2 )
    local pointsset, l = {}, 1

    for i, q in ipairs( vtex1 ) do
        local p1 = vec2add( vec2( q ), o1 )

        for j, r in ipairs( vtex2 ) do
            local p2 = vec2add( vec2( r ), o2 )
            local p = vec2sub( vec2( p1 ), p2 )

            pointsset[l], l = p, l + 1
        end
    end

    return pointsset
end

local _drawmat = mat3()

function phys.drawform( pobj )
    mat3identity( _drawmat )
    mat3setTr( _drawmat, vec2unpack( pobj.pos ) )
    mat3rot( _drawmat, pobj.ang )
    mat3mul( mat3setSc( mat3(), vec2unpack( pobj.scl ) ), _drawmat, _drawmat )

    draw.pushmatrix( _drawmat )
    local l = #pobj.vtex
    for i = 1, l do
        local j = (i%l)+1
        draw.line( pobj.vtex[i], pobj.vtex[j], phys.debugcol )
    end
    draw.line( 0, 0, 0, 1, draw.blue )
    --draw.text( vec2tostring( pobj.vel ), 0, 0 )
    draw.popmatrix()

    local a = vec2( pobj.vel )
    vec2mul( a, .5 )
    vec2add( a, pobj.pos )
    draw.line( pobj.pos, a, draw.pink )

end

function phys.orientation( p, q, r )
    local val = ( q[2] - p[2] ) * ( r[1] - q[1] ) - ( q[1] - p[1] ) * ( r[2] - q[2] )
    if ( val == 0 ) then return 0 end
    return (val > 0) and 1 or 2
end

function phys.convexHull( points )
    local hull, lh, l, n = {}, 1, 1, #points

    for i = 1, n do
        if ( points[i][1] < points[l][1] ) then
            l = i
        end
    end

    local p, q = l, 0

    repeat
        hull[lh] = points[p]
        lh, q = lh + 1, ( p % n ) + 1

        for i = 1, n do
            if ( phys.orientation( points[p], points[i], points[q] ) == 2 ) then
                q = i
            end
        end

        p = q
    until( p == l )

    return hull
end

function phys.solve( pobj1, pobj2, n )
    local vd = vec2sub( vec2( pobj2.vel ), pobj1.vel )
    local e = .8
    local j = -( 1 - e ) * vec2dot( vd, n )
    j = j / ( ( 1 / pobj1.mass ) + ( 1 / pobj2.mass ) )
    vec2sub( pobj1.vel, vec2mul( vec2( n ), j / pobj1.mass ) )
    vec2add( pobj2.vel, vec2mul( vec2( n ), j / pobj2.mass ) )
end

local _ACC, _VEL, _DIR, _ADDACC, _DRAG = vec2(), vec2(), vec2(), vec2(), vec2()

function phys.bodysim( poly1, CT, DT )
    for j = 1, phys.objbufferlen do
        local poly2 = phys.objectbuffer[j]
        if ( poly1 == poly2 ) then
            goto skiptest
        end

        local pointsset = phys.minkowskiSum( poly1.pos, poly1.vtex_t, poly2.pos, poly2.vtex_t )
        local hull = phys.convexHull( pointsset )

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
            --local n, depth = vec2normalized( d )
            --local a = vec2mul( vec2( n ), depth * .5 )

            vec2sub( poly1.pos, d )
            --vec2add( poly2.pos, a )

            --phys.solve( poly1, poly2, vec2normalized( d ) )

            local v = vec2reflected( poly1.vel, vec2normalized( d ) )
            vec2set( poly1.vel, v )
        end

        ::skiptest::
    end
end

function phys.motionsim( obj, CT, DT )
    vec2set( _ACC, obj.acc )
    vec2set( _VEL, obj.vel )

    vec2set( _DIR, _VEL )
    vec2normalize( _DIR )

    --************************************
    -- Gravity

    vec2set( _ADDACC, obj.gravity or phys.gravity )
    vec2mul( _ADDACC, obj.mass )

    --************************************
    -- Drag

    local v = vec2sqrmag( _VEL )

    vec2set( _DRAG, _DIR )

    local Area = math.pi * ( obj.radius * obj.radius ) * vec2mag( obj.scl )
    local DragF = phys.airdensity * obj.coef * v * Area * .5
    vec2mul( _DRAG, DragF )
    vec2sub( _ADDACC, _DRAG )

    --************************************
    -- Apply Acceleration

    vec2mul( _ADDACC, 1 / obj.mass )
    vec2add( _ACC, _ADDACC )
    vec2mul( _ACC, DT )

    --************************************
    -- Apply Velocity

    vec2add( _VEL, _ACC )
    vec2set( obj.vel, _VEL )

    vec2set( obj.acc, _ACC )

    --************************************
    -- Apply Position

    vec2mul( _VEL, DT )
    vec2add( obj.pos, _VEL )
end

local _trsfmat, _sclmat = mat3(), mat3()

function phys.pretransform( pobj, CT, DT )
    mat3identity( _trsfmat )
    --mat3setTr( _trsfmat, vec2unpack( pobj.scl ) )
    mat3rot( _trsfmat, pobj.ang )
    mat3setSc( _sclmat, pobj.scl[1], pobj.scl[2] )
    mat3mul( _sclmat, _trsfmat, _trsfmat )

    for i = 1, #pobj.vtex do
        local x, y = mat3mulxy( _trsfmat, pobj.vtex[i][1], pobj.vtex[i][2] )
        vec2set( pobj.vtex_t[i], x, y )
    end
end

function phys.tick( CT, DT )
    for i = 1, phys.objbufferlen do
        local pobj = phys.objectbuffer[i]
        phys.pretransform( pobj, CT, DT )
    end

    for i = 1, phys.objbufferlen do
        local pobj = phys.objectbuffer[i]

        if ( pobj.frozen == false ) then
            phys.motionsim( pobj, CT, DT )
        end

        phys.bodysim( pobj, CT, DT )

        phys.drawform( pobj )
    end
end
