if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

--[[          Config                 ]]

local cfg = {
    forceattack = true, --if attack is possible make it only valid move
    nobackwardmove = true, --disallow to move backwards freely
    allqueens = false, --make every unit a queen at start
    move8 = false, --ability to move in any direction
    size = 8, --board width and height
}

local function rgb( r, g, b )
    return { r / 255, g / 255, b / 255, 1 }
end

local T_WHITE = 0
local T_BLACK = 1

local TeamTurn = 0

local bg1, bg2 = rgb(37, 64, 6), rgb(111, 43, 3)

local tCol = {
    [T_WHITE] = { .9, .9, .9, 1 },
    [T_BLACK] = { .1, .1, .1, 1 }
}

local tFrags = {
    [T_WHITE] = 0,
    [T_BLACK] = 0
}

local function opositeteam( n )
    if ( n == T_WHITE ) then
        return T_BLACK
    end
    return T_WHITE
end

local t_checkers, t_tiles = {}, {}

local tiles = cfg.size
local size = 1

local function drawtile( x, y, c )
    draw.filltriangle( x, y, x + size, y, x + size, y + size, c )
    draw.filltriangle( x, y, x + size, y + size, x, y + size, c )
end

local m1 = mat3()
local m2 = mat3()

local sheer = 1

mat3setSheer( m1, vec2( 0, -sheer ) )
mat3setSheer( m2, vec2( -sheer, 0 ) )

local function drawboard( CT, DT )
    for i = 0, tiles * tiles - 1 do
        local x, y = i % tiles, math.floor( i / tiles )
        local col = ( ( ( x + y ) % 2 ) == 0 ) and bg1 or bg2
        drawtile( x, y, col )
    end

    local c = draw.yellow

    draw.pushmatrix( m1 )
    for y = 0, tiles - 1 do
        local col = ( y % 2 == 1 ) and bg1 or bg2
        drawtile( -1, y, col )
        draw.text( y + 1, -.5, y + .5 )
    end

    for y = 0, tiles do
        draw.line( -1, y, 0, y, c )
    end
    draw.line( -1, 0, -1, tiles, c )

    draw.popmatrix()

    draw.pushmatrix( m2 )
    for x = 0, tiles - 1 do
        local col = ( x % 2 == 0 ) and bg1 or bg2
        drawtile( tiles + x, tiles, col )
        draw.text( string.char(65+x), tiles + x + .5, tiles + .5 )
    end

    for x = 0, tiles do
        draw.line( tiles + x, tiles, tiles + x, tiles+1, c )
    end

    draw.line( tiles, tiles+1, tiles + tiles, tiles+1, c )

    draw.popmatrix()
end

local function drawgridoverlay()
    local c = draw.green

    for i = 0, tiles do
        draw.line( i, 0, i, tiles, c )
        draw.line( 0, i, tiles, i, c )
    end
end

local function killmovetiles()
    for i, tile in ipairs( t_tiles ) do
        tile:remove()
        t_tiles[i] = nil
    end
end

--**********************
local CMoveTile = {}
CMoveTile.__index = CMoveTile

function CMoveTile.new()
    local tile = setmetatable( {
        pos = vec2(),
        linked = false,
        target = false,
    }, CMoveTile )
    return tile
end

function CMoveTile.construct( cheker )

end

function CMoveTile:setPos( ... )
    vec2set( self.pos, ... )
end

function CMoveTile:press()
    killmovetiles()

    if ( self.target ) then
        self.target:kill()
    end

    self.linked:move( self.pos )

    TeamTurn = opositeteam( TeamTurn )
end

function CMoveTile:link( cheker )
    self.linked = cheker
end

local selecttilecol = { .2, 0, 1, .5 }

function CMoveTile:draw()
    drawtile( self.pos[1], self.pos[2], selecttilecol )

    if ( self.target ) then
        for i = 0, 1, .1 do
            draw.line( self.pos[1] + i, self.pos[2], self.pos[1], self.pos[2] + i, draw.gray )
        end

        for i = 0, 1, .1 do
            draw.line( self.pos[1] + i, self.pos[2] + 1, self.pos[1] + 1, self.pos[2] + i, draw.gray )
        end
    end

    --draw.text( tostring(self.target), self.pos[1], self.pos[2] )
end

function CMoveTile:remove()
    self = nil
    return
end

function CMoveTile:settarget( t )
    self.target = t
end

function CMoveTile:gettarget( t )
    return self.target
end

local function pointoutboard( x, y )
    return ( x < 0 or x > cfg.size - 1 ) or ( y < 0 or y > cfg.size - 1)
end

local tdir = {
    vec2( -1, 1 ),
    vec2( 1, 1 ),
    vec2( 1, -1 ),
    vec2( -1, -1 )
}

if ( cfg.move8 ) then
    tdir = {
        vec2( -1, 1 ),
        vec2( 0, 1 ),
        vec2( 1, 1 ),
        vec2( 1, 0 ),
        vec2( 1, -1 ),
        vec2( 0, -1 ),
        vec2( -1, -1 ),
        vec2( -1, 0 )
    }
end

local function getintile( v )
    for i, checker in ipairs( t_checkers ) do
        if ( ( not checker.inactive ) and 0.01 > vec2distsqr( checker.pos, v ) ) then
            return checker
        end
    end

    return false
end

local tMoveDir = {
    [T_WHITE] = -1,
    [T_BLACK] = 1
}

local queenypos = {
    [T_WHITE] = tiles - 1,
    [T_BLACK] = 0,
}

function ConstructMoveTiles( checker )
    local ox, oy = vec2unpack( checker.pos )
    local killnontarget = false

    for i in ipairs( tdir ) do
        local numsteps = ( checker.queen == true ) and 13 or 1
        local curp = vec2( ox, oy )
        local killtarget = false

        repeat
            vec2add( curp, tdir[i] )

            local dot = vec2dot( vec2( 0, tdir[i][2] ), vec2( 0, queenypos[checker.team] - checker.pos[2] ) )

            if ( pointoutboard( vec2unpack( curp ) ) ) then
                numsteps = 0
            else
                local checkertarget = getintile( curp )

                if ( checkertarget ) then
                    if ( checker.team == checkertarget.team ) then
                        numsteps = 0
                    elseif ( not killtarget ) then
                        killtarget = checkertarget
                    else
                        numsteps = 0
                    end
                else
                    if ( not checker.queen and not killtarget ) then
                        if ( cfg.nobackwardmove and dot < 0 ) then
                            numsteps = 0
                            goto skip
                        end
                    end

                    local tile = CMoveTile.new()
                    tile:setPos( curp )
                    tile:link( checker )
                    tile:settarget( killtarget )

                    if ( killtarget ~= false ) then
                        killnontarget = true
                    end

                    table.insert( t_tiles, tile )

                    numsteps = numsteps - 1
                end
            end

            ::skip::

        until numsteps < 1
    end

    if ( cfg.forceattack and killnontarget ) then
        local nt = {}
        for i, tile in ipairs( t_tiles ) do
            if ( tile:gettarget() == false ) then
                tile:remove()
            else
                table.insert( nt, tile )
            end
        end

        t_tiles = nt
    end
end

--**********************

local CChecker = {}
CChecker.__index = CChecker

function CChecker.new()
    local checker = setmetatable( {
        pos = vec2(),
        drawpos = vec2(),
        team = 0,
        selected = false,
        inactive = false,
        queen = cfg.allqueens or false,
    }, CChecker )
    return checker
end

function CChecker:setPos( x, y )
    vec2set( self.pos, x, y )
end

function CChecker:setTeam( t )
    self.team = t
end

function CChecker:spawn()

end

function CChecker:move( v )
    self:setPos( v )
    if ( v[2] == queenypos[self.team] ) then
        self.queen = true
    end
end

function CChecker:kill()
    self.inactive = true

    local i = tFrags[opositeteam(self.team) ]
    tFrags[ opositeteam(self.team) ] = i + 1
    local x, y = i % tiles, math.floor( i / tiles )

    if ( self.team ~= T_WHITE ) then
        y = -2 - y
    else
        y = y + tiles + 1
    end

    self:setPos( vec2( x, y ) )
end

function CChecker:select()
    ConstructMoveTiles( self )
end

function CChecker:draw( DT )
    --if ( not vec2similar( self.drawpos, self.pos, .00000000001 ) ) then
    vec2approach( self.drawpos, self.pos, DT * 20 )
    --end

    local pos = self.drawpos

    if ( not self.inactive and TeamTurn == self.team ) then
        local c = tCol[opositeteam( self.team )]
        draw.meshcircle( pos[1] + .5, pos[2] + .5, .5, c, 16 )
    end

    draw.meshcircle( pos[1] + .5, pos[2] + .5, .45, self.selected and draw.yellow or tCol[self.team], 16 )

    if ( self.queen ) then
        local c = tCol[opositeteam(self.team)]
        local a = .25 * .5
        local x, y = pos[1], pos[2]
        for i = .25, .75, .25 do
            draw.filltriangle( x + i - a, y + .6, x + i + a, y + .6, x + i, y + .3, c )
        end
    end
end

local function ResetGame()
    for i, checker in ipairs( t_checkers ) do
        checker:remove()
        t_checkers[i] = nil
    end

    tFrags[T_WHITE] = 0
    tFrags[T_BLACK] = 0
    TeamTurn = T_WHITE

    for i = 0, tiles * 3 - 1, 2 do
        local y = math.floor( i / tiles )
        i = i + ( y % 2 )

        local checker = CChecker.new()
        table.insert( t_checkers, checker )
        checker:setPos( vec2( i % tiles, y ) )
        checker:setTeam( T_WHITE )
        checker:spawn()
    end

    for i = tiles * 3 - 1, 0, -2 do
        local y = math.floor( i / tiles )
        i = i + ( y % 2 )

        local checker = CChecker.new()
        table.insert( t_checkers, checker )
        checker:setPos( vec2( i % tiles, tiles - 1 - y ) )
        checker:setTeam( T_BLACK )
        checker:spawn()
    end
end

local isomat, cam

local function Init()
    bg_color = { .3, .3, .3, 1 }
    isomat = mat3()

    local a = ( 3 ^ .5 ) / 8
    mat3setSheer( isomat, vec2( a, 0 ) )
    mat3setSc( isomat, 1, 1 )

    cam = mat3()
    local s = ScrW() / 9
    mat3setSc( cam, s, s )

    --mat3setTr( cam, sc * .5, sc ) -- s * .5, s * .5)
    draw.setmatrix( cam )

    ResetGame()
end

local lcx, lcy = 0, 0

local function Loop( CT, DT )
    local a = ( 1 + math.cos( CT * 12 ) * .5 )
    selecttilecol[4] = .4 + a * .2
    local cursormat = mat3()

    local invcam = mat3inv( cam, mat3() )
    local invm = mat3inv( isomat, mat3() )

    mat3mul( cursormat, invcam, cursormat )
    local dx, dy = mat3mulxy( cursormat, cursor.delta2() )

    mat3mul( cursormat, invm, cursormat )

    local cx, cy = mat3mulxy( cursormat, cursor.pos2() )
    local mx, my = math.floor( cx ), math.floor( cy )

    if ( pointoutboard( mx, my ) ) then
        mat3addTr( isomat, dx, dy )
    end

    draw.pushmatrix( isomat )

    drawboard( CT, DT )

    local col = draw.purple

    --************

    drawtile( mx, my, col )

    for i, tile in ipairs( t_tiles ) do
        tile:draw()
    end

    for i, checker in ipairs( t_checkers ) do
        checker:draw( DT )
    end

    --************

    drawgridoverlay()

    draw.popmatrix()
end

local function touchend( nId )
    local cursormat = mat3()
    local invcam = mat3inv( cam, mat3() )
    local invm = mat3inv( isomat, mat3() )

    mat3mul( cursormat, invcam, cursormat )
    mat3mul( cursormat, invm, cursormat )

    local cx, cy = mat3mulxy( cursormat, cursor.pos2( nId ) )
    local mx, my = math.floor( cx ), math.floor( cy )

    local selection = false

    for i, checker in ipairs( t_checkers ) do
        if ( checker.selected ) then
            checker.selected = false
        end

        local curTeam = TeamTurn == checker.team
        local isActive = not checker.inactive
        local inTile = 0.01 > vec2distsqr( checker.pos, vec2( mx, my ) )

        if ( curTeam and isActive and inTile ) then
            selection = checker
        end
    end

    if ( selection ) then
        killmovetiles()

        selection.selected = true
        selection:select()
    else
        local seltile = false
        for i, tile in ipairs( t_tiles ) do
            if ( 0.01 > vec2distsqr( tile.pos, vec2(mx, my) ) ) then
                tile:press()
                seltile = true
                break
            end
        end

        if ( seltile ) then
        else
            killmovetiles()
        end
    end
end

callback( cursor.tCallbacks.ended, touchend )

callback( _LOOPCALLBACK, Loop )
callback( "Init", Init )
