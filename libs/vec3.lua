local sqrt, atan, abs = math.sqrt, math.atan, math.abs
local cos, sin, tan = math.cos, math.sin, math.tan
local pi, hpi = math.pi, math.pi * .5
local function remap( value, inMin, inMax, outMin, outMax ) return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) ) end
local function approach( cur, target, inc ) inc = abs( inc ) if ( cur < target ) then return min( cur + inc, target ) elseif ( cur > target ) then return max( cur - inc, target ) end return target end
local function clamp( inval, minval, maxval ) if (inval < minval) then return minval end if (inval > maxval) then return maxval end return inval end
local function lerp( delta, from, to ) if ( delta > 1 ) then return to end if ( delta < 0 ) then return from end return from + ( to - from ) * delta end

local TABLE, type = "table", type

local function istable( t )
    return type( t ) == TABLE
end

do
    function vec3( x, y, z )
        if istable( x ) then
            return vec3( x[1], x[2], x[3] )
        end

        return { x or 0, y or x or 0, z or x or 0 }
    end

    function vec3mag( v )
        return sqrt( vec3dot( v, v ) )
    end

    function vec3magsqr( v )
        return vec3dot( v, v )
    end

    function vec3set( v, x, y, z )
        if ( istable( x ) ) then
            return vec3set( v, x[1], x[2], x[3] )
        end

        v[1] = x
        v[2] = y or x
        v[3] = z or x

        return v
    end

    function vec3mul( v, x, y, z )
        if ( istable( x ) ) then
            return vec3mul( v, x[1], x[2], x[3] )
        end
        v[1] = v[1] * x
        v[2] = v[2] * ( y or x )
        v[3] = v[3] * ( z or x )
        return v
    end

    function vec3div( v, x, y, z )
        if ( istable( x ) ) then
            return vec3div( v, x[1], x[2], x[3] )
        end
        v[1] = v[1] / x
        v[2] = v[2] / ( y or x )
        v[3] = v[3] / ( z or x )
        return v
    end

    function vec3add( v, x, y, z )
        if ( istable( x ) ) then
            return vec3add( v, x[1], x[2], x[3] )
        end
        v[1] = v[1] + x
        v[2] = v[2] + ( y or x )
        v[3] = v[3] + ( z or x )
        return v
    end

    function vec3sub( v, x, y, z )
        if ( istable( x ) ) then
            return vec3sub( v, x[1], x[2], x[3] )
        end
        v[1] = v[1] - x
        v[2] = v[2] - ( y or x )
        v[3] = v[3] - ( z or x )
        return v
    end
end

local vec3sub, vec3mul, vec3add, vec3div, vec3set, vec3mag, vec3magsqr, vec3 = vec3sub, vec3mul, vec3add, vec3div, vec3set, vec3mag, vec3magsqr, vec3

function vec3approach( v1, v2, stepx, stepy, stepz )
    v1[1] = approach( v1[1], v2[1], stepx )
    v1[2] = approach( v1[2], v2[2], stepy or stepx )
    v1[3] = approach( v1[3], v2[3], stepz or stepx )
end

function vec3lerp( v, v1, v2, fracx, fracy, fracz )
    v[1] = lerp( fracx, v1[1], v2[1] )
    v[2] = lerp( fracy or fracx, v1[2], v2[2] )
    v[3] = lerp( fracz or fracx, v1[3], v2[3] )
end

function vec3angdir( v, forward, right, up )
    local sr, sp, sy, cr, cp, cy

    sy, cy = sin( v[2] ), cos( v[2] )
    sp, cp = sin( v[1] ), cos( v[1] )
    sr, cr = sin( v[3] ), cos( v[3] )

    if ( forward ) then
        vec3set( forward, cp*sy, -sp, cp*cy )
    end

    if ( right ) then
        vec3set( right, sr*sp*cy-cr*sy, sr*cp, sr*sp*sy+cr*cy )
    end

    if ( up ) then
        vec3set( up, (cr*sp*cy+-sr*-sy), cr*cp, (cr*sp*sy+-sr*cy) )
    end
end

function vec3angf( a, v )
    if ( not v ) then
        v = vec3()
    end

    local sp, cp, sy, cy, sr, cr
    sp, cp = sin( a[1] ), cos( a[1] )
    sy, cy = sin( a[2] ), cos( a[2] )
    sr, cr = sin( a[3] ), cos( a[3] )

    vec3set( v, sp, cy * cp, sy * cp )
end

function vec3angdirr( a, v )
    local sp, sy, cp, cy
    local yaw = a[2] + hpi

    sy, cy = sin( yaw ), cos( yaw )
    sp, cp = 0, 1 --sin( a[1] ), cos( a[1] )

    vec3set( v, cp*sy, -sp, cp*cy )
end

function vec3toang( v, o )
    o[1] = math.atan(v[2], v[3])
    o[2] = math.atan(v[1], v[3])
    o[3] = math.atan(v[2], v[1])
    return o
end

function vec3diff( v1, v2, v3 )
    local dx = v2[1] - v1[1]
    local dy = v2[2] - v1[2]
    local dz = v2[3] - v1[3]

    if ( v3 ) then
        v3[1] = dx
        v3[2] = dy
        v3[3] = dz
    end

    return dx, dy, dz
end

local __DistDiffVec = vec3()

function vec3dist( v1, v2 )
    vec3diff( v1, v2, __DistDiffVec )
    return vec3mag( __DistDiffVec )
end

function vec3distsqr( v1, v2 )
    vec3diff( v1, v2, __DistDiffVec )
    return vec3magsqr( __DistDiffVec )
end

function vec3dirto( v1, v2 )
    vec3diff( v1, v2, __DistDiffVec )
    return vec3normal( __DistDiffVec )
end

function vec3diffto( v1, v2 )
    vec3diff( v1, v2, __DistDiffVec )
    return __DistDiffVec
end

do
    local _A, _B, N = vec3(), vec3(), vec3()

    function vec3normal( A, B, C, N )
        vec3diff( A, B, _A )
        vec3diff( A, C, _B )

        vec3cross( _A, _B, N )
        vec3normalize( N )
    end
end

function vec3normalize( v )
    local l = vec3mag( v )
    local il = 1 / l
    vec3mul( v, il )
    return l
end

function vec3getnormal( v1 )
    local v = vec3( v1 )
    local l = vec3mag( v )
    local il = 1 / l
    vec3mul( v, il )
    return l
end

function vec3inverse( v )
    v[1] = -v[1]
    v[2] = -v[2]
    v[3] = -v[3]
    return v
end

vec3negate = vec3inverse

function vec3dot( v1, v2 )
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

function vec3cross( v1, v2, v3 )
    if ( not v3 ) then
        v3 = vec3()
    end
    v3[1] = v1[2] * v2[3] - v1[3] * v2[2]
    v3[2] = v1[3] * v2[1] - v1[1] * v2[3]
    v3[3] = v1[1] * v2[2] - v1[2] * v2[1]
    return v3
end

local format, formatvector = string.format, "vec3( %f, %f, %f )"
function vec3tostring( v )
    return format( formatvector, v[1], v[2], v[3] )
end

