local keystring = '["%s"] = %s,'
local keynumber = "[%s] = %s,"

local keytblstring = '["%s"] ='
local keytblnum = '[%s] ='

local spacestr = "    "
local empty = ""
local close = "},"

local Output = print
local NUMBER, TABLE = "number", "table"
local type, format = type, string.format

function istable( t )
    return type(t) == TABLE
end

function isnumber( t )
    return type(t) == NUMBER
end

local function formatvalue( str, value )
    if isnumber( str ) then
        if istable(value) then
            return format(keytblnum, str), true
        end
        return format(keynumber, str, value)
    end
    if istable(value) then
        return format(keytblstring, str), true
    end
    return format(keystring, tostring(str), value)
end

local spaces = 0

local function outputvalue(value)
    if istable( value ) then
        spaces = spaces + 1

        PrintTable(value, true)
        spaces = spaces - 1

        for _ = 1, spaces do
            close = spacestr .. close
        end

        Output(close)
    end
end

function PrintTable(tbl, r)
    assert( istable( tbl ), "table expected got " .. type( tbl ) )
    for key, value in pairs( tbl ) do
        local st, bl = formatvalue( key, value )

        for _ = 1, spaces do
            st = spacestr .. st
        end

        Output( st .. ( bl and " {" or empty ) )

        if ( bl ) then
            outputvalue( value )
        end
    end
end

function table.copy( t )
    local o = {}

    for key, value in pairs( t ) do
        if ( istable( value ) ) then
            o[key] = table.copy( value )
        else
            o[key] = value
        end
    end

    return o
end

function table.shiftLeft(tbl)
    local firstValue = tbl[1]
    for i = 1, #tbl - 1 do
        tbl[i] = tbl[i + 1]
    end
    tbl[#tbl] = firstValue
end

function table.shiftRight(tbl)
    local length = #tbl
    local lastValue = tbl[length]

    for i = length, 2, -1 do
        tbl[i] = tbl[i - 1]
    end

    tbl[1] = lastValue
end

function table.KeyFromValue( tbl, val )
    for key, value in pairs( tbl ) do
        if ( value == val ) then return key end
    end
end

function table.RemoveByValue( tbl, val )

    local key = table.KeyFromValue( tbl, val )
    if ( not key ) then return false end

    if ( isnumber( key ) ) then
        table.remove( tbl, key )
    else
        tbl[ key ] = nil
    end

    return key

end


function table.Copy( t, lookup_table )
    if ( t == nil ) then return nil end

    local copy = {}
    setmetatable( copy, debug.getmetatable( t ) )
    for i, v in pairs( t ) do
        if ( not istable( v ) ) then
            copy[ i ] = v
        else
            lookup_table = lookup_table or {}
            lookup_table[ t ] = copy
            if ( lookup_table[ v ] ) then
                copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
            else
                copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
            end
        end
    end
    return copy
end

function table.Merge( dest, source, forceOverride )
    for k, v in pairs( source ) do
        if ( not forceOverride and istable( v ) and istable( dest[ k ] ) ) then
            table.Merge( dest[ k ], v )
        else
            dest[ k ] = v
        end
    end

    return dest
end

local function toKeyValues( tbl )

    local result = {}

    for k, v in pairs( tbl ) do
        table.insert( result, { key = k, val = v } )
    end

    return result

end

local function getKeys( tbl )

    local keys = {}

    for k in pairs( tbl ) do
        table.insert( keys, k )
    end

    return keys

end

function SortedPairs( pTable, Desc )
    local keys = getKeys( pTable )

    if ( Desc ) then
        table.sort( keys, function( a, b )
            return a > b
        end )
    else
        table.sort( keys, function( a, b )
            return a < b
        end )
    end

    local i, key
    return function()
        i, key = next( keys, i )
        return key, pTable[key], 0
    end
end

function SortedPairsByValue( pTable, Desc )

    local sortedTbl = toKeyValues( pTable )

    if ( Desc ) then
        table.sort( sortedTbl, function( a, b ) return a.val > b.val end )
    else
        table.sort( sortedTbl, function( a, b ) return a.val < b.val end )
    end

    return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

end

function table.enum( tParams )
    local nId = 0

    for nKey, nValue in pairs( tParams ) do
        if ( isnumber( nKey ) ) then
            _G[nValue] = nId
            nId = nId + 1
        else
            _G[nKey] = nValue
        end
    end
end
