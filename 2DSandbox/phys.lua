if ( not Inited ) then require( "init" ) return end
local sqrt, abs = math.sqrt, math.abs
local vec2add, vec2mul, vec2set = vec2add, vec2mul, vec2set
local mat2trsl = mat2trsl
local debugdraw = true
local line = draw.line

local w, h = Scr()

--local function line( x1, y1, x2, y2, c )
--    oline( x1, h - y1, x2, h - y2, c )
--end

local white = draw.white

phys = {}
Rigids, Buffer = 0, {}

local Grav = 9.81 * 2
local AirD = 1.225
local DragC = .7
local AngDrag = .98

local _rotmat, _sclmat, _trsmat = mat2born(), mat2born(), mat2born()

local function setrotmat( a )
    mat2rot( _rotmat, a )
end

local function setsclmat( sx, sy )
    mat2scl( _sclmat, sx, sy )
end

local function settrsmat( x, y )
    mat2trs( _trsmat, x, y )
end

function phys.rigid( points )
    local obj = {}
    obj.pos = vec2()
    obj.vel = vec2()
    obj.acc = vec2()
    obj.ang = 0
    obj.scl = vec2( 1 )
    obj.form = points
    obj.mass = 100
    obj.angvel = 0
    obj.inert = 1

    Rigids = Rigids + 1
    Buffer[Rigids] = obj
    return obj
end

local _GRAVITY = vec2( 100 )
local _ADDACC, _ACC, _VEL, _DRAG = vec2(), vec2(), vec2(), vec2()
local _NRM, _TEMP = vec2(), vec2()
local _TORQ = 0
local _lx, _ly = 0, 0
local _MESH = {}
local _MAXALOC = 200
local _MESHL = 0

for i = 1, _MAXALOC do
    _MESH[i] = vec2()
end
--_trsmat = nil

function sim( obj, ct, dt )
    vec2set( _ACC, obj.acc )
    vec2set( _VEL, obj.vel )
    vec2set( _ADDACC, 0, 0 )

    --************************************
    -- Mesh
    for i = 1, #obj.form, 2 do
        vec2set( _MESH[i], obj.form[i], obj.form[i+1] )
    end

    vec2set( _NRM, _VEL )
    vec2normalize( _NRM )
    --vec2perp( _NRM )

    --************************************
    -- Gravity

    _GRAVITY[2] = -Grav * obj.mass
    vec2add( _ADDACC, _GRAVITY )

    --************************************
    -- Drag

    local v = vec2sqrmag( _VEL )

    vec2set( _DRAG, _NRM )

    local Area =  math.pi * ( 1 ^ 2 )
    local DragF = AirD * DragC * v * Area * .5
    vec2mul( _DRAG, DragF )
    vec2sub( _ADDACC, _DRAG )

    --************************************
    -- Apply Acceleration
    vec2div( _ADDACC, obj.mass )
    vec2add( _ACC, _ADDACC )
    vec2div( _ACC, obj.mass )

    vec2set( obj.acc, _ACC )

    --************************************
    -- Apply Velocity
    vec2add( _VEL, _ACC )
    vec2set( obj.vel, _VEL )

    --************************************
    -- Apply Position
    vec2mul( _VEL, dt )
    vec2add( obj.pos, _VEL )

    --************************************
    -- Angular Velocity
    _TORQ = 0-- cursordown() and 30 or 0
    obj.angvel = obj.angvel + (_TORQ / obj.inert) * dt
    local angDrag = AngDrag * obj.angvel
    obj.ang = obj.ang + obj.angvel * dt
    obj.ang = obj.ang - angDrag * dt

    line( obj.pos[1], obj.pos[2], obj.pos[1] + _NRM[1], obj.pos[2] + _NRM[2], white )

    setsclmat( obj.scl[1], obj.scl[2] )
    setrotmat( obj.ang )
    settrsmat( obj.pos[1], obj.pos[2] )

    if ( obj.pos[2] < -100 ) then
        obj.acc[2] = 1000
        obj.vel[2] = abs( obj.vel[2] )
    end

    draw.text( "drag " .. vec2mag( _DRAG ), 40, 110, white )
    draw.text( "vel " .. vec2mag( obj.vel ), 40, 130, white )

    local x1, y1 = mat2trsl( obj.form[1], obj.form[2], _rotmat, _sclmat, _trsmat )
    _lx, _ly = x1, y1

    for i = 3, #obj.form, 2 do
        local x, y = mat2trsl( obj.form[i], obj.form[i+1], _rotmat, _sclmat, _trsmat )
        line( _lx, _ly, x, y, white )
        _lx, _ly = x, y
    end

    line( _lx, _ly, x1, y1, white )
end

function simphysic( CT, DT )
    for i = 1, Rigids do
        sim( Buffer[i], CT, DT )
    end
end
