local cScroll = gui.get("gui.frame"):extend()
cScroll.sClassname = "gui.scroll"

function cScroll:init()
    cScroll.tBaseClass.init( self )
    self.bDrawScrollBar = false
    self.vScrollDir = vec2( 1, 0 )
    self.vDelta = vec2()
    return self
end

function cScroll:draw( w, h )

end
