if ( not bInitialized ) then require( "init" ) return end

movedata = setmetatable( {
    tData = {
        vWishDir = vec3(),
        vWishMoveDir = vec3(),
        vViewAngle = vec3( 0, math.pi, 0 ),
        vOrigin = vec3( 0, 0, 2 ),
        nSpeed = 1,
        nMaxSpeed = 2,
        nButtons = 0,
    },
}, { __call = function( bPrev ) return bPrev and movedata.tPrevData or movedata.tData end } )
movedata.tPrevData = table.copy( movedata.tData, {} )

table.enum( {
    "INP_UP",
    "INP_DOWN",
}, "bitmask" )

function movedata.think( nTime, nFrameTime )
    local tMD, tMDPrev = movedata(), movedata(true)

    table.copyTo( tMD, tMDPrev )
    vec3set( tMD.vWishDir, 0, 0, 0 )
    tMD.nButtons = 0

    movedata.setup( nTime, nFrameTime, tMD, tMDPrev )
    movedata.finish( nTime, nFrameTime, tMD, tMDPrev )
end

function movedata.setup( nTime, nFrameTime, tMD, tMDPrev )
    RunCallback( "MD.Setup", nTime, nFrameTime, tMD, tMDPrev )
end

local vUp, vForward, vRight = vec3(), vec3(), vec3()

local nMinPitch, nMaxPitch = math.rad( -89 ), math.rad( 89 )

function movedata.finish( nTime, nFrameTime, tMD, tMDPrev )
    RunCallback( "MD.Finish", nTime, nFrameTime, tMD, tMDPrev )

    local tCam = render.camera( 1 )

    vec3set( vUp, cam.up( tCam ) )
    vec3set( vForward, cam.forward( tCam ) )
    vec3set( vRight, cam.right( tCam ) )

    vec3mul( vForward,tMD.vWishDir[2] * tMD.nSpeed )
    vec3mul( vRight, tMD.vWishDir[1] * tMD.nSpeed )

    local nM = ( movedata.buttonDown( INP_UP ) and 1 or 0 ) - ( movedata.buttonDown( INP_DOWN ) and 1 or 0 )
    vec3mul( vUp, nM )

    vec3set( tMD.vWishMoveDir, vForward )
    vec3sub( tMD.vWishMoveDir, vRight )
    vec3sub( tMD.vWishMoveDir, vUp )

    local nP, nY, nR = vec3unpack( tMD.vViewAngle )
    vec3set( tMD.vViewAngle, clamp( nP, nMinPitch, nMaxPitch ), nY % ( math.pi * 2 ), nR )
    vec3set( tCam.vAng, tMD.vViewAngle )

    vec3mul( tMD.vWishMoveDir, nFrameTime )
    vec3add( tMD.vOrigin, tMD.vWishMoveDir )
    vec3set( tCam.vPos, tMD.vOrigin )
end

function movedata.getButtons()
    return movedata.tPrevData.nButtons
end

function movedata.setButtons( nB )
    movedata.tPrevData.nButtons = nB
end

function movedata.addButton( nB )
    movedata.setButtons( movedata.getButtons() | nB )
end

function movedata.removeButton( nB )
    movedata.setButtons( movedata.getButtons() & ( ~nB ) )
end

function movedata.buttonDown( nB )
    return movedata.getButtons() & nB == nB
end
