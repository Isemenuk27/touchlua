if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local cos, sin, ceil = math.cos, math.sin, math.ceil

local div = 8

local function Loop( CT, DT )
    local ox, oy = .5, .5 * ScrRatio()
    local lx, ly

    div = 2 + ( cos( CT ) + 1 ) * .5 * 16

    local step = ( math.pi * 2 ) / ceil( div )
    for i = 0, div do
        local a = step * ( ( CT % (math.pi * 2) ) + i )
        local x, y = ox + cos( a ) * .2, oy + sin( a ) * .2

        if ( lx ) then
            filltri( lx, ly, x, y, ox, oy, draw.white )
        end

        lx, ly = x, y
    end
end

callback( _LOOPCALLBACK
  , Loop )
