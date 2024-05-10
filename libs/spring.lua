local sqrt, abs, atan, pow, cos, sin = math.sqrt, math.abs, math.atan, math.pow, math.cos, math.sin

local spring = {}

local nEPS = 1e-5
local nBFT = 1 / 66

function spring.lerp( nA, nB, nF )
    return ( 1 - nF ) * nA + nF * nB
end

local function negexp( x )
    return 1 / ( 1 + x + 0.48 * x * x + 0.235 * x * x * x )
end

local function dampRatioToStiffness( nRatio, nDamping )
    return ( nDamping / ( nRatio * 2 ) ) ^ 2
end

local function halflifeToDamping( nHalflife )
    return ( 4 * 0.69314718056 ) / ( nHalflife + nEPS )
end

function spring.exact( nA, nB, nHalflife, nDeltaTime )
    return spring.lerp( nA, nB, 1 - negexp( ( 0.69314718056 * nDeltaTime ) / ( nHalflife + nEPS ) ) )
end

function spring.exponential( nA, nB, nDamping, nDeltaTime )
    return spring.lerp( nA, nB, 1 - ( 1 / ( 1 - nBFT * nDamping ) ) ^ ( -nDeltaTime / nBFT ) )
end

function spring.exactRatio( nA, nV, nB, nV2, nDamping, nHalflife, nDeltaTime )
    local nD = halflifeToDamping( nHalflife )
    local nS = dampRatioToStiffness( nDamping, nD )
    local nC, nY = nB + ( nD * nV2 ) / ( nS + nEPS ), nD * .5

    local nQ = nS - ( nD * nD ) * .25

    if ( abs( nQ ) < nEPS ) then -- Critically Damped
        local j0 = nA - nC
        local j1 = nV + j0 * nY

        local nExpYDt = negexp( nY * nDeltaTime )

        return j0 * nExpYDt + nDeltaTime * j1 * nExpYDt + nC,
        -nY * j0 * nExpYDt - nY * nDeltaTime * j1 * nExpYDt + j1 * nExpYDt
    elseif ( nQ > 0 ) then -- Under Damped
        local nW = sqrt( nQ )
        local nJ = sqrt( ( ( nV + nY * ( nA - nC ) ) ^ 2 ) / ( nW * nW + nEPS ) + ( nA - nC ) ^ 2 )
        local nP = atan( ( nV + ( nA - nC ) * nY ) / ( -( nA - nC ) * nW + nEPS ) )

        nJ = ( nA - nC ) > 0 and nJ or -nJ

        local nExpYDt = negexp( nY * nDeltaTime )
        local nJExpCosWDtP = nJ * nExpYDt * cos( nW * nDeltaTime + nP )

        return nJExpCosWDtP + nC, -nY * nJExpCosWDtP - nW * nJ * nExpYDt * sin( nW * nDeltaTime + nP )
    elseif ( nQ < 0 ) then -- Over Damped
        local nW = sqrt( nD * nD - 4 * nS )
        local y0, y1 = ( nD + nW ) * .5, ( nD - nW ) * .5
        local j1 = ( nC * y0 - nA * y0 - nV ) / ( y1 - y0 )
        local j0 = nA - j1 - nC

        local ey0dt, ey1dt = negexp( y0 * nDeltaTime ), negexp( y1 * nDeltaTime )

        return j0 * ey0dt + j1 * ey1dt + nC,
        -y0 * j0 * ey0dt - y1 * j1 * ey1dt
    end

    return nA, nV
end

_G.spring = spring
