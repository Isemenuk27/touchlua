local abs, max, min = math.abs, math.max, math.min
local sqrt, ceil, floor = math.sqrt, math.ceil, math.floor

function math.Lerp( delta, from, to )
    if ( delta > 1 ) then return to end
    if ( delta < 0 ) then return from end
    return from + ( to - from ) * delta
end

function math.DistanceSqr( x1, y1, x2, y2 )
    local xd = x2 - x1
    local yd = y2 - y1
    return xd * xd + yd * yd
end

function math.Distance( x1, y1, x2, y2 )
    local xd = x2 - x1
    local yd = y2 - y1
    return sqrt( xd * xd + yd * yd )
end

function math.BinToInt( bin )
    return tonumber( bin, 2 )
end

local intbin = {
    ["0"] = "000", ["1"] = "001", ["2"] = "010", ["3"] = "011",
    ["4"] = "100", ["5"] = "101", ["6"] = "110", ["7"] = "111"
}

function math.IntToBin( int )
    local str = string.gsub( string.format( "%o", int ), "(.)", function ( d ) return intbin[ d ] end )
    return str
end

function math.Clamp( inval, minval, maxval )
    if (inval < minval) then return minval end
    if (inval > maxval) then return maxval end
    return inval
end

function math.Rand( low, high )
    return low + ( high - low ) * random()
end

function math.EaseInOut( fProgress, fEaseIn, fEaseOut )
    if ( fEaseIn == nil ) then fEaseIn = 0 end
    if ( fEaseOut == nil ) then fEaseOut = 1 end
    if ( fProgress == 0 or fProgress == 1 ) then return fProgress end
    local fSumEase = fEaseIn + fEaseOut
    if ( fSumEase == 0 ) then return fProgress end
    if ( fSumEase > 1 ) then
        fEaseIn = fEaseIn / fSumEase
        fEaseOut = fEaseOut / fSumEase
    end
    local fProgressCalc = 1 / ( 2 - fEaseIn - fEaseOut )
    if ( fProgress < fEaseIn ) then
        return ( ( fProgressCalc / fEaseIn ) * fProgress * fProgress )
    elseif ( fProgress < 1 - fEaseOut ) then
        return ( fProgressCalc * ( 2 * fProgress - fEaseIn ) )
    else
        fProgress = 1 - fProgress
        return ( 1 - ( fProgressCalc / fEaseOut ) * fProgress * fProgress )
    end
end

local function KNOT( i, tinc ) return ( i - 3 ) * tinc end

function math.calcBSplineN( i, k, t, tinc )
    if ( k == 1 ) then
    if ( ( KNOT( i, tinc ) <= t ) and ( t < KNOT( i + 1, tinc ) ) ) then return 1 else return 0 end
    else
        local ft = ( t - KNOT( i, tinc ) ) * math.calcBSplineN( i, k - 1, t, tinc )
        local fb = KNOT( i + k - 1, tinc ) - KNOT( i, tinc )

        local st = ( KNOT( i + k, tinc ) - t ) * math.calcBSplineN( i + 1, k - 1, t, tinc )
        local sb = KNOT( i + k, tinc ) - KNOT( i + 1, tinc )

        local first = 0
        local second = 0

        if ( fb > 0 ) then first = ft / fb end
        if ( sb > 0 ) then second = st / sb end
        return first + second
    end
end

function math.BSplinePoint( tDiff, tPoints, tMax )
    local Q = Vector( 0, 0, 0 )
    local tinc = tMax / ( #tPoints - 3 )
    tDiff = tDiff + tinc
    for idx, pt in pairs( tPoints ) do
        local n = math.calcBSplineN( idx, 4, tDiff, tinc )
        Q = Q + ( n * pt )
    end
    return Q
end

function math.Round( num, idp )
    local mult = 10 ^ ( idp or 0 )
    return floor( num * mult + 0.5 ) / mult
end

function math.Truncate( num, idp )
    local mult = 10 ^ ( idp or 0 )
    local FloorOrCeil = num < 0 and ceil or floor
    return FloorOrCeil( num * mult ) / mult
end

function math.Approach( cur, target, inc )
    inc = abs( inc )
    if ( cur < target ) then
        return min( cur + inc, target )
    elseif ( cur > target ) then
        return max( cur - inc, target )
    end

    return target
end

function math.NormalizeAngle( a )
    return ( a + 180 ) % 360 - 180
end

function math.AngleDifference( a, b )
    local diff = math.NormalizeAngle( a - b )
    if ( diff < 180 ) then return diff end
    return diff - 360
end

function math.ApproachAngle( cur, target, inc )
    local diff = math.AngleDifference( target, cur )
    return math.Approach( cur, cur + diff, inc )
end

function math.TimeFraction( Start, End, Current )
    return ( Current - Start ) / ( End - Start )
end

function math.Remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

-- Snaps the provided number to the nearest multiple
function math.SnapTo( num, multiple )
    return floor( num / multiple + 0.5 ) * multiple
end

function math.InRange( xmin, xmax, x )
    return (x > xmin) and (x < xmax)
end

function math.InBounds( xmin, ymin, xmax, ymax, x, y )
    return (x > xmin) and (x < xmax) and (y > ymin) and (y < ymax)
end

function math.InCircle(cx, cy, cr, x, y)
    local cx = cx - x
    local cy = cy - y
    return math.abs( (cx * cx) + (cy * cy) ) < cr * cr
end

return math
