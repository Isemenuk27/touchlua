local tRequirements = {
    "libs/string",
    "libs/table",
    "libs/math",
    "libs/globals",
    "libs/stack",

    "class",
    "screen",

    "libs/1252xUnicode",
    "libs/stream",
    "libs/callback",
    "libs/mat3",
    "libs/vec2",
    "libs/cursor+",
    "libs/draw+",
    "gui-framework",

    "gui/themes",
    "gui/base",
    "gui/frame",
    "gui/label",
    "gui/scroll",

    "test",
}

local function requireEverything()
    bInitialized = true
    local sOldPath = package.path
    package.path = ";../?.lua;../GUI/?.lua"

    for _, sFileName in ipairs( tRequirements ) do
        local bSuccess, sErrorCode = pcall( require, sFileName )

        if ( not bSuccess ) then
            print( "Failed to load " .. sFileName )
            print( sErrorCode )
            sys.halt()
        end
    end

    package.path = sOldPath
end

local function init()
    requireEverything()
    showscreen()
    RunCallback( "Init" )

    RunCallback( "PostInit" )
end

local function frame()
    RunCallback( "Frame" )
    gui.think( curtime(), deltatime() )
    RunCallback( "FrameEnd" )
    local nSize = ScrW( .02 )
    draw.setFontSize( nSize )
    draw.text( round( 1 / deltatime() ), 0, nSize )
end

local function loop()
    frameBegin()
    RunCallback( "Loop" )

    draw.clear( draw.black )
    draw.doevents()
    frame()
    draw.post()
    cursor.clearDelta()

    frameEnd()
end

init()

while true do
    loop()
end
