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
local TILE_START = 1
local TILE_FINISH = 2
local TILE_PATH = 3

local TILE = {
    [TILE_EMPTY] = draw.white,
    [TILE_FINISH] = draw.yellow,
    [TILE_START] = draw.blue,
    [TILE_PATH] = draw.gray,
}

local nTilemapWidth = 16
local nTilemapHeight = math.floor( ScrRatio() * nTilemapWidth )
local nTilemapRatio = nTilemapWidth / nTilemapHeight
local nTileSize = 1 / nTilemapWidth
local tTilemap = {}
local sTravelStack = stack()
local nTotalTiles = nTilemapWidth * nTilemapHeight
local nCurTiles = 0

local function resettilemap()
    tTilemap = {}
    sTravelStack = stack()
    nCurTiles = 0
    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        tTilemap[i] = false
    end
end

local function toIndex( x, y )
    return x + y * nTilemapWidth
end

local function indexToXY( i )
    return i % nTilemapWidth, math.floor( i / nTilemapWidth )
end

local function getTile( x, y )
    return tTilemap[toIndex( x, y )]
end

local function setTile( x, y, i )
    local nIndex = toIndex( x, y )
    tTilemap[nIndex] = i
    tTilemap[nIndex][1], tTilemap[nIndex][2] = x, y
end

local function tilemapToWorld( x, y )
    return x * nTileSize, y * nTileSize
end

local function worldToTilemap( x, y )
    return x * nTilemapWidth, y * nTilemapWidth
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
    push( tTilemap[parent].children, toIndex( tile[1], tile[2] ) )
end

local function createTile( t )
    return {
        col = t.col,
        parent = t.parent,
        children = t.children or {},
    }
end

local function setTile2( x, y, i )
    nCurTiles = nCurTiles + 1
    local t = createTile( i )
    setTile( x, y, t )
    local p = vec2( x, y )
    push( sTravelStack, p )
    return t
end

local function expand( p )
    if ( nCurTiles >= nTotalTiles ) then
        return false
    end

    local tList, nListLen

    while ( true ) do
        tList, nListLen = findAround( p[1], p[2] )

        if ( nListLen > 0 ) then break end

        p = pop( sTravelStack )
    end

    push( sTravelStack, p )

    local vTile = tList[math.random(1,nListLen)]

    local bLast = nCurTiles + 1 >= nTotalTiles

    local t = setTile2( vTile[1], vTile[2], { col = TILE_EMPTY } )
    setParent( t, toIndex( p[1], p[2] ) )

    return true
end

local function createStartPoint()
    local sx, sy = math.random( 0, nTilemapWidth - 1 ), math.random( 0, nTilemapHeight - 1 )

    --[[if ( math.random( 0, 1 ) == 1 ) then
        sx = 0
    else
        sy = 0
    end]]

    local t = setTile2( sx, sy, { col = TILE_START, parent = toIndex( sx, sy ) } )
end

local function regenerate()
    resettilemap()
    createStartPoint()

    while ( true ) do
        local v = stacklast( sTravelStack )

        if ( not expand( v ) ) then
            for i = #sTravelStack, 2, -1 do
                local t = sTravelStack[i]
                local tTile = getTile( t[1], t[2] )
                --if ( tTile.col == TILE_EMPTY ) then
                tTile.path = true -- TILE_PATH
                --end
            end
            local t = pop( sTravelStack )
            local tTile = getTile( t[1], t[2] )
            tTile.col = TILE_FINISH
            break
        end
    end
end

local mCam

local function Init()
    mCam = mat3()
    local S = ScrW()
    mat3setSc( mCam, S, S )
    mat3setTr( mCam, 0, 0 * S )
    draw.setmatrix( mCam )

    local guiRestartButton = GUI.AddElement( "rect", ScrW( .5 ), ScrH( .75 ), ScrW( .2 ), ScrW( .2 ) )
    function guiRestartButton:Press()
        regenerate()
    end
    guiRestartButton.text = "regenerate"
end

local lastTile = false
local nNextStep = 0
local function Loop( CT, DT )
    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        local x, y = indexToXY( i )

        local aTile = getTile( x, y )
        local x1, y1 = tilemapToWorld( x, y )

        if ( aTile ) then
            draw.fillbox( x1, y1, nTileSize, nTileSize, TILE[aTile.col] )
        end
    end

    local hs = nTileSize * .5

    for i = 0, nTilemapWidth * nTilemapHeight - 1 do
        local x, y = i % nTilemapWidth, math.floor( i / nTilemapWidth )

        local aTile = getTile( x, y )

        if ( aTile ) then
            local x1, y1 = tilemapToWorld( x, y )
            local x2, y2 = tilemapToWorld( indexToXY( aTile.parent ) )
            local path = aTile.path
            draw.setlinestyle( path and 5 or 1, "round" )
            draw.line( x1 + hs, y1 + hs, x2 + hs, y2 + hs, path and draw.red or draw.purple )
        end
    end

    local mCursor = mat3()
    mat3mul( mCursor, mat3inv( mCam ), mCursor )
    local mx, my = mat3mulxy( mCursor, cursor.pos2() )

    local tx, ty = math.floor( mx * nTilemapWidth ) * nTileSize, math.floor( my * nTilemapWidth ) * nTileSize
    tx, ty = worldToTilemap( tx, ty )
    local aTile = getTile( tx, ty )

    if ( aTile and not lastTile ) then
        lastTile = aTile
    end

    if ( lastTile ) then
        local Tile = lastTile
        local t = toIndex( Tile[1], Tile[2] )
        local x1, y1 = tilemapToWorld( indexToXY( t ) )

        for i, t in ipairs( Tile.children ) do
            local x2, y2 = tilemapToWorld( indexToXY( t ) )
            draw.setlinestyle( 5, "round" )
            draw.line( x1 + hs, y1 + hs, x2 + hs, y2 + hs, draw.blue )
        end
    end

    if ( lastTile and nNextStep < CT ) then
        local next = lastTile.children[1]
        if ( not next ) then
            next = lastTile.parent
        end

        lastTile = getTile( indexToXY( next ) )
        nNextStep = CT + .4
    end
    --draw.fillbox( tx, ty, nTileSize, nTileSize, draw.gray )
end

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
