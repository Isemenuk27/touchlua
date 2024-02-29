local d = draw
local clear, post, otext = d.clear, d.post, d.text
local ipairs, pairs = ipairs, pairs
local cos, sin, rad, deg = math.cos, math.sin, math.rad, math.deg
local tan, random, floor = math.tan, math.random, math.floor
local red, green, white, black = d.red, d.green, d.white, d.black
local gray
do local br = .3 gray = { br, br, br, .4 } end
local CurTime, FrameTime, RealTime = 0, 0, sys.gettime
local circle, oline, fillrect = d.circle, d.line, d.fillrect
local rect = d.rect
local sqrt, atan, pi = math.sqrt, math.atan, math.pi
local pi2 = pi * .5
local rad1 = rad(1)
local osubimg = draw.subimage
local transformedimage = draw.transformedimage

local function trimg( x1, y1, x2, y2, ox, oy, ang, scl, file )
    osubimg(file, x1, y1, x2, y2, ox or (x1 + x2) * .5, oy or (y1 + y2) * .5, scl or 1, ang or 0)
end

d.showdrawscreen()

local Sprites = {
    'images/SmokePuff01.png',
    'images/SmokePuff02.png',
    'images/SmokePuff03.png'
}
local smsize
for i, s in ipairs(Sprites) do
    smsize = draw.cacheimage( s )
end
local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5
local mx, my, md, mhold, mpressed = 0, 0, false, false, false

local Obj = {}

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

local function line( x, y, x1, y1, c )
    return oline( x, y, x1, y1, c or white )
end

local cs = 20

local function cross( x, y, c )
    line( x - cs, y, x + cs, y, c or green )
    line( x, y - cs, x, y + cs, c or green )
end

local CSmokePuff = { }

function CSmokePuff:New( x, y )
    self.x = x
    self.y = y
    self.s = Rand( .5, 1.7 )
    self.startSize = self.s
    self.ang = random(-10, 10)
    self.img = Sprites[random( #Sprites )]
    self.BornTime = CurTime
    self.DieTime = CurTime + Rand( 1, 2 )
    return self
end

function CSmokePuff:Kill()
    Obj[self.id] = nil
    self = nil
    return
end

function CSmokePuff:Draw()
    if ( self.DieTime < CurTime ) then
        self:Kill()
        return
    end
    self.s = Remap( CurTime, self.BornTime, self.DieTime, self.startSize, 0 )
    transformedimage( self.img, self.x, self.y, self.s, self.ang )
    --draw.circle(self.x, self.y, self.s, white )
    self.y = self.y - FrameTime * 1000
    self.x = self.x + sin( self.y ) * random( 1, 10)
    self.ang = self.ang * 1.1
end

CSmokePuff.__index = CSmokePuff

local function SmokePuff( x, y )
    local i = #Obj + 1
    Obj[i] = { id = i }
    setmetatable( Obj[i], CSmokePuff )
    Obj[i]:New( x, y )
    Obj[i].id = i
    return Obj[i]
end

local function Draw()

    SmokePuff( mx, my )
    for k, o in pairs( Obj ) do
        o:Draw()
    end
    text( #Obj, 20, 20, white )
end

d.touchbegan = function (touche)
    mx, my = touche.x, touche.y

    md = true
    mhold = true
    mpressed = true
end

d.touchmoved = function (touche)
    mx, my = touche.x, touche.y
    EndX, EndY = mx, my
    md = true
end

d.touchended = function (touche)
    md = false
    mhold = false
    rx, mr, mup = 0, 0, 0
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
