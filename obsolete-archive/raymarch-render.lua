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
d.showdrawscreen()
local w, h = d.getdrawsize()
local hw, hh = w * .5, h * .5
local mx, my, md, mhold, mpressed = 0, 0, false, false, false

--//////////// Raymarch options
local accuracy = 1 --4 -- Smaller - Better
local maxcycles = 29
--//////////// Render options
local draw2d = not false -- Render 2d objects
local drawrays = false -- Render ray line
local spawncircles = not false
local randcirc = 20 -- Amount of random circles
local Quality = 2 --Bigger - Better
local Fov = 90
local farclip = 1000 --Max length of ray
--////////////

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

local CCircle = {}

function CCircle:New( x, y, r )
    self.x = x or random( 0, w )
    self.y = y or random( 0, h )
    self.r = r or random( 30, 120 )
    self.c = { Rand( 0, 1 ), Rand( 0, 1 ), Rand( 0, 1 ), .2 }
    return self
end

function CCircle:Draw()
    circle( self.x, self.y, self.r, self.c or green )
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

if ( spawncircles ) then
    local t = {
        { 800, 600, 200 },
        { 503, 383, 120 },
        { 360, 690, 60 },
        { 1104, 204, 90 },
        { 600, 1700, 80 },
        { 1000, 200, 180 }
    }

    for i, c in ipairs( t ) do
        Circle(c[1], c[2], c[3])
    end

    for i = 1, randcirc do
        Circle()
    end
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

    local dirx, diry = cx - x, cy - y
    local dist = sqrt( dirx * dirx + diry * diry)
    return dist, id
end

local function Raymarch( PosX, PosY, EndX, EndY, Angle )
    local DirX, DirY = EndX - PosX, EndY - PosY
    local Length = sqrt( DirX * DirX + DirY * DirY )
    local IL = 1 / Length
    local NrmX, NrmY = DirX * IL, DirY * IL

    local ang = atan( NrmY, NrmX )

    Length = Length * ( Angle and cos( ang - Angle ) or 1 )

    local Ended, ClosestDist = false, nil
    local h = 0
    local x, y = PosX, PosY
    local TotalDist = 0
    local id

    while ( h < maxcycles ) do
        local l = ClosestDist or 0
        ClosestDist, id = GetClosestDists( x, y )
        if ( not ClosestDist ) then ClosestDist = Length end
        TotalDist = TotalDist + ClosestDist
        if ( TotalDist > Length ) then
            ClosestDist = ClosestDist - ( TotalDist - Length)
            TotalDist = Length
        end
        --circle( x, y, ClosestDist, red )
        x, y = x + cos( ang ) * ClosestDist, y + sin( ang ) * ClosestDist
        h = h + 1
        if ( ClosestDist < accuracy ) then break end
        if ( TotalDist >= Length ) then break end
    end
    if ( drawrays ) then
        line( PosX, PosY, x, y )
    end
    return TotalDist, x, y, id
end

local PosX, PosY = hw, hh
local EndX, EndY = 0, 0
local NrmX, NrmY = 0, 0
local DirX, DirY = 0, 0

local rx, mr, mup = 0, 0, 0
local rd = farclip
local anl = 0

local HFov = Fov * .5
local IFov = Quality * HFov
local QMod = 1 / Quality

local xspacing = w / (Fov * Quality)
local oy = hh * .5
local miny = oy * .5
local drawcol = { 1, 1, 1, 1 }

local fpsi = 1
local fpst = {}
local fpslen = 10

local function Draw( dt, ct )
    if ( draw2d ) then
        for i, o in pairs( Objects ) do
            o:Draw()
        end
    end

    local sum = 0
    for _, val in ipairs(fpst)do
        sum = sum + val
    end

    local FPS = sum / fpslen

    fpst[fpsi] = 1 / FrameTime
    fpsi = (fpsi % fpslen) + 1

    anl = (anl + rx)
    local angl = rad( anl )
    local pdx, pdy = cos(angl) * rd, sin(angl) * rd
    local anglr = angl + pi2
    local pdxr, pdyr = cos( anglr ) * rd, sin( anglr ) * rd
    local endx, endy = PosX + pdx, PosY + pdy
    local pdist = sqrt( pdx * pdx + pdy * pdy )
    local pIdist = 1 / pdist
    local pnx, pny = pdx * pIdist, pdy * pIdist
    local pnxr, pnyr = pdxr * pIdist, pdyr * pIdist

    if ( mup ~= 0 ) then
        local mf = mup * FrameTime * 100
        PosX = PosX + mf * pnx
        PosY = PosY + mf * pny
    end
    if ( mr ~= 0 ) then
        local mf = mr * FrameTime * 100
        PosX = PosX + mf * pnxr
        PosY = PosY + mf * pnyr
    end

    cross( PosX, PosY, green )
    cross( endx, endy, green )
    line( PosX, PosY, endx, endy, gray )

    local sx, sy = PosX, PosY

    local ih = 0

    for i = -IFov, IFov do
        local im = i * QMod
        local a = rad(anl + im)
        local ex, ey = sx + cos(a) * rd, sy + sin(a) * rd

        local d, hx, hy, id = Raymarch( sx, sy, ex, ey, angl )
        local dh = Remap( d, 0, rd, miny, 0)
        if ( id ) then
            local br = Clamp( Remap( d, 0, rd, 1, 0 ), 0, 1 )
            for c = 1, 3 do
                drawcol[ c ] = Objects[id].c[c] * br
            end
        else
            local br = Clamp( Remap( d, 0, rd, 1, 0 ), 0, 1 )
            for c = 1, 3 do
                drawcol[c] = br
            end
        end
        local rx1, ry1 = xspacing * ih, oy - dh
        local rx2, ry2 = rx1 + xspacing, oy + dh
        ih = ih + 1
        fillrect( rx1, ry1, rx2, ry2, drawcol )
    end

    rect( 0, 0, 100, h - 400, gray )
    rect( w - 100, 0, w, h - 400, gray )
    rect( hw - 200, h - 400, hw + 200, h, gray )
    line( hw - 200, h - 200, hw + 200, h - 200, gray )
    rect( 0, h - 400, hw - 200, h, gray )
    rect( hw + 200, h - 400, w, h, gray )

    text( "FPS: " .. FPS .. " FT: " .. (floor(FrameTime * 1000) * .001), 20, 60 )
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
        elseif mx > w - 100 then
            rx = 1
        end
    else
        if (mx < hw + 200) and (mx > hw - 200) then
            mup = (my < h - 200) and 1 or - 1
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
