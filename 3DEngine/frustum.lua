if ( not Inited ) then require( "init" ) return end

local tan = math.tan
local vec3set, vec3mul, vec3sub, vec3, vec3cross = vec3set, vec3mul, vec3sub, vec3, vec3cross

local _FRUSTUM = {
    top = nil,
    bottom = nil,

    right = nil,
    left = nil,

    far = nil,
    near = nil,

    fz = nil,
    nz = nil,
    fov = nil,
    aspect = nil,

    frozen = false,

    farTopRight = vec3(),
    farTopLeft = vec3(),
    farBottomRight = vec3(),
    farBottomLeft = vec3(),
}

function updateFrustum( CT, DT )
    --_FRUSTUM.frozen = CT > 1

    vec3set( _FRUSTUM.near[1], CamForward() )
    vec3mul( _FRUSTUM.near[1], _FRUSTUM.zn )
    vec3add( _FRUSTUM.near[1], GetCamPos() )

    vec3set( _FRUSTUM.near[2], CamForward() )

    vec3set( _FRUSTUM.far[1], CamForward() )
    vec3mul( _FRUSTUM.far[1], _FRUSTUM.zf )
    vec3add( _FRUSTUM.far[1], GetCamPos() )

    vec3set( _FRUSTUM.far[2], CamForward() )
    vec3mul( _FRUSTUM.far[2], -1 )

    local up, right = vec3mul( vec3( CamUp() ), _FRUSTUM.farHeight * .5 ), vec3mul( vec3( CamRight() ), _FRUSTUM.farWidth * .5 )

    vec3add( vec3add( vec3set( _FRUSTUM.farTopRight, _FRUSTUM.far[1] ), up ), right )
    vec3sub( vec3add( vec3set( _FRUSTUM.farTopLeft, _FRUSTUM.far[1] ), up ), right )
    vec3add( vec3sub( vec3set( _FRUSTUM.farBottomRight, _FRUSTUM.far[1] ), up ), right )
    vec3sub( vec3sub( vec3set( _FRUSTUM.farBottomLeft, _FRUSTUM.far[1] ), up ), right )

    vec3set( _FRUSTUM.bottom[1], GetCamPos() )
    vec3normal( _FRUSTUM.farBottomRight, GetCamPos(), _FRUSTUM.farBottomLeft, _FRUSTUM.bottom[2] )

    vec3set( _FRUSTUM.top[1], GetCamPos() )
    vec3normal( _FRUSTUM.farTopRight, _FRUSTUM.farTopLeft, GetCamPos(), _FRUSTUM.top[2] )

    vec3set( _FRUSTUM.left[1], GetCamPos() )
    vec3normal( _FRUSTUM.farTopLeft, _FRUSTUM.farBottomLeft, GetCamPos(), _FRUSTUM.left[2] )

    vec3set( _FRUSTUM.right[1], GetCamPos() )
    vec3normal( _FRUSTUM.farBottomRight, _FRUSTUM.farTopRight, GetCamPos(), _FRUSTUM.right[2] )

end

function buildFrustum( fov, aspect, zn, zf )
    _FRUSTUM.zf = zf
    _FRUSTUM.zn = zn
    _FRUSTUM.fov = fov
    _FRUSTUM.aspect = aspect

    local halfVSide = zf * tan( fov * .5 )
    local halfHSide = halfVSide * aspect
    local frontMultFar = vec3mul( vec3( GetCamDir() ), zf )

    _FRUSTUM.hvside = halfVSide
    _FRUSTUM.hhside = halfHSide
    _FRUSTUM.frontMulFar = frontMultFar

    _FRUSTUM.nearHeight = 2 * tan( _FRUSTUM.fov * .5 ) * _FRUSTUM.zn
    _FRUSTUM.farHeight = 2 * tan( _FRUSTUM.fov * .5 ) * _FRUSTUM.zf
    _FRUSTUM.nearWidth = _FRUSTUM.nearHeight * _FRUSTUM.aspect
    _FRUSTUM.farWidth = _FRUSTUM.farHeight * _FRUSTUM.aspect

    _FRUSTUM.near = {
        vec3add( vec3mul( vec3( GetCamDir() ), zn ), GetCamPos() ),
        vec3( GetCamDir() )
    }

    _FRUSTUM.far  = {
        vec3add( vec3mul( vec3( GetCamDir() ), zf ), GetCamPos() ),
        vec3negate( vec3( GetCamDir() ) )
    }

    local up, right = vec3mul( vec3( CamUp() ), _FRUSTUM.farHeight * .5 ), vec3mul( vec3( CamRight() ), _FRUSTUM.farWidth * .5 )

    --Far plane points

    vec3add( vec3add( vec3set( _FRUSTUM.farTopRight, _FRUSTUM.far[1] ), up ), right )
    vec3sub( vec3add( vec3set( _FRUSTUM.farTopLeft, _FRUSTUM.far[1] ), up ), right )
    vec3add( vec3sub( vec3set( _FRUSTUM.farBottomRight, _FRUSTUM.far[1] ), up ), right )
    vec3sub( vec3sub( vec3set( _FRUSTUM.farBottomLeft, _FRUSTUM.far[1] ), up ), right )

    _FRUSTUM.bottom = { vec3(), vec3() }
    _FRUSTUM.top = { vec3(), vec3() }
    _FRUSTUM.left = { vec3(), vec3() }
    _FRUSTUM.right = { vec3(), vec3() }

    pushClipPlane( _FRUSTUM.near )
    pushClipPlane( _FRUSTUM.far )
    pushClipPlane( _FRUSTUM.bottom )
    pushClipPlane( _FRUSTUM.top )
    pushClipPlane( _FRUSTUM.left )
    pushClipPlane( _FRUSTUM.right )

    return _FRUSTUM
end
