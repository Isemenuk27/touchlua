if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local draw = draw

local TILE_EMPTY = false
local TILE_SPAWN = 1
local TILE_WHITE = 2
local TILE_RED = 3
local TILE_GRAY = 4

local TILE = {
    [TILE_WHITE] = draw.white,
    [TILE_RED] = draw.red,
    [TILE_SPAWN] = draw.blue,
    [TILE_GRAY] = draw.gray,
}

local nTilemapWidth = 20
local nTilemapHeight = 20
local nTileSize = 1 / nTilemapWidth
local tTilemap = {}
local sTravelStack = stack()
local nTotalTiles = nTilemapWidth * nTilemapHeight
local nCurTiles = 0

local function resettilemap()
    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        tTilemap[i] = false
    end
end

local function toIndex( x, y )
    return x + y * nTilemapWidth
end

local function indexToXY( i )
    return i % nTilemapWidth, math.floor( i / nTilemapHeight )
end

local function getTile( x, y )
    return tTilemap[toIndex( x, y )]
end

local function setTile( x, y, i )
    tTilemap[toIndex( x, y )] = i
end

local function tilemapToWorld( x, y )
    return x * nTileSize, y * nTileSize
end

local function inBounds( x, y )
    return x >= 0 and x < nTilemapWidth and y >= 0 and y < nTilemapHeight
end

local dir = { vec2( 1, 0 ), vec2( 0, 1 ), vec2( -1, 0 ), vec2( 0, -1 ) }

local function findAround( x, y )
    local tList, nListLen = {}, 0
    for i in ipairs( dir ) do
        local cx, cy = x + dir[i][1], y + dir[i][2]
        if ( not inBounds( cx, cy ) ) then goto skipfind end
        if ( getTile( cx, cy ) ~= false ) then goto skipfind end
        do
            nListLen = nListLen + 1
            tList[nListLen] = vec2( cx, cy )
        end
        ::skipfind::
    end

    return tList, nListLen
end

local function getParent( tile )
    return tile.parent
end

local function setParent( tile, parent )
    tile.parent = parent
end

local function setTile2( x, y, i )
    nCurTiles = nCurTiles + 1
    setTile( x, y, i )
    local t = vec2( x, y )
    push( sTravelStack, t )
    return t
end

local function expand( p )
    if ( nCurTiles >= nTotalTiles ) then
        return
    end

    local tList, nListLen

    while ( true ) do
        tList, nListLen = findAround( p[1], p[2] )

        if ( nListLen > 0 ) then break end

        p = pop( sTravelStack )
    end

    push( sTravelStack, p )

    local vTile = tList[math.random(1,nListLen)]

    local t = setTile2( vTile[1], vTile[2], {
    col = TILE_WHITE, parent = toIndex( p[1], p[2] ) } )

    if ( nCurTiles >= nTotalTiles ) then
        for i, t in ipairs( sTravelStack ) do
            getTile( t[1], t[2] ).col = TILE_GRAY
        end
    end
end

local function createStartPoint()
    local sx, sy = math.random( 0, nTilemapWidth - 1 ), math.random( 0, nTilemapHeight - 1 )

    if ( math.random( 0, 1 ) == 1 ) then
        sx = 0
    else
        sy = 0
    end

    local t = setTile2( sx, sy, { col = TILE_SPAWN, parent = toIndex( sx, sy ) } )
end

local function Init()
    local mCam = mat3()
    local S = ScrW()
    mat3setSc( mCam, S, S )
    mat3setTr( mCam, 0, .5 * S )
    draw.setmatrix( mCam )

    resettilemap()
    createStartPoint()
end

local nNextExpand = 0

local function Loop( CT, DT )
    for i = 0, 1, nTileSize do
        draw.line( 0, i, 1, i )
        draw.line( i, 0, i, 1 )
    end

    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        local x, y = indexToXY( i )

        local aTile = getTile( x, y )
        local x1, y1 = tilemapToWorld( x, y )

        if ( aTile ) then
            draw.fillrect( x1, y1, x1 + nTileSize, y1 + nTileSize, TILE[aTile.col] )
            --draw.text( x .. " / " .. y, x1, y1 + nTileSize * .5, draw.black )
        end
    end

    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        local x, y = i % nTilemapWidth, math.floor( i / nTilemapWidth )

        local aTile = getTile( x, y )

        if ( aTile ) then
            local x1, y1 = tilemapToWorld( x, y )

            local x2, y2 = tilemapToWorld( indexToXY( aTile.parent ) )
            local hs = nTileSize * .5
            draw.line( x1 + hs, y1 + hs, x2 + hs, y2 + hs, draw.purple )
        end
    end

    if ( nNextExpand < CT ) then
        local v = stacklast( sTravelStack )
        expand( v )
        nNextExpand = CT + .0
    end
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
