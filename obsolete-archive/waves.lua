local d = draw
local clear = d.clear
local post = d.post
local oline, ocircle = d.line, d.circle
local otext, point = d.text, d.point
local filltriangle = d.filltriangle
local ipairs, pairs = ipairs, pairs
local cos, sin, rad, deg = math.cos, math.sin, math.rad, math.deg
local red, green, white, black = d.red, d.green, d.white, d.black
local random = math.random
d.showdrawscreen()
local CurTime, DeltaTime, RealTime = 0, 0, sys.gettime
local Objects, freeids = {}, {}
local Tick = 0

local w, h = draw.getdrawsize()
local hw, hh = w * .5, h * .5
local function line( x, y, x1, y1, c )
    oline( x, y, x1, y1, c or white )
end

local function circle( x, y, r, c )
    ocircle( x, y, r, c or white )
end

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

local drawcol = { 1, 1, 1, 1 }

local function CalcColor( r, tr )
    drawcol[4] = Clamp( Remap( r, 0, tr, 1, 0 ), 0, 1 )
end

local CWave = {}

function CWave:New( x, y, r, a )
    self.x = x or random( 10, w )
    self.y = y or random( 10, h )
    self.tr = r or random(200, 300)
    self.a = a or 1
    --self.id = self.id or 1

    self.borntime = CurTime
    self.dietime = self.borntime + Rand( 1, 4 )
end

function CWave:Draw()
    self.r = Clamp( Remap( CurTime, self.borntime, self.dietime, 0, self.tr ), 0, self.tr )
    CalcColor( self.r, self.tr )
    if ( drawcol[4] <= 0 ) then self:Kill() return end
    draw.fillcircle(self.x, self.y, self.r, drawcol)
    --text( tostring(self.id), self.x, self.y )
end

function CWave:Kill()
    freeids[ #freeids + 1 ] = self.id
    Objects[ self.id ] = nil
    self = nil
    return
end

CWave.__index = CWave

local function AddObject( Class )
    local fi, i = next(freeids), nil

    if ( fi ) then
        local l = #freeids
        i = freeids[l]
        freeids[l] = nil
    else
        i = #Objects + 1
    end

    Objects[i] = {}
    setmetatable( Objects[i], Class )
    Objects[i].id = i
    return Objects[i]
end

local function Wave(hx, hy, tx, ty, k)
    return AddObject( CWave ):New( mx, my )
end

local function Draw( dt, ct )
    Tick = (Tick + 1) % 60
    for i, o in pairs(Objects)do
        o:Draw()
    end
    if ( md ) then
        Wave( random(0, w), random(0, h) )
    end
end

clear( black )

d.touchbegan = function (touche)
    mx, my = touche.x, touche.y
    md = true
    mhold = true
    mpressed = true
    --Wave(mx, my)
end

d.touchmoved = function (touche)
    mx, my = touche.x, touche.y
    md = true
    if mx * mx + my * my > 100 then

    end
end

d.touchended = function (touche)
    md = false
    mhold = false
end

while true do
    mpressed = false
    d.doevents()
    local st = RealTime()
    clear( black )
    Draw( FrameTime, CurTime )
    post()
    FrameTime = RealTime() - st
    CurTime = CurTime + FrameTime
end
