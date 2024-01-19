local Time = sys.gettime
local times = 10 ^ 7

local t = { a = "string" }
local key = "a"

local function output( ... )
    print( string.format( "%s [%.8f ms] \n", ... ) )
end

print( "loop for", times, "times\n" )

do
    local ts = Time()

    for i = 1, times do
        local a = t[key]
    end

    local d = Time() - ts
    output( "t[val]", d )
end

do
    local ts = Time()

    for i = 1, times do
        local a = rawget( t, key )
    end

    local d = Time() - ts
    output( "rawget", d )
end

do
    local rg = rawget
    local ts = Time()

    for i = 1, times do
        local a = rg( t, key )
    end

    local d = Time() - ts
    output( "local rawget", d )
end
