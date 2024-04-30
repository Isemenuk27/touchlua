if ( not bInitialized ) then require( "init" ) return end

local tBorderColor = { .8, .8, .8, .5 }
local tBorderPressedColor = { .8, .8, 1, .8 }

local function drawbounds( self, nW, nH )
    draw.rect( 0, 0, nW - 1, nH - 1,
    self:GetState() == WINDOW_SELECTED and tBorderPressedColor or tBorderColor )
end

local function onPress( self, cCursor )
    self:SetState( WINDOW_SELECTED )
end

local function onRelease( self, cCursor )
    self:SetState( WINDOW_ACTIVE )
end

local nNX, nNY, nF = 0, 0, 0
local nDX, nDY = 0, 0

local function createControls()
    local gParentPanel = gui.new( "gui.base" )
    gParentPanel:SetSize( ScrW(), ScrH() )

    local gView = gui.new( "gui.base" )
    gView:SetParent( gParentPanel )
    gView:SetSize( gParentPanel:GetSize( 1, .66 ) )
    gView.draw = drawbounds

    gView.OnCursorPress = onPress
    gView.OnCursorRelease = onRelease

    --***********************

    local nSize = .45
    local nRad = nSize * .5

    local gMove = gui.new( "gui.base" )
    gMove:SetParent( gParentPanel )
    gMove:SetLocalPos( gParentPanel:GetSize( .1 + nSize * .5, 1 - .05 - nSize * .25 ) )
    gMove:SetSize( gParentPanel:GetSize( nSize ), gParentPanel:GetSize( nSize ) )
    gMove:LocalCenter()
    gMove.draw = drawbounds

    gMove.OnCursorPress = onPress
    gMove.OnCursorRelease = onRelease

    --********************

    local nSize = .2
    local nButtonSize = gParentPanel:GetSize( nSize )

    local gForward = gui.new( "gui.label" )
    gForward:SetParent( gParentPanel )
    gForward:SetLocalPos( gParentPanel:GetSize( 1 - nSize - .05, 1 - nSize - .1 ) )
    gForward:SetSize( nButtonSize, nButtonSize )

    gForward:SetAlign( TEXT_RIGHT, TEXT_MIDDLE )
    gForward:SetText( "↑" )
    gForward:ResizeContent()

    function gForward:draw( nW, nH )
        self.tBase.draw( self, nW, nH )
        drawbounds( self, nW, nH )
    end

    gForward.OnCursorPress = onPress
    gForward.OnCursorRelease = onRelease

    --********************

    local gBackwards = gui.new( "gui.label" )
    gBackwards:SetParent( gParentPanel )
    gBackwards:SetLocalPos( gParentPanel:GetSize( 1 - nSize - .05, 1 - nSize * .5 - .05 ) )
    gBackwards:SetSize( nButtonSize, nButtonSize )

    gBackwards:SetAlign( TEXT_RIGHT, TEXT_MIDDLE )
    gBackwards:SetText( "↓" )
    gBackwards:ResizeContent()

    function gBackwards:draw( nW, nH )
        self.tBase.draw( self, nW, nH )
        drawbounds( self, nW, nH )
    end

    gBackwards.OnCursorPress = onPress
    gBackwards.OnCursorRelease = onRelease

    --**************************

    function gView:OnCursorMove( cCursor )
        nDX, nDY = cursor.delta2( cCursor )
    end

    function gMove:postDraw( nW, nH )
        local cCursor = self:HeldBy()

        if ( not cCursor ) then
            nNX, nNY, nF = 0, 0, 0
            return
        end

        local tCam = render.camera( 1 )

        local nCX, nCY = vec2unpack( cursor.pos3( cCursor ) )
        local nDX, nDY = nW * .5 - nCX, nH * .5 - nCY
        local nL = math.sqrt( nDX * nDX + nDY * nDY )
        local nIL = 1 / nL
        nNX, nNY = nDX * nIL, nDY * nIL

        local nR = ScrW( nRad )
        nF = math.min( nR, nL ) / nR

        draw.line( nW * .5 - nNX * nF * nR, nH * .5 - nNY * nF * nR, nW * .5, nH * .5 )
    end

    local function setupMD( nTime, nFrameTime, tMD, tMDPrev )
        vec3set( tMD.vWishDir, nNX, nNY, 0 )
        local nS = math.pi / ScrW()
        vec2add( tMD.vViewAngle, nDY * nS, nDX * -nS )
        tMD.nSpeed = nF

        if ( gForward:HeldBy() ) then
            movedata.addButton( INP_UP )
        end

        if ( gBackwards:HeldBy() ) then
            movedata.addButton( INP_DOWN )
        end

        nDX, nDY = 0, 0
    end

    AddCallback( "MD.Setup", setupMD, "Controls" )
end

AddCallback( "Init", function()
    createControls()
end )
