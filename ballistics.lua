local GUI = require "libs/2dgui"

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

--#####################################--
local gridsize = 190 --meters
local textevery = 50
local gridunit = w / ( gridsize * 2 )--1 pixel to grid
local ratio = h / w

local ox, oy = hw, hh
local g = 9.81
local r = 60
local v = 120 --3000 / 39.37
local h1 = .1
local h2 = 40
local SU = 39.37

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

local mx, my = 0, 0
local a = 0

local function Loop( CT, DT )

    grid()

    --r = ( my / h ) * 200
    --local a = atan(( v * v + sqrt( v ^ 4 - g * (g * r + 2 * h1 * ( v * v ) ))) / (g * r))

    local a = atan( ( v * v + sqrt( v ^ 4 - g * ( g * (r * r) + 2 * (h2 - h1) * (v * v) ) ) ) / (g * r))

    --[[if GUI.cursors[1] then
        mx, my = GUI.cursors[1].x, GUI.cursors[1].y
        a = atan( oy - my, mx - ox )
    end]]--

    do
        local ta = floor( deg( a ) * 100 ) * .01
        local tv = floor( v * 100 ) * .01
        local tr = floor( r * 100 ) * .01

        tv = tv .. "(" .. tv * 39.37 .. ")"
        tr = tr .. "(" .. tr * 39.37 .. ")"

        local y = oy - h1 * gridunit

        text( "a⁰: " .. ta, ox, y + 15, yellow )
        text( "vel: " .. tv, ox, y + 37, yellow )
        text( "r: " .. tr, ox, y + 53, yellow )
    end

    local bx = ( ( CT * 50 ) % gridsize ) * 2 - gridsize

    local by = TrajectoryPoint( h1, a, v, bx ) * gridunit

    local lx, ly

    local xh = 0

    for x = -gridsize, gridsize do
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
    end

    local dh2 = oy - h2 * gridunit
    line( ox, dh2, xh, dh2, green )

    local dh = oy - h1 * gridunit
    line( ox, dh, -xh, dh, red )

    --line( ox, oy - h2 / gridunit, ox + r * gridunit, oy - h2 / gridunit, green )
    line( ox, oy, ox + cos(a) * w * .1, oy - sin(a) * w * .1, yellow )

    circle( ox + bx * gridunit, oy - by, 4, yellow )
    --text( bx, 20, 40, white )
    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
end

GUI.AddElement( "rect", w * .75, h * .85, w * .2, w * .2 ).Think = function( self, pressed )
    text( "v+", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    v = v + FrameTime * 50
end

GUI.AddElement( "rect", w * .05, h * .85, w * .2, w * .2 ).Think = function( self, pressed )
    text( "v-", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    v = v - FrameTime * 50
end

GUI.AddElement( "rect", w * .52, h * .85, w * .2, w * .2 ).Think = function( self, pressed )
    text( "r+", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    r = r + FrameTime * 100
end

GUI.AddElement( "rect", w * .27, h * .85, w * .2, w * .2 ).Think = function( self, pressed )
    text( "r-", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    r = r - FrameTime * 100
end

GUI.AddElement( "rect", w * .52, h * .65, w * .2, w * .2 ).Think = function( self, pressed )
    text( "h1+", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    h1 = h1 + FrameTime * 100
end

GUI.AddElement( "rect", w * .27, h * .65, w * .2, w * .2 ).Think = function( self, pressed )
    text( "h1-", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    h1 = h1 - FrameTime * 100
end

GUI.AddElement( "rect", w * .75, h * .65, w * .2, w * .2 ).Think = function( self, pressed ) text( "h2+", self.x + self.w * .5, self.y + self.h * .5, white ) if ( not pressed ) then return end h2 = h2 + FrameTime * 100 end
GUI.AddElement( "rect", w * .05, h * .65, w * .2, w * .2 ).Think = function( self, pressed ) text( "h2-", self.x + self.w * .5, self.y + self.h * .5, white ) if ( not pressed ) then return end h2 = h2 - FrameTime * 100 end

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
