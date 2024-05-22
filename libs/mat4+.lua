local cos, sin, tan, nPi = math.cos, math.sin, math.tan, math.pi
local vec3add, vec3set, vec3mul, vec3dot = vec3add, vec3set, vec3mul, vec3dot
local atan, asin, sqrt = math.atan, math.asin, math.sqrt
local istable = istable

function mat4( m )
    if ( m ) then
        return mat4copy( m )
    end

    return {
        [0] = { [0] = 1, 0, 0, 0 },
        [1] = { [0] = 0, 1, 0, 0 },
        [2] = { [0] = 0, 0, 1, 0 },
        [3] = { [0] = 0, 0, 0, 1 }
    }
end

function mat4copy( m )
    return {
        [0] = { [0] = m[0][0], m[0][1], m[0][2], m[0][3] },
        [1] = { [0] = m[1][0], m[1][1], m[1][2], m[1][3] },
        [2] = { [0] = m[2][0], m[2][1], m[2][2], m[2][3] },
        [3] = { [0] = m[3][0], m[3][1], m[3][2], m[3][3] },
    }
end

function mat4set( m, nA0, nA1, nA2, nA3, nB0, nB1, nB2, nB3, nC0, nC1, nC2, nC3, nD0, nD1, nD2, nD3 )
    m[0][0], m[0][1], m[0][2], m[0][3] = nA0, nA1, nA2, nA3
    m[1][0], m[1][1], m[1][2], m[1][3] = nB0, nB1, nB2, nB3
    m[2][0], m[2][1], m[2][2], m[2][3] = nC0, nC1, nC2, nC3
    m[3][0], m[3][1], m[3][2], m[3][3] = nD0, nD1, nD2, nD3
    return m
end

function mat4identity( m )
    return mat4set( m,
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1 )
end

function mat4unpack( m )
    return m[0][0], m[0][1], m[0][2], m[0][3], m[1][0], m[1][1], m[1][2], m[1][3], m[2][0], m[2][1], m[2][2], m[2][3], m[3][0], m[3][1], m[3][2], m[3][3]
end

--****************************************

-- Multiplication
function mat4mul( mA, mB, mC ) -- By other matrix
    local nA0, nA1, nA2, nA3 =
    mA[0][0] * mB[0][0] + mA[1][0] * mB[0][1] + mA[2][0] * mB[0][2] + mA[3][0] * mB[0][3],
    mA[0][1] * mB[0][0] + mA[1][1] * mB[0][1] + mA[2][1] * mB[0][2] + mA[3][1] * mB[0][3],
    mA[0][2] * mB[0][0] + mA[1][2] * mB[0][1] + mA[2][2] * mB[0][2] + mA[3][2] * mB[0][3],
    mA[0][3] * mB[0][0] + mA[1][3] * mB[0][1] + mA[2][3] * mB[0][2] + mA[3][3] * mB[0][3];

    local nB0, nB1, nB2, nB3 =
    mA[0][0] * mB[1][0] + mA[1][0] * mB[1][1] + mA[2][0] * mB[1][2] + mA[3][0] * mB[1][3],
    mA[0][1] * mB[1][0] + mA[1][1] * mB[1][1] + mA[2][1] * mB[1][2] + mA[3][1] * mB[1][3],
    mA[0][2] * mB[1][0] + mA[1][2] * mB[1][1] + mA[2][2] * mB[1][2] + mA[3][2] * mB[1][3],
    mA[0][3] * mB[1][0] + mA[1][3] * mB[1][1] + mA[2][3] * mB[1][2] + mA[3][3] * mB[1][3];

    local nC0, nC1, nC2, nC3 =
    mA[0][0] * mB[2][0] + mA[1][0] * mB[2][1] + mA[2][0] * mB[2][2] + mA[3][0] * mB[2][3],
    mA[0][1] * mB[2][0] + mA[1][1] * mB[2][1] + mA[2][1] * mB[2][2] + mA[3][1] * mB[2][3],
    mA[0][2] * mB[2][0] + mA[1][2] * mB[2][1] + mA[2][2] * mB[2][2] + mA[3][2] * mB[2][3],
    mA[0][3] * mB[2][0] + mA[1][3] * mB[2][1] + mA[2][3] * mB[2][2] + mA[3][3] * mB[2][3];

    local nD0, nD1, nD2, nD3 =
    mA[0][0] * mB[3][0] + mA[1][0] * mB[3][1] + mA[2][0] * mB[3][2] + mA[3][0] * mB[3][3],
    mA[0][1] * mB[3][0] + mA[1][1] * mB[3][1] + mA[2][1] * mB[3][2] + mA[3][1] * mB[3][3],
    mA[0][2] * mB[3][0] + mA[1][2] * mB[3][1] + mA[2][2] * mB[3][2] + mA[3][2] * mB[3][3],
    mA[0][3] * mB[3][0] + mA[1][3] * mB[3][1] + mA[2][3] * mB[3][2] + mA[3][3] * mB[3][3];

    return mat4set( mC, nA0, nA1, nA2, nA3, nB0, nB1, nB2, nB3, nC0, nC1, nC2, nC3, nD0, nD1, nD2, nD3 )
end

function mat4mulVector( m, v, vOut ) -- By vector
    local nVx, nVy, nVz = v[1], v[2], v[3]
    local nX, nY, nZ, nW =
    nVx * m[0][0] + nVy * m[1][0] + nVz * m[2][0] + m[3][0],
    nVx * m[0][1] + nVy * m[1][1] + nVz * m[2][1] + m[3][1],
    nVx * m[0][2] + nVy * m[1][2] + nVz * m[2][2] + m[3][2],
    nVx * m[0][3] + nVy * m[1][3] + nVz * m[2][3] + m[3][3]

    vOut[1], vOut[2], vOut[3], vOut[4] = nX, nY, nZ, nW

    if ( nW ~= 0 ) then
        vec3mul( vOut, 1 / nW )
    end

    return vOut
end

---==Matrix magic zone==---
function mat4determinant( m )
    local nD =
    m[0][0] * ( m[1][1] * ( m[2][2] * m[3][3] - m[2][3] * m[3][2] ) -
    m[1][2] * ( m[2][1] * m[3][3] - m[2][3] * m[3][1] ) +
    m[1][3] * ( m[2][1] * m[3][2] - m[2][2] * m[3][1] ) ) -
    m[0][1] * ( m[1][0] * ( m[2][2] * m[3][3] - m[2][3] * m[3][2] ) -
    m[1][2] * ( m[2][0] * m[3][3] - m[2][3] * m[3][0] ) +
    m[1][3] * ( m[2][0] * m[3][2] - m[2][2] * m[3][0] ) ) +
    m[0][2] * ( m[1][0] * ( m[2][1] * m[3][3] - m[2][3] * m[3][1] ) -
    m[1][1] * ( m[2][0] * m[3][3] - m[2][3] * m[3][0] ) +
    m[1][3] * ( m[2][0] * m[3][1] - m[2][1] * m[3][0] ) ) -
    m[0][3] * ( m[1][0] * ( m[2][1] * m[3][2] - m[2][2] * m[3][1] ) -
    m[1][1] * ( m[2][0] * m[3][2] - m[2][2] * m[3][0] ) +
    m[1][2] * ( m[2][0] * m[3][1] - m[2][1] * m[3][0] ) )
    return nD
end

function mat4quickInverse( m, mOut )
    local nA0, nA1, nA2 = m[0][0], m[1][0], m[2][0]
    local nB0, nB1, nB2 = m[0][1], m[1][1], m[2][1]
    local nC0, nC1, nC2 = m[0][2], m[1][2], m[2][2]

    return mat4set( mOut or mat4(),
    nA0, nA1, nA2, 0, nB0, nB1, nB2, 0, nC0, nC1, nC2, 0,
    -( m[3][0] * nA0 + m[3][1] * nB0 + m[3][2] * nC0 ),
    -( m[3][0] * nA1 + m[3][1] * nB1 + m[3][2] * nC1 ),
    -( m[3][0] * nA2 + m[3][1] * nB2 + m[3][2] * nC2 ), 1 )
end
---==End==---

-- Translation
function mat4translate( m, vTr )
    for nI = 0, 2 do
        m[3][nI] = m[3][nI] + vTr[nI+1]
    end

    return m
end

function mat4setTranslation( m, vTr )
    for nI = 0, 2 do
        m[3][nI] = vTr[nI+1]
    end

    return m
end

function mat4mulTranslation( m, vTr )
    for nI = 0, 2 do
        m[3][nI] = m[3][nI] * vTr[nI+1]
    end

    return m
end

function mat4getTranslation( m )
    return m[3][0], m[3][1], m[3][2]
end

-- Scale
function mat4scale( m, vScl )
    for nI = 0, 2 do
        m[nI][nI] = m[nI][nI] * vScl[nI+1]
    end

    return m
end

function mat4setScale( m, vTr )
    for nI = 0, 2 do
        m[nI][nI] = vScl[nI+1]
    end

    return m
end

function mat4addScale( m, vScl )
    for nI = 0, 2 do
        m[nI][nI] = m[nI][nI] + vScl[nI+1]
    end
    return m
end

function mat4getScale( m )
    return m[0][0], m[1][1], m[2][2]
end

-- Rotation
function mat4rotateX( m, nA )
    local nS, nC = sin( nA ), cos( nA )
    return mat4set( m, 1, 0, 0, 0, 0, nC, -nS, 0, 0, nS, nC, 0, 0, 0, 0, 1 )
end

function mat4rotateY( m, nA )
    local nS, nC = sin( nA ), cos( nA )
    return mat4set( m, nC, 0, nS, 0, 0, 1, 0, 0, -nS, 0, nC, 0, 0, 0, 0, 1 )
end

function mat4rotateZ( m, nA )
    local nS, nC = sin( nA ), cos( nA )
    return mat4set( m, nC, -nS, 0, 0, nS, nC, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 )
end

function mat4setAngles( m, vA )

end

local vTemp = vec3()

function mat4lookAt( m, vOrigin, vNormal, vUp, vForward, vRight )
    vec3set( vForward, vNormal )

    vec3set( vTemp, vForward )
    vec3mul( vTemp, vec3dot( vUp, vForward ) )

    vec3diff( vTemp, vUp, vUp )
    vec3normalize( vUp )

    vec3cross( vUp, vForward, vRight )

    mat4set( m,
    vRight[1], vRight[2], vRight[3], 0,
    vUp[1], vUp[2], vUp[3], 0,
    vForward[1], vForward[2], vForward[3], 0,
    vOrigin[1], vOrigin[2], vOrigin[3], 1 )

    return m, vUp, vForward, vRight
end
