local Callbacks = {}

function callback( id, f )
    if ( not Callbacks[id] ) then
        Callbacks[id] = {}
    end

    table.insert( Callbacks[id], f )
    return #Callbacks[id]
end

function exec( id, ... )
    if ( not Callbacks[id] ) then
        return
    end

    for _, f in ipairs( Callbacks[id] ) do
        local r = f( ... )

        if ( r ) then
            return true, r, _
        end
    end
end
