local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi = math.sqrt, math.random, math.pi
local TABLE, type = "table", type

local function istable( t )
    return type( t ) == TABLE
end

function mat2born( a, b, c, d )
    local m = {
        [0] = { [0] = a or 0, [1] = b or 0 },
        [1] = { [0] = c or 0, [1] = d or 0 },
    }
    return m
end

function mat12born( a, b )
    local m = { [0] = { [0] = a or 0, [1] = b or 0 } }
    return m
end

function mat2set( m, a, b, c, d )
    if istable( a ) then
        return mat2set( m, a[0][0], m[0][1], m[1][0], m[1][0] )
    end

    m[0][0] = a or 0
    m[0][1] = b or 0
    m[1][0] = c or 0
    m[1][1] = d or 0

    return m
end

function mat21set( m, a, b )
    if istable( a ) then
        return mat2set( m, a[0][0], m[1][0] )
    end

    m[0][0] = a or 0
    m[1][0] = b or 0

    return m
end

function mat23born()
    local m = {
        [0] = { [0] = 0, [1] = 0 },
        [1] = { [0] = 0, [1] = 0 },
        [2] = { [0] = 0, [1] = 0 }
    }
    return m
end

function mat2rot( m, a )
    mat2set( m, cos( a ), -sin( a ), sin( a ), cos( a ) )
end

function mat2trs( m, x, y )
    mat2set( m, x, 0, 0, y )
end

function mat2scl( m, sx, sy )
    mat2set( m, sx, 0, 0, sy or sx )
end

function mat2tr( m, x, y )
    --assert( m[2][1], "Using wrong matrix type" )
    m[2][0] = x
    m[2][1] = y or x
end

local _tempmat = mat23born()

function mat2trvec2( v, rotm, sclm )
    _tempmat[0][0] = v[1]
    _tempmat[1][0] = v[2]

    mat2mul( _tempmat, sclm )
    mat2mul( _tempmat, rotm )

    vec2set( v, _tempmat[0][0], _tempmat[0][1] )
    return v
end

function mat2trsl( x, y, rotm, sclm, tsr )
    x, y = mat22mulxy( sclm, x, y )
    x, y = mat22mulxy( rotm, x, y )


    if ( tsr ) then
        x, y = mat22addxy( tsr, x, y )
    end

    return x, y
end

--[[
[ A¹¹ * B¹¹ + A¹² * B²¹ | A¹¹ * B¹² + A¹² * B²² ]
[ A²¹ * B¹¹ + A²² * B²¹ | A²¹ * B¹² + A²² * B²²
]]--

function mat2mul( m, x, tm )
    local a = m[0][0] * x[0][0] + m[0][1] * x[1][0]
    local b = m[0][0] * x[0][1] + m[0][1] * x[1][1]
    local c = m[1][0] * x[0][0] + m[1][1] * x[1][0]
    local d = m[1][0] * x[0][1] + m[1][1] * x[1][1]

    mat2set( tm or m, a, b, c, d )
end

function mat22mul21( m, x, tm )
    local a = m[0][0] * x[0][0] + m[0][1] * x[1][0]
    local b = m[1][0] * x[0][0] + m[1][1] * x[1][0]

    mat21set( tm or m, a, b )
end

function mat22mulxy( m, x, y )
    local a = m[0][0] * x + m[0][1] * y
    local b = m[1][0] * x + m[1][1] * y

    return a, b
end

function mat22addxy( m, x, y )
    local a = m[0][0] + x
    local b = m[1][1] + y

    return a, b
end
