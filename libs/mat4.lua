local cos, sin, tan = math.cos, math.sin, math.tan
local vec3add, vec3set, vec3mul, vec3dot = vec3add, vec3set, vec3mul, vec3dot

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
end
