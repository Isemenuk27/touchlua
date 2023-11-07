local Time = sys.gettime
local times = 10 ^ 7

local ent = { x = 1 }
ent.__index = ent

function ent:func()
    self.x = self.x + self.x
    return self.x
end

local h = setmetatable( {}, ent )

do
    local t = Time()

    for _ = 0, times do
        h:func()
    end

    local tt = Time() - t
    print( string.format( "total: %s   score: %s", tt, times / tt )  )
end

h.x = nil

do --No __index call
    local t = Time()

    for _ = 0, times do
        ent.func( h )
    end

    local tt = Time() - t
    print( string.format( "total: %s   score: %s", tt, times / tt )  )
end

h.x = nil

do --Localized function
    local t = Time()

    local f = h.func

    for _ = 0, times do
        f( h )
    end

    local tt = Time() - t
    print( string.format( "total: %s   score: %s", tt, times / tt )  )
end

h.x = nil

do
    local t = Time()

    local a = h.x

    for _ = 0, times do
        a = a + a
    end

    h.x = a

    local tt = Time() - t
    print( string.format( "total: %s   score: %s", tt
      , times / tt )  )
end
