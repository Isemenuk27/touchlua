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

d.showdrawscreen()
local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5
local mx, my, md, mhold, mpressed = 0, 0, false, false, false

local Objects, freeids = {}, {}

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

local CChain = {}

local gravity = 6
local mass = 2

function CChain:New( parent, xpos, ypos, m, g )
    self.vx, self.vy = 0, 0
    self.x, self.y = xpos or hw, ypos or hh
    self.g = g or 9.8
    self.mass = m or 1
    self.radius = 20
    self.stiffness = 1
    self.damping = .1
    self.p = parent and parent.id or nil
end

function CChain:Think( targetX, targetY )
    local forceX = (targetX - self.x) * self.stiffness
    local ax = forceX / self.mass
    self.vx = self.damping * ( self.vx + ax )
    self.x = self.x + self.vx
    local forceY = ( targetY - self.y ) * self.stiffness
    forceY = forceY + self.g
    local ay = forceY / self.mass
    self.vy = self.damping * ( self.vy + ay )
    self.y = self.y + self.vy
end

function CChain:Draw( nx, ny )
    circle( self.x, self.y, self.radius, green )
    line(self.x, self.y, nx, ny, white)
end

CChain.__index = CChain

local Obj = {}
local function Chain( p, x, y, r, m, g )
    local i = #Obj + 1
    Obj[i] = { id = i }
    setmetatable( Obj[i], CChain )
    Obj[i]:New(p, x, y, r, m, g)
    return Obj[i]
end

for i = 1, 100 do
    local c
    if ( not lastid ) then
        c = Chain()
    else
        c = Chain( Obj[lastid] )
    end
    lastid = c.id
end

local function Draw()
    for k, o in pairs( Obj ) do
        local p = Obj[o.p]
        if ( p ) then
            o:Think( p.x, p.y )
            o:Draw( p.x, p.y )
        else
            o:Think(mx, my)
            o:Draw(mx, my)
        end
    end
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
