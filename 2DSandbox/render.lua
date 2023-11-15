if ( not Inited ) then require( "init" ) return end

local abs = math.abs

local w, h, pixelmeter
local _CamOff, _CamAng, _CamScl = vec2(), 0, vec2()

callback( "screen", function()
    w, h = Scr()
    hw, hh = HScr()
    pixelmeter = w / 70
    local scl = vec2mul( vec2( 1, -1 ), pixelmeter )
    local off = vec2div( vec2( hw, hh ), pixelmeter )
    Cam( off, 0, scl )
end )

local lmx, lmy, ld, la
local x1, y1, x2, y2 = nil

local function touch( t )
    if ( t.id == 1 ) then
        lmx, lmy = t.x, t.y
        x11, y11 = lmx, lmy
    else
        lmx = nil
    end
end

local function moved( t )
    if ( t.id == 1 ) then
        x1, y1 = t.x, t.y
    elseif ( t.id == 2 ) then
        x2, y2 = t.x, t.y
    end

    if ( lmx ) then
        local dx, dy = t.x - lmx, t.y - lmy
        local x, y = GetCamOff()[1], GetCamOff()[2]
        x, y = x + dx, y + dy
        CamOff( x, y )
        lmx, lmy = t.x, t.y
    elseif ( x1 and x2 ) then
        local d = dist( x1, y1, x2, y2 )

        if ( x11 and ( dist( x11, y11, x1, y1 ) < 60 ) ) then
            local dx, dy = x2 - x11, y2 - y11
            local a = math.atan( dy, dx )

            if ( la ) then
                CamAng( GetCamAng() - ( la - a ) )
            end

            la = a
        else
            x11 = nil
            if ( ld ) then
                local dl = d - ld
                local scl = GetCamScl()
                local sx = scl[1] + ( dl * .002 * abs( scl[1] ) )
                local sy = scl[2] - ( dl * .002 * abs( scl[2] ) )
                CamScl( sx, sy )
            end
        end
        ld = d
    end
end

local function tend( t )
    ld = nil
    x2, y2 = nil, nil
    x1, y1 = nil, nil
    la = nil
end

callback( "touch.start", touch )
callback( "touch.move", moved )
callback( "touch.end", tend )

local white = draw.white
local oline1 = draw.line

--local function oline( a, b, c, d )
local oline = draw.line

local _rotmat, _sclmat, _trsmat = mat2born(), mat2born(), mat2born()

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

function draw.line( a, b, c, d, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    c, d = mat2trsl( c, d, _rotmat, _sclmat, _trsmat )
    oline( a, b, c, d, col or white )
end

local la, lb
function draw.linefrom( a, b )
    la, lb = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
end

function draw.linefromv( v )
    la, lb = mat2trsl( v[1], v[2], _rotmat, _sclmat, _trsmat )
end

function draw.lineto( a, b, col )
    a, b = mat2trsl( a, b, _rotmat, _sclmat, _trsmat )
    oline( la, lb, a, b, col or white )
    la, lb = a, b
end

function draw.linetov( v, col )
    local a, b = mat2trsl( v[1], v[2], _rotmat, _sclmat, _trsmat )
    oline( la, lb, a, b, col or white )
    la, lb = a, b
end

