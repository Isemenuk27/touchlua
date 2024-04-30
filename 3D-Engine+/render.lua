if ( not bInitialized ) then
    require( "init" )
    return
end

render = {}
local mCurProj = mat3()
local sReadFrom = "textures/"

--**************************************

local tTextureCache = {}

function render.loadTexture( sFileName )
    local cStream = Stream()
    local cFile = io.open( sReadFrom .. sFileName, "rb" )

    cStream:ReadFromFile( cFile )
    cFile:close()

    local tBitmap = parseBitmap( cStream )

    local tTexture = { nWidth = tBitmap.nWidth, nHeight = tBitmap.nHeight }

    local nI = 0

    for i = 0, #tBitmap.tContent, tBitmap.nChannels do
        tTexture[nI] = tBitmap.tContent[i+2] / 255
        tTexture[nI+1] = tBitmap.tContent[i+1] / 255
        tTexture[nI+2] = tBitmap.tContent[i] / 255
        nI = nI + 3
    end

    tTextureCache[sFileName] = tTexture

    return tBitmap.nSize
end

function render.getTexture( sName )
    return tTextureCache[sName]
end

--**************************************

function render.getFaceIndexData( tModel )
    return tModel.nFaceArrayOffset, tModel.nFaceArrayLen
end

function render.getVertexIndexData( tModel )
    return tModel.nVertexArrayOffset, tModel.nVertexArrayLen
end

--**************************************

local trianglePlane do
    local vDiff = vec3()

    trianglePlane = function( tPoints, vPos, vDir )
        local c = 0

        for i = 1, 3 do
            vec3diffto( tPoints[i], vPos, vDiff )
            local dot = vec3dot( vDir, vDiff )

            if ( dot > 0 ) then
                c = c + 1
            end
        end

        return ( c == 3 and -1 ) or ( c > 0 and 1 ) or 0
    end
end

local toScreen do
    local vOut = vec3()

    toScreen = function( vPoint, mProj, nHW, nHH, nH )
        mat4mulVector( mProj, vPoint, vOut )

        vec3add( vOut, 1, 1, 0 )
        vec3mul( vOut, nHW, nHH, 1 )

        return vOut[1], nH - vOut[2], vOut[3]
    end
end

local toScreenC do
    local function mat4mulVectorC( m, nVx, nVy, nVz )
        local nR0, nR1, nR2, nR3 = m[0], m[1], m[2], m[3]
        local nW = 1 / ( nVx * nR0[3] + nVy * nR1[3] + nVz * nR2[3] + nR3[3] )

        return ( nVx * nR0[0] + nVy * nR1[0] + nVz * nR2[0] + nR3[0] ) * nW,
        ( nVx * nR0[1] + nVy * nR1[1] + nVz * nR2[1] + nR3[1] ) * nW,
        ( nVx * nR0[2] + nVy * nR1[2] + nVz * nR2[2] + nR3[2] ) * nW
    end

    toScreenC = function( nX, nY, nZ, mProj, nHW, nHH, nH )
        nX, nY, nZ = mat4mulVectorC( mProj, nX, nY, nZ )
        return ( nX + 1 ) * nHW, nH - ( nY + 1 ) * nHH, nZ
    end
end

--**************************************
local tCameraList = {}

function render.pushCamera( tCam )
    table.insert( tCameraList, tCam )
end

function render.popCamera( tCam )
    table.RemoveByValue( tCameraList, tCam )
end

function render.camera( nIndex )
    return tCameraList[nIndex]
end

function render.init()
    local tCam = cam.new()
    cam.buildPerspective( tCam, math.deg( 65 ), ScrW(), ScrH(), .1, 10 )
    render.pushCamera( tCam )
end

local tPoints = {
    vec3( .25, .1, 10 ),
    vec3( -.25, .1, 1 ),
    vec3( -.25, 0, .5 ),
    vec3( .25, 0, .5 ),
}

local mRotationY, mRotationX, mRotationZ = mat4(), mat4(), mat4()
local mView, mViewProjection = mat4(), mat4()
local vFaceNormal, vDirToFace = vec3(), vec3()

function render.view( tCam, nTime, nFrameTime )
    local mProj = cam.matrix( tCam )
    local vCamPos = tCam.vPos

    mat4identity( mView ) -- Reset marix

    local nPitch, nYaw, nRoll = vec3unpack( tCam.vAng )

    -- Setup rotations
    mat4rotateX( mRotationX, nPitch )
    mat4rotateY( mRotationY, nYaw )
    mat4rotateZ( mRotationZ, nRoll )

    -- Apply the to matrix
    mat4mul( mView, mRotationY, mView )
    mat4mul( mView, mRotationX, mView )
    mat4mul( mView, mRotationZ, mView )

    -- Should reset firstly
    vec3setc( tCam.vDir, 0, 0, 1 )
    vec3setc( tCam.vUpDir, 0, 1, 0 )

    -- Apply rotations to vector
    mat4mulVector( mView, tCam.vDir, tCam.vDir )

    local _, vUp, vForward, vRight = mat4lookAt( mView, vCamPos, tCam.vDir, tCam.vUpDir, tCam.vForwardDir, tCam.vRightDir )

    mat4quickInverse( mView, mViewProjection )
    mat4mul( tCam.mProj, mViewProjection, mViewProjection )
    -- Now its time to project points

    local nHScrW, nHScrH = tCam.nWidth * .5, tCam.nHeight * .5
    local nScrH = tCam.nHeight

    local tModel = mdl.get( "cube.mdl" )
    draw.setTexture( render.getTexture( "cat.bmp" ) )

    for nI = tModel.nFaceArrayOffset, tModel.nFaceArrayOffset + tModel.nFaceArrayLen, 6 do
        local nVertexA, nVertexB, nVertexC = tModel[nI], tModel[nI+1], tModel[nI+2]

        local nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ =
        tModel[nVertexA], tModel[nVertexA+1], tModel[nVertexA+2],
        tModel[nVertexB], tModel[nVertexB+1], tModel[nVertexB+2],
        tModel[nVertexC], tModel[nVertexC+1], tModel[nVertexC+2];

        local nNX, nNY, nNZ = tModel[nI+3], tModel[nI+4], tModel[nI+5];

        vec3setc( vFaceNormal, nNX, nNY, nNZ )
        vec3setv( vDirToFace, vCamPos )
        vec3subc( vDirToFace, nAX, nAY, nAZ )

        if ( vec3dot( vDirToFace, vFaceNormal ) < 0 ) then
            goto skipface
        end

        local nAU, nAV, nBU, nBV, nCU, nCV =
        tModel[nVertexA+3], tModel[nVertexA+4],
        tModel[nVertexB+3], tModel[nVertexB+4],
        tModel[nVertexC+3], tModel[nVertexC+4]

        local nX1, nY1, nZ1 = toScreenC( nAX, nAY, nAZ, mViewProjection, nHScrW, nHScrH, nScrH )
        local nX2, nY2, nZ2 = toScreenC( nBX, nBY, nBZ, mViewProjection, nHScrW, nHScrH, nScrH )
        local nX3, nY3, nZ3 = toScreenC( nCX, nCY, nCZ, mViewProjection, nHScrW, nHScrH, nScrH )

        --draw.triangle( nX1, nY1, nX2, nY2, nX3, nY3, draw.black )
        --math.randomseed( nI )

        draw.texturedTriangle( nX1, nY1, nX2, nY2, nX3, nY3,
        nAU, nAV, nBU, nBV, nCU, nCV )
        --draw.filltriangle( nX1, nY1, nX2, nY2, nX3, nY3, { math.random( 0, 10 ) * .1, math.random( 0, 10 ) * .1, math.random( 0, 10 ) * .1, 1 } )

        ::skipface::
    end
end

function render.draw( nTime, nFrameTime )
    for _, tCam in ipairs( tCameraList ) do
        render.view( tCam, nTime, nFrameTime )
    end
end

--**************************************
