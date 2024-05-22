if ( package.pathinit ) then package.path = package.pathinit end
package.path = package.path .. ";../?.lua"
bInitialized = true
sHomeDir = ""
local sFolder = "3D-Engine+"

local tRequirements = {
    "libs/string",
    "libs/table",
    "libs/math",

    "libs/callback",
    "libs/globals",
    "libs/1252xUnicode",
    "libs/stream",
    "libs/bitmap",

    "libs/vec2",
    "libs/vec3+",
    "libs/mat3",
    "libs/mat4+",
    "libs/math3d",

    "libs/draw+",
    "libs/screen",

    "libs/cursor+",
    "libs/gui-framework",
    "libs/class",

    --"libs/draw-textured",
    sFolder.."/raster",

    sFolder.."/camera",
    sFolder.."/render",
    sFolder.."/model-load",

    sFolder.."/content-load",

    sFolder.."/gui/themes",
    sFolder.."/gui/base",
    sFolder.."/gui/frame",
    sFolder.."/gui/label",

    sFolder.."/movedata",
    sFolder.."/controls",

    sFolder.."/inteface",
}

local function requireEverything()
    bInitialized = true
    local sOldPath = package.path
    package.path = ";../?.lua;../3D-Engine+/?.lua"

    for _, sFileName in ipairs( tRequirements ) do

        --local bSuccess, sErrorCode = pcall( require, sFileName )

        require( sFileName )

        --[[ if ( not bSuccess ) then
            print( "Failed to load " .. sFileName )
            print( sErrorCode )
            print()

            print( debug.traceback() )
            sys.halt()
        end ]]--
    end

    package.path = sOldPath
end

local function init()
    requireEverything()
    frameBegin()
    showscreen()
    render.init() -- Initialize 3D
    RunCallback( "Init" )
    RunCallback( "PostInit" )

    -- Actual width, actual height, virtual width
    --draw.initTextured( ScrW(), ScrH(), 2 ^ 6.5 )

    frameEnd()
end

local nTargetDT = 1 / 60

local function loop()
    frameBegin()
    local nT = sys.gettime()

    RunCallback( "Loop" )

    draw.clear( draw.black )
    draw.doevents()

    local nTime, nFrameTime = curtime(), deltatime()

    movedata.think( nTime, nFrameTime )

    RunCallback( "Frame", nTime, nFrameTime )
    render.draw( nTime, nFrameTime ) --Draw 3D

    -- GUI
    gui.think( nTime, nFrameTime )

    do
        local nSize = ScrW( .02 )
        draw.setFontSize( nSize )
        draw.text( round( 1 / nFrameTime ), 0, nSize )
    end

    draw.post()
    cursor.clearDelta()

    if ( nTargetDT > 0 ) then -- FPS Lock
        while ( sys.gettime() - nT < nTargetDT ) do end
    end

    frameEnd()
end

init()

while true do
    loop()
end
