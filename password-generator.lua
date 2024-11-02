local nLen = 12
local nResults = 5

local bNumbers = true
local bLowerCaseChars = true
local bUpperCaseChars = true
local bSpecialChars = true

local tT = {}

local function addif( bAdd, tTarget, tTable )
    if ( not bAdd ) then
        return
    end

    tTarget[#tTarget+1] = tTable
end

addif( bNumbers, tT, { 48, 57 } ) -- 0-9
addif( bLowerCaseChars, tT, { 97, 122 } ) -- a-z
addif( bUpperCaseChars, tT, { 65, 90 } ) -- A-Z
addif( bSpecialChars, tT,
{ false,
    "%", "@", "#", "$",
    "&", "*", "(", ")",
    "?", "{", "}", "="
} )

local nSeed = os.time()
math.randomseed( nSeed )

print( "Seed:", nSeed, "\n" .. nResults .. " Results:\n" )

for nI = 1, nResults do

    local sOut = "\t"
    for i = 1, nLen do
        local nTableIndex = math.random( 1, #tT )
        local nMin, nMax = tT[nTableIndex][1], tT[nTableIndex][2]

        if ( nMin == false ) then
            sOut = sOut .. tT[nTableIndex][math.random( 2, #tT[nTableIndex] )]
        else
            sOut = sOut .. string.char( math.random( nMin, nMax ) )
        end
    end

    print( sOut )
end
