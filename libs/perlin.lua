local permutation = {
    151, 160, 137, 91, 90, 15,
    131, 13, 201, 95, 96, 53,
    194, 233, 7, 225, 140, 36,
    103, 30, 69, 142, 8, 99,
    37, 240, 21, 10, 23, 190,
    6, 148, 247, 120, 234, 75,
    0, 26, 197, 62, 94, 252,
    219, 203, 117, 35, 11, 32,
    57, 177, 33, 88, 237, 149,
    56, 87, 174, 20, 125, 136,
    171, 168, 68, 175, 74, 165,
    71, 134, 139, 48, 27, 166,
    77, 146, 158, 231, 83, 111,
    229, 122, 60, 211, 133, 230,
    220, 105, 92, 41, 55, 46,
    245, 40, 244, 102, 143, 54,
    65, 25, 63, 161, 1, 216, 80,
    73, 209, 76, 132, 187, 208,
    89, 18, 169, 200, 196, 135,
    130, 116, 188, 159, 86, 164,
    100, 109, 198, 173, 186, 3,
    64, 52, 217, 226, 250, 124,
    123, 5, 202, 38, 147, 118,
    126, 255, 82, 85, 212, 207,
    206, 59, 227, 47, 16, 58, 17,
    182, 189, 28, 42, 223, 183,
    170, 213, 119, 248, 152, 2,
    44, 154, 163, 70, 221, 153,
    101, 155, 167, 43, 172, 9,
    129, 22, 39, 253, 19, 98,
    108, 110, 79, 113, 224, 232,
    178, 185, 112, 104, 218, 246,
    97, 228, 251, 34, 242, 193,
    238, 210, 144, 12, 191, 179,
    162, 241, 81, 51, 145, 235,
    249, 14, 239, 107, 49, 192,
    214, 31, 181, 199, 106, 157,
    184, 84, 204, 176, 115, 121,
    50, 45, 127, 4, 150, 254,
    138, 236, 205, 93, 222,
    114, 67, 29, 24, 72, 243,
    141, 128, 195, 78, 66, 215,
    61, 156, 180
}

local cos, sin, pi = math.cos, math.sin, math.pi
local floor = math.floor

local function interpolate( a0, a1, w )
    return (a1 - a0) * w + a0
end

local function randomGradient( ix, iy )
    -- No precomputed gradients mean this works for any number of grid coordinates
    local w = 32
    local s = w * .5 -- rotation width
    local a = floor( ix )
    local b = floor( iy )
    a = a * 3284157443
    b = b ^ ( a << s | a >> w-s )
    b = b * 1911520717
    a = a ^ ( b << s | b >> w-s )
    a = a * 2048419325
    local random = a * ( pi / ~( 0xFFFF >> 1) )
    return cos(random), sin(random)
end

-- Computes the dot product of the distance and gradient vectors.
local function dotGridGradient( ix, iy, x, y )
    -- Get gradient from integer coordinates
    local gx, gy = randomGradient(ix, iy)

    -- Compute the distance vector
    local dx = x - ix
    local dy = y - iy

    -- Compute the dot-product
    return ( dx * gx + dy *gy )
end

-- Compute Perlin noise at coordinates x, y
function perlin( x, y )
    -- Determine grid cell coordinates
    local x0 = floor(x)
    local x1 = x0 + 1
    local y0 = floor(y)
    local y1 = y0 + 1

    -- Determine interpolation weights
    -- Could also use higher order polynomial/s-curve here
    local sx = x - x0
    local sy = y - y0

    -- Interpolate between grid point gradients
    local n0, n1, ix0, ix1, value

    n0 = dotGridGradient(x0, y0, x, y)
    n1 = dotGridGradient(x1, y0, x, y)
    ix0 = interpolate(n0, n1, sx)

    n0 = dotGridGradient(x0, y1, x, y)
    n1 = dotGridGradient(x1, y1, x, y)
    ix1 = interpolate(n0, n1, sx)

    value = interpolate(ix0, ix1, sy)
    return ( value + 1 ) * .5 -- [0,1]
end
