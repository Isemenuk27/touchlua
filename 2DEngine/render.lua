if ( not Inited ) then require( "init" ) return end

local drawtri, drawfilltri, drawline = draw.triangle, draw.filltriangle, draw.line
local drawrect = draw.rect
local abs = math.abs
local cos, sin = math.cos, math.sin
local pi, pi2 = math.pi, math.pi * 2
local white, black = draw.white, draw.black

local _CamOff, _CamAng, _CamScl = vec2(), 0, vec2()

local oline1 = draw.line
local oline = draw.line

local _rotmat, _sclmat, _trsmat = mat2born(), mat2born(), mat2born()

draw.matstack = {}
draw.matstackl = 0

function draw.pushmatrix( m )
    draw.matstackl = draw.matstackl + 1
    draw.matstack[draw.matstackl] = m
    return draw.matstackl
end

function draw.popmatrix()
    local m = draw.matstack[draw.matstackl]
    draw.matstack[draw.matstackl] = nil
    draw.matstackl = draw.matstackl - 1
    return m
end

draw.pushmatrix( mat3() )

function draw.getmatrix( i )
    return draw.matstack[i]
end

function draw.setmatrix( m )
    draw.matstack[1] = m
end

function CamAng( a )
    _CamAng = a
    mat2rot( _rotmat, a )
end

function CamScl( sx, sy )
    vec2set( _CamScl, sx, sy )
    mat2scl( _sclmat, sx, sy )
end

function CamOff( x, y )
    vec2set( _CamOff, x, y )
    mat2trs( _trsmat, x, y )
end

function GetCamOff()
    return _CamOff
end

function GetCamScl()
    return _CamScl
end

function GetCamAng()
    return _CamAng
end

function Cam( off, ang, scl )
    if ( off ) then
        CamOff( off[1], off[2] )
    end

    if ( ang ) then
        CamAng( ang )
    end

    if ( scl ) then
        CamScl( scl[1], scl[2] )
    end
end

function tri( a, b, c, d, e, f, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    c, d = mat2trsl( c, d, _rotmat, _sclmat, _trsmat )
    e, f = mat2trsl( e, f, _rotmat, _sclmat, _trsmat )
    drawtri( a, b, c, d, e, f, col or white )
end

function filltri( a, b, c, d, e, f, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    c, d = mat2trsl( c, d, _rotmat, _sclmat, _trsmat )
    e, f = mat2trsl( e, f, _rotmat, _sclmat, _trsmat )
    drawfilltri( a, b, c, d, e, f, col or white )
end

function line( a, b, c, d, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    c, d = mat2trsl( c, d, _rotmat, _sclmat, _trsmat )
    oline( a, b, c, d, col or white )
end

function rect( a, b, c, d, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    c, d = mat2trsl( c, d, _rotmat, _sclmat, _trsmat )
    drawrect( a, b, c, d, col or white )
end

function circle( ox, oy, r, s, c )
    local lx = ox + cos( 0 ) * r
    local ly = oy + sin( 0 ) * r

    for _ = 0, s do
        local i = ( pi2 / s ) * _
        local x = ox + cos( i ) * r
        local y = oy + sin( i ) * r

        filltri( lx, ly, x, y, ox, oy, c )

        lx, ly = x, y
    end
end

local la, lb
function linefrom( a, b )
    la, lb = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
end

function linefromv( v )
    la, lb = mat2trsl( v[1], v[2], _rotmat, _sclmat, _trsmat )
end

function lineto( a, b, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    oline( la, lb, a, b, col or white )
    la, lb = a, b
end

function linetov( v, col )
    local a, b = mat2trsl( v[1], v[2], _rotmat, _sclmat, _trsmat )
    oline( la, lb, a, b, col or white )
    la, lb = a, b
end

local pixelmeter = ScrW()
local scl = vec2mul( vec2( 1, -1 ), pixelmeter )
local off = vec2( 0, ScrH() )
Cam( off, 0, scl )
