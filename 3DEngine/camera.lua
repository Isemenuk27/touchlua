if ( not Inited ) then require( "init" ) return end

local _CAM = {
    _PROJ = mat4(),
    _POS = vec3(),
    _ANG = vec3(),
    _DIR = vec3(),
    _SCL = vec3( 1, 1, 1 ),
    _FAR = 300,
    _NEAR = .1,
    _FOV = math.rad( 70 ),
    _LEFTHANDED = not true,
    _ORTHO = not true,
    _ORTHOSCALE = 400,
    _NEARCULL = true,
    _F = vec3(),
    _R = vec3(),
    _U = vec3(),
    _FRUSTUM = nil,
    _BACKFACECULL = true,
    _SORTTRIS = true,
    _MOVEMENTSCALE = 1,
    _YMOVESCALE = 1.1,
    _SMOOTHSHADE = not true,
}

function CamAng( p, y, r )
    vec2set( GetCamAng(), p, y, r )
end

function CamScl( sx, sy, sz )
    vec2set( GetCamScl(), sx, sy, sz )
end

function CamPos( x, y, z )
    vec2set( GetCamPos(), x, y, z )
end

function GetCamPos()
    return _CAM._POS
end

function GetCamScl()
    return _CAM._SCL
end

function GetCamAng()
    return _CAM._ANG
end

function GetCamDir()
    return _CAM._DIR
end

function GetCamProj()
    return _CAM._PROJ
end

function CamForward()
    return _CAM._F
end

function CamRight()
    return _CAM._R
end

function CamUp()
    return _CAM._U
end

function CamCull()
    return _CAM._NEARCULL
end

function CamLefthanded()
    return _CAM._LEFTHANDED
end

function CamSort()
    return _CAM._SORTTRIS
end

function CamFar()
    return _CAM._FAR
end

function CamBackfaceCull()
    return _CAM._BACKFACECULL
end

function CamMoveScale()
    return _CAM._MOVEMENTSCALE
end

function CamYMoveScale()
    return _CAM._MOVEMENTSCALE * _CAM._YMOVESCALE
end

function CamFrustum()
    return _CAM._FRUSTUM
end

function CamFov()
    return _CAM._FOV
end

function Cam( off, ang, scl )
    if ( off ) then
        CamPos( off[1], off[2], off[3] )
    end

    if ( ang ) then
        CamAng( ang[1], ang[2], ang[3] )
    end

    if ( scl ) then
        CamScl( scl[1], scl[2], scl[3] )
    end
end

function mat4perspective(fov, aspect, zn, zf, mat)
    local leftHanded = false
    local frustumDepth = zf - zn
    local oneOverDepth = 1 / frustumDepth

    local f = 1 / math.tan( 0.5 * fov )

    mat[1][1] = f
    mat[0][0] = (_CAM._LEFTHANDED and 1 or -1 ) * f / aspect
    mat[2][2] = zf * oneOverDepth
    mat[3][2] = (-zf * zn) * oneOverDepth
    mat[2][3] = 1
    mat[3][3] = 0

    _CAM._FRUSTUM = buildFrustum( fov, aspect, zn, zf )
end

function mat4ortho( w, h, zn, zf, mat )
    mat4set( mat, 2 / w, 0, 0, 0,
    0, 2 / h, 0, 0,
    0, 0, 1 / (zf - zn), 0,
    0, 0, zn / (zn - zf), 1 )
end

local function _CAMERAINIT()
    if ( _CAM._ORTHO ) then
        local w, h = _CAM._ORTHOSCALE, ( ScrW() / ScrH() ) * _CAM._ORTHOSCALE
        mat4ortho( w, h, _CAM._NEAR, _CAM._FAR, _CAM._PROJ )
    else
        mat4perspective( _CAM._FOV, ScrRatio(), _CAM._NEAR, _CAM._FAR, _CAM._PROJ )
        --_CAM._FRUSTUM = buildFrustum( _CAM._FOV, ScrRatio(), _CAM._NEAR, _CAM._FAR )
    end
end

callback( "firstframe", _CAMERAINIT )
callback( "build.camera", _CAMERAINIT )

exec( "camera.ready" )
