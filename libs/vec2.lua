local sqrt, atan, abs = math.sqrt, math.atan, math.abs
local cos, sin, tan = math.cos, math.sin, math.tan
local TABLE, type = "table", type
local _EPS = 0.0001
local function istable( t )
    return type( t ) == TABLE
end

function vec2( x, y )
    if ( istable( x ) ) then
        return { x[1], x[2] }
    end
    return { x or 0, y or x or 0 }
end

vec2zero = vec2( 0 )

function vec2approach( v1, v2, stepx, stepy )
    v1[1] = approach( v1[1], v2[1], stepx )
    v1[2] = approach( v1[2], v2[2], stepy or stepx )
end

function vec2lerp( v, v1, v2, fracx, fracy )
    v[1] = lerp( fracx, v1[1], v2[1] )
    v[2] = lerp( fracy or fracx, v1[2], v2[2] )
end

function vec2dot( v1, v2 )
    return v1[1] * v2[1] + v1[2] * v2[2]
end

function vec2atan( v1, v2 )
    if ( v2 ) then
        return atan( v2[2] - v1[2], v2[1] - v1[1] )
    end
    return atan( v1[2], v1[1] )
end

local _AB, _AC = vec2(), vec2()

function vec2distsqr( A, B )
    vec2set( _AB, B )
    vec2sub( _AB, A )
    return vec2sqrmag( _AB )
end

function vec2dist( A, B )
    vec2set( _AB, B )
    vec2sub( _AB, A )
    return vec2mag( _AB )
end

function vec2project( A, B, C, D )
    vec2set( _AB, B )
    vec2sub( _AB, A )
    vec2set( _AC, C )
    vec2sub( _AC, A )

    vec2set( D, _AB )
    vec2mul( D, vec2dot( _AB, _AC ) )
    vec2div( D, vec2dot( _AB, _AB ) )
    vec2add( D, A )
    return D
end

function vec2projected( A, B, C )
    vec2set( _AB, B )
    vec2sub( _AB, A )
    vec2set( _AC, C )
    vec2sub( _AC, A )

    local _AD = vec2()

    vec2set( _AD, _AB )
    vec2mul( _AD, vec2dot( _AB, _AC ) )
    vec2div( _AD, vec2dot( _AB, _AB ) )
    vec2add( _AD, A )
    return _AD
end

function vec2lineprojected( A, _AB, C )
    vec2set( _AC, C )
    vec2sub( _AC, A )

    local _AD = vec2()

    vec2set( _AD, _AB )
    local dot = vec2dot( _AB, _AC )
    vec2mul( _AD, dot )
    vec2div( _AD, vec2dot( _AB, _AB ) )
    vec2add( _AD, A )
    return _AD, dot
end

function vec2normalized( v )
    local vec = vec2( v )
    vec2normalize( vec )
    return vec
end

function vec2sqrmag( v )
    return ( v[1] * v[1] ) + ( v[2] * v[2] )
end

function vec2magnitude( v )
    return sqrt( vec2sqrmag( v ) + _EPS )
end

vec2mag = vec2magnitude

function vec2smaler( v, l )
    return v[1] < l[1] and v[2] < l[2]
end

function vec2bigger( v, l )
    return v[1] > l[1] and v[2] > l[2]
end

function vec2normalize( v )
    local l = vec2magnitude( v )
    local il = 1 / l
    v[1] = v[1] * il
    v[2] = v[2] * il
    return l
end

function vec2diff( a, b )
    local v = vec2( b[1] - a[1], b[2] - a[2] )
    return v
end

function vec2normalto( s, e )
    local v = vec2( e[1] - s[1], e[2] - s[2] )
    vec2normalize( v )
    return v
end

function vec2reflect( v, n )
    local dot = vec2dot( v, n )
    v[1] = v[1] - 2 * dot * n[1]
    v[2] = v[2] - 2 * dot * n[2]
end

function vec2reflected( v, n )
    local dot = vec2dot( v, n )
    return vec2( v[1] - 2 * dot * n[1], v[2] - 2 * dot * n[2] )
end

function vec2similar( v1, v2, EPS )
    local dx = v1[1] - v2[1]
    local dy = v1[1] - v2[1]
    return ( abs( dx ) <= ( ESP or 0 ) ) and ( abs( dy ) <= ( ESP or 0 ) )
end

function vec2getperp( v )
    return vec2( v[2], -v[1] )
end

function vec2setperp( t, v )
    t[1] = v[2]
    t[2] = -v[1]
    return t
end

local _tempperp = {}

function vec2perp( v )
    vec2set( _tempperp, v )
    return vec2setperp( v, _tempperp )
end

function vec2setx( v, x )
    v[1] = x
    return v
end

function vec2sety( v, y )
    v[1] = y
    return v
end

function vec2set( v, x, y )
    if ( istable( x ) ) then
        v[1] = x[1]
        v[2] = x[2]
        return v
    end

    v[1] = x
    v[2] = y
    return v
end

function vec2add( v, x, y )
    if ( istable( x ) ) then
        v[1] = v[1] + x[1]
        v[2] = v[2] + x[2]
        return v
    end

    v[1] = v[1] + x
    v[2] = v[2] + ( y or x )
    return v
end

function vec2sub( v, x, y )
    if ( istable( x ) ) then
        v[1] = v[1] - x[1]
        v[2] = v[2] - x[2]
        return v
    end

    v[1] = v[1] - x
    v[2] = v[2] - ( y or x )
    return v
end

function vec2div( v, x, y )
    if ( istable( x ) ) then
        v[1] = v[1] / x[1]
        v[2] = v[2] / x[2]
        return v
    end

    v[1] = v[1] / x
    v[2] = v[2] / ( y or x )
    return v
end

function vec2mul( v, x, y )
    if ( istable( x ) ) then
        v[1] = v[1] * x[1]
        v[2] = v[2] * x[2]
        return v
    end

    v[1] = v[1] * x
    v[2] = v[2] * ( y or x )
    return v
end

function vec2rad( v, a, d )
    v[1] = v[1] + cos( a ) * ( d or 1 )
    v[2] = v[2] + sin( a ) * ( d or 1 )
    return v
end

function vec2rotate( v, t )
    local a = v[1] * cos( t ) - v[2] * sin( t )
    local b = v[1] * sin( t ) + v[2] * cos( t )
    v[1] = a
    v[2] = b
    return v
end

local format, formatvector = string.format, "vec2( %f, %f )"
function vec2string( v )
    return format( formatvector, v[1], v[2] )
end

vec2tostring = vec2string

return vec2
