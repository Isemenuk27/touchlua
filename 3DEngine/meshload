if ( not Inited ) then require( "init" ) return end

local tn = tonumber
local insert = table.insert

local vertexbuffer, form = {}, {}

local function numChars(str, char)
    local count = 0

    for i = 1, #str do
        if string.sub(str, i, i) == char then
            count = count + 1
        end
    end

    return count
end

local function writeVertex( a )
    local v_Vtex = vec3( tn( a[2] ), tn( a[3] ), tn( a[4] ) )
    insert( vertexbuffer, v_Vtex )
end

local function constructFace( a )
    local numslashes = numChars( a[2], "/" )

    if ( sl == 0 ) then --Only vertices
        local p1 = vec3( vertexbuffer[tn(a[2])] )
        local p2 = vec3( vertexbuffer[tn(a[3])] )
        local p3 = vec3( vertexbuffer[tn(a[4])] )

        insert( form, face( p1, p2, p3 ) )

        if ( a[5] ) then
            local p1 = vec3( vertexbuffer[tn(a[4])] )
            local p2 = vec3( vertexbuffer[tn(a[5])] )
            local p3 = vec3( vertexbuffer[tn(a[2])] )
            insert( form, face( p1, p2, p3 ) )
        end
    else
        local pf1 = string.Split( a[2], "/" )
        local pf2 = string.Split( a[3], "/" )
        local pf3 = string.Split( a[4], "/" )

        local p1 = vec3( vertexbuffer[tn(pf1[1])] )
        local p2 = vec3( vertexbuffer[tn(pf2[1])] )
        local p3 = vec3( vertexbuffer[tn(pf3[1])] )

        insert( form, face( p1, p2, p3 ) )

        if ( a[5] ) then
            local pf4 = string.Split( a[5], "/" )
            local p1 = vec3( vertexbuffer[tn(pf3[1])] )
            local p2 = vec3( vertexbuffer[tn(pf4[1])] )
            local p3 = vec3( vertexbuffer[tn(pf1[1])] )
            insert( form, face( p1, p2, p3 ) )
        end
    end
end

local keys = {
    ["v"] = writeVertex,
    ["f"] = constructFace,
}

function loadobj( name )
    local f = io.open ( "mesh/" .. name , "r" )

    form, vertexbuffer = {}, {}

    local vertexbuffer = {}

    for c in f:lines() do
        local a = string.Split( c, " " )

        if ( not keys[ a[1] ] ) then
            goto skipobj
        end

        keys[ a[1] ]( a )

        ::skipobj::
    end

    return form
end
