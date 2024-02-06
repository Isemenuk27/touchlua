NO2DGUI = false
GUIPLUS = true

if ( not Inited ) then
    local path = debug.getinfo(1, "S").source:match("@(.*)")
    for i = #path, 1, -1 do; local c = string.sub( path, i, i );
    if ( c == "/" or c == "\\" ) then return string.sub( path, i + 1 ) end end
    _SCENETOLOAD = string.sub( path, 1, -5)
    package.path = package.path .. ";../../?.lua"
    return require("2DEngine/init")
end

local nInvM = 1 / 255
local function rgb( r, g, b )
    return { r * nInvM, g * nInvM, b * nInvM, 1 }
end

local Colors = {
    OUTLINEPLUS = rgb(126,126,125),
    OUTLINEMINUS = rgb(42,48,35),
    FOREGROUND = rgb(76,88,68),
    BACKGROUND = rgb(62,70,55),
    TEXTSELECTED = rgb(172,173,78),
    TEXTACTIVE = rgb(250,250,250 ),
    TEXTINACTIVE = rgb(143,153,127),
}

do
    local WINDOW = {
        sClassname = "gui.frame",
        bg = false,
    }

    WINDOW.__index = WINDOW

    function WINDOW:draw( w, h )
        draw.fillbox( 1, 1, w - 1, h - 1, self.bg and Colors.BACKGROUND or Colors.BACKGROUND )
        draw.line( 0, 0, w, 0, Colors.OUTLINEPLUS )
        draw.line( 0, 0, 0, h, Colors.OUTLINEPLUS )

        draw.line( w, 0, w, h, Colors.OUTLINEMINUS )
        draw.line( 0, h, w, h, Colors.OUTLINEMINUS )
    end

    function WINDOW:center()
        local vTemp = vec2mul( vec2( self.vSize ), .5 )
        vec2sub( self.vPos, vTemp )
    end

    function WINDOW:setBackground( b )
        self.bg = b
    end

    function WINDOW:setSize( ... )
        vec2set( self.vSize, ... )
    end

    function WINDOW:setPos( ... )
        vec2set( self.vPos, ... )
    end

    function WINDOW:getPos()
        return self.vPos
    end

    function WINDOW:getSize()
        return self.vSize
    end

    function WINDOW:centerScreen()
        vec2set( self.vPos, HScrW() - self.vSize[1] * .5, HScrH() - self.vSize[2] * .5 )
    end

    gui.register( WINDOW )
end

do
    local WINDOW = {
        sClassname = "gui.button",
        bg = false,
        text = "Button",
        sBase = "gui.frame"
    }

    WINDOW.__index = WINDOW

    function WINDOW:draw( w, h )
        self.tBase.draw( self, w, h )
        local nS = draw.nicesize( self.text, w, h )
        draw.etext( self.text, w * .1, 1, TEXT_RIGHT, TEXT_TOP, Colors.TEXTACTIVE, nS )
    end

    gui.register( WINDOW )
end

local gWindowText
local function Init()
    local gWindow = gui.new( "gui.frame" )
    gWindow:centerScreen()
    vec2add( gWindow:getPos(), 0, 400 )

    gWindowText = gui.new( "gui.button" )
    gWindowText:setSize( ScrW() * .8, ScrH() * .7)

    gWindowText.text = [[
Lua - це мова програмування загального
призначення, яка була розроблена в
1993 році в компанії Tecgraf національного
університету Бразилії в Ріо-де-Жанейро.
Вона має простий синтаксис та потужну систему
вбудованих функцій, що робить її
досить популярною для використання у
великих системах програмування та ігровій
індустрії. Одним з основних принципів
Lua є простота та легкість використання,
що робить її ідеальним вибором
для вбудовуваних систем та скриптінгу. 
Вона також добре інтегрується з іншими мовами
програмування та має мінімальні вимоги
до пам'яті та ресурсів системи. Багато
відомих проектів, таких як World of
Warcraft і Adobe Lightroom, використовують
Lua для розширення своєї функціональності
через скриптінг. Lua має велику
активну спільноту користувачів та розвинуту
документацію, що дозволяє швидко вирішувати
проблеми та вивчати нові можливості
мови програмування.]]

    gWindowText:centerScreen()
end

callback( "Init", Init )

local function Loop( CT, DT )
    local a = 0 --600 * ( math.cos( CT ) + 1 ) * .5
    gWindowText:setSize( ScrW() * .8 - a, ScrH() * .7 )
end

callback( _LOOPCALLBACK, Loop )
