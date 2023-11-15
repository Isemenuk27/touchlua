local d = draw
local clear, post, otext = d.clear, d.post, d.text
local ipairs, pairs = ipairs, pairs
local cos, sin, rad, deg = math.cos, math.sin, math.rad, math.deg
local tan, random, floor = math.tan, math.random, math.floor
local red, green, white, black = d.red, d.green, d.white, d.black

--////////////
local accuracy = 4
local maxcycles = 70
--////////////


local gray
do
    local br = .3
    gray = { br, br, br, 1 }
end

local CurTime, FrameTime, RealTime = 0, 0, sys.gettime
local circle, line = d.circle, d.line
local sqrt, atan, pi = math.sqrt, math.atan, math.pi
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

local cs = 20

local function cross( x, y, c )
    line( x - cs, y, x + cs, y, c or green )
    line( x, y - cs, x, y + cs, c or green )
end

local CCircle = {}

function CCircle:New( x, y, r )
    self.x = x or random( 0, w )
    self.y = y or random( 0, h )
    self.r = r or random( 30, 120 )
    return self
end

function CCircle:Draw()
    circle( self.x, self.y, self.r, green )
end

CCircle.__index = CCircle

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

local function Circle(x, y, r)
    return AddObject( CCircle ):New( x, y, r )
end

local t = {
    { 800, 600, 200 },
    { 503, 383, 120 },
    { 360, 690, 60 },
    { 1104, 204, 90 },
    { 600, 1700, 80 },
    { 1000, 200, 180 },
    { false, false, false },
    { false, false, false },
    { false, false, false }
}

for i, c in ipairs( t ) do
    Circle(c[1], c[2], c[3])
end

local closest, closestId
local cx, cy, cdx, cdy = 0, 0, 0, 0

local function GetDists( x, y )
    closest = nil
    for i, o in pairs( Objects ) do
        if o.r then
            local dx, dy = o.x - x, o.y - y
            local d = sqrt( dx * dx + dy * dy ) - o.r
            if ( not closest or d < closest ) then
                closest = d
                closestId = o.id
                cdx, cdy = dx, dy
            end
        end
    end
    return closest, closestId
end

local function GetClosestDists( x, y )
    local d, id = GetDists( x, y )
    if ( not d ) then return end

    local o = Objects[ id ]

    local il = 1 / (d + o.r)
    local l = o.r
    local nx, ny = cdx * il, cdy * il
    cx, cy = o.x - nx * l, o.y - ny * l

    --circle( x, y, d * 1, red )
    --line(x, y, cx, cy, gray )

    local dirx, diry = cx - x, cy - y
    local dist = sqrt( dirx * dirx + diry * diry)
    --text( dist, ( x + cx ) * .5, ( y + cy ) * .5 )
    return dist
end

local function Raymarch( PosX, PosY, EndX, EndY )
    local DirX, DirY = EndX - PosX, EndY - PosY
    local Length = sqrt( DirX * DirX + DirY * DirY )
    local IL = 1 / Length
    local NrmX, NrmY = DirX * IL, DirY * IL

    local ang = atan( NrmY, NrmX )

    local Ended, ClosestDist = false, nil
    local h = 0
    local x, y = PosX, PosY
    local TotalDist = 0

    while ( h < maxcycles ) do
        local l = ClosestDist or 0
        ClosestDist = GetClosestDists( x, y )
        TotalDist = TotalDist + ClosestDist
        if ( TotalDist > Length ) then
            ClosestDist = ClosestDist - ( TotalDist - Length)
            TotalDist = Length
        end
        circle( x, y, ClosestDist, red )
        x, y = x + cos( ang ) * ClosestDist, y + sin( ang ) * ClosestDist
        h = h + 1
        if ( ClosestDist < accuracy ) then break end
        if ( TotalDist >= Length ) then break end
    end
    text( floor(TotalDist) .. " " .. floor(Length) .. " " .. h, w - 200, 30 )
end

local PosX, PosY = hw, hh
local EndX, EndY = 0, 0
local NrmX, NrmY = 0, 0
local DirX, DirY = 0, 0

local rx, mr, mup = 0, 0, 0
local rd = 1000
local anl = 0

local function Draw( dt, ct )
    for i, o in pairs( Objects ) do
        o:Draw()
    end
    anl = (anl + rx)
    local angl = rad( anl )
    local endx, endy = PosX + cos(angl) * rd, PosY + sin(angl) * rd

    PosX = PosX + mr * FrameTime * 100
    PosY = PosY - mup * FrameTime * 100

    line( PosX, PosY, endx, endy, gray )

    cross( PosX, PosY, green )
    cross( endx, endy, green )

    Raymarch( PosX, PosY, endx, endy )

    text( PosX .. "," .. PosY .. "  " .. (floor(FrameTime * 1000) * .001), 20, 60 )
end

clear( black )

d.touchbegan = function (touche)
    mx, my = touche.x, touche.y

    md = true
    mhold = true
    mpressed = true

    if my < h - 400 then
        if mx < 100 then
            rx = -1
        elseif mx > w - 400 then
            rx = 1
        end
    else
        if (mx < hw + 200) and (mx > hw - 200) then
            mup = (my < h - 50) and 1 or - 1
        else
            mr = (mx > hw) and 1 or -1
        end
    end
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
