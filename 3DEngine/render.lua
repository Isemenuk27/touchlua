if ( not Inited ) then require( "init" ) return end

local mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot = mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot
local vec3add, vec3set, vec3mul, vec3dot = vec3add, vec3set, vec3mul, vec3dot
local abs = math.abs
local _VIEWPROJ, _VIEW, _OBJMAT = mat4(), mat4(), mat4()
local _VTEX, _VTEXTR = vec3(), vec3()
local _MAT, _ROT, _ROT2, _VTEXMAT = mat4(), mat4(), mat4(), mat4()
local _ROT, _VTX = mat4(), mat4()
local _X, _Y, _Z, _TRCAM = mat4(), mat4(), mat4(), mat4()
local _OBJPOS, _OBJANG, _OBJSCL, _CAMDIR = vec3(), vec3( 0, 0, 0 ), vec3( 1 ), vec3()
local triangle, white = draw.triangle, draw.white
local red = draw.red

local GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj = GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj

local function trivec( v1, v2, v3, col )
    triangle( v1[1], v1[2], v2[1], v2[2], v3[1], v3[2], col or white )
end

function plane( pos, nrm ) return { pos, nrm } end

local pNear, pFar = plane( vec3(), vec3() ), plane( vec3(), vec3() )

function planePos( p )    return p[1] end
function planeNrm( p )    return p[2] end

local _PV = vec3()

function vec3toscreen( vec )
    mat4mulvec( vec, _PV, _VIEWPROJ )

    vec3add( _PV, 1, 1, 0 )
    vec3mul( _PV, HScrW(), HScrH(), 1 )

    return _PV[1], _PV[2], _PV[3]
end

local LineD = vec3()

function vec3plane( P, N, A )
    vec3set( LineD, P )
    vec3sub( LineD, A )
    local dot = vec3dot( N, LineD )

    return dot > 0
end

local PA, PB, PC = vec3(), vec3(), vec3()

MDL_WIREFRAME = 0
MDL_POINTS = 1
MDL_LINE = 2

local RENDERTRI = { [0] = vec3(), vec3(), vec3() }
local tformed = { [0] = vec3(), vec3(), vec3() }
local co = { [0] = draw.white, [1] = draw.red, [2] = draw.black }

local modeltype = {
    [MDL_WIREFRAME] = function( obj )
        local _OAng = obj.ang
        local _OPos = obj.pos
        local _OScl = obj.scl

        mat4identity( _OBJMAT )

        mat4setSc( _OBJMAT, _OScl )

        -- Rotation

        mat4zrot( _Z, _OAng[3] ) -- Roll
        mat4yrot( _Y, _OAng[2] ) -- Yaw
        mat4xrot( _X, _OAng[1] ) -- Pitch

        mat4set( _MAT, _OBJMAT )

        mat4mul( _MAT, _Z, _OBJMAT )
        mat4mul( _OBJMAT, _X, _MAT )
        mat4mul( _MAT, _Y, _OBJMAT )

        mat4addTr( _OBJMAT, _OPos )

        --mat4mul( _MAT, _TRCAM, _OBJMAT )

        for i = 1, #obj.form, 3 do -- Transform

            --vec3normal( obj.form[i], obj.form[i+1], obj.form[i+2], _N )
            --vec3diff( obj.form[i], _CAMPOS, _Diff )

            local c = false

            for j = 0, 2 do
                local vtex = obj.form[i+j]

                mat4mulvec( vtex, tformed[j], _OBJMAT )

                local a = vec3plane( pNear[1], pNear[2], tformed[j] )
                local b = vec3plane( pFar[1], pFar[2], tformed[j] )

                if ( not c and ( a or b ) ) then
                    c = true
                end
            end

            if ( CamCull() ) then
                for j = 0, 2 do
                    if ( behindplane( GetCamPos(), GetCamDir(), tformed[j] ) ) then
                        goto skip
                    end
                end
            end

            for j = 0, 2 do
                mat4mulvec( tformed[j], _VTEX, _VIEWPROJ ) -- mat4mulvec( i, o, m )

                vec3add( _VTEX, 1, 1, 0 ) -- Transform into screen
                vec3mul( _VTEX, HScrW(), HScrH(), 1 )

                vec3set( RENDERTRI[j], _VTEX )
                --draw.text( vec3tostring( tformed[j] ), _VTEX[1], _VTEX[2], white )
            end

            trivec( RENDERTRI[0], RENDERTRI[1], RENDERTRI[2], c and red or white)

            ::skip::
        end
    end,
    [MDL_POINTS] = function()

    end,
    [MDL_LINE] = function()

    end
}

function behindplane( P, N, A )
    local Diff = vec3sub( vec3( P ), A )
    local dot = vec3dot( N, Diff )

    return dot < 0 --Точка знаходиться за площиною.
end

local UP, TARGET = vec3( 0, 1, 0 ), vec3( 0, 0, 1 )

function render()
    vec3set( UP, 0, 1, 0 )
    vec3set( TARGET, 0, 0, 1 )

    draw.text( vec3tostring( GetCamPos() ), 20, 100, white )
    draw.text( vec3tostring( GetCamDir() ), 20, 130, white )

    -- Setup Camera

    mat4identity( _VIEW )
    local Ang = GetCamAng()

    mat4setSc( _VIEW, GetCamScl() )

    -- Rotation

    mat4yrot( _Y, Ang[2] ) -- Yaw
    mat4xrot( _X, Ang[1] ) -- Pitch
    mat4zrot( _Z, Ang[3] ) -- Roll

    mat4mul( _VIEW, _Y, _MAT )
    mat4mul( _MAT, _Z, _VIEW )
    mat4mul( _VIEW, _X, _MAT )

    mat4mulvec( TARGET, GetCamDir(), _MAT )
    vec3add( vec3set( TARGET, GetCamPos() ), GetCamDir() )

    mat4identity( _MAT )

    local _, F, R, U = mat4pointat( _MAT, GetCamPos(), TARGET, UP )

    --vec3set( GetCamDir() )

    vec3set( CamForward(), F )
    vec3set( CamRight(), R )
    vec3set( CamUp(), U )

    mat4qinv( _MAT, _VIEW )

    --mat4mul( _MAT, _TRCAM, _VIEW )

    mat4mul( GetCamProj(), _VIEW, _VIEWPROJ )

    for _, obj in ipairs( _OBJS ) do
        modeltype[obj.rendermode or MDL_WIREFRAME](obj)
    end
end
