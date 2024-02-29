local perlin = require('perlin')
local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local FrameTime = 0
local CurTime = 0
local RealTime = sys.gettime
local max, cos, sin = math.max, math.cos, math.sin
local fillrect, text = draw.fillrect, draw.text
local floor = math.floor

local line, circle = draw.line, draw.circle
draw.showdrawscreen()
local w, h = draw.getdrawsize()
clear()

local scroll = not false
local smin, smax = 0, 10
local bw = false

local function Remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

local function Clamp( inval, minval, maxval )
    if (inval < minval) then return minval end
    if (inval > maxval) then return maxval end
    return inval
end

local c = { 1, 1, 1, 1}

function c:Set( c )
    self[1] = c[1] or self[1]
    self[2] = c[2] or self[2]
    self[3] = c[3] or self[3]
    self[4] = c[4] or self[4]
    return self
end

function c:SetCh( r, g, b, a )
    self[1] = r or self[1]
    self[2] = g or self[2]
    self[3] = b or self[3]
    self[4] = a or self[4]
    return self
end

local minsize, maxsize = 50, w * .25

local sx, sy = 0, 0
local size = maxsize * .25
local seed = 0

local scale = .1

local s = w / size
local ratio = h / w
local wlvl, slvl, glvl = 0, .7, 1

local coltbl = {
    { .1, .1, .9 },
    { 1, 1, 0 },
    { .2, .7, .2 }
}

perlin:load()

local function Color( c, h )
    h = Clamp( h, 0, 1 )
    if bw then
        c[1] = h
        c[2] = h
        c[3] = h
        return
    end
    local r, g, b

    if ( h <= wlvl ) then
        c:Set( coltbl[ 1 ] )
    elseif ( h <= slvl ) then
        local c1, c2 = coltbl[1], coltbl[2]
        r = Remap( h, 0, slvl, c1[1], c2[1] )
        g = Remap( h, 0, slvl, c1[2], c2[2] )
        b = Remap( h, 0, slvl, c1[3], c2[3] )
        c:SetCh( r, g, b )
    else
        local c1, c2 = coltbl[2], coltbl[3]
        r = Remap( h, slvl, 1, c1[1], c2[1] )
        g = Remap( h, slvl, 1, c1[2], c2[2] )
        b = Remap( h, slvl, 1, c1[3], c2[3] )
        c:SetCh( r, g, b )
    end
end

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
    line( self.x , self.y, self.x + self.w, self.y, white )
    circle( self.ballx, self.bally, self.ballr, white )
    text( self.val, self.ballx - 20, self.bally - 20, white )
end

CSlider.__index = CSlider

local Objects = {}

local function AddObject( Class )
    local i = #Objects + 1
    Objects[i] = {}
    setmetatable( Objects[i], Class )
    Objects[i].id = i
    return Objects[i]
end

local function Slider(x, y, wd, min, max)
    return AddObject( CSlider ):New( x, y, wd, min, max )
end

local slider = Slider( nil, nil, nil, smin, smax )

local function Draw( ft, ct )
    for i= 0,size do
        for j= 0,size * ratio + 1 do
            local h = 2 * perlin:noise( (i + sx) * scale, (j + sy) * scale, seed)
            local x, y = s*(i-1), s*(j-1)
            Color( c, h )
            fillrect( x, y, x + s, y + s, c)
        end
    end
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
    --seed = ct
    if scroll then
        sx = sx + ft * 10
        sy = sy + sin( ct )
    end
    seed = slider:GetValue()
    --s = w / size
    --scale = scaleratio * size
    --scale = ( cos( ct ) + 2 ) * .03
    --text( scale, w * .1, h * .9, black )
end

draw.touchbegan = function (touche)
    mx, my = touche.x, touche.y
    md = true
    mhold = true
    mpressed = true
end

draw.touchmoved = function (touche)
    mx, my = touche.x, touche.y
    md = true
end

draw.touchended = function (touche)
    md = false
    mhold = false
end

while true do
    mpressed = false
    draw.doevents()
    clear()
    local f = RealTime()
    Draw( FrameTime, CurTime )
    FrameTime = RealTime() - f
    CurTime = CurTime + FrameTime
    post()
end
