if ( not Inited ) then require( "init" ) return end

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
}

function updateFrustum()
    vec3set( _FRUSTUM.near[1], GetCamDir() )
    vec3mul( _FRUSTUM.near[1], _FRUSTUM.zn )
    vec3add( _FRUSTUM.near[1], GetCamPos() )

    vec3set( _FRUSTUM.near[2], GetCamDir() )


    vec3set( _FRUSTUM.far[1], GetCamDir() )
    vec3mul( _FRUSTUM.far[1], _FRUSTUM.zf )
    vec3add( _FRUSTUM.far[1], GetCamPos() )

    vec3set( _FRUSTUM.far[2], GetCamDir() )
    vec3mul( _FRUSTUM.far[2], -1 )
end

function buildFrustum( fov, aspect, zn, zf )
    _FRUSTUM.zf = zf
    _FRUSTUM.zn = zn
    _FRUSTUM.fov = fov
    _FRUSTUM.aspect = aspect

    local halfVSide = zf * math.tan(fov * .5)
    local halfHSide = halfVSide * aspect
    local frontMultFar = vec3mul( vec3( GetCamDir() ), zf )

    _FRUSTUM.hvside = halfVSide
    _FRUSTUM.hhside = halfHSide
    _FRUSTUM.frontMulFar = frontMultFar

    _FRUSTUM.near = {
        vec3add( vec3mul( vec3( GetCamDir() ), zn ), GetCamPos() ),
        vec3( GetCamDir() )
    }

    _FRUSTUM.far  = {
        vec3add( vec3mul( vec3( GetCamDir() ), zf ), GetCamPos() ),
        vec3negate( vec3( GetCamDir() ) )
    }

    _FRUSTUM.right  = {
        vec3( GetCamPos() ),
        vec3cross( vec3mul( vec3sub( vec3( frontMultFar ), CamRight() ), halfHSide ), CamUp() )
    }
    _FRUSTUM.left   = {
        vec3( GetCamPos() ),
        vec3cross( CamUp(), vec3mul( vec3add( vec3( frontMultFar ), CamRight() ), halfHSide ) )
    }

    _FRUSTUM.top    = {
        vec3( GetCamPos() ),
        vec3cross( CamRight(), vec3mul( vec3sub( vec3( frontMultFar ), CamUp() ), halfVSide ) )
    }
    _FRUSTUM.bottom = {
        vec3( GetCamPos() ),
        vec3cross( vec3mul( vec3add( vec3( frontMultFar ), CamUp() ), halfVSide ), CamRight() )
    }

    return _FRUSTUM
end
