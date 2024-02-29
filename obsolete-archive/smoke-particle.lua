local perlin = require('perlin')
draw.showdrawscreen()
local scrw, scrh = draw.getdrawsize()
local black, white = draw.black, draw.white
local clear = draw.clear
local bg = {0,0,0,0}
local random = math.random

local function Remap( value, inMin, inMax, outMin, outMax )
    return outMin + ( ( ( value - inMin ) / ( inMax - inMin ) ) * ( outMax - outMin ) )
end

local wide, height = 512, 512
local savename = 'images/SmokePuff02.png'
local r, g, b = 1, .4, 0
perlin:load()

local rad = 256
local ox, oy = rad * .5, rad * .5

local post = draw.post
local point = draw.point
local text = draw.text
local sqrt = math.sqrt
local ftime = sys.gettime
local saved = false
local maxa = .8

local function Rand( low, high )
    return low + ( high - low ) * random()
end

local function Lerp( val_a, val_b, factor )
    return ( val_a * (1 - factor)) + (val_b * factor)
end

local function Clamp( val )
    return ( val > 1 and 1 ) or ( val < 0 and 0 ) or val
end

local function f1(x, y, dx, dxs)
    local dy = oy - y
    local dist = sqrt(dxs + dy * dy)
    local a = Remap(dist, 0, rad * .5, 1, 0)
    if a > maxa then a = maxa end
    if a < 0 then a = 0 end
    return a
end

local f = f1
local seed = math.random( 0, 1000 )

local mask = {}

local scl = .01

for x = -1, wide + 1 do
    mask[x] = {}
    for y = -1, height + 1 do
        local br = perlin:noise(x * scl, y * scl, seed)
        mask[x][y] = Clamp( br )--{ br, br, br, 1 }
    end
end

local imagetable = {}

for x = 0, wide do
    imagetable[x] = {}
    for y = 0, height do
        local m = mask[x][y]
        imagetable[x][y] = {m * r,m * g, m * b, 1}
        --imagetable[x][y] = {mask[x][y][1] * r,mask[x][y][2] * g, mask[x][y][3] * b,0}
    end
end

while true do
    local ft = ftime()
    clear( (saved and black) or bg)
    if not saved then

        for x = 0, wide do
            local dx = ox - x
            local dxs = dx * dx
            for y = 0, height do
                imagetable[x][y][4] = f(x, y, dx, dxs)
                point(x, y, imagetable[x][y])
            end
        end

        post()

        draw.imagesave(savename, 0, 0, rad, rad)
        saved = true
    else
        for x = 0, wide do
            for y = 0, height do
                point(x, y, imagetable[x][y])
            end
        end
    end
    text( ftime() - ft, 30, scrh - 30, white)
    post()
end
