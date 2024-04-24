local vec3 = vec3
local vec3diff = vec3diff
local vec3add = vec3add
local vec3set = vec3set
local vec3mul = vec3mul
local vec3dot = vec3dot

local vDiffAB, vDiffBA = vec3(), vec3()
local vDiffAC, vDiffCA = vec3(), vec3()

local function sign( x )
    return ( x > 0 and 1 ) or ( x < 0 and -1 ) or 0
end

function math.normalFrom3Points( vP1, vP2, vP3, vOutNormal )
    vec3diff( vP2, vP1, vDiffBA )
    vec3diff( vP3, vP1, vDiffCA )
    vOutNormal = vec3cross( vDiffBA, vDiffCA, vOutNormal or vec3() )
    vec3mul( vOutNormal, 1 / vec3mag( vOutNormal ) )
    return vOutNormal
end

function math.centerOf3Points( vP1, vP2, vP3, vOutPos )
    vOutPos = vec3set( vOutPos or vec3(), vP1 )
    vec3add( vOutPos, vP2 )
    vec3add( vOutPos, vP3 )
    return vec3mul( vOutPos, 1 / 3 )
end

function math.planeFrom3Points( vP1, vP2, vP3, vOutNormal, vOutPos )
    return math.centerOf3Points( vP1, vP2, vP3, vOutPos or vec3() ), math.normalFrom3Points( vP1, vP2, vP3, vOutNormal )
end

function math.closestPointOnLine( vStart, vEnd, vPoint, vOutPoint )
    vec3diff( vStart, vPoint, vDiffAC )
    vec3diff( vStart, vEnd, vDiffAB )
    local nD = vec3dot( vDiffAC, vDiffAB ) / vec3sqrmag( vDiffAB )
    vOutPoint = vec3set( vOutPoint or vec3(), vDiffAB )
    vec3mul( vOutPoint, nD )
    vec3add( vOutPoint, vStart )
    return vOutPoint, nD
end

function math.pointInFrontOfPlane( vOrigin, vNormal, vPoint )
    return vec3dot( vec3diff( vOrigin, vPoint, vDiffAB ), vNormal ) > 0
end

function math.planeTriangleIntersection( vOrigin, vNormal, vP1, vP2, vP3 )
    local nI = 0
    nI = nI + ( math.pointInFrontOfPlane( vOrigin, vNormal, vP1 ) and 1 or 0 )
    nI = nI + ( math.pointInFrontOfPlane( vOrigin, vNormal, vP2 ) and 1 or 0 )
    nI = nI + ( math.pointInFrontOfPlane( vOrigin, vNormal, vP3 ) and 1 or 0 )
    return ( nI == 3 and 1 ) or ( nI == 0 and -1 ) or 0
end

function math.planeLineIntersection( vOrigin, nNormal, vStart, vEnd, vOut )
    vec3diff( vStart, vOrigin, vDiffBA )
    vec3diff( vEnd, vOrigin, vDiffCA )

    local nDot1, nDot2 = vec3dot( nNormal, vDiffBA ), vec3dot( nNormal, vDiffCA )

    if ( sign( nDot1 ) == sign( nDot2 ) ) then
        return false
    end

    local nT = nDot1 / ( nDot2 - nDot1 )

    vOut = vec3diff( vStart, vEnd, vOut or vec3() )
    vec3mul( vOut, -nT )
    return vec3add( vOut, vStart )
end
