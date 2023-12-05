if ( not Inited ) then require( "init" ) return end

local w, h = Scr()
local hw, hh = HScr()

local white, black, green, red = draw.white, draw.black, draw.green, draw.red
local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi, hpi = math.sqrt, math.random, math.pi, math.pi * .5
local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local function smooth( x )
    return  0.5 * (1 - cos( 2 * pi * x) )
end

local skynum = 1

local skys = {
    { { 4 / 255, 0, 68 / 255 },
    { 37 / 255, 161 / 255, 170 / 255 }, },

    { { 31 / 255, 54 / 255, 76 / 255 },
    { 168 / 255, 105 / 255, 0 / 255 }, },

    { vec3mul( vec3( 248, 212, 171 ), 1 / 255 ),
    vec3mul( vec3( 85, 124, 173 ), 1 / 255 ), },

    { vec3mul( vec3(108), 1 / 255 ),
    vec3mul( vec3(89), 1 / 255 ) },
}

local skycol1, skycol2, skydiff

if ( skys[skynum] ) then
    skycol1 = skys[skynum][1]
    skycol2 = skys[skynum][2]
    skydiff = { skycol2[1] - skycol1[1], skycol2[2] - skycol1[2], skycol2[3] - skycol1[3] }
end

local sky = { 1, 0, 1, 1 }

function drawsky()
    if ( not skycol1 ) then
        return clear( black )
    end

    local step = h / 40
    local b = h / step

    for i = 0, b do
        local c = smooth( .5 * ( ( ( GetCamDir()[2] + 1 ) * .5 ) - (i/b) ) )

        for j = 1, 3 do
            sky[j] = skycol1[j] + ( skydiff[j] * c )
        end

        local y = step * i

        fillrect( 0, y, w, y + step, sky )
    end
end
