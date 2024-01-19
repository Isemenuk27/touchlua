local leet = {
    a = { "4", "@" },
    b = { "I3", "8", "13", "|3" },
    c = { "(", "[", "©", "¢" },
    d = { "])", "|)", "|>" },
    e = { "€", "&" },
    f = { "|=", "I=" },
    g = { "9", "(_+" },
    h = { "|-|", "/-/", "I+I" },
    i = { "1", "!" },
    j = { "_]", "_)" },
    k = { "|{", "|c", "]{" },
    l = { "|_", "£" },
    m = { "(\\/)", "^^", "/\\/\\" },
    n = { "/\\/", "/V" },
    o = { "()", "∅" },
    p = { "|⁰", "|9" },
    q = { "O_", "()_" },
    r = { "I2", "|2" },
    s = { "5", "$" },
    t = { "1", "'|'"},
    u = { "μ", "|_|", "(_)" },
    v = { "\\/", "√" },
    w = { "\\/\\/", "VV" },
    x = { "}{", ")(", "%" },
    y = { "\\|", "`/" },
    z = { "2", "`/_", "7_" },

    -- Unsupported :(
    --[[ ["а"] = { "4", "@" },
    ["б"] = { "6", "|5" },
    ["в"] = { "I3", "|3" },
    ["г"] = { "|`", "/'" },
    ["ґ"] = { "|`/", "|√" },
    ["д"] = { "/=\\", "/^-\\" } ]]
}

::start::

local text = tostring( io.read() ) or "nil"
local newtext = ""
local lastletter = {}

local function rand( letter )
    local t = leet[letter]
    local newletter

    repeat
        newletter = t[math.random( 1, #t )]
    until newletter ~= lastletter[letter]

    lastletter[letter] = newletter
    return newletter
end

for letter in string.gmatch( text, "." ) do
    letter = string.lower( letter )

    if ( leet[letter] ) then
        letter = rand( letter )
    end

    newtext = newtext .. letter
end

print( newtext, "\n" )

goto start
