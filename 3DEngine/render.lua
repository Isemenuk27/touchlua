if ( not Inited ) then require( "init" ) return end

local mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot = mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot
local vec3add, vec3set, vec3mul, vec3dot = vec3add, vec3set, vec3mul, vec3dot
local abs = math.abs

local fovy = math.rad(70)
local aspect = ScrRatio()
local near = .1
local far = 10
local NO_CULL = true

local _VIEWPROJ, _VIEW, _OBJMAT = mat4(), mat4(), mat4()
local _VTEX, _VTEXTR = vec3(), vec3()
local _MAT, _ROT, _ROT2, _VTEXMAT = mat4(), mat4(), mat4(), mat4()
local _PROJ, _ROT, _VTX = mat4(), mat4(), mat4()
local _CAMPOS, _CAMANG, _CAMSCL = vec3( 0, 0, -6 ), vec3( 0, 0, 0 ), vec3( 1, 1, 1 )
local _X, _Y, _Z = mat4(), mat4(), mat4()
local _OBJPOS, _OBJANG, _OBJSCL, _CAMDIR = vec3(), vec3( 0, 0, 0 ), vec3( 1 ), vec3()

local triangle, white = draw.triangle, draw.white

local function trivec( v1, v2, v3, col )
    triangle( v1[1], v1[2], v2[1], v2[2], v3[1], v3[2], col or white )
end

local function mat4per(fovy, aspect, near, far)
    local f = 1.0 / math.tan(fovy / 2.0)
    mat4set( _PROJ, f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (far + near) / (near - far), -1,
    0, 0, (2 * far * near) / (near - far), 0 )
end

function plane( pos, nrm )
    return { pos, nrm }
end

local pNear = plane( vec3(), vec3() )

function planePos( p )
    return p[1]
end

function planeNrm( p )
    return p[2]
end

function CamAng( p, y, r )
    vec2set( _CAMANG, p, y, r )
end

function CamScl( sx, sy, sz )
    vec2set( _CAMSCL, sx, sy, sz )
end

function CamPos( x, y, z )
    vec2set( _CAMPOS, x, y, z )
end

function GetCamPos()
    return _CAMPOS
end

function GetCamScl()
    return _CAMSCL
end

function GetCamAng()
    return _CAMANG
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

local _PV = vec3()
local _T = vec3()

function vec3toscreen( vec )
    vec3set( _T, vec )
    vec3add( _T, _CAMPOS )

    mat4mulvec( _T, _PV, _VIEWPROJ )

    vec3add( _PV, 1, 1, 0 )
    vec3mul( _PV, HScrW(), HScrH(), 1 )

    return _PV[1], _PV[2]
end

local LineD = vec3()

function vec3plane( P, N, A, B )
    local d = -vec3dot( N, P )
    local ad = vec3dot( A, N )
    local bd = vec3dot( B, N )
    local t = ( -d - ad ) / ( bd - ad )

    vec3set( LineD, B )
    vec3sub( LineD, A )

    return vec3add( vec3mul( LineD, t ), lineStart )
end

local PA, PB, PC = vec3(), vec3(), vec3()

MDL_WIREFRAME = 0
MDL_POINTS = 1
MDL_LINE = 2

local RENDERTRI = {
    [0] = vec3(),
    vec3(),
    vec3()
}

local tformed = {
    [0] = vec3(),
    vec3(),
    vec3()
}

local co = {
    [0] = draw.white,
    [1] = draw.red,
    [2] = draw.black,
}

local modeltype = {
    [MDL_WIREFRAME] = function( obj )
        local _OAng = obj.ang
        local _OPos = obj.pos
        local _OScl = obj.scl

        mat4identity( _OBJMAT )

        mat4setTr( _OBJMAT, _OPos )
        mat4setSc( _OBJMAT, _OScl )

        -- Rotation

        mat4zrot( _Z, _OAng[3] ) -- Roll
        mat4yrot( _Y, _OAng[2] ) -- Yaw
        mat4xrot( _X, _OAng[1] ) -- Pitch

        mat4set( _MAT, _OBJMAT )

        mat4mul( _MAT, _Z, _OBJMAT )
        mat4mul( _OBJMAT, _X, _MAT )
        mat4mul( _MAT, _Y, _OBJMAT )

        -- Transform

        for i = 1, #obj.form, 3 do

            --vec3normal( obj.form[i], obj.form[i+1], obj.form[i+2], _N )

            --vec3diff( obj.form[i], _CAMPOS, _Diff )

            for j = 0, 2 do
                local vtex = obj.form[i+j]

                --vec3set( tformed[j], vtex ) -- Transform vertex

                mat4mulvec( vtex, tformed[j], _OBJMAT )
            end


            --local b = triplane( pNear[1], pNear[2], tformed[0], tformed[1], tformed[2] )

            if ( NO_CULL or ( vec3dot( _N, _Diff ) < 0 ) ) then
                for j = 0, 2 do

                    --[[
                    local vtex = obj.form[i+j]

                    vec3set( _VTEXTR, vtex ) -- Transform vertex

                    mat4mulvec( vtex, _VTEXTR, _OBJMAT ) ]]--

                    vec3add( tformed[j], _CAMPOS ) --I O M

                    mat4mulvec( tformed[j], _VTEX, _VIEWPROJ ) -- mat4mulvec( i, o, m )

                    -- Transform into screen

                    vec3add( _VTEX, 1, 1, 0 )
                    vec3mul( _VTEX, HScrW(), HScrH(), 1 )

                    vec3set( RENDERTRI[j], _VTEX )
                end

                trivec( RENDERTRI[0], RENDERTRI[1], RENDERTRI[2] )
            end
        end
    end,
    [MDL_POINTS] = function()

    end,
    [MDL_LINE] = function()

    end
}

function render()
    --[[    vec3angdir( GetCamAng(), _CAMDIR )

    --Setup near clip plane
    vec3set( pNear[2], _CAMDIR )
    vec3set( pNear[1], _CAMDIR )
    vec3add( vec3mul( pNear[1], near ), _CAMPOS )
]]--
    -- Setup Camera

    mat4per(fovy, aspect, near, far)

    mat4identity( _VIEW )

    mat4setTr( _VIEW, _CAMPOS )
    mat4setSc( _VIEW, _CAMSCL )

    -- Rotation

    mat4zrot( _Z, _CAMANG[3] ) -- Roll
    mat4yrot( _Y, _CAMANG[2] ) -- Yaw
    mat4xrot( _X, _CAMANG[1] ) -- Pitch

    mat4set( _MAT, _VIEW )

    mat4mul( _MAT, _Z, _VIEW )
    mat4mul( _VIEW, _X, _MAT )
    mat4mul( _MAT, _Y, _VIEW )

    -- Transform

    mat4mul( _PROJ, _VIEW, _VIEWPROJ )

    --mat4mul( _VIEW, _PROJ, _VIEWPROJ )

    for _, obj in ipairs( _OBJS ) do
        modeltype[obj.rendermode or MDL_WIREFRAME](obj)
    end
end
