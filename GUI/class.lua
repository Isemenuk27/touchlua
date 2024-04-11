local tMetatable, copyTable
local Class = {}

function Class:init()
    return self
end

function Class:destruct()
    return self
end

function Class:new(...)
    local tObj = self:extend({})
    if ( tObj.init ) then tObj:init(...) end
    return tObj
end

function Class:extend( tObj )
    if ( tObj ) then
        tObj.tBaseClass = self.tBaseClass
    else
        tObj = { tBaseClass = self }
    end

    tObj.tBase = self
    copyTable( self, tObj )

    return setmetatable( tObj, tMetatable )
end

--**********************************

do
    local function call( self, ... )
        return self:new(...)
    end

    local function index( self, key )
        return self.tBase[key]
    end

    local function gc( self )
        return self:destruct()
    end

    tMetatable = {
        __call = call,
        __index = index,
        __gc = gc,
    }
end

--**********************************

do
    local tFilter = {
        ["__index"] = true,
        ["__newindex"] = true,
    }

    local type, TABLE = type, "table"
    function istable(t)
        return type(t) == TABLE
    end

    copyTable = function( tFrom, tTo )
        for k, v in pairs( tFrom ) do
            if ( not tTo[k] ) then
                if ( istable( v ) and ( not tFilter[k] ) ) then
                    tTo[k] = copyTable( v, {} )
                else
                    tTo[k] = v
                end
            end
        end

        return tTo
    end
end

function class()
    return Class:extend({})
end
