--assert( callback, "missing callback lib" )
--assert( vec2, "vec2 lib is missing" )

cursor = {
    tActive = {},
    tCallbacks = {
        began = "cursor.began",
        moved = "cursor.moved",
        ended = "cursor.ended",
    }
}

local function createCursor( nTId )
    return {
        pos = vec2(),
        prevpos = vec2(),
        delta = vec2(),
        down = false,
        id = nTId,
        downtime = -1,
        pressframe = -1,
    }
end

local cCursorFallback = createCursor(1)

local function getCursor( nId )
    return cursor.tActive[nId or 1]
end

local function getCursorList()
    return cursor.tActive
end

local function pushCursor( cCursor )
    local nL = #getCursorList() + 1
    getCursorList()[nL] = cCursor
    return nL
end

local function getCursorIndex( cCursor )
    for j, c in ipairs( getCursorList() ) do
        if ( c == cCursor ) then return j end
    end
    return false
end

local function getCursorIndexByTId( nTId )
    for j, c in ipairs( getCursorList() ) do
        if ( c.id == nTId ) then return j end
    end
    return 0
end

local function getCursorByTId( nTId )
    return getCursor( getCursorIndexByTId( nTId ) )
end

local function removeCursor( cCursor )
    table.remove( getCursorList(), getCursorIndex( cCursor ) )
end

--********************

function cursor.pos( nId )
    return getCursor( nId ).pos
end

function cursor.pos2( nId )
    return vec2unpack( getCursor( nId ).pos )
end

if ( mat3 ) then
    local mTemp = mat3()
    local vOut = vec2()

    function cursor.pos3( nId )
        local mCursor = mat3()
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            mat3mul( mCursor, mat3inv( m, mTemp ), mCursor )
        end

        return vec2set( vOut, mat3mulxy( mCursor, cursor.pos2( nId ) ) )
    end
end

function cursor.isPressed( nId )
    return getCursor( nId ).down
end

function cursor.delta( nId )
    return getCursor( nId ).delta
end

function cursor.delta2( nId )
    return vec2unpack( getCursor( nId ).delta )
end

function cursor.isTapped( nId )
    return getCursor( nId ).pressframe == frameNum()
end

function cursor.down()
    local nIndex = 0
    return function()
        while ( nIndex < #getCursorList() ) do
            nIndex = nIndex + 1
            if ( cursor.isPressed( nIndex ) ) then
                return nIndex
            end
        end
    end
end

function cursor.getPressDuration( nId )
    return cursor.isPressed( nId ) and ( cursor.downtime( nId ) - curtime() ) or 0
end

function cursor.clearDelta( nId )
    if ( #getCursorList() == 0 ) then return end

    if ( nId ~= true ) then
        vec2set( getCursor( nId ).delta, 0, 0 )
        return true
    end

    for i, cCursor in ipairs( getCursorList() ) do
        vec2set( cCursor.delta, 0, 0 )
    end
end

cursor.getCursor = getCursor

--********************

pushCursor( cCursorFallback )

local function cursorBegan( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local nId = getCursorIndexByTId( nTId )
    local cCursor = getCursor( nId )

    if ( not cCursor ) then
        cCursor = createCursor( nTId )
        nId = pushCursor( cCursor )
    end

    print( cCursor, nId, nTId, nX, nY )

    exec( cursor.tCallbacks.began, nId )

    vec2set( cCursor.prevpos, cCursor.pos )
    vec2set( cCursor.pos, nX, nY )
    vec2set( cCursor.delta, 0, 0 )
    cCursor.down = true
    cCursor.pressframe = frameNum()
    cCursor.downtime = curtime()
end

local function cursorMoved( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local nId = getCursorIndexByTId( nTId )
    local cCursor = getCursor( nId )

    if ( cCursor ) then
        exec( cursor.tCallbacks.moved, nId )

        vec2set( cCursor.prevpos, cCursor.pos )
        vec2set( cCursor.pos, nX, nY )
        vec2diff( cCursor.prevpos, cCursor.pos, cCursor.delta )
    end
end

local function cursorEnded( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local nId = getCursorIndexByTId( nTId )
    local cCursor = getCursor( nId )

    if ( cCursor ) then
        exec( cursor.tCallbacks.ended, nId )

        vec2set( cCursor.prevpos, cCursor.pos )
        vec2set( cCursor.pos, nX, nY )
        vec2diff( cCursor.prevpos, cCursor.pos, cCursor.delta )

        cCursor.down = false
    end
end

draw.touchbegan = cursorBegan
draw.touchmoved = cursorMoved
draw.touchended = cursorEnded
