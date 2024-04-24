local sqrt, atan, abs = math.sqrt, math.atan, math.abs
local cos, sin, tan = math.cos, math.sin, math.tan
local pi, hpi = math.pi, math.pi * .5

local TABLE, type = "table", type

local function istable( t )
    return type( t ) == TABLE
end

--Create
function vec3( nX, nY, nZ )
    if istable( nX ) then
        return vec3( vec3unpack( nX ) )
    end

    return { nX or 0, nY or nX or 0, nZ or nX or 0 }
end

--Unpack
function vec3unpack( vA )
    return vA[1], vA[2], vA[3]
end

--Set
function vec3setc( vA, nX, nY, nZ )
    vA[1], vA[2], vA[3] = nX or 0, nY or nX or 0, nZ or nX or 0
    return vA
end

function vec3setv( vA, vB )
    return vec3setc( vA, vB[1], vB[2], vB[3] )
end

function vec3set( vA, nX, nY, nZ )
    if ( istable( nX ) ) then
        return vec3setv( vA, nX )
    end
    return vec3setc( vA, nX, nY, nZ )
end

--Add
function vec3addc( vA, nX, nY, nZ )
    return vec3setc( vA, vA[1] + ( nX or 0 ), vA[2] + ( nY or nX or 0 ), vA[3] + ( nZ or nX or 0 ) )
end

function vec3addv( vA, vB )
    return vec3addc( vA, vB[1], vB[2], vB[3] )
end

function vec3add( vA, nX, nY, nZ )
    if ( istable( nX ) ) then
        return vec3addv( vA, nX )
    end
    return vec3addc( vA, nX, nY, nZ )
end

--Sub
function vec3subc( vA, nX, nY, nZ )
    return vec3setc( vA, vA[1] - ( nX or 0 ), vA[2] - ( nY or nX or 0 ), vA[3] - ( nZ or nX or 0 ) )
end

function vec3subv( vA, vB )
    return vec3subc( vA, vB[1], vB[2], vB[3] )
end

function vec3sub( vA, nX, nY, nZ )
    if ( istable( nX ) ) then
        return vec3subv( vA, nX )
    end
    return vec3subc( vA, nX, nY, nZ )
end

--Mul
function vec3mulc( vA, nX, nY, nZ )
    return vec3setc( vA, vA[1] * ( nX or 0 ), vA[2] * ( nY or nX or 0 ), vA[3] * ( nZ or nX or 0 ) )
end

function vec3mulv( vA, vB )
    return vec3mulc( vA, vB[1], vB[2], vB[3] )
end

function vec3mul( vA, nX, nY, nZ )
    if ( istable( nX ) ) then
        return vec3mulv( vA, nX )
    end
    return vec3mulc( vA, nX, nY, nZ )
end

--Div
function vec3divc( vA, nX, nY, nZ )
    return vec3setc( vA, vA[1] / ( nX or 0 ), vA[2] / ( nY or nX or 0 ), vA[3] / ( nZ or nX or 0 ) )
end

function vec3divv( vA, vB )
    return vec3divc( vA, vB[1], vB[2], vB[3] )
end

function vec3div( vA, nX, nY, nZ )
    if ( istable( nX ) ) then
        return vec3divv( vA, nX )
    end
    return vec3divc( vA, nX, nY, nZ )
end

--Lerps vector
function vec3lerp( nF, vStart, vEnd, vOut )
    vOut = vec3diff( vStart, vEnd, vOut or vec3() )
    vec3mul( vOut, nF )
    return vec3add( vOut, vStart )
end

--Reflects direction by normal
function vec3reflect( vDir, vNormal, vOut )
    local nF = -2 * vec3dot( vNormal, vDir )
    vOut = vec3set( vOut or vec3(), vNormal )
    vec3add( vOut, vDir )
    return vec3mul( vOut, nF )
end

--Writes difference ( B-A ) to vC or creates new one
function vec3diff( vA, vB, vC )
    return vec3set( vC or vec3(), vB[1] - vA[1], vB[2] - vA[2], vB[3] - vA[3] )
end

--Flips direction backwards
function vec3negate( vA )
    return vec3set( vA, -vA[1], -vA[2], -vA[3] )
end

--Normalizes vector
function vec3normalize( vA )
    return vec3mulc( vA, 1 / vec3mag( vA ) )
end

--Return normalized copy of other vector
function vec3normalized( vA )
    return vec3mulc( vec3( vA ), 1 / vec3mag( vA ) )
end

--Magnitude
function vec3mag( vA )
    return ( vA[1] * vA[1] + vA[2] * vA[2] + vA[3] * vA[3] ) ^ .5
end

--Magnitude squared
function vec3sqrmag( vA )
    return vA[1] * vA[1] + vA[2] * vA[2] + vA[3] * vA[3]
end

--Dot
function vec3dot( vA, vB )
    return vA[1] * vB[1] + vA[2] * vB[2] + vA[3] * vB[3]
end

--Cross
function vec3cross( vA, vB, vC )
    return vec3set( vC or vec3(),
    vA[2] * vB[3] - vA[3] * vB[2],
    vA[3] * vB[1] - vA[1] * vB[3],
    vA[1] * vB[2] - vA[2] * vB[1] )
end

--Converts Euler angles ( in radians ) to direction vector
function vec3fromEuler( vA, nP, nY, nR )
    return vec3set( vA or vec3(),
    -cos(nY) * sin(nP) * sin(nR) - sin(nY) * cos(nR),
    -sin(nY) * sin(nP) * sin(nR) + cos(nY) * cos(nR),
    cos(nP) * sin(nR) )
end

--Useful for print
local format, formatvector = string.format, "vec3( %f, %f, %f )"

function vec3tostring( v )
    return format( formatvector, v[1], v[2], v[3] )
end
