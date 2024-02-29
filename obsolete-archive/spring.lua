local d = draw
local m = math
local cos, sin, atan, rad, deg = m.cos, m.sin, m.atan, m.rad, m.deg
local clear, post, otext = d.clear, d.post, d.text
local ipairs, pairs, pi = ipairs, pairs, m.pi
local random, floor = m.random, m.floor
local ocircle, oline, sqrt = d.circle, d.line, m.sqrt
local acos = m.acos
local moveto = d.movecurrentpoint
local red, green, white, black = d.red, d.green, d.white, d.black
local CurTime, FrameTime, RealTime = 0, 0, sys.gettime
local TickFix = 0
local min, max = math.min, math.max
d.showdrawscreen()
local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5
local mx, my, md = hw * .5, hh * .5, false
local mhold, mpressed = false, false
local g = 0

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

local CSpring = {}
local CBody = {}

local springshape = {
    { 0, 0},
    {.2, 0},
    {.25, .1},
    {.3, -.1},
    {.35, .1},
    {.4, -.1},
    {.45, .1},
    {.5, -.1},
    {.55, .1},
    {.6, -.1},
    {.65, .1},
    {.7, -.1},
    {.75, .1},
    {.8, 0},
    { 1, 0},
    origin = {0, 0}
}

local boxshape = {
    { .7, 0 },
    { 1, 1 },
    { 0, 1 },
    { .3, 0 },
    { .7, 0 },
    origin = {.5, 0}
}

function CBody:New( x, y, mass, parent )
    self.x = x or hw
    self.y = y or hh * 1.5
    self.mass = mass or 1
    self.parent = parent
    self.shape = boxshape
    self.vel = 0
    self.size = 100
    return self
end

local function RotatePoint( px, py, ox, oy, ang, scale )
    px = px * scale
    py = py * scale
    local x = cos(ang) * px - sin(ang) * py
    local y = sin(ang) * px + cos(ang) * py

    return x + ox, y + oy
end

local yforce = 0

function CBody:SimulateParent()
    local x, y = self.parent:GetChildPoint()
    ---self.x, self.y = x, y
    yforce = yforce + (self.y - y) * FrameTime
end

function CBody:GravityAffect()
    yforce = yforce + g
    self.a = yforce / self.mass
    self.vel = self.vel + self.a --* 1--FrameTime
    self.y = self.y + self.vel --* 1--FrameTime

    self.vel = self.vel - FrameTime * 10
end

function CBody:AffectParent()
    self.parent:SetChildAffect( self.x, self.y )
end

function CBody:Simulate()

    if ( self.parent ) then
        self:SimulateParent()
        self:AffectParent()


    end
    self:GravityAffect()
end

function CBody:Draw()
    draw.setfont( "arial", 60 )
    for i, pos in ipairs( self.shape ) do
        if ( not self.shape[ i + 1 ] ) then break end
        local p = self.shape[ i + 1 ]
        local ang = 0
        local ox = self.x - self.shape.origin[1] * self.size
        local oy = self.y - self.shape.origin[2] * self.size
        local x1, y1 = ox + pos[1] * self.size, oy + pos[2] * self.size
        local x2, y2 = ox + p[1] * self.size, oy + p[2] * self.size

        line(x1, y1, x2, y2, green)
    end
    text( self.mass, self.x, self.y + self.size * .5, green)
end

function CSpring:New( hx, hy, tx, ty, k )
    self.hx = hx or hw
    self.hy = hy or hh
    self.tx = tx or hw
    self.ty = ty or hh * 1.5
    self.r = .2
    self.k = k or 1
    self.d = 1 - self.k
    self.c = green
    self:Calculate( true )
    self.olen = self.len
    self.spring = true
    return self
end

function CSpring:Calculate( skip )
    self.dx = self.tx - self.hx
    self.dy = self.ty - self.hy
    self.lensqr = self.dx * self.dx + self.dy * self.dy
    self.len = sqrt( self.lensqr )
    local il = 1 / self.len
    self.nx = self.dx * il
    self.ny = self.dy * il
    self.ang = atan( -self.ny, -self.nx ) + pi
    if ( skip ) then return end
    self.d = self.len - self.olen
    self.k = self.len / self.olen
    self.ik = self.olen / self.len
    text( g, 30, 30 )
end

function CSpring:Linear()
    local F = (self.r * self.d) * TickFix
    self.tx = self.tx - self.nx * F
    self.ty = self.ty - self.ny * F
end

function CSpring:Simulate( skip )
    skip = md
    if ( not skip ) then
        self:Linear()
    end
    self:Calculate()
end

function CSpring:GetTail()
    return self.tx, self.ty
end

CSpring.GetChildPoint = CSpring.GetTail

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
    --self:Draw()
end

function CSlider:Draw()
    self:Think()
    line( self.x , self.y, self.x + self.w, self.y )
    circle( self.ballx, self.bally, self.ballr )
    text( self.val, self.ballx - 20, self.bally - 20 )
end

CSlider.__index = CSlider

local function RotatePointSpring( px, py, ox, oy, ang, spring )
    px = px * spring.len
    py = py * spring.len * spring.ik
    local x = cos(ang) * px - sin(ang) * py
    local y = sin(ang) * px + cos(ang) * py

    return x + ox, y + oy
end

function CSpring:Draw()
    local mx, my = self.len * -self.nx, self.len * -self.ny
    for i, pos in ipairs( springshape ) do
        if ( not springshape[ i + 1 ] ) then return end
        local p = springshape[ i + 1 ]
        local ox, oy = self.hx, self.hy
        local ang = self.ang
        local x1, y1 = RotatePointSpring( pos[1], pos[2], ox, oy, ang, self  )
        local x2, y2 = RotatePointSpring( p[1], p[2], ox, oy, ang, self )

        line(x1, y1, x2, y2, green)
    end
end

function CSpring:SetChildAffect( x, y )
    self.tx = x
    self.ty = y
end

CSpring.__index = CSpring
CBody.__index = CBody

local Objects = {}

local function AddObject( Class )
    local i = #Objects + 1
    Objects[i] = {}
    setmetatable( Objects[i], Class )
    Objects[i].id = i
    return Objects[i]
end

local function Spring(hx, hy, tx, ty, k)
    return AddObject( CSpring ):New()
end

local function Box( x, y, mass, parent )
    return AddObject( CBody ):New( x, y, mass, parent )
end

local function Slider(x, y, wd, min, max)
    return AddObject( CSlider ):New( x, y, wd, min, max )
end

--local slider = Slider( nil, nil, nil, -.0001, .0001 )
local spring = Spring()
--local box = Box( nil, nil, nil, spring )

local function Draw( dt, ct )
    for i, o in pairs( Objects ) do
        if ( md and o.tx ) then
            o.tx = mx
            o.ty = my
        end
        if ( o.Simulate ) then
            o:Simulate()
        end
        o:Draw()
    end
    --g = slider:GetValue()
end

d.touchbegan = function (touche)
    mx, my = touche.x, touche.y
    md = true
    mhold = true
    mpressed = true
end

d.touchmoved = function (touche)
    mx, my = touche.x, touche.y
    md = true
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
    draw.text( FrameTime, 20, 50, white )
    post()
    FrameTime = RealTime() - st
    CurTime = CurTime + FrameTime
    TickFix = FrameTime * 33.333
end
