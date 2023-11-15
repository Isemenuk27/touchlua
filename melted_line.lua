local d = draw
local doevents = d.doevents
local clear, post, otext = d.clear, d.post, d.text
local ocircle, oline, point = d.circle, d.line, d.point
local ipairs, pairs = ipairs, pairs
local log, exp = math.log, math.exp
local cos, sin, rad, deg = math.cos, math.sin, math.rad, math.deg
local tan, random, floor = math.tan, math.random, math.floor
local red, green, white, black = d.red, d.green, d.white, d.black
local gray, dred
do
    local b = .7
    gray = { b, b, b, .3 }
    dred = { b, 0, 0, 1 }
end
local CurTime, FrameTime, RealTime = 0, 0, sys.gettime
d.showdrawscreen()

local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5

local mx, my = hw, hh
local mhold, mpressed = false, false

local function Rand( low, high )
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

local function line( x1, y1, x2, y2, c )
    return oline( x1, y1, x2, y2, c or white )
end

local function text( s, x, y, c )
    return otext( s, x, y, c or white )
end

local function circle( x, y, r, c )
    return ocircle( x, y, r, c or white )
end

local function dot(x, y, c )
    return point( x, y, c or white)
end

local function smoothMax( a, b, k )
    return log( exp( k * a) + exp( k * b ) ) / k
end

local function smoothMin( a, b, k )
    return -smoothMax( -a, -b, k )
end

--Класи
local CSlider = {}

function CSlider:New( x, y, wd, min, max )
    self.x = x or 50
    self.y = y or h - 100
    self.w = wd or w - 100
    self.min = min or -.5
    self.max = max or .5
    self.cur = self.x + self.w * .5
    local x2 = self.x + self.w
    self.ballr = 60
    self.ballx = Remap( self.cur, self.min, self.max, self.x, x2 )
    self.bally = self.y
    self.val = Remap( self.cur, self.x, x2, self.min, self.max )
    return self
end

function CSlider:GetValue()
    return self.val
end

function CSlider:SetValue( val )
    self.val = val
end

function CSlider:TestCursor( cx, cy )
    local dirx, diry = cx - self.ballx, cy - self.bally
    local dist = dirx * dirx + diry * diry
    if ( dist > self.ballr * self.ballr ) then return end
    self.pressed = true
    return true
end

function CSlider:CalcVal()
    if ( not self.pressed ) then return end
    local x2 = self.x + self.w
    self.cur = Clamp( mx, self.x, x2 )
    self.val = Remap( self.cur, self.x, x2, self.min, self.max )
end

function CSlider:Think()
    if ( mpressed ) then
        self:TestCursor( mx, my )
    elseif ( not mhold ) then
        self.pressed = false
    end
    self:CalcVal()
    self.ballx = self.cur
    self.bally = self.y
    self:Draw()
end

function CSlider:Draw()
    line( self.x , self.y, self.x + self.w, self.y )
    circle( self.ballx, self.bally, self.ballr )
    text( floor( self.val * 1000 ) * .001, self.ballx - 20, self.bally - 20 )
end

CSlider.__index = CSlider

--Лінія

local CCurve = {}

function CCurve:New( f, c, height, div )
    self.points = {}
    self.c = c
    self.f = f
    div = div or 1600
    self.xspace = w / div

    for i = 1, div do
        self.points[i] = 0
    end
    return self
end

function CCurve:Draw( c )
    for x, y in ipairs( self.points ) do
        --if ( x + 1 <= #self.points ) then
        local lx = ( x - 1 ) * self.xspace
        local lx2 = lx + self.xspace
        line( lx, self.f( x ), lx2, self.f( x + 1 ), self.c or c )
        --end
    end
end

CCurve.__index = CCurve

local CHCurve = {}

function CHCurve:New( f, c, height, div )
    self.points = {}
    self.c = c
    self.f = f
    div = div or 1600
    self.yspace = w / div

    for i = 1, div do
        self.points[i] = 0
    end
    return self
end

function CHCurve:Draw( c )
    for y, x in ipairs( self.points ) do
        --if ( x + 1 <= #self.points ) then
        local ly = ( y - 1 ) * self.yspace
        local ly2 = ly + self.yspace
        line( self.f( y ), ly, self.f( y + 1 ), ly2, self.c or c )
        --end
    end
end

CHCurve.__index = CHCurve

clear( black )

local sl = CSlider:New()

local function funclin( x )
    return (h * .7 ) - (x * .2)
end

local function funcpar( x )
    return h * .7 - ( ( x - w * .7 ) ^ 2 ) * .002
end

local function funcmelt( x )
    return smoothMax( funclin( x ), funcpar( x ), sl:GetValue() )
    -- return math.max( funclin( x ), funcpar( x ) )
end

local function AddCurve( f, hor )
    local t = {}
    setmetatable( t, hor and CHCurve or CCurve )
    t:New( f )
    return t
end

local curlin = AddCurve( funclin )
local curpar = AddCurve( funcpar )
local hcurpa = AddCurve( funclin, true )

local curmelt = AddCurve( funcmelt )

local function Draw( dt, ct )
    sl:Think()
    curlin:Draw( gray )
    curpar:Draw( gray )
    curmelt:Draw( red )
    hcurpa:Draw(white)
    text( (floor(FrameTime * 1000) * .001), 20, 60 )
end

draw.touchbegan = function (t)
    mx, my = t.x, t.y
    mhold = true
    mpressed = true
end

draw.touchmoved = function (t)
    mx, my = t.x, t.y
end

draw.touchended = function (t)
    mhold = false
    return
end

while true do
    local st = RealTime()
    clear( black )
    doevents()
    Draw( FrameTime, CurTime )
    post()
    mpressed = false
    FrameTime = RealTime() - st
    CurTime = CurTime + FrameTime
end
