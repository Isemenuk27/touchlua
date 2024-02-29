local max, min, floor, ceil, abs, sqrt = math.max, math.min, math.floor, math.ceil, math.abs, math.sqrt
local pi, pi2 = math.pi, math.pi * 2
local random = math.random
math.tau = math.pi * 2

function distd( dx, dy )
    return sqrt( dx * dx + dy * dy )
end

function rand( low, high )
    return low + ( high - low ) * random()
end

function clamp01( x )
    if ( istable( x ) ) then
        x[1] = clamp( x[1], 0, 1 )
        x[2] = clamp( x[2], 0, 1 )
        x[3] = clamp( x[3], 0, 1 )
        return x
    end
    return clamp( x, 0, 1 )
end

function dist( x1, y1, x2, y2 )
    return distd( x2 - x1, y2 - y1 )
end

function sign( i )
    return ( ( i > 0 ) and 1 ) or ( ( i < 0 ) and -1 ) or 0
end

function clamp( i, a, b )
    if ( i > b ) then return b end
    if ( i < a ) then return a end
    return i
end

function isnan( a )
    return a ~= a
end

function round( num, idp )
    local mult = 10 ^ ( idp or 0 )
    return floor( num * mult + 0.5 ) / mult
end

function truncate( num, idp )
    local mult = 10 ^ ( idp or 0 )
    local FloorOrCeil = num < 0 and ceil or floor

    return FloorOrCeil( num * mult ) / mult
end

function approach( cur, target, inc )
    inc = abs( inc )

    if ( cur < target ) then
        return min( cur + inc, target )
    elseif ( cur > target ) then
        return max( cur - inc, target )
    end

    return target
end

function normalizeAngle( a )
    return ( a + 180 ) % 360 - 180
end

function angleDifference( a, b )
    local diff = normalizeAngle( a - b )
    if ( diff < 180 ) then return diff end
    return diff - 360
end

function approachAngle( cur, target, inc )
    local diff = angleDifference( target, cur )

    return approach( cur, cur + diff, inc )
end

function normalizeRadian( a )
    return ( a + pi ) % pi2 - pi
end

function radianDifference( a, b )
    local diff = normalizeRadian( a - b )
    if ( diff < pi ) then return diff end
    return diff - pi2
end

function approachRadian( cur, target, inc )
    local diff = radianDifference( target, cur )
    return approach( cur, cur + diff, inc )
end

function remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

function fraction( Start, End, Current )
    return ( Current - Start ) / ( End - Start )
end

function lerp( delta, from, to )
    if ( delta > 1 ) then
        return to
    end
    if ( delta < 0 ) then
        return from
    end
    return from + ( to - from ) * delta
end
