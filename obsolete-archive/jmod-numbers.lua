local d = draw
local clear, post, otext = d.clear, d.post, d.text
local ipairs, pairs = ipairs, pairs
local cos, sin, rad, deg = math.cos, math.sin, math.rad, math.deg
local tan, random, floor = math.tan, math.random, math.floor
local red, green, white, black = d.red, d.green, d.white, d.black
local CurTime, FrameTime, RealTime = 0, 0, sys.gettime
d.showdrawscreen()
local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5
local Particles, freeids = {}, {}

local minnum, maxnum = .5, 2.5
local period = 1

local initialVel = 6
local borntime = .2
local lifetime = 6

local g = 9.8
local floory = hh * .7
local floordist = 300

local bounds = 100

d.setfont( "Arial", 60 )

local function Rand( low, high ) --Генератор float чисел
    return low + ( high - low ) * random()
end

local function Remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

local function Clamp( inval, minval, maxval )
    if (inval < minval) then return minval end
    if (inval > maxval) then return maxval end
    return inval
end

local function text( s, x, y, c )
    return otext( s, x, y, c or white )
end

local col1, col2, drawcol = { 1,0,0,0 } , { 0,1,0,0 }, { 0,0,0,0 }

local function CalcColor( n, l, tn, tm, ptb )
    for i = 1, 3 do
        drawcol[i] = Clamp( Remap( n, minnum, maxnum, col1[i], col2[i] ), 0, 1 )
    end
    if ( tn < l ) then
        drawcol[4] = Clamp( Remap( l, tn, tm, 1, 0 ), 0, 1 )
    else
        drawcol[4] = Clamp( Remap( l, ptb, tn, 0, 1 ), 0, 1 )
    end
end

local CNumParticle = {}

function CNumParticle:Born( n, x, y, id )
    self.n = n or 99
    self.x = x or hw
    self.y = y or 300
    self.oy = self.y
    self.id = id or 0
    self.velSqr = 9
    self.speed = 100
    self.bounces = 0

    self.a = rad( Rand( 70, 81 ) )
    self.m = ( random( 0, 10 ) < 5 )
    self.prebornTime = CurTime
    self.bornTime = CurTime + borntime
    self.killTime = self.bornTime + lifetime
    return self
end

function CNumParticle:Draw()
    CalcColor( self.n, CurTime, self.bornTime, self.killTime, self.prebornTime )
    text( self.n, self.x, self.y, drawcol )
end

function CNumParticle:Kill()
    freeids[ #freeids + 1 ] = self.id
    Particles[ self.id ] = nil
    self = nil
    return
end

function CNumParticle:InBounds()
    if ( self.y < -bounds or self.y > h + bounds ) then return false end
    if ( self.x < -bounds or self.x > w + bounds ) then return false end
    return true
end

function CNumParticle:Simulate()
    if ( self.killTime < CurTime ) then self:Kill() return end
    if ( not self:InBounds() ) then self:Kill() return end
    local cosa = cos( self.a )
    local x = ( CurTime - (self.bouncetime or self.prebornTime) ) * 10
    self.y = self.oy - ( x * tan( self.a ) - g * ( (x * x) / (2 * self.velSqr * (cosa * cosa) ) ) )
    self.x = self.x + FrameTime * (self.m and 1 or - 1) * self.speed
    --if self.bounces > 3 then return end
    if ( self.y < floory + self.bounces * floordist ) then return end
    self.bouncetime = CurTime
    self.bounces = self.bounces + 1
    self.oy = self.y
    self.a = rad( 89 )
    self.velSqr = 100 * random( 30,40 )
    self.m = ( random( 0, 10 ) < 5 )
    self.speed = random( 180, 220 )
end

CNumParticle.__index = CNumParticle

local function NewParticle()
    local fi, i = next(freeids), nil

    if ( fi ) then
        local l = #freeids
        i = freeids[l]
        freeids[l] = nil
    else
        i = #Particles + 1
    end

    Particles[i] = {}
    setmetatable( Particles[i], CNumParticle )
    Particles[i]:Born( floor( Rand(minnum, maxnum) * 10) * .1, nil, nil, i )
end

local np = 0

local function Draw( dt, ct )
    if ( np < CurTime ) then
        NewParticle()
        np = CurTime + period
    end
    for i, p in pairs( Particles ) do
        p:Draw()
        p:Simulate()
    end
    text( #Particles .. "," .. #freeids .. "  " .. (floor(FrameTime * 1000) * .001), 20, 60 )
end

clear( black )

while true do
    local st = RealTime()
    clear( black )
    Draw( FrameTime, CurTime )
    post()
    FrameTime = RealTime() - st
    CurTime = CurTime + FrameTime
end
