local string = string
local math = math

local totable = string.ToTable
local string_sub = string.sub
local string_find = string.find
local string_len = string.len

local sExplodeFormat = "[^%s]+"

function string.Explode( sSeparator, sInput )
    local sPattern = string.format( sExplodeFormat, sSeparator )
    local tRes, nLen = {}, 0

    for sPart in string.gmatch( sInput, sPattern) do
        nLen = nLen + 1
        tRes[nLen] = sPart
    end

    return tRes
end

function string.Split( str, delimiter )
    return string.Explode( delimiter, str )
end

local sFilePathExtension = "^.+(%..+)$"

function string.GetFileExtension( sFilePath )
    return string.match( sFilePath, sFilePathExtension )
end

function string.StripExtension( path )
    for i = #path, 1, -1 do
        local c = string_sub( path, i, i )
        if ( c == "/" or c == "\\" ) then return path end
        if ( c == "." ) then return string_sub( path, 1, i - 1 ) end
    end

    return path
end

function string.GetPathFromFilename( path )
    for i = #path, 1, -1 do
        local c = string_sub( path, i, i )
        if ( c == "/" or c == "\\" ) then return string_sub( path, 1, i ) end
    end

    return ""
end

function string.GetFileFromFilename( path )
    for i = #path, 1, -1 do
        local c = string_sub( path, i, i )
        if ( c == "/" or c == "\\" ) then return string_sub( path, i + 1 ) end
    end

    return path
end

function string.Left( str, num )
    return string_sub( str, 1, num )
end
function string.Right( str, num )
    return string_sub( str, -num )
end

function string.Replace( str, tofind, toreplace )
    local tbl = string.Explode( tofind, str )
    if ( tbl[ 1 ] ) then return table.concat( tbl, toreplace ) end
    return str
end

function string.Trim( s, char )
if ( char ) then char = string.PatternSafe( char ) else char = "%s" end
    return string.match( s, "^" .. char .. "*(.-)" .. char .. "*$" ) or s
end

function string.TrimRight( s, char )
if ( char ) then char = string.PatternSafe( char ) else char = "%s" end
    return string.match( s, "^(.-)" .. char .. "*$" ) or s
end

function string.TrimLeft( s, char )
if ( char ) then char = string.PatternSafe( char ) else char = "%s" end
    return string.match( s, "^" .. char .. "*(.+)$" ) or s
end

function string.NiceSize( size )

    size = tonumber( size )

    if ( size <= 0 ) then return "0" end
    if ( size < 1000 ) then return size .. " Bytes" end
    if ( size < 1000 * 1000 ) then return round( size / 1000, 2 ) .. " KB" end
    if ( size < 1000 * 1000 * 1000 ) then return round( size / ( 1000 * 1000 ), 2 ) .. " MB" end

    return round( size / ( 1000 * 1000 * 1000 ), 2 ) .. " GB"

end

function string.StartsWith( str, start )
    return string.sub( str, 1, string.len( start ) ) == start
end

function string.EndsWith( str, endStr )
    return endStr == "" or string.sub( str, -string.len( endStr ) ) == endStr
end

function string.Comma( number, str )

    local replace = str == nil and "%1,%2" or "%1" .. str .. "%2"

    if ( isnumber( number ) ) then
        number = string.format( "%f", number )
        number = string.match( number, "^(.-)%.?0*$" ) -- Remove trailing zeros
    end

    local index = -1
    while index ~= 0 do number, index = string.gsub( number, "^(-?%d+)(%d%d%d)", replace ) end

    return number

end

local sFormat = "[^\n]+"

function string.lines( sStr )
    return string.gmatch( sStr, sFormat )
end

function printf( sFormat, ... )
    return print( string.format( sFormat, ... ) )
end

local sMat4F =
[[%.01f, %.01f, %.01f, %.01f,
%.01f, %.01f, %.01f, %.01f,
%.01f, %.01f, %.01f, %.01f,
%.01f, %.01f, %.01f, %.01f
]];

local sMat3F =
[[%.01f, %.01f, %.01f,
%.01f, %.01f, %.01f,
%.01f, %.01f, %.01f
]];

function printm( m )
    if ( #m == 3 ) then
        return printf( sMat4F, mat4unpack( m ) )
    end
    return printf( sMat3F, mat3unpack( m ) )
end

function printv( vVec )
    if ( vVec[3] ) then
        return print( vec3tostring( vVec ) )
    end
    return print( vec2tostring( vVec ) )
end
