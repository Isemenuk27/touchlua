NO2DGUI = true

if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local function Init()
    bg_color = { 1, 0, 0, 0 }
    bg_clear = false
end

callback( "Init", Init )

local function Loop( CT, DT )
    for nId in cursor.down() do
        draw.cross( cursor.pos( nId ), 20 )
        local nX, nY = vec2unpack( cursor.pos( nId ) )
        draw.text( nId, nX + 20, nY + 8)
    end

    bg_clear = frameNum() % 100 == 0
end

callback( _LOOPCALLBACK, Loop )
