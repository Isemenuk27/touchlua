if ( not bInitialized ) then require( "init" ) return end

cam = {}

function cam.new()
    return {
        vPos = vec3(),
        vDir = vec3( 0, 0, 1 ),
        vAng = vec3(),

        vForwardDir = vec3(),
        vRightDir = vec3(),
        vUpDir = vec3(),

        tFrustum = false,
        mProj = false,
        nFov = math.pi, -- Vertical Fov

        nWidth = 0,
        nHeight = 0,
        nResX = 0,
        nResY = 0,

        nAspect = 0,
        nFarZ = 0,
        nNearZ = 0,

        nVW = 2 ^ 4,
    }
end

function cam.pos( tCam )
    return tCam.vPos
end

function cam.dir( tCam )
    return tCam.vDir
end

function cam.ang( tCam )
    return tCam.vAng
end

function cam.frustum( tCam )
    return tCam.tFrustum
end

function cam.matrix( tCam )
    return tCam.mProj
end

function cam.update( tCam )
    vec3fromEuler( tCam.vDir, vec3unpack( tCam.vAng ) )
end

function cam.forward( tCam )
    return tCam.vForwardDir
end

function cam.right( tCam )
    return tCam.vRightDir
end

function cam.up( tCam )
    return tCam.vUpDir
end

function cam.setResolution( tCam, n )
    tCam.nVW = n
end

function cam.buildPerspective( tCam, nFov, nW, nH, nNearZ, nFarZ )
    tCam.nFov = nFov
    tCam.nWidth = nW
    tCam.nHeight = nH
    tCam.nAspect = nW / nH
    tCam.nNearZ = nNearZ
    tCam.nFarZ = nFarZ

    --print( tCam, nFov, nW, nH, nNearZ, nFarZ )

    local nAspect = tCam.nAspect

    local nOrientation = bLeftHanded and 1 or -1
    local nDepth = nFarZ - nNearZ
    local nInvDepth = 1 / nDepth

    local nF = 1 / math.tan( 0.5 * nFov )

    local mProj = mat4()

    mProj[1][1] = nF
    mProj[0][0] = nOrientation * nF / nAspect
    mProj[2][2] = nFarZ * nInvDepth
    mProj[3][2] = ( -nFarZ * nNearZ ) * nInvDepth
    mProj[2][3] = 1
    mProj[3][3] = 0

    tCam.mProj = mProj

    tCam.tFrustum = cam.newFrustum( nFov, nAspect, nNearZ, nFarZ )
    cam.buildPerspectiveFrustum( tCam )
    return tCam
end

local vZero = vec3()

function cam.buildPerspectiveFrustum( tCam )
    local nFarZ, nNearZ, nFov, nAspect =
    tCam.nFarZ, tCam.nNearZ, tCam.nFov, tCam.nAspect

    local nO = math.tan( nFov * .5 )

    -- b = a * tan(O)
    local nHeightNear, nHeightFar =
    nO * nNearZ, nO * nFarZ
    local nWidthNear, nWidthFar =
    nHeightNear * nAspect, nHeightFar * nAspect

    local vFarTopRight, vFarTopLeft, vFarBottomRight, vFarBottomLeft =
    vec3( -nWidthFar, nHeightFar, nFarZ ), vec3( nWidthFar, nHeightFar, nFarZ ),
    vec3( -nWidthFar, -nHeightFar, nFarZ ), vec3( nWidthFar, -nHeightFar, nFarZ )

    local vNearTopRight, vNearTopLeft, vNearBottomRight, vNearBottomLeft =
    vec3( -nWidthNear, nHeightNear, nNearZ ), vec3( nWidthNear, nHeightNear, nNearZ ),
    vec3( -nWidthNear, -nHeightNear, nNearZ ), vec3( nWidthNear, -nHeightNear, nNearZ )

    local tPlanes = tCam.tFrustum.tOriginalPlanes

    -- Near plane
    table.insert( tPlanes, vec3( 0, 0, nNearZ ) )
    table.insert( tPlanes, vec3( 0, 0, 1) )

    -- Far plane
    table.insert( tPlanes, vec3( 0, 0, nFarZ ) )
    table.insert( tPlanes, vec3( 0, 0, -1 ) )

    --Right plane
    table.insert( tPlanes, vec3() )
    table.insert( tPlanes, math.normalFrom3Points(
    vFarTopRight, vFarBottomRight, vNearBottomRight ) )

    --Left plane
    table.insert( tPlanes, vec3() )
    table.insert( tPlanes, math.normalFrom3Points(
    vFarBottomLeft, vFarTopLeft, vNearTopLeft ) )

    --Top plane
    table.insert( tPlanes, vec3() )
    table.insert( tPlanes, math.normalFrom3Points(
    vFarTopLeft, vFarTopRight, vNearTopRight ) )

    --Bottom plane
    table.insert( tPlanes, vec3() )
    table.insert( tPlanes, math.normalFrom3Points(
    vFarBottomRight, vFarBottomLeft, vNearBottomRight ) )

    for nI = 1, #tPlanes do
        tCam.tFrustum.tPlanes[nI] = vec3()
    end
end

function cam.newFrustum( nFov, nAspect, nNearZ, nFarZ )
    return {
        tOriginalPlanes = {},
        tPlanes = {},
        nFarZ = nFarZ,
        nNearZ = nNearZ,
        nFov = nFov,
        nAspect = nAspect,
    }
end

local mTransform = mat4()

local mRotationX, mRotationY, mRotationZ = mat4(), mat4(), mat4()
local mTransform = mat4()

function cam.updateFrustum( tCam )
    -- Use inverse matrix transpose
    local vPos, vAng = cam.pos( tCam ), cam.ang( tCam )
    local nPitch, nYaw, nRoll = vec3unpack( vAng )

    mat4identity( mTransform )

    mat4rotateX( mRotationX, nPitch )
    mat4rotateY( mRotationY, nYaw )
    mat4rotateZ( mRotationZ, nRoll )

    -- Apply the to matrix
    mat4mul( mTransform, mRotationY, mTransform )
    mat4mul( mTransform, mRotationX, mTransform )
    mat4mul( mTransform, mRotationZ, mTransform )

    local tFrustum = tCam.tFrustum

    local nLen = #tFrustum.tOriginalPlanes

    -- Transform normals
    for nI = 2, nLen, 2 do
        mat4mulVector( mTransform, tFrustum.tOriginalPlanes[nI], tFrustum.tPlanes[nI] )

    end

    -- Transform origins
    mat4setTranslation( mTransform, vPos )

    for nI = 1, nLen, 2 do
        mat4mulVector( mTransform, tFrustum.tOriginalPlanes[nI], tFrustum.tPlanes[nI] )
        --printv( tFrustum.tPlanes[nI] )
    end
end
