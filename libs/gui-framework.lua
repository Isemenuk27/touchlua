gui = {
    tCache = {},
    sRegistered = {},
    tHeld = {},
}

--**********************

local function validCall( vFunc, ... )
    if ( vFunc ) then return vFunc( ... ) end
end

local function removeByValue( t, v )
    for i, val in ipairs( t ) do
        if ( val ~= v ) then goto guiSkipIter end
        table.remove( t, i )
        ::guiSkipIter::
    end
end

local function killByValue( t, v )
    local nIndex = false

    for i, val in ipairs( t ) do
        if ( val == v ) then break end
        nIndex = i
    end

    if ( not nIndex ) then return false end

    t[nIndex] = nil
    table.remove( t, nIndex )
end

--**********************

function gui.new( sClass, gParent )
    assert( gui.get( sClass ), "Class is not registered " .. tostring( sClass ) )

    local gWindow = gui.get( sClass )()

    validCall( gWindow.postinit, gWindow )
    table.insert( gui.tCache, gWindow )
    return gWindow
end

function gui.register( tWindow )
    local sClass = tWindow.sClassname
    assert( sClass, "trying to register window without classname" )

    if ( tWindow.sBase ) then
        gui.sRegistered[sClass] = gui.get( tWindow.sBase ):extend()
    else
        gui.sRegistered[sClass] = tWindow
    end
end

--**********************

local function traceWindow( cCursor )
    local gMaxZWindow
    local nCx, nCy = cursor.pos2( cCursor )

    for i, gWindow in ipairs( gui.tCache ) do
        local bInCursor = gWindow:testCursor( nCx, nCy )

        if ( bInCursor ) then
            if ( not gMaxZWindow ) then
                gMaxZWindow = gWindow
            elseif ( gui.getZ( gWindow ) > gui.getZ( gMaxZWindow ) ) then
                gMaxZWindow = gWindow
            end
        end
    end

    return gMaxZWindow
end

local function touchBegan( cCursor )
    local gWindow = traceWindow( cCursor )

    if ( not gWindow ) then
        return
    end

    gui.tHeld[cCursor] = gWindow
    gWindow:OnCursorPress( cCursor )
end

local function touchMoved( cCursor )
    local gWindow = gui.tHeld[cCursor]
    if ( gWindow ) then
        gWindow:OnCursorMove( cCursor )
    end

    do
        local gWindow = traceWindow( cCursor )

        if ( gWindow ) then
            gWindow:CursorMoved( cCursor )
        end
    end
end

local function touchEnded( cCursor )
    do
        local gWindow = gui.tHeld[cCursor]

        if ( gWindow ) then
            gWindow:OnCursorRelease( cCursor )
        end
    end
    do
        local gWindow = traceWindow( cCursor )

        if ( gWindow ) then
            gWindow:CursorReleased( cCursor )
        end
    end
    gui.tHeld[cCursor] = false
end

callback( cursor.tCallbacks.began, touchBegan )
callback( cursor.tCallbacks.moved, touchMoved )
callback( cursor.tCallbacks.ended, touchEnded )

--**********************

local mTrMat = mat3()

local renderWindows, renderWindow
do
    renderWindow = function( gWindow )
        local gParent = gWindow.gParent

        if ( gParent ) then
            mat3setTr( mTrMat, vec2unpack( gParent.vPos ) )
            mat3addTr( mTrMat, vec2unpack( gParent.vLocalPos ) )
        else
            mat3setTr( mTrMat, vec2unpack( gWindow.vPos ) )
        end
        mat3addTr( mTrMat, vec2unpack( gWindow.vLocalPos ) )

        local w, h = vec2unpack( gWindow.vSize )
        validCall( gWindow.draw, gWindow, w, h )
        validCall( gWindow.postDraw, gWindow, w, h )

        if ( gWindow.tChildren ) then
            renderWindows( gWindow.tChildren )
        end
    end

    renderWindows = function( tWindows )
        for i, gWindow in ipairs( tWindows ) do
            if ( gWindow.bDraw ) then
                renderWindow( gWindow )
            end
        end
    end
end

function gui.think( CT, DT )
    for i, gWindow in ipairs( gui.tCache ) do
        gWindow:think( CT, DT )
    end

    draw.pushmatrix( mTrMat )

    local tRenderFirst = {}

    for i, gWindow in ipairs( gui.tCache ) do
        if ( gWindow.bDraw and not gParent ) then
            table.insert( tRenderFirst, gWindow )
        end
    end

    table.sort( tRenderFirst, function( a, b ) return a.nZPos > b.nZPos end )

    renderWindows( tRenderFirst )

    draw.popmatrix()
end

--**********************

function gui.get( sClass )
    return gui.sRegistered[sClass]
end

function gui.getZ( gWindow )
    return gWindow.nZPos
end

function gui.setZ( gWindow, nVal )
    gWindow.nZPos = nVal
end

function gui.invalidateChildren( gWindow, gChild )
    if ( #gWindow.tChildren <= 0 ) then return false end
    removeByValue( gWindow.tChildren, gChild )
    return true
end

function gui.getChildren( gWindow )
    return gWindow.tChildren
end

function gui.setChildren( gWindow, gChild )
    if ( not gWindow.tChildren ) then
        gWindow.tChildren = {}
    end

    local nIndex = #gWindow.tChildren + 1
    gWindow.tChildren[nIndex] = gChild
    return nIndex
end

function gui.getParent( gWindow )
    return gWindow.gParent
end

function gui.setParent( gWindow, gParent )
    gWindow.gParent = gParent
    return gParent
end

function gui.isValid( gWindow )
    if ( not gWindow ) then return false end
    if ( gWindow.bMarkedForRemove ) then return false end
    return true
end

function gui.parent( gParent, gChild )
    gui.setChildren( gParent, gChild )
    gui.setParent( gChild, gParent )
    gui.setZ( gChild, gui.getZ( gParent ) + 1 )
end

function gui.remove( gWindow, bRecursive )
    gWindow.bMarkedForRemove = true
    if ( not bRecursive ) then
        local gParent = gui.getParent( gWindow )
        if ( gui.isValid( gParent ) ) then
            gui.invalidateChildren( gWindow, gChild )
        end
    end

    for i, gChild in ipairs( gui.getChildren( gWindow ) ) do
        gui.remove( gChild, true )
    end

    killByValue( tCache, gWindow )
end
