if ( not bInitialized ) then require( "init" ) return end

local bLockPrint = false
local nMaxTextLines = 6
local tPrintText = {}
print2 = print

function print( ... )
    if ( bLockPrint ) then
        return
    end
    for _, aParam in ipairs( { ... } ) do
        table.insert( tPrintText, string.format( "%.2f %s", curtime(), tostring( aParam ) ) )
        if ( #tPrintText > nMaxTextLines ) then
            table.remove( tPrintText, 1 )
        end
    end
end

local nPrintPading = 1.5

local function createUI()
    local gPrintConsole = gui.new( "gui.frame" )

    local nSize = ScrW( .02 )

    gPrintConsole:SetSize( ScrW( .3 ), nSize * nPrintPading * nMaxTextLines )
    gPrintConsole:SetPos( 0, nSize * 2 )

    gPrintConsole:SetZPos( 100 )

    function gPrintConsole:draw( w, h )
        self.tBase.draw( self, w, h )

        bLockPrint = self:HeldBy() ~= nil

        draw.setFontSize( nSize )

        for nI, sText in ipairs( tPrintText ) do
            draw.text( sText, 0, nSize + nSize * nI * 1.2, self:StateColorText() )
        end
    end
end

AddCallback( "Init", function()
    createUI()
end )
