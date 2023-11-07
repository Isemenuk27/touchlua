require( "libs/2dgui" )
require( "libs/math" )
local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red, yellow, blue = draw.red, draw.yellow, draw.blue

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
local mx, my = 0, 0
local cx, cy = hw - hw * .2, hh
local cw, ch = 500, 300

local abs = math.abs

function AABBCollide() end

function PointAABB( x1, y1, x2, y2, w, h )
    return ( x1 > x2 ) and ( y1 > y2 ) and ( x1 < x2 + w ) and ( y1 < y2 + hh )
end

function PointAABB( x1, y1, x2, y2, w, h )
    local hw, hh = w * .5, h * .5
    local ox, oy = x2 + hw, y2 + hh

    local dx = x1 - ox
    local px = hw - abs( dx )

    if (px <= 0) then
        return false
    end

    local dy = y1 - oy
    local py = hh - abs( dy )

    if (py <= 0) then
        return false
    end

    local hx, hy, hnx, hny, hdx, hdy

    if ( px < py ) then
        local sx = sign( dx )
        hdx = px * sx
        hnx = sx
        hx = ox + (hw * sx)
        hy = y1
    else
        local sy = sign( dy )
        hdy = py * sy
        hny = sy
        hx = x1
        hy = oy + (hh * sy)
    end

    return hx, hy, hnx, hny, hdx, hdy
end

function LineAABB( x1, y1, x2, y2, x3, y3, w, h, paddingX, paddingY )
    paddingX = paddingX or 0
    paddingY = paddingY or 0

    local dx, dy = x2 - x1, y2 - y1

    local scaleX = 1 / dx
    local scaleY = 1 / dy

    local signX = sign(scaleX)
    local signY = sign(scaleY)

    local hw, hh = w * .5, h * .5
    local ox, oy = x3 + hw, y3 + hh

    local nearTimeX = ( ox - signX * ( hw + paddingX ) - x1 ) * scaleX
    local nearTimeY = ( oy - signY * ( hh + paddingY ) - y1 ) * scaleY
    local farTimeX = ( ox + signX * ( hw + paddingX ) - x1 ) * scaleX
    local farTimeY = ( oy + signY * ( hh + paddingY ) - y1 ) * scaleY
    if ( nearTimeX > farTimeY or nearTimeY > farTimeX ) then
        return false
    end

    local nearTime = nearTimeX > nearTimeY and nearTimeX or nearTimeY
    local farTime = farTimeX < farTimeY and farTimeX or farTimeY
    if ( nearTime >= 1 or farTime <= 0 ) then
        return false
    end

    local hx, hy, hnx, hny, hdx, hdy, ht
    ht = clamp( nearTime, 0, 1 )

    if ( nearTimeX > nearTimeY ) then
        hnx = -signX
        hny = 0
    else
        hnx = 0
        hny = -signY
    end

    hdx = (1 - ht) * -dx
    hdy = (1 - ht) * -dy

    hx = x1 + dx * ht
    hy = y1 + dy * ht

    return hx, hy, hnx, hny, hdx, hdy, ht
end

function ClosestCircleAABB( x1, y1, r, x2, y2, w, h )
    local hw, hh = w * .5, h * .5
    local ox, oy = x2 + hw, y2 + hh

    local distx = x2 - x1
    local disty = y2 - y1

    local clmpx = clamp( distx, -hw, hw )
    local clmpy = clamp( disty, -hh, hh )

    local cx = ox + clmpx
    local cy = oy + clmpy

    local dx = cx - x1
    local dy = cy - y1

    return ( dx * dx + dy * dy ) > r * r
end

function AABBSolve( x1, y1, x2, y2, w1, h1, w2, h2 )
    local inX = x1 < x2 + w2 and x1 + w1 > x2
    local inY = y1 < y2 + h2 and y1 + h1 > y2

    if ( not ( inX and inY ) ) then return false end

    local hw1, hh1 = w1 * .5, h1 * .5
    local hw2, hh2 = w2 * .5, h2 * .5
    local ox1, oy1 = x1 + hw1, y1 + hh1
    local ox2, oy2 = x2 + hw2, y2 + hh2

    local dx, dy = 0, 0

    if ( ox1 > ox2 ) then
        dx = ox2 + ( hw2 - x1 )
    else
        dx = x2 - ( ox1 + hw1 )
    end

    if ( oy1 > oy2 ) then
        dy = oy2 + ( hh2 - y1 )
    else
        dy = y2 - ( oy1 + hh1 )
    end

    if ( abs( dx ) <= abs( dy ) ) then
        x1 = x1 + dx
    else
        y1 = y1 + dy
    end

    return x1, y1
end

function colliders()

end

function raycast( )

end

math.randomseed(10)

local cols = {}
for i = 1, 100 do
    local c = {}
    c.x = math.random( 100, w - 100 )
    c.y = math.random( 100, h - 100 )
    c.w = math.random( 10, 210 )
    c.h = math.random( 10, 210 )
    table.insert( cols, c )
end

local function Loop( CT, DT )

    local x1, y1, x2, y2 = mx, my, mx + 30, my + 30
    local aw, ah = 60, 60
    local c = false

    line(x1, y1, x1 + 200, y1 + 200, blue )

    for i, v in ipairs( cols ) do
        fillrect( v.x, v.y, v.x + v.w, v.y + v.h, white )

        local cx1, cy1 = LineAABB( x1, y1, x1 + 200, y1 + 200,v.x, v.y, v.w, v.h )

        if ( cx1 ) then
            --text( cx1, 20, 60, red
            line( x1, y1, cx1, cy1, red )
            circle( cx1, cy1, 7, red )
        end

        --circle( x1 + 100, y1 + 100, 7, cx1 and red or yellow )
        local nx, ny = AABBSolve( x1, y1, v.x, v.y, aw, ah, v.w, v.h )
        local coll = nx ~= false

        if ( coll ) then
            x1, y1 = nx, ny
            c = true
        end
    end

    if ( c ) then
        mx = x1
        my = y1
    end

    fillrect( x1, y1, x1 + 60, y1 + 60, c and red or green )
    text( floor( ( 1 / DT ) * 10 ) * .1, 20, 20, red )
    --text( , 20, 50, white )
end

local padx, pady = hw * .5, h - hh * .5
local padbs = padx * .8
local pad = padx * .1

local center = GUI.AddElement( "rect", padx, pady, padbs, padbs )
center.Think = function( self, pressed, hover )
    text( " ", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
end

local down = GUI.AddElement( "rect", padx, pady + padbs + pad, padbs, padbs )
down.Think = function( self, pressed, hover )
    text( "↓", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    my = my + FrameTime * 100
end

local up = GUI.AddElement( "rect", padx, pady - padbs - pad, padbs, padbs )
up.Think = function( self, pressed, hover )
    text( "↑", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    my = my - FrameTime * 100
end

local left = GUI.AddElement( "rect", padx - padbs - pad, pady, padbs, padbs )
left.Think = function( self, pressed, hover )
    text( "←", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    mx = mx - FrameTime * 100
end

local right = GUI.AddElement( "rect", padx + padbs + pad, pady, padbs, padbs )
right.Think = function( self, pressed, hover )
    text( "→", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    mx = mx + FrameTime * 100
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
