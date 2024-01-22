if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local function isometricrender( CT, DT )
    local tiles = 8
    local size = 1

    for i = 0, tiles * tiles - 1 do
        local x, y = i % tiles, math.floor( i / tiles )
        local col = ( ( ( x + y ) % 2 ) == 0 ) and draw.white or draw.gray

        x, y = x * size, y * size

        draw.filltriangle( x, y, x + size, y, x + size, y + size, col )
        draw.filltriangle( x, y, x + size, y + size, x, y + size, col )
        --[[ ]]

        local c = draw.blue
        draw.line( x, y, x + size, y, c )
        draw.line( x, y, x, y + size, c )
        draw.line( x + size, y + size, x + size, y, c )
        draw.line( x + size, y + size, x, y + size, c )
    end
end

local m, cam

local function Init()
    m = mat3()

    local a = ( 3 ^ .5 ) / 2
    mat3setSheer( m, vec2( a, 0 ) )
    mat3setSc( m, 1, 1 )

    cam = mat3()
    local s = ScrW() / 10
    mat3setSc( cam, s, s )

    --mat3setTr( cam, sc * .5, sc ) -- s * .5, s * .5)
    draw.setmatrix( cam )
end

local function Loop( CT, DT )

    local cursormat = mat3()
    local mx, my = cursor()
    --mat3setTr( cursormat, mx, my )

    mat3mul( cursormat, mat3inv( cam ), cursormat )
    mat3mul( cursormat, mat3inv( m ), cursormat )
    --mat3setSheer( m, vec2mul( vec2( cursor() ), 1 / ScrW() ) )

    local ml = 16 / ScrW()
    local tx, ty = mat3getTr( m )
    local dx, dy = cursordeltax() * ml, cursordeltay() * ml
    mat3setTr( m, tx + dx, ty + dy )

    draw.pushmatrix( m )

    isometricrender( CT, DT )

    local a, b = mat3mulxy( cursormat, cursor() )
    --[[ draw.line( 0, 0, a, b, draw.red )
    draw.cross( a, b, 1, draw.red ) ]]--

    --draw.text( vec2tostring( vec2(a, b) ), a, b )

    local x, y = math.floor( a ), math.floor( b )
    local col = draw.purple
    draw.filltriangle( x, y, x + 1, y, x + 1, y + 1, col )
    draw.filltriangle( x, y, x + 1, y + 1, x, y + 1, col )

    draw.text( string.format( "%.2i / %.2i", x, y ), x, y + .5 )

    draw.popmatrix()
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
