local cLabel = gui.get("gui.frame"):extend()
cLabel.sClassname = "gui.label"

function cLabel:init()
    cLabel.tBaseClass.init( self )
    self.sText = "Label"
    self.bDrawFrame = false
    self.nTextSize = 1
    self.nAlignX = TEXT_RIGHT
    self.nAlignY = TEXT_TOP
    return self
end

function cLabel:draw( w, h )
    if ( self.bDrawFrame ) then
        cLabel.tBaseClass.draw( self, w, h )
    end

    draw.setFontSize( self.nTextSize )
    draw.etext( self.sText, self.nTextSize * .5, 1, self.nAlignX, self.nAlignY, self:StateColorText(), nS )
end

function cLabel:SetText( sText )
    self.sText = tostring( sText )
end

local sFormat = "[^\r\n]+"
local function lines( sStr )
    return string.gmatch( sStr, sFormat )
end

function cLabel:IdealContentSize()
    draw.setFontSize( 10 )

    local nMaxTextWidth = 0
    for sLine in lines( self.sText ) do
        local nWidth = draw.gettextsize( sLine ) + 10
        nMaxTextWidth = math.max( nMaxTextWidth, nWidth )
    end

    return 10 * ( self:GetWidth() / nMaxTextWidth )
end

function cLabel:ResizeToContent()
    --self:getSize()[1] = self:IdealContentSize()
end

function cLabel:SetAlign( nX, nY )
    self.nAlignX = nX or self.nAlignX
    self.nAlignY = nY or self.nAlignY
end

function cLabel:GetAlign( nX, nY )
    return self.nAlignX, self.nAlignY
end

function cLabel:ResizeContent( nScale )
    if ( nScale ) then
        self.nTextSize = nScale
        return nScale
    end

    self.nTextSize = self:IdealContentSize()

    return self.nTextSize
end

function cLabel:GetText()
    return self.sText
end

function cLabel:SetDrawFrame( bState )
    self.bDrawFrame = bState
end

function cLabel:GetDrawFrame()
    return self.bDrawFrame
end

gui.register( cLabel )
