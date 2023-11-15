local _Dict = {}
local DictSize = 0

local CLDICT = {}

::retry::
local str = io.read( )

if ( _Dict[str] ) then
    print( string.format( "%s is already registered with %s index", str, _Dict[str] ) )
else
    DictSize = DictSize + 1
    _Dict[str] = DictSize
    print( "added with " .. DictSize .. " index" )
end

goto retry

