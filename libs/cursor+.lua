cursor = {
    tActive = {},
    cFakeCursor = false,
    tCallbacks = {
        began = "cursor.began",
        moved = "cursor.moved",
        ended = "cursor.ended",
    }
}

function cursor.create( nTId )
    return {
        vPos = vec2(),
        vPrevPos = vec2(),
        vDelta = vec2(),
        nDowntime = 0,
        nPressframe = 0,
        bDown = false,
        nTId = nTId,
    }
end

cursor.cFakeCursor = cursor.create( 0 )

function cursor.getFakeCursor()
    return cursor.cFakeCursor
end

local function getCursorByTId( nTId )
    for _, cCursor in ipairs( cursor.tActive ) do
        if ( cCursor.nTId == nTId ) then
            return cCursor
        end
    end
end

local function pushCursor( cCursor )
    return table.insert( cursor.tActive, cCursor )
end

local function removeCursor( cCursor )
    for nId, cFoundCursor in ipairs( cursor.tActive ) do
        if ( cCursor == cFoundCursor ) then
            return table.remove( cursor.tActive, nId )
        end
    end
end

cursor.removeCursor = removeCursor
cursor.pushCursor = pushCursor
cursor.getCursorByTId = getCursorByTId

local function handleCursor( cCursor, nX, nY )
    vec2set( cCursor.vPrevPos, cCursor.vPos )
    vec2set( cCursor.vPos, nX, nY )
    vec2diff( cCursor.vPrevPos, cCursor.vPos, cCursor.vDelta )
end

local function handleCursorPress( cCursor )
    cCursor.nPressframe = frameNum()
    cCursor.nDowntime = curtime()
    cCursor.bDown = true
end

local function handleCursorRelease( cCursor )
    cCursor.bDown = false
end

local function cursorBegan( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local cCursor = cursor.create( nTId )

    handleCursor( cCursor, nX, nY )
    handleCursorPress( cCursor )
    vec2set( cCursor.vDelta, 0, 0 )

    if ( nTId == 1 ) then
        handleCursor( cursor.cFakeCursor, nX, nY )
        handleCursorPress( cursor.cFakeCursor )
        vec2set( cursor.cFakeCursor.vDelta, 0, 0 )
    end

    pushCursor( cCursor )

    exec( cursor.tCallbacks.began, cCursor )
end

local function cursorMoved( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local cCursor = getCursorByTId( nTId )

    handleCursor( cCursor, nX, nY )

    if ( nTId == 1 ) then
        handleCursor( cursor.cFakeCursor, nX, nY )
    end

    exec( cursor.tCallbacks.moved, cCursor )
end

local function cursorEnded( t )
    local nTId, nX, nY = t.id, t.x, t.y
    local cCursor = getCursorByTId( nTId )

    handleCursor( cCursor, nX, nY )
    handleCursorRelease( cCursor )

    if ( nTId == 1 ) then
        handleCursor( cursor.cFakeCursor, nX, nY )
        handleCursorRelease( cursor.cFakeCursor )
    end

    exec( cursor.tCallbacks.ended, cCursor )

    removeCursor( cCursor )
end

draw.touchbegan = cursorBegan
draw.touchmoved = cursorMoved
draw.touchended = cursorEnded

--********************

function cursor.pos( cCursor )
    return cCursor and cCursor.vPos or cursor.cFakeCursor.vPos
end

function cursor.pos2( cCursor )
    return vec2unpack( cursor.pos( cCursor ) )
end

if ( mat3 ) then
    local mTemp = mat3()
    local vOut = vec2()

    function cursor.pos3( cCursor )
        local mCursor = mat3()
        for i = draw.matstackl, 1, -1 do
            local m = draw.getmatrix( i )
            mat3mul( mCursor, mat3inv( m, mTemp ), mCursor )
        end

        return vec2set( vOut, mat3mulxy( mCursor, cursor.pos2( cCursor ) ) )
    end
end

function cursor.isPressed( cCursor )
    return cCursor and cCursor.bDown or false
end

function cursor.delta( cCursor )
    return cCursor and cCursor.vDelta or cursor.cFakeCursor.vDelta
end

function cursor.delta2( cCursor )
    return vec2unpack( cursor.delta( cCursor ) )
end

function cursor.isTapped( cCursor )
    return cCursor and ( cCursor.nPressframe == frameNum() ) or false
end

function cursor.getPressDuration( cCursor )
    return curtime() - cCursor.nDowntime
end

function cursor.clearDelta()
    for i, cCursor in ipairs( cursor.tActive ) do
        vec2set( cCursor.vDelta, 0, 0 )
    end

    vec2set( cursor.cFakeCursor.vDelta, 0, 0 )
end

local iterator = ipairs({})
function cursor.down()
    return iterator, cursor.tActive, 0
end
