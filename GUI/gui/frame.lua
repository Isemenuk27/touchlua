local cFrame = gui.get("gui.base"):extend()
cFrame.sClassname = "gui.frame"

function cFrame:init()
    cFrame.tBaseClass.init( self )
    return self
end

function cFrame:draw( w, h )
    cFrame.tBaseClass.draw( self )
    draw.fillbox( 1, 1, w - 1, h - 1, self:StateColor() )
    draw.line( 0, 0, w, 0, tTheme.OutlineBright )
    draw.line( 0, 0, 0, h, tTheme.OutlineBright )

    draw.line( w, 0, w, h, tTheme.OutlineDark )
    draw.line( 0, h, w, h, tTheme.OutlineDark )
end

gui.register( cFrame )
