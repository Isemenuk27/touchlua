gui = {
    tCache = {},
    sRegistered = {},
}

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

local function validCall( vFunc, ... )
    if ( vFunc ) then
        return vFunc( ... )
    end
end

local mTrMat = mat3()

function gui.think( CT, DT )
    handleControls()

    for i, gWindow in ipairs( gui.tCache ) do
        validCall( gWindow.think, gWindow )
    end

    draw.pushmatrix( mTrMat )

    for i, gWindow in ipairs( gui.tCache ) do
        mat3setTr( mTrMat, vec2unpack( gWindow.vPos ) )
        local w, h = vec2unpack( gWindow.vSize )
        validCall( gWindow.draw, gWindow, w, h )
        validCall( gWindow.postDraw, gWindow, w, h )
    end

    draw.popmatrix()
end

function gui.new( sClass, gParent )
    local gWindow = setmetatable( {
        vPos = vec2( 600, 700 ),
        vSize = vec2( 400, 130 ),
        gParent = false,
    }, gui.sRegistered[sClass] )
    validCall( gWindow.init, gWindow )
    validCall( gWindow.postinit, gWindow )
    table.insert( gui.tCache, gWindow )
    return gWindow
end

function gui.get( sClass )
    return gui.sRegistered[sClass]
end

function gui.register( tWindow )
    local sClass = tWindow.sClassname
    assert( sClass, "trying to register window without classname" )
    if ( tWindow.sBase ) then
        local tFrame = gui.get( tWindow.sBase )
        setmetatable( tWindow, tFrame )
        tWindow.tBase = tFrame
    end
    gui.sRegistered[sClass] = tWindow
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
