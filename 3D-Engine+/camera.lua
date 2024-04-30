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
        nFov = math.pi,

        nWidth = 0,
        nHeight = 0,
        nResX = 0,
        nResY = 0,

        nAspect = 0,
        nFarZ = 0,
        nNearZ = 0,
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

function cam.buildPerspective( tCam, nFov, nW, nH, nNearZ, nFarZ )
    tCam.nFov = nFov
    tCam.nWidth = nW
    tCam.nHeight = nH
    tCam.nAspect = nW / nH
    tCam.nNearZ = nNearZ
    tCam.nFarZ = nFarZ

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
    cam.buildPerspectiveFrustum( tCam.tFrustum )
    return tCam
end

function cam.buildPerspectiveFrustum()

end

function cam.newFrustum( nFov, nAspect, nNearZ, nFarZ )
    return {
        vTop = vec3(),
        vBottom = vec3(),

        vRight = vec3(),
        vLeft = vec3(),

        vFar = vec3(),
        vNear = vec3(),

        nFarZ = nFarZ,
        nNearZ = nNearZ,
        nFov = nFov,
        nAspect = nAspect,
    }
end

function cam.updateFrustum( nTime, nFrameTime )
    -- Use inverse matrix transpose
end
