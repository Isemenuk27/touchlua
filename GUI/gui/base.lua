local cBase = class()
cBase.sClassname = "gui.base"

function cBase:init()
    self.vPos = vec2( 600, 700 )
    self.vSize = vec2( 400, 130 )
    self.vLocalPos = vec2( 0, 0 )
    -- self.vCenter = vec2()
    self.gParent = false
    self.tChildren = false
    self.bDraw = true
    self.nZPos = 0
    self.nState = 0
    return self
end

function cBase:draw( w, h )
    return
end

function cBase:think( nTime, nFrameTime )
    return
end

function cBase:SetState( nState )
    self.nState = nState
end

function cBase:GetState()
    return self.nState
end

table.enum( {
    "WINDOW_ACTIVE",
    "WINDOW_INACTIVE",
    "WINDOW_SELECTED",
} )

local nStateColors = {
    [WINDOW_ACTIVE] = {
        tTheme.TextActive,
        tTheme.Foreground,
    },
    [WINDOW_INACTIVE] = {
        tTheme.TextInctive,
        tTheme.Background,
    },
    [WINDOW_SELECTED] = {
        tTheme.TextSelected,
        tTheme.Foreground,
    },
}

function cBase:StateColorText()
    return nStateColors[self:GetState()][1]
end

function cBase:StateColor()
    return nStateColors[self:GetState()][2]
end

function cBase:Center()
    local vTemp = vec2mul( vec2( self.vSize ), .5 )
    vec2sub( self.vPos, vTemp )
end

function cBase:SetZPos( nVal )
    self.nZPos = nVal
end

function cBase:GetZPos()
    return self.nZPos
end

function cBase:SetSize( ... )
    vec2set( self.vSize, ... )
end

function cBase:SetPos( ... )
    vec2set( self.vPos, ... )
end

function cBase:GetPos()
    return self.vPos
end

function cBase:GetSize( nM )
    if ( nM ) then
        return self.vSize[1] * nM, self.vSize[2] * nM
    end

    return self.vSize
end

function cBase:CenterOnScreen()
    vec2set( self.vPos, HScrW() - self.vSize[1] * .5, HScrH() - self.vSize[2] * .5 )
end

--*************************************

local function pointaabb( x, y, x1, y1, x2, y2 )
    return x > x1 and x < x2 and y > y1 and y < y2
end

local function aabbaabb( x1, y1, x2, y2, x3, y3, x4, y4 )
    return x1 < x4 and x2 > x3 and y1 < y4 and y2 > y3
end

local vTr = vec2()

function cBase:testCursor( nCx, nCy )
    local gParent = self.gParent

    if ( gParent ) then
        vec2set( vTr, gParent.vPos )
        vec2add( vTr, gParent.vLocalPos )
    else
        vec2set( vTr, self.vPos )
    end

    vec2add( vTr, self.vLocalPos )

    local nX, nY = vec2unpack( vTr )
    local nX2, nY2 = nX + self.vSize[1], nY + self.vSize[2]

    --draw.rect( nX, nY, nX2, nY2, draw.red )

    return pointaabb( nCx, nCy, nX, nY, nX2, nY2 )
end

function cBase:CursorInside( cCursor )
    return seld:testCursor( cursor.pos2( cCursor ) )
end

do
    local vOut = vec2()
    function cBase:ScreenToLocal( vIn )
        return vec2diff( self.vPos, vIn, vOut )
    end
end

function cBase:IsHeldBy( cCursor )
    return gui.tHeld[cCursor] == self
end

function cBase:HeldBy()
    for cCursor, gWindow in pairs( gui.tHeld ) do
        if ( gWindow == self ) then
            return cCursor
        end
    end
end

-- Called when frame directly pressed
function cBase:OnCursorPress( cCursor )
    return
end

-- Called when linked cursor moves
function cBase:OnCursorMove( cCursor )
    return
end

-- Called when any cursor moved on frame
function cBase:CursorMoved( cCursor )
    return
end

-- Called when linked cursor stop's holding it
function cBase:OnCursorRelease( cCursor )
    return
end

-- Called when any cursor released over it
function cBase:CursorReleased( cCursor )
    return
end

gui.register( cBase )
