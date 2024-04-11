-- WIP 

gui = {
    tCache = {},
    sRegistered = {},
    tHeld = {},
}

local function validCall( vFunc, ... )
    if ( vFunc ) then
        return vFunc( ... )
    end
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

local function pointaabb( x, y, x1, y1, x2, y2 )
    return x > x1 and x < x2 and y > y1 and y < y2
end

local function aabbaabb( x1, y1, x2, y2, x3, y3, x4, y4 )
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

local function handleControls()

end

local function touchBegan( nId )
    print( nId )
    if ( gui.tHeld[nId] ) then
        return
    end

    local gMaxZWindow = nil
    local nCx, nCy = cursor.pos2( nId )

    for i, gWindow in ipairs( gui.tCache ) do
        local bInCursor = gWindow.testCursor and gWindow:testCursor( nId ) or nil
        if ( bInCursor == nil ) then
            local nX, nY = gWindow.vPos[1] - gWindow.vCenter[1], gWindow.vPos[2] - gWindow.vCenter[2]
            local nX2, nY2 = nX + gWindow.vSize[1], nY + gWindow.vSize[2]
            bInCursor = pointaabb( nCx, nCy, nX, nY, nX2, nY2 )
        end

        if ( bInCursor ) then
            if ( not gMaxZWindow ) then
                gMaxZWindow = gWindow
            elseif ( gui.getZ( gWindow ) > gui.getZ( gMaxZWindow ) ) then
                gMaxZWindow = gWindow
            end
        end
    end

    if ( not gMaxZWindow ) then
        return
    end

    gui.tHeld[nId] = gMaxZWindow
    validCall( gMaxZWindow.press, gMaxZWindow, cursor.pos( nId ) )
end

local function touchMoved( nId )

end

local function touchEnded( nId )
    local gWindow = gui.tHeld[nId]

    if ( gWindow ) then
        validCall( gWindow.press, gWindow, cursor.pos( nId ) )
    end

    gui.tHeld[nId] = false
end

callback( cursor.tCallbacks.began, touchBegan )
callback( cursor.tCallbacks.moved, touchMoved )
callback( cursor.tCallbacks.ended, touchEnded )

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
            renderWindows( tWindows )
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
    handleControls()

    for i, gWindow in ipairs( gui.tCache ) do
        validCall( gWindow.think, gWindow )
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

function gui.new( sClass, gParent )
    assert( gui.get( sClass ), "Class is not registered " .. tostring( sClass ) )

    local gWindow = gui.get( sClass )()

    gWindow.vPos = vec2( 600, 700 )
    gWindow.vSize = vec2( 400, 130 )
    gWindow.vLocalPos = vec2( 0, 0 )
    gWindow.vCenter = vec2()
    gWindow.gParent = false
    gWindow.tChildren = false
    gWindow.bDraw = true
    gWindow.nZPos = 0

    validCall( gWindow.postinit, gWindow )
    table.insert( gui.tCache, gWindow )
    return gWindow
end

function gui.get( sClass )
    return gui.sRegistered[sClass]
end

function gui.getZ( gWindow )
    return gWindow.nZPos
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

function gui.invalidateChildren( gWindow, gChild )
    if ( #gWindow.tChildren <= 0 ) then return false end
    removeByValue( gWindow.tChildren, gChild )
    return true
end

function gui.getChildren( gWindow )
    return gWindow.tChildren
end

function gui.setChildren( gWindow, gChild )
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
