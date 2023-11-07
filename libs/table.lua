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
