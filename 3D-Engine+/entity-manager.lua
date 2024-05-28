if ( not bInitialized ) then require( "init" ) return end

local ents = {
    tCache = {},
    tDrawList = {},
    tRegistered = {}
}

table.enum( {
    "ENT_POINT",
    "ENT_PROP"
} )

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

function ents.spawn( sClass, nType )
    assert( ents.getRegistered( sClass ), "Class is not registered " .. tostring( sClass ) )

    local eEnt = ents.getRegistered( sClass )()

    --validCall( eEnt.postInit, eEnt )
    table.insert( ents.tCache, eEnt )

    local nType = nType or eEnt.nType

    if ( nType == ENT_PROP ) then
        table.insert( ents.tDrawList, eEnt )
    end

    return eEnt
end

function ents.remove( eEnt, bRecursive )
    eEnt.bMarkedForRemove = true
    killByValue( ents.tCache, eEnt )

    local nType = nType or eEnt.nType

    if ( nType == ENT_PROP ) then
        killByValue( ents.tDrawList, eEnt )
    end
end

function ents.getRegistered( sClass )
    return ents.tRegistered[sClass]
end

function ents.register( tEnt )
    local sClass = tEnt.sClassname
    assert( sClass, "trying to register entiry without classname" )

    if ( tEnt.sBase ) then
        ents.tRegistered[sClass] = ents.getRegistered( tEnt.sBase ):extend()
    else
        ents.tRegistered[sClass] = tEnt
    end
end

function ents.getDrawable()
    return ents.tDrawList
end

_G.ents = ents
