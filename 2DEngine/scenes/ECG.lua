if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local function inRange( x, a, b )
    return x > a and x < b
end

local function ECG( x ) -- https://www.desmos.com/calculator/xpnbjcemcf
    x = x % 1
    if ( inRange( x, 0.02, 0.15963 ) ) then
        return math.sin( -0.45 + x * 22.5 ) * 0.07
    elseif ( inRange( x, 0.241, 0.26015 ) ) then
        return ( -x + 0.241 ) * 1.6
    elseif ( inRange( x, 0.26015, 0.3635 ) ) then
        return ( x - 0.268 ) * 3.9
    elseif ( inRange( x, 0.3635, 0.4607 ) ) then
        return ( -x + 0.438 ) * 5
    elseif ( inRange( x, 0.4607, 0.51 ) ) then
        return ( x - 0.51 ) * 2.3
    elseif ( inRange( x, 0.6, 0.8327 ) ) then
        return math.sin( -8.1 + x * 13.5 ) * 0.108
    end

    return 0
end

local function Init()
    local cam = mat3()
    local s = ScrW()
    mat3setSc( cam, s, s )
    mat3setTr( cam, 0, 1 * s )
    draw.setmatrix( cam )
end

local function InExpo( x )
    return x == 0 and 0 or ( 2 ^ ( 10 * x - 10 ) )
end

local c = { 0, 1, 0, 1 }
local function Loop( CT, DT )
    local w, h = 1, 0
    local num = 250
    local step = 1 / num

    local BPM = 73
    local BPS = BPM / 60

    local offset = CT * BPS
    local amplitude = 1

    for i = 0, .8, step do
        --c[4] = InExpo( i )
        local j = i + step
        local h1 = ECG( i + offset ) * amplitude
        local h2 = ECG( j + offset ) * amplitude
        draw.line( w * i, h - h1, w * j, h - h2, c )
    end
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
