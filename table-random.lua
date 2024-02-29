local t = { "a", "b", "c", "d", "e", "f", "g", "h" }

local last = -1
local function random( t )
    local l, o = #t, -1
    local i = 0
    repeat
        o = t[math.random(1,l)]
        i = i + 1
    until o ~= last
    last = o
    return o, i
end

for i = 0, 20 do
    print( random( t ) )
end
