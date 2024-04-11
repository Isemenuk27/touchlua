if ( not bInitialized ) then require( "main" ) return end

local function Init()
    local gButton = gui.new( "gui.label" )
    gButton:SetSize( ScrW(.75), ScrH(.1) )
    gButton:SetText( "Button" )
    gButton:SetDrawFrame( true )
    gButton:ResizeContent()

    function gButton:OnCursorPress( cCursor )
        self:SetState( WINDOW_SELECTED )
        self:SetText( "Selected" )
        self:ResizeContent()
    end

    function gButton:OnCursorRelease( cCursor )
        self:SetState( WINDOW_ACTIVE )
        self:SetText( "Button" )
        self:ResizeContent()
    end

    gTextWindow = gui.new( "gui.label" )
    gTextWindow:SetSize( ScrW(.8), ScrH(.4) )

    gTextWindow:SetText( [[
Lua - це мова програмування загального призначення,
яка була розроблена в 1993 році в компанії Tecgraf
національного університету Бразилії в Ріо-де-Жанейро.

Вона має простий синтаксис та потужну систему
вбудованих функцій, що робить її досить популярною
для використання у великих системах програмування
та ігровій індустрії.

Одним з основних принципів Lua є простота та
легкість використання, що робить її ідеальним вибором
для вбудовуваних систем та скриптінгу.

Вона також добре інтегрується з іншими мовами програмування
та має мінімальні вимоги до пам'яті та ресурсів системи.
Багато проектів використовують Lua для розширення
своєї функціональності через скриптінг.

Lua має велику активну спільноту користувачів
та розвинуту документацію, що дозволяє швидко
вирішувати проблеми та вивчати нові можливості
мови програмування.]] )

    function gTextWindow:OnCursorPress( cCursor )
        self:SetState( WINDOW_SELECTED )
    end

    function gTextWindow:OnCursorRelease( cCursor )
        self:SetState( WINDOW_ACTIVE )
    end

    function gTextWindow:think( nTime, nFrameTime )
        self.vPos[2] = math.cos( nTime ) * 200 + ScrH(.5)
    end

    gTextWindow:SetDrawFrame( true )
    gTextWindow:ResizeContent()
    gTextWindow:CenterOnScreen()

    vec2set( gButton.vLocalPos, ( gTextWindow:GetSize()[1] - gButton:GetSize()[1] ) * .5, gTextWindow:GetSize()[2] - gButton:GetSize()[2] - 10 )

    gui.parent( gTextWindow, gButton )
end

AddCallback( "Init", Init )
