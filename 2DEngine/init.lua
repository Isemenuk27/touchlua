if ( package.pathinit ) then
    package.path = package.pathinit
end
package.path = package.path .. ";../?.lua"

local function requireCondition( bBool, sPath )
    if ( bBool ) then
        return require( sPath )
    end
    return false
end

if ( PARAMS ) then
    NO2DGUI = PARAMS.No2DGui or false
    GUIPLUS = PARAMS.GuiPlus or false
    _SCENETOLOAD = PARAMS.LoadScene or false
    NoDrawPlus = PARAMS.NoDrawPlus or false
end

require( "libs/globals" )
require( "libs/table" )
require( "libs/math" )
require( "libs/vec2" )
require( "libs/stack" )
require( "libs/mat2" )
require( "libs/mat3" )
require( "libs/callback" )
require( "libs/baseclass" )
--require( "libs/cursor" )
require( "libs/cursor+" )
requireCondition( not NO2DGUI, "libs/2dgui" )
requireCondition( GUIPLUS, "libs/2DGUI+" )
require( "libs/string" )

--**********************

Inited = 1
bg_color = { 0, 0, 0, 1 }
bg_clear = true

local clear, post = draw.clear, draw.post
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red

local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi, hpi = math.sqrt, math.random, math.pi, math.pi * .5

local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local function circle2( r, col, x, y )
    circle( x, y, r, col )
end

function memused()
    return collectgarbage('count') * 1024
end

_LOOPCALLBACK = "Scene.Loop"

require( "screen" )
showscreen()
require( "render" )

requireCondition( not NoDrawPlus, "libs/draw+" )
require( "menu" )
require( "phys" )

local w, h = Scr()
local hw, hh = HScr()

local function menuLoop( DT )
    text( round( 1 / DT, 2 ), 20, 20, red )
end

local dt = 0

while true do
    if ( _SCENETOLOAD ) then
        require( "scenes/" .. _SCENETOLOAD )
        break
    end

    local t = sys.gettime()

    clear( black )

    draw.doevents()

    if ( dt > 0 ) then
        menuLoop( dt )
        GUI.Render()
        post()
    else
        exec( "firstmenuframe", w, h )
    end

    dt = sys.gettime() - t
end

function worldcursor()
    local wtr = mat3( draw.getmatrix( 1 ) )
    local ctr = mat3()

    local x, y = cursor()
    mat3setTr( ctr, x, y )

    local m = mat3mul( mat3inv( wtr ), ctr )

    draw.text( mat3tostring( m ), .1, .2 )

    return vec2( mat3getTr( m ) )
end

local function Loop( CT, DT )
    exec( _LOOPCALLBACK, CT, DT )
    --draw.ftext( round( 1 / DT, 2 ), w * .02, h * .01, TEXT_RIGHT, TEXT_MIDDLE, red, ScrH() * .01 )
end

exec( "Init" )

while true do
    frameBegin()

    draw.doevents()

    if ( bg_clear ) then
        clear( bg_color )
    end

    if ( curtime() > 0 ) then
        Loop( curtime(), deltatime() )
        if ( GUI ) then
            GUI.Render()
        end
        if ( GUIPLUS ) then
            gui.think( curtime(), deltatime() )
        end
        post()
        if ( cursorcleardelta ) then
            cursorcleardelta()
        else
            cursor.clearDelta( true )
        end
    else
        exec( "firstframe" )
    end

    frameEnd()
end
