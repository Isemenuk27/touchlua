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
local nEPS = 1e-5

local function trianglePlane( nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ, vPos, vDir )
    local nX, nY, nZ = vPos[1], vPos[2], vPos[3]
    local nNX, nNY, nNZ = vDir[1], vDir[2], vDir[3]

    return nEPS < ( nNX * ( nX - nAX ) + nNY * ( nY - nAY ) + nNZ * ( nZ - nAZ ) ),
    nEPS < ( nNX * ( nX - nBX ) + nNY * ( nY - nBY ) + nNZ * ( nZ - nBZ ) ),
    nEPS < ( nNX * ( nX - nCX ) + nNY * ( nY - nCY ) + nNZ * ( nZ - nCZ ) )
end

local function planeLineIntersection( nOX, nOY, nOZ, nNX, nNY, nNZ, nX0, nY0, nZ0, nX1, nY1, nZ1 )
    local nDX0, nDY0, nDZ0 = nX0 - nOX, nY0 - nOY, nZ0 - nOZ
    local nDX1, nDY1, nDZ1 = nX1 - nOX, nY1 - nOY, nZ1 - nOZ

    local nD1, nD2 = ( nDX0 * nNX ) + ( nDY0 * nNY ) + ( nDZ0 * nNZ ),
    ( nDX1 * nNX ) + ( nDY1 * nNY ) + ( nDZ1 * nNZ )

    local nT = nD1 / ( nD2 - nD1 )

    return nX0 - ( nX1 - nX0 ) * nT, nY0 - ( nY1 - nY0 ) * nT, nZ0 - ( nZ1 - nZ0 ) * nT, -nT
end

local toScreen do
    local vOut = vec3()

    toScreen = function( vPoint, mProj )
        mat4mulVector( mProj, vPoint, vOut )

        vec3add( vOut, 1, 1, 0 )
        vec3mul( vOut, HScrW(), HScrH(), 1 )

        return vOut[1], ScrH() - vOut[2], vOut[3]
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
    cam.buildPerspective( tCam,
    math.pi * .5, ScrW(), ScrH(),
    .1, 10 )

    cam.setResolution( tCam, 2 ^ 7 )
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

do
    local filltriangle = draw.filltriangle
    local nHScrW, nHScrH, nScrH
    local vCamPos, mProj

    local function mat4mulVectorC( m, nVx, nVy, nVz, nU, nV )
        local nR0, nR1, nR2, nR3 = m[0], m[1], m[2], m[3]
        local nW = 1 / ( nVx * nR0[3] + nVy * nR1[3] + nVz * nR2[3] + nR3[3] )

        return ( nVx * nR0[0] + nVy * nR1[0] + nVz * nR2[0] + nR3[0] ) * nW,
        ( nVx * nR0[1] + nVy * nR1[1] + nVz * nR2[1] + nR3[1] ) * nW,
        ( nVx * nR0[2] + nVy * nR1[2] + nVz * nR2[2] + nR3[2] ) * nW,
        nU, nV, nW
    end

    local function toScreenC( nX, nY, nZ, nU, nV )
        local nOX, nOY, nOZ, nOU, nOV, nOW = mat4mulVectorC( mViewProjection, nX, nY, nZ, nU, nV )
        return ( nOX + 1 ) * nHScrW, nScrH - ( nOY + 1 ) * nHScrH, nOZ,
        nOU * nOW, nOV * nOW, nOW
    end


    local vColor = vec3( 1, 1, 1 )
    vColor[4] = 1

    local tTriangleList = {}

    local function pushTriangle( nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ, nNX, nNY, nNZ, nAU, nAV, nBU, nBV, nCU, nCV )
        local nTriangleListLen = #tTriangleList

        tTriangleList[nTriangleListLen+1], tTriangleList[nTriangleListLen+2], tTriangleList[nTriangleListLen+3],
        tTriangleList[nTriangleListLen+4], tTriangleList[nTriangleListLen+5], tTriangleList[nTriangleListLen+6],
        tTriangleList[nTriangleListLen+7], tTriangleList[nTriangleListLen+8], tTriangleList[nTriangleListLen+9],
        tTriangleList[nTriangleListLen+10], tTriangleList[nTriangleListLen+11], tTriangleList[nTriangleListLen+12],
        tTriangleList[nTriangleListLen+13], tTriangleList[nTriangleListLen+14],
        tTriangleList[nTriangleListLen+15], tTriangleList[nTriangleListLen+16],
        tTriangleList[nTriangleListLen+17], tTriangleList[nTriangleListLen+18] = nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ, nNX, nNY, nNZ, nAU, nAV, nBU, nBV, nCU, nCV
    end

    function render.view( tCam, nTime, nFrameTime )
        mProj, vCamPos = cam.matrix( tCam ), tCam.vPos

        draw.initTextured( tCam.nWidth, tCam.nHeight, tCam.nVW )

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

        cam.updateFrustum( tCam )
        local tClipPlanes = tCam.tFrustum.tPlanes

        nHScrW, nHScrH, nScrH = tCam.nWidth * .5, tCam.nHeight * .5, tCam.nHeight

        local tModel = mdl.get( "cube.mdl" )
        draw.setTexture( render.getTexture(
        "cat.bmp" ) )

        tTriangleList = {}

        for nI = tModel.nFaceArrayOffset, tModel.nFaceArrayOffset + tModel.nFaceArrayLen, 6 do
            local nVertexA, nVertexB, nVertexC = tModel[nI], tModel[nI+1], tModel[nI+2]

            -- Point of 3 vertecies
            local nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ =
            tModel[nVertexA], tModel[nVertexA+1], tModel[nVertexA+2],
            tModel[nVertexB], tModel[nVertexB+1], tModel[nVertexB+2],
            tModel[nVertexC], tModel[nVertexC+1], tModel[nVertexC+2]

            -- Normals is precomputed
            local nNX, nNY, nNZ = tModel[nI+3], tModel[nI+4], tModel[nI+5]
            vec3setc( vFaceNormal, nNX, nNY, nNZ )

            vec3setv( vDirToFace, vCamPos ) -- Direction to camera
            vec3subc( vDirToFace, nAX, nAY, nAZ )

            -- Backface culling
            if ( vec3dot( vDirToFace, vFaceNormal ) < 0 ) then
                goto skip
            end

            pushTriangle( nAX, nAY, nAZ,
            nBX, nBY, nBZ,
            nCX, nCY, nCZ,
            nNX, nNY, nNZ,
            tModel[nVertexA+3], tModel[nVertexA+4],
            tModel[nVertexB+3], tModel[nVertexB+4],
            tModel[nVertexC+3], tModel[nVertexC+4] )

            ::skip::
        end

        local nI = 1 - 18

        while ( true ) do
            nI = nI + 18

            if ( not tTriangleList[nI] ) then
                break
            end

            local nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ,
            nNX, nNY, nNZ, nAU, nAV, nBU, nBV, nCU, nCV = table.unpack( tTriangleList, nI, nI + 17 )

            for nI = 1, #tClipPlanes, 2 do
                -- Number of points in front of plane
                local vOrigin, vNormal = tClipPlanes[nI], tClipPlanes[nI+1]
                local bA, bB, bC = trianglePlane( nAX, nAY, nAZ, nBX, nBY, nBZ, nCX, nCY, nCZ, vOrigin, vNormal )

                if ( bA and bB and bC ) then
                    goto skip -- Triangle fully behind the plane, skip it
                elseif ( not ( bA or bB or bC ) ) then
                    --Triangle in bounds, skip any cliping
                else
                    local nC = ( bA and 1 or 0 ) + ( bB and 1 or 0 ) + ( bC and 1 or 0 )
                    local nOX, nOY, nOZ, nNX, nNY, nNZ = vOrigin[1], vOrigin[2], vOrigin[3], vNormal[1], vNormal[2], vNormal[3]

                    local nXS, nYS, nZS, nXE0, nYE0, nZE0, nXE1, nYE1, nZE1,
                    nU0, nV0, nU1, nV1, nU2, nV2

                    local bClip2 = nC == 1

                    if ( bA == bClip2 ) then
                        nXS, nYS, nZS = nAX, nAY, nAZ
                        nU0, nV0, nU1, nV1, nU2, nV2 =
                        nAU, nAV, nBU, nBV, nCU, nCV
                        nXE0, nYE0, nZE0 = nBX, nBY, nBZ
                        nXE1, nYE1, nZE1 = nCX, nCY, nCZ
                    elseif ( bB == bClip2 ) then
                        nXS, nYS, nZS = nBX, nBY, nBZ
                        nU0, nV0, nU1, nV1, nU2, nV2 =
                        nBU, nBV, nAU, nAV, nCU, nCV
                        nXE0, nYE0, nZE0 = nAX, nAY, nAZ
                        nXE1, nYE1, nZE1 = nCX, nCY, nCZ
                    else
                        nU0, nV0, nU1, nV1, nU2, nV2 =
                        nCU, nCV, nAU, nAV, nBU, nBV
                        nXS, nYS, nZS = nCX, nCY, nCZ
                        nXE0, nYE0, nZE0 = nAX, nAY, nAZ
                        nXE1, nYE1, nZE1 = nBX, nBY, nBZ
                    end

                    if ( bClip2 ) then
                        local nX0, nY0, nZ0, nT0 = planeLineIntersection( nOX, nOY, nOZ, nNX, nNY, nNZ, nXS, nYS, nZS, nXE0, nYE0, nZE0 )
                        local nX1, nY1, nZ1, nT1 = planeLineIntersection( nOX, nOY, nOZ, nNX, nNY, nNZ, nXS, nYS, nZS, nXE1, nYE1, nZE1 )

                        local nNU0, nNV0 = nU0 + ( nU1 - nU0 ) * nT0, nV0 + ( nV1 - nV0 ) * nT0
                        local nNU1, nNV1 = nU0 + ( nU2 - nU0 ) * nT1, nV0 + ( nV2 - nV0 ) * nT1

                        pushTriangle( nXE0, nYE0, nZE0, nXE1, nYE1, nZE1, nX0, nY0, nZ0, nNX, nNY, nNZ,
                        nU1, nV1, nU2, nV2, nNU0, nNV0  )
                        pushTriangle( nX1, nY1, nZ1, nXE1, nYE1, nZE1, nX0, nY0, nZ0, nNX, nNY, nNZ,
                        nNU1, nNV1, nU2, nV2, nNU0, nNV0  )
                    else
                        local nX0, nY0, nZ0, nT0 = planeLineIntersection( nOX, nOY, nOZ, nNX, nNY, nNZ, nXS, nYS, nZS, nXE0, nYE0, nZE0 )
                        local nX1, nY1, nZ1, nT1 = planeLineIntersection( nOX, nOY, nOZ, nNX, nNY, nNZ, nXS, nYS, nZS, nXE1, nYE1, nZE1 )

                        local nNU0, nNV0 = nU0 + ( nU1 - nU0 ) * nT0, nV0 + ( nV1 - nV0 ) * nT0
                        local nNU1, nNV1 = nU0 + ( nU2 - nU0 ) * nT1, nV0 + ( nV2 - nV0 ) * nT1

                        pushTriangle( nXS, nYS, nZS, nX0, nY0, nZ0, nX1, nY1, nZ1, nNX, nNY, nNZ,
                        nU0, nV0, nNU0, nNV0, nNU1, nNV1 )
                    end

                    goto skip
                end -- if end
            end -- clip loop end

            do
                --Crazy shit
                local nX1, nY1, nZ1, nU1, nV1, nW1 = toScreenC( nAX, nAY, nAZ, nAU, nAV )
                local nX2, nY2, nZ2, nU2, nV2, nW2 = toScreenC( nBX, nBY, nBZ, nBU, nBV )
                local nX3, nY3, nZ3, nU3, nV3, nW3 = toScreenC( nCX, nCY, nCZ, nCU, nCV )

                --[[ ]]
                draw.texturedTriangle(
                nX1, nY1, nU1, nV1, nW1,
                nX2, nY2, nU2, nV2, nW2,
                nX3, nY3, nU3, nV3, nW3 ) --]]

                --math.randomseed( nI )
                --vec3setc( vColor, rand( 0, 1 ), rand( 0, 1 ), rand( 0, 1 ) )
                --filltriangle( nX1, nY1, nX2, nY2, nX3, nY3, vColor )
            end

            ::skip::
        end -- while end
    end -- function end
end -- do end

function render.draw( nTime, nFrameTime )
    local nT = sys.gettime()
    for _, tCam in ipairs( tCameraList ) do
        render.view( tCam, nTime, nFrameTime )
    end
    draw.text( string.format( "%.04f", sys.gettime() - nT ), 60, 70 )
end

--**************************************
