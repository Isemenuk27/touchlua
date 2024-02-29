local GUI = require "libs/2dgui"
require "libs/units"
require "libs/math"

local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red, gridcol, yellow = draw.red, { .8, .8, .8, .8 }, draw.yellow

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local FrameTime, CurTime, RealTime = 0, 0, sys.gettime
local sqrt, random, pi = math.sqrt, math.random, math.pi

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

draw.showdrawscreen()
local w, h = draw.getdrawsize()
local hw, hh = w  * .5, h * .5

local bullettypes = {
    ["9x19"] = { mass = 7.45, diameter = 9.01, energy = 481 },
    ["7.62"] = { mass = 11.3, diameter = 7.62, energy = 3593 }
}

--#####################################--
local SU = 1 --52.49344--39.37
local gridsize = floor( 6000 / SU ) --meters
local numd = string.len(tostring(gridsize))
local textevery = 1000 --floor( (gridsize * .25 ) / numd ) * numd
local gridunit = w / ( gridsize * 2 )--1 pixel to grid
local ratio = h / w

local ox, oy = hw, hh
local g = 9.81
local r = 60
local h1 = .1
local h2 = 40
local rho = 1.225  -- Density of air in kg/m^3 (adjust as needed)
local cdrag = .4

local diameter, mass, energy, radius, area, dragCoef, v

function rebuild( type )
    assert( bullettypes[type] )
    diameter = mm2m( bullettypes[type].diameter )
    mass = g2kg( bullettypes[type].mass )
    energy = bullettypes[type].energy --J
    radius = diameter * .5 -- Radius in m
    area = .25 * pi * ( diameter * diameter )
    v = ( 2 * energy / mass ) ^ 0.5
    dragCoef = .2
end

rebuild( "7.62" )

local function gridScr( x, y )
    return x * gridunit, y * gridunit
end

local function grid()
    for x = -gridsize, gridsize do
        if ( x % floor( textevery * .1 ) == 0 ) then
            local dx = ox + x * gridunit
            if ( x % textevery == 0 ) then
                text( floor(x * SU), dx - 3, oy - 10, gridcol )
                line( dx, oy + w * .04, dx, oy - 8, white )
            else
                line( dx, oy + 5, dx, oy - 5, gridcol )
            end
        end
    end

    for y = -gridsize * ratio, gridsize * ratio do
        if ( floor( y ) % floor( textevery * .1 ) == 0 ) then
            local dy = oy + y * gridunit
            if ( floor( y ) % textevery == 0 ) then
                text( floor(y * SU), ox - 3, dy - 10, gridcol )
                line( ox + 8, dy, ox - 8, dy, white )
            else
                line( ox + 5, dy, ox - 5, dy, gridcol )
            end
        end
    end
end

local function TrajectoryPoint(h, a, v, x)
    local cosa = cos( a )
    return h + x * tan( a ) - g * ( (x * x) / ( 2 * (v * v) * (cosa * cosa) ) )
end

local BulletsTable = {}
local CBullet = {}
local BulletsNum = 0
CBullet.__index = CBullet

function CBullet:Born( x, y, a, sh, CT )
    BulletsNum = BulletsNum + 1
    self.x = x
    self.y = y
    self.a = a
    self.v = v

    self.borntime = CT
    self.LCT = CT

    self.vx = cos( a ) * v
    self.vy = sin( a ) * v

    self.mass = ma or 11 --g2kg( 10 )
    self.area = area
    self.radius = radius
end

local function inBounds( x, y )
    return y > -80000
end

function CBullet:Think( CT )
    if not inBounds( self.x, self.y ) then
        self:Kill()
        return
    end

    local DT  = CT - self.LCT

    local sqr = self.vx * self.vx + self.vy * self.vy
    local il = 1 / sqrt( sqr )
    local nx, ny = self.vx * il, self.vy * il

    --local dragm = rho * area * dragCoef
    --local DragX = 0.5 * ( dragm * ( self.vx * self.vx ) )
    --local DragY = 0.5 * ( dragm * ( self.vy * self.vy ) )

    local Fx = -cdrag * self.vx
    local Fy = -( self.mass * g ) - cdrag * self.vy

    local Ax = Fx / self.mass
    local Ay = Fy / self.mass

    --self.vx = self.vx - ( DragX * sign( self.vx ) * DT )
    --self.vy = self.vy - ( DragY * sign( self.vy ) * DT )
    --self.vy = self.vy - ( g * DT )
    self.vx = self.vx + ( Ax * DT )
    self.vy = self.vy + ( Ay * DT )

    self.x = self.x + ( self.vx * DT )
    self.y = self.y + ( self.vy * DT )

    --Bullet.NextPos   = Bullet.Pos + ACF.Scale * DeltaTime * (Bullet.Flight + Correction)
    --Bullet.Flight    = Bullet.Flight + (Accel - Drag) * DeltaTime

    self.LCT = CT

    --self.x = ( CurTime - self.borntime ) * self.vx
    --self.y = TrajectoryPoint( self.h, self.a, self.v, self.x )

    --local spd = sqrt( self.vx ^ 2 + self.vy ^ 2 )
    --spd = ( spd - self.v ) / ( CT - self.borntime )
    --spd = floor( spd * 10 ) * .1
    --text( self.vx, ox + self.x * gridunit, oy - self.y * gridunit, white )
    circle( ox + self.x * gridunit, oy - self.y * gridunit, 2, green )
end

function CBullet:Kill()
    BulletsTable[ self.Id ] = nil
    self = nil
    BulletsNum = BulletsNum - 1
end

local function NewBullet( x, y, a, sh )
    local Id = #BulletsTable + 1
    local Bullet = {}
    setmetatable( Bullet, CBullet )

    Bullet:Born( x, y, a, sh, CurTime )

    Bullet.Id = Id
    BulletsTable[Id] = Bullet
    return Bullet
end

local mx, my = 0, 0
local a = 0

local nextb = 0

local function Loop( CT, DT )

    grid()

    --r = ( my / h ) * 200
    --local a = atan(( v * v + sqrt( v ^ 4 - g * (g * r + 2 * h1 * ( v * v ) ))) / (g * r))

    --local a = atan( ( v * v + sqrt( v ^ 4 - g * ( g * (r * r) + 2 * (h2 - h1) * (v * v) ) ) ) / (g * r))

    if GUI.cursors[1] then
        mx, my = GUI.cursors[1].x, GUI.cursors[1].y
        a = atan( oy - my, mx - ox )
        h2 = ( oy - my ) / gridunit
        r = ( mx - ox ) / gridunit
        --a = atan( ( v * v + sqrt( v ^ 4 - g * ( g * (r * r) + 2 * (h2 - h1) * (v * v) ) ) ) / (g * r))
        if nextb < CT then
            NewBullet( 0, 0, a, 0 )
            --nextb = CT + 1
        end
    end

    do
        local ta = floor( deg( a ) * 100 ) * .01
        local tv = floor( v * 100 ) * .01
        local tr = floor( r * 100 ) * .01

        tv = tv .. "(" .. tv * 39.37 .. ")"
        tr = tr .. "(" .. tr * 39.37 .. ")"

        local y = oy - h1 * gridunit

        --text( "a⁰: " .. ta, ox, y + 15, yellow )
        --text( "vel: " .. tv, ox, y + 37, yellow )
        --text( "r: " .. tr, ox, y + 53, yellow )
    end

    local bx = ( ( CT * 50 ) % gridsize ) * 2 - gridsize

    local by = TrajectoryPoint( h1, a, v, bx ) * gridunit

    local lx, ly

    local xh = 0

    --[[for x = -gridsize, gridsize do
        local dx = ox + x * gridunit
        local y = TrajectoryPoint( h1, a, v, x )

        if ( ly and ly > h2 and y <= h2 ) then
            xh = dx
            line( dx, oy, dx, oy - y * gridunit - 60, yellow )
            text( x, dx, oy - y * gridunit - 65, white )
        end

        if ( ly ) then
            line( lx, oy - ly * gridunit, dx, oy - y * gridunit, white)
        end

        lx, ly = dx, y
    end ]]--

    local dh2 = oy - h2 * gridunit
    line( ox, dh2, xh, dh2, green )

    local dh = oy - h1 * gridunit
    line( ox, dh, -xh, dh, red )

    for i, Bullet in pairs( BulletsTable ) do
        Bullet:Think( CT, DT )
    end
    --line( ox, oy - h2 / gridunit, ox + r * gridunit, oy - h2 / gridunit, green )
    line( ox, oy, ox + cos(a) * w * .1, oy - sin(a) * w * .1, yellow )

    circle( ox + bx * gridunit, oy - by, 4, yellow )
    --text( bx, 20, 40, white )
    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

while true do
    local TimeStart = RealTime()
    draw.doevents()

    clear( black )

    if ( CurTime > 0 ) then
        Loop( CurTime, FrameTime )
        GUI.Render()
        post()
    end

    FrameTime = RealTime() - TimeStart
    CurTime = CurTime + FrameTime
end
