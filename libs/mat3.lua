local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi = math.sqrt, math.random, math.pi
local TABLE, type = "table", type

local function istable( t )
    return type( t ) == TABLE
end

function mat3( a, b, c, d, e, f, g, h, i )
    local m = {
        [0] = { [0] = 1, 0, 0 },
        [1] = { [0] = 0, 1, 0 },
        [2] = { [0] = 0, 0, 1 },
    }
    return m
end

function mat3identity( m )
    return mat3set( m, 1, 0, 0, 0, 1, 0, 0, 0, 1 )
end

function mat3unack( m )  -- unpack??
    return m[0][0], m[0][1], m[0][2], m[1][0], m[1][1], m[1][2], m[2][0], m[2][1], m[2][2]
end

function mat3set( m, a, b, c, d, e, f, g, h, i )
    if istable( a ) then
        return mat3set( m, mat3unack( a ) )
    end

    m[0][0] = a
    m[0][1] = b
    m[0][2] = c

    m[1][0] = d
    m[1][1] = e
    m[1][2] = f

    m[2][0] = g
    m[2][1] = h
    m[2][2] = i

    return m
end

function mat3setTr( m, x, y )
    m[2][0] = x
    m[2][1] = y
    return m
end

function mat3addTr( m, x, y )
    m[2][0] = m[2][0] + x
    m[2][1] = m[2][1] + y
    return m
end

function mat3getTr( m )
    return m[2][0], m[2][1]
end

function mat3setSc( m, x, y )
    m[0][0] = x
    m[1][1] = y
    return m
end

function mat3addSc( m, x, y )
    m[0][0] = m[0][0] + x
    m[1][1] = m[1][1] + y
    return m
end

function mat3getSc( m )
    return m[0][0], m[1][1]
end

function mat3rot( m, a )
    m[0][0] = cos( a )
    m[0][1] = -sin( a )

    m[1][0] = sin( a )
    m[1][1] = cos( a )

    return m
end

function mat3mulxy( m, x, y )
    local nx = x * m[0][0] + y * m[1][0] + m[2][0]
    local ny = x * m[0][1] + y * m[1][1] + m[2][1]
    local nz = 1 / ( x * m[0][2] + y * m[1][2] + m[2][2] )

    return nx * nz, ny * nz
end

function mat3mulvec2( m, v )
    return mat3mulxy( m, v[1], v[2] )
end

function mat3setSheer( m, v )
    m[1][0] = v[1]
    m[0][1] = v[2]
end

function inverse3x3(matrix)
    local det = matrix[0][0] * (matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]) -
    matrix[0][1] * (matrix[1][0] * matrix[2][2] - matrix[1][2] * matrix[2][0]) +
    matrix[0][2] * (matrix[1][0] * matrix[2][1] - matrix[1][1] * matrix[2][0])

    local invDet = 1 / det

    local result = {}
    for i = 0, 2 do
        result[i] = {}
        for j = 0, 2 do
            local cofactor = matrix[(j + 1) % 3][(i + 1) % 3] * matrix[(j + 2) % 3][(i + 2) % 3] -
            matrix[(j + 2) % 3][(i + 1) % 3] * matrix[(j + 1) % 3][(i + 2) % 3]

            result[i][j] = cofactor * invDet
        end
    end

    return result
end

function mat3inv( m, o )
    if ( not o ) then
        o = mat3()
    end

    local det = m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
    m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
    m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])

    local invDet = 1 / det

    local a = (m[1][1] * m[2][2] - m[1][2] * m[2][1]) * invDet
    local b = (m[0][2] * m[2][1] - m[0][1] * m[2][2]) * invDet
    local c = (m[0][1] * m[1][2] - m[0][2] * m[1][1]) * invDet

    local d = (m[1][2] * m[2][0] - m[1][0] * m[2][2]) * invDet
    local e = (m[0][0] * m[2][2] - m[0][2] * m[2][0]) * invDet
    local f = (m[0][2] * m[1][0] - m[0][0] * m[1][2]) * invDet

    local g = (m[1][0] * m[2][1] - m[1][1] * m[2][0]) * invDet
    local h = (m[0][1] * m[2][0] - m[0][0] * m[2][1]) * invDet
    local i = (m[0][0] * m[1][1] - m[0][1] * m[1][0]) * invDet

    return mat3set( o, a, b, c, d, e ,f, g, h, i )
end

function mat3mul( A, B, O )
    local a = A[0][0] * B[0][0] + A[0][1] * B[1][0] + A[0][2] * B[2][0]
    local b = A[0][0] * B[0][1] + A[0][1] * B[1][1] + A[0][2] * B[2][1]
    local c = A[0][0] * B[0][2] + A[0][1] * B[1][2] + A[0][2] * B[2][2]

    local d = A[1][0] * B[0][0] + A[1][1] * B[1][0] + A[1][2] * B[2][0]
    local e = A[1][0] * B[0][1] + A[1][1] * B[1][1] + A[1][2] * B[2][1]
    local f = A[1][0] * B[0][2] + A[1][1] * B[1][2] + A[1][2] * B[2][2]

    local g = A[2][0] * B[0][0] + A[2][1] * B[1][0] + A[2][2] * B[2][0]
    local h = A[2][0] * B[0][1] + A[2][1] * B[1][1] + A[2][2] * B[2][1]
    local i = A[2][0] * B[0][2] + A[2][1] * B[1][2] + A[2][2] * B[2][2]

    return mat3set( O or mat3(), a, b, c, d, e, f, g, h, i )
end

local f = [[%.2f, %.2f, %.2f | %.2f, %.2f, %.2f | %.2f, %.2f, %.2f]]

function mat3tostring( m )
    return string.format( f, m[0][0], m[0][1], m[0][2],  m[1][0], m[1][1], m[1][2], m[2][0], m[2][1], m[2][2] )
end

