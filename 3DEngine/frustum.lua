if ( not Inited ) then require( "init" ) return end

local _FRUSTUM = {
    top = nil,
    bottom = nil,

    right = nil,
    left = nil,

    far = nil,
    near = nil,
}

function buildFrustum( fov, aspect, zn, zf )
    local halfVSide = zf * math.tan(fov * .5)
    local halfHSide = halfVSide * aspect
    local frontMultFar = vec3mul( vec3( GetCamDir() ), zf )

    _FRUSTUM.near = {
        vec3mul( vec3add( vec3( GetCamPos() ), zn ), GetCamDir() ),
        vec3( GetCamDir() )
    }
    _FRUSTUM.far  = {
        vec3add( vec3( GetCamPos() ), frontMultFar ),
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
