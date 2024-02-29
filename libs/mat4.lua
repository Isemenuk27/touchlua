local cos, sin, tan = math.cos, math.sin, math.tan
local vec3add, vec3set, vec3mul, vec3dot = vec3add, vec3set, vec3mul, vec3dot
local atan = math.atan
local asin = math.asin
local sqrt = math.sqrt
local pi = math.pi
local istable = istable

function mat4( a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p )
    if ( istable( a ) ) then
        return mat4copy( a )
    end

    if ( b ) then
        return {
            [0] = { [0] = a or 1, b or 0, c or 0, d or 0 },
            [1] = { [0] = e or 0, f or 1, g or 0, h or 0 },
            [2] = { [0] = i or 0, j or 0, k or 1, l or 0 },
            [3] = { [0] = m or 0, n or 0, o or 0, p or 1 }
        }
    end

    return {
        [0] = { [0] = 1, 0, 0, 0 },
        [1] = { [0] = 0, 1, 0, 0 },
        [2] = { [0] = 0, 0, 1, 0 },
        [3] = { [0] = 0, 0, 0, 1 }
    }
end

function mat4identityfast( m )
    for i = 0, 3 do
        m[i][i] = 1
    end

    return m
end

function mat4identity( m )
    m[0][0] = 1
    m[0][1] = 0
    m[0][2] = 0
    m[0][3] = 0

    m[1][0] = 0
    m[1][1] = 1
    m[1][2] = 0
    m[1][3] = 0

    m[2][0] = 0
    m[2][1] = 0
    m[2][2] = 1
    m[2][3] = 0

    m[3][0] = 0
    m[3][1] = 0
    m[3][2] = 0
    m[3][3] = 1

    return m
end

--****************************************
-- Rotations

function mat4xrot( m, t )
    m[1][1] = cos( t )
    m[1][2] = -sin( t )
    m[2][1] = sin( t )
    m[2][2] = cos( t )

    return m
end

function mat4yrot( m, t )
    m[0][0] = cos( t )
    m[0][2] = sin( t )
    m[2][0] = -sin( t )
    m[2][2] = cos( t )

    return m
end

function mat4zrot( m, t )
    m[0][0] = cos( t )
    m[0][1] = -sin( t )
    m[1][0] = sin( t )
    m[1][1] = cos( t )

    return m
end

local function SinCos( a )
    return sin( a ), cos( a )
end

function mat4setupangles( mat, ang )
    local sy, cy = SinCos( ang[2] )
    local sp, cp = SinCos( ang[1] )
    local sr, cr = SinCos( ang[3] )

    mat[0][0] = cp*cy
    mat[1][0] = cp*sy
    mat[2][0] = -sp
    mat[0][1] = sr*sp*cy+cr*-sy
    mat[1][1] = sr*sp*sy+cr*cy
    mat[2][1] = sr*cp
    mat[0][2] = (cr*sp*cy+-sr*-sy)
    mat[1][2] = (cr*sp*sy+-sr*cy)
    mat[2][2] = cr*cp
    mat[0][3] = 0
    mat[1][3] = 0
    mat[2][3] = 0

    return mat
end

do
    local forward, left, up = vec3(), vec3(), vec3()

    function mat4toAng( m, vAngles )
        local x, y, z
        local cy = sqrt(m[1][1] * m[1][1] + m[0][1] * m[0][1])

        if ( cy > .001 ) then
            x = atan( m[2][0], m[2][2] )
            y = atan( -m[2][1], cy )
            z = atan( m[0][1], m[1][1] )
        else
            x = atan( m[0][2], m[0][0] )
            y = atan( -m[2][1], cy )
            z = 0
        end

        vec3set( vAngles, x, y, z )

        return vAngles
    end
end

function mat4copy( mat )
    local m = { [0] = {}, {}, {}, {} }

    m[0][0] = mat[0][0]
    m[0][1] = mat[0][1]
    m[0][2] = mat[0][2]
    m[0][3] = mat[0][3]

    m[1][0] = mat[1][0]
    m[1][1] = mat[1][1]
    m[1][2] = mat[1][2]
    m[1][3] = mat[1][3]

    m[2][0] = mat[2][0]
    m[2][1] = mat[2][1]
    m[2][2] = mat[2][2]
    m[2][3] = mat[2][3]

    m[3][0] = mat[3][0]
    m[3][1] = mat[3][1]
    m[3][2] = mat[3][2]
    m[3][3] = mat[3][3]

    return m
end

function mat4unpack( m )
    return m[0][0], m[0][1], m[0][2], m[0][3], m[1][0], m[1][1], m[1][2], m[1][3], m[2][0], m[2][1], m[2][2], m[2][3], m[3][0], m[3][1], m[3][2], m[3][3]
end

function mat4set( mat, a1, b1, c1, d1, a2, b2, c2, d2, a3, b3, c3, d3, a4, b4, c4, d4 )
    if ( istable( a1 ) ) then
        return mat4set( mat, mat4unpack( a1 ) )
    end

    mat[0][0] = a1
    mat[0][1] = b1
    mat[0][2] = c1
    mat[0][3] = d1

    mat[1][0] = a2
    mat[1][1] = b2
    mat[1][2] = c2
    mat[1][3] = d2

    mat[2][0] = a3
    mat[2][1] = b3
    mat[2][2] = c3
    mat[2][3] = d3

    mat[3][0] = a4
    mat[3][1] = b4
    mat[3][2] = c4
    mat[3][3] = d4

    return mat
end

function mat4setTr( m, tr )
    for i = 0, 2 do
        m[3][i] = tr[i+1]
    end

    return m
end

function mat4addTr( m, tr )
    for r = 0, 2 do
        m[3][r] = m[3][r] + tr[r+1]
    end

    return m
end

function mat4setSc( m, scl )
    for i = 0, 2 do
        m[i][i] = scl[i+1]
    end

    return m
end

function mat4setupSc( m, scl )
    for i = 0, 2 do
        m[i][i] = m[i][i] + scl[i+1]
    end

    return m
end

function mat4getTr( m, v )
    return vec3set( v or vec3(), m[3][0], m[3][1], m[3][2] )
end

function mat4mul( A, B, o )
    if ( not o ) then
        o = mat4()
    end

    o[0][0] = A[0][0] * B[0][0] + A[1][0] * B[0][1] + A[2][0] * B[0][2] + A[3][0] * B[0][3]
    o[0][1] = A[0][1] * B[0][0] + A[1][1] * B[0][1] + A[2][1] * B[0][2] + A[3][1] * B[0][3]
    o[0][2] = A[0][2] * B[0][0] + A[1][2] * B[0][1] + A[2][2] * B[0][2] + A[3][2] * B[0][3]
    o[0][3] = A[0][3] * B[0][0] + A[1][3] * B[0][1] + A[2][3] * B[0][2] + A[3][3] * B[0][3]

    o[1][0] = A[0][0] * B[1][0] + A[1][0] * B[1][1] + A[2][0] * B[1][2] + A[3][0] * B[1][3]
    o[1][1] = A[0][1] * B[1][0] + A[1][1] * B[1][1] + A[2][1] * B[1][2] + A[3][1] * B[1][3]
    o[1][2] = A[0][2] * B[1][0] + A[1][2] * B[1][1] + A[2][2] * B[1][2] + A[3][2] * B[1][3]
    o[1][3] = A[0][3] * B[1][0] + A[1][3] * B[1][1] + A[2][3] * B[1][2] + A[3][3] * B[1][3]

    o[2][0] = A[0][0] * B[2][0] + A[1][0] * B[2][1] + A[2][0] * B[2][2] + A[3][0] * B[2][3]
    o[2][1] = A[0][1] * B[2][0] + A[1][1] * B[2][1] + A[2][1] * B[2][2] + A[3][1] * B[2][3]
    o[2][2] = A[0][2] * B[2][0] + A[1][2] * B[2][1] + A[2][2] * B[2][2] + A[3][2] * B[2][3]
    o[2][3] = A[0][3] * B[2][0] + A[1][3] * B[2][1] + A[2][3] * B[2][2] + A[3][3] * B[2][3]

    o[3][0] = A[0][0] * B[3][0] + A[1][0] * B[3][1] + A[2][0] * B[3][2] + A[3][0] * B[3][3]
    o[3][1] = A[0][1] * B[3][0] + A[1][1] * B[3][1] + A[2][1] * B[3][2] + A[3][1] * B[3][3]
    o[3][2] = A[0][2] * B[3][0] + A[1][2] * B[3][1] + A[2][2] * B[3][2] + A[3][2] * B[3][3]
    o[3][3] = A[0][3] * B[3][0] + A[1][3] * B[3][1] + A[2][3] * B[3][2] + A[3][3] * B[3][3]

    return o
end

function mat4mulvec( i, o, m )
    o[1] = i[1] * m[0][0] + i[2] * m[1][0] + i[3] * m[2][0] + m[3][0]
    o[2] = i[1] * m[0][1] + i[2] * m[1][1] + i[3] * m[2][1] + m[3][1]
    o[3] = i[1] * m[0][2] + i[2] * m[1][2] + i[3] * m[2][2] + m[3][2]
    o[4] = i[1] * m[0][3] + i[2] * m[1][3] + i[3] * m[2][3] + m[3][3]

    if ( o[4] ~= 0 ) then
        vec3div( o, o[4] )
    end

    return o
end

function mat4mulvecnotr( i, o, m )
    o[1] = i[1] * m[0][0] + i[2] * m[1][0] + i[3] * m[2][0]
    o[2] = i[1] * m[0][1] + i[2] * m[1][1] + i[3] * m[2][1]
    o[3] = i[1] * m[0][2] + i[2] * m[1][2] + i[3] * m[2][2]
    o[4] = i[1] * m[0][3] + i[2] * m[1][3] + i[3] * m[2][3] + 1

    if ( o[4] ~= 0 ) then
        vec3div( o, o[4] )
    end

    return o
end

function mat4qinv( m, o )
    if ( not o ) then
        o = mat4()
    end

    o[0][0] = m[0][0]; o[0][1] = m[1][0]; o[0][2] = m[2][0]; o[0][3] = 0
    o[1][0] = m[0][1]; o[1][1] = m[1][1]; o[1][2] = m[2][1]; o[1][3] = 0
    o[2][0] = m[0][2]; o[2][1] = m[1][2]; o[2][2] = m[2][2]; o[2][3] = 0
    o[3][0] = -(m[3][0] * o[0][0] + m[3][1] * o[1][0] + m[3][2] * o[2][0])
    o[3][1] = -(m[3][0] * o[0][1] + m[3][1] * o[1][1] + m[3][2] * o[2][1])
    o[3][2] = -(m[3][0] * o[0][2] + m[3][1] * o[1][2] + m[3][2] * o[2][2])
    o[3][3] = 1

    return o
end

function mat4det( m )
    local det = m[0][0] * (m[1][1] * (m[2][2] * m[3][3] - m[2][3] * m[3][2]) -
    m[1][2] * (m[2][1] * m[3][3] - m[2][3] * m[3][1]) +
    m[1][3] * (m[2][1] * m[3][2] - m[2][2] * m[3][1]))
    - m[0][1] * (m[1][0] * (m[2][2] * m[3][3] - m[2][3] * m[3][2]) -
    m[1][2] * (m[2][0] * m[3][3] - m[2][3] * m[3][0]) +
    m[1][3] * (m[2][0] * m[3][2] - m[2][2] * m[3][0]))
    + m[0][2] * (m[1][0] * (m[2][1] * m[3][3] - m[2][3] * m[3][1]) -
    m[1][1] * (m[2][0] * m[3][3] - m[2][3] * m[3][0]) +
    m[1][3] * (m[2][0] * m[3][1] - m[2][1] * m[3][0]))
    - m[0][3] * (m[1][0] * (m[2][1] * m[3][2] - m[2][2] * m[3][1]) -
    m[1][1] * (m[2][0] * m[3][2] - m[2][2] * m[3][0]) +
    m[1][2] * (m[2][0] * m[3][1] - m[2][1] * m[3][0]))

    return det
end

function mat4invtr( tM, tO )
    local a = tM[0][0]
    local b = tM[1][0]
    local c = tM[2][0]

    local e = tM[0][1]
    local f = tM[1][1]
    local g = tM[2][1]

    local i = tM[0][2]
    local j = tM[1][2]
    local k = tM[2][2]

    -- Transform the translation.
    local n1, n2, n3 = -tM[0][3], -tM[1][3], -tM[2][3]

    local d = a * n1 + b * n2 + c * n3
    local h = e * n1 + f * n2 + g * n3
    local l = i * n1 + j * n2 + k * n3

    --[[ local m = 0
    local n = 0
    local o = 0
    local p = 1 ]]

    return mat3set( tO or mat4(), a, b, c, d, e, f, g, h, i, j, k, l, 0, 0, 0, 1 )
end

do
    local _X, _Y, _Z, _MAT, _R = mat4(), mat4(), mat4(), mat4(), mat4()
    local vec3origin = vec3( 1 )

    function mat4toworld( wpos, wang, lpos, out )
        mat4identity( _R )

        mat4setSc( _R, vec3origin )

        mat4yrot( _Y, wang[2] )
        mat4xrot( _X, wang[1] )
        mat4zrot( _Z, wang[3] )

        mat4mul( _R, _Y, _MAT )
        mat4mul( _MAT, _Z, _R )
        mat4mul( _R, _X, _MAT )

        mat4setTr( _MAT, wpos )

        mat4mulvec( lpos, out, _MAT )
    end

    local _M = mat4()

    function mat4setAng( mat, ang )
        mat4yrot( _Y, ang[2] )
        mat4xrot( _X, ang[1] )
        mat4zrot( _Z, ang[3] )

        mat4mul( mat, _Y, _M )
        mat4mul( _M, _X, mat )
        mat4mul( mat, _Z, _M )

        mat4set( mat, _M )

        return mat
    end

    function mat4getAng( mat, ang )
        local p, y, r
        p = asin( -mat[3][2] )

        if ( cos( p ) > 0.0001 ) then
            y = atan( mat[3][1], mat[3][3] )
            r = atan( mat[1][2], mat[2][2] )
        else
            y = 0.0
            r = atan( -mat[2][1], mat[1][1] )
        end

        return vec3set( ang or vec3(), p, y, r )
    end

    local _MAT2, _RES = mat4(), mat4()

    function mat4worldtolocal( wpos, wang, lpos, lang )
        mat4identity( _MAT )

        mat4setTr( _MAT, lpos )
        mat4setAng( _MAT, lang )

        mat4identity( _MAT2 )

        mat4setTr( _MAT2, wpos )
        mat4setAng( _MAT2, wang )
        mat4invtr( _MAT2, _MAT2 )

        mat4mul( _MAT2, _MAT, _RES )

        return mat4getTr( _RES ), mat4toAng( _RES, vec3() )
    end

    function mat4localtoworld( wpos, wang, lpos, lang )
        mat4identity( _MAT )

        mat4setTr( _MAT, lpos )
        mat4setAng( _MAT, lang )

        mat4identity( _MAT2 )

        mat4setTr( _MAT2, wpos )
        mat4setAng( _MAT2, wang )

        mat4mul( _MAT2, _MAT, _RES )

        return mat4getTr( _RES ), mat4toAng( _RES, vec3() )
    end
end
do
    local newForward, newRight, newUp, a = vec3(), vec3(), vec3(), vec3()

    function mat4pointat( mat, pos, target, up )
        vec3set( newForward, target )
        vec3sub( newForward, pos )
        vec3normalize( newForward )

        vec3set( a, newForward )
        vec3mul( a, vec3dot(up, newForward) )

        vec3set( newUp, up )
        vec3sub( newUp, a )
        vec3normalize( newUp )

        vec3cross( newUp, newForward, newRight )

        mat4set( mat, newRight[1], newRight[2], newRight[3], 0,
        newUp[1], newUp[2], newUp[3], 0,
        newForward[1], newForward[2], newForward[3], 0,
        pos[1], pos[2], pos[3], 1 )

        return mat, newForward, newRight, newUp
    end

    function mat4pointto( mat, pos, dir, up )
        vec3set( a, dir )
        vec3mul( a, vec3dot(up, dir) )

        vec3set( newUp, up )
        vec3sub( newUp, a )
        vec3normalize( newUp )

        vec3cross( newUp, dir, newRight )

        mat4set( mat, newRight[1], newRight[2], newRight[3], 0,
        newUp[1], newUp[2], newUp[3], 0,
        dir[1], dir[2], dir[3], 0,
        pos[1], pos[2], pos[3], 1 )

        return mat, dir, newRight, newUp
    end
end
