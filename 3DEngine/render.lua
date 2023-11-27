if ( not Inited ) then require( "init" ) return end

local _PRECOMPUTENORMALS = false
local _PRECOMPUTETRIORIGIN = false
--*******************
-- Localize variables

-- mat4 and vec3 functions
local mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot = mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot
local vec3add, vec3sub, vec3set, vec3mul, vec3dot = vec3add, vec3sub, vec3set, vec3mul, vec3dot

local abs, max = math.abs, math.max

--Matrices and vectors
local m_VIEWPROJ, m_VIEW, m_OBJMAT = mat4(), mat4(), mat4()
local m_MAT, m_ROT, m_ROT2, m_VTEXMAT = mat4(), mat4(), mat4(), mat4()
local m_ROT, m_VTX = mat4(), mat4()
local m_X, m_Y, m_Z = mat4(), mat4(), mat4()
local v_OBJPOS, v_OBJANG, v_OBJSCL, v_CAMDIR = vec3(), vec3( 0, 0, 0 ), vec3( 1 ), vec3()
local v_VTEX, v_VTEXTR = vec3(), vec3()

--Draw
local triangle, filltriangle, white = draw.triangle, draw.filltriangle, draw.white

--Camera functions
local GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj = GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj

local s_RENDER = stack()
local computeLighting --function

--*******************
-- Detect if triangle behind, infront or intersects plane

local function planeTriangles( t_points, pos, normal )
    local c = 0

    for i = 1, 3 do
        local diff = vec3diffto( t_points[i], pos )
        local dot = vec3dot( normal, diff )

        --[[local x, y = vec3toscreen( t_points[i] )
        draw.text( dot, x, y, draw.white ) ]]--

        if ( dot > 0 ) then
            c = c + 1
        end
    end

    return c == 3
end

--*******************
-- Vertex struct

function vertex( pos, color )
    return { pos, color }
end

--*******************
-- Face struct

local _BA, _CA, _N, _O = vec3(), vec3(), vec3(), vec3()

function face( p1, p2, p3 )
    if ( _PRECOMPUTENORMALS ) then
        vec3sub( vec3set( _BA, p2 ), p1 )
        vec3sub( vec3set( _CA, p3 ), p1 )

        vec3cross( _BA, _CA, _N )
        vec3normalize( _N ) --Direction
    end

    vec3set( _O, 0 )
    vec3add( _O, p1 )
    vec3add( _O, p2 )
    vec3add( _O, p3 )
    vec3mul( _O, 1 / 3 ) --Mid point

    local tr = {
        v1 = vec3(), v2 = vec3(), v3 = vec3(),
        nr = vec3(), og = vec3(), col = { 0, 0, 0 }
    }

    return { verts = { p1, p2, p3 }, origin = _O, normal = _N, tr = tr }
end

--*******************
-- Transforms 3d point

local v_PV = vec3() --Projected Vector

local function toscreen( vec )
    mat4mulvec( vec, v_PV, m_VIEWPROJ )

    vec3add( v_PV, 1, 1, 0 )
    vec3mul( v_PV, HScrW(), HScrH(), 1 )

    return v_PV[1], ScrH() - v_PV[2], v_PV[3]
end

vec3toscreen = toscreen

--*******************
-- Cull and clip, then push them to render stack

local t_transformed = { vec3(), vec3(), vec3() }
-- List of 3 transformed vertecies
local v_normal = vec3() -- rotated normal
local v_origin = vec3()
local v_CamToTri = vec3()

local function pushtorender( obj )
    local v_OAng = obj.ang
    local v_OPos = obj.pos
    local v_OScl = obj.scl

    mat4identity( m_OBJMAT )

    mat4setSc( m_OBJMAT, v_OScl ) --Scale

    -- Rotation

    mat4zrot( m_Z, v_OAng[3] ) -- Roll
    mat4yrot( m_Y, v_OAng[2] ) -- Yaw
    mat4xrot( m_X, v_OAng[1] ) -- Pitch

    mat4set( m_MAT, m_OBJMAT )

    mat4mul( m_MAT, m_Z, m_OBJMAT )
    mat4mul( m_OBJMAT, m_X, m_MAT )
    mat4mul( m_MAT, m_Y, m_OBJMAT ) -- Rotations

    mat4setTr( m_OBJMAT, v_OPos )

    --Loop though all object faces

    local v_CamPos = GetCamPos()

    for faceid = 1, #obj.form do
        local face = obj.form[faceid]
        local t_verts = face.verts

        --mat4mulvecnotr( face.normal, v_normal, m_OBJMAT )
        --vec3normalize( v_normal )

        for j = 1, 3 do
            mat4mulvec( t_verts[j], t_transformed[j], m_OBJMAT )
        end

        do
            local c1 = planeTriangles( t_transformed, CamFrustum().far[1], CamFrustum().far[2] )
            local c2 = planeTriangles( t_transformed, CamFrustum().near[1], CamFrustum().near[2] )

            if ( c1 or c2 ) then
                goto skipface
            end
        end

        if ( not _PRECOMPUTENORMALS ) then
            vec3sub( vec3set( _BA, t_transformed[2] ), t_transformed[1] )
            vec3sub( vec3set( _CA, t_transformed[3] ), t_transformed[1] )
            vec3cross( _BA, _CA, v_normal )
        end

        vec3set( v_CamToTri, t_transformed[1] )
        vec3sub( v_CamToTri, v_CamPos )

        if ( vec3dot( v_normal, v_CamToTri ) > 0 ) then
            goto skipface
        end

        vec3normalize( v_normal )

        --vec3normalize( v_CamToTri )
        --local dot = -vec3dot( v_normal, v_CamToTri )

        if ( _PRECOMPUTETRIORIGIN ) then
            mat4mulvec( face.origin, v_origin, m_OBJMAT )
        else
            vec3set( v_origin, t_transformed[1] )
            vec3add( v_origin, t_transformed[2] )
            vec3add( v_origin, t_transformed[3] )
            vec3mul( v_origin, 1/3 )
        end

        -- Write transformed vectors in stack

        vec3set( face.tr.v1, t_transformed[1] )
        vec3set( face.tr.v2, t_transformed[2] )
        vec3set( face.tr.v3, t_transformed[3] )
        vec3set( face.tr.nr, v_normal )
        vec3set( face.tr.og, v_origin )

        computeLighting( face.tr )

        push( s_RENDER, face.tr )

        ::skipface::
    end
end

local _TEMPFACECOL = vec3()

computeLighting = function( face )
    --vec3set( face.col, 0 )

    local dot = vec3dot( face.nr, _SUN.dir )

    vec3set( face.col, _SUN.diff )
    vec3mul( face.col, ( dot + 1 ) * .5 )
    vec3add( face.col, _SUN.ambient )

    for _, light in ipairs( _LIGHTS ) do
        GetPointLight( light, face.og, face.nr, _TEMPFACECOL )
        vec3add( face.col, _TEMPFACECOL )
    end

end

local sortFaces

do
    local tablesort, vec3distsqr = table.sort, vec3distsqr
    local CamPos

    local function compareDist( a, b )
        return vec3distsqr( CamPos, a.og ) < vec3distsqr( CamPos, b.og )
    end

    sortFaces = function()
        CamPos = GetCamPos()
        tablesort( s_RENDER, compareDist )
    end
end
--*******************
-- Render stack

local t_Drawcol = { 0, 0, 0, 1 }

local function renderFaces()
    while ( #s_RENDER > 0 ) do
        local face = pop( s_RENDER )

        local x1, y1, z1 = toscreen( face.v1 )
        local x2, y2, z2 = toscreen( face.v2 )
        local x3, y3, z3 = toscreen( face.v3 )

        vec3set( t_Drawcol, face.col )
        clamp01( t_Drawcol )

        filltriangle( x1, y1, x2, y2, x3, y3, t_Drawcol )
    end
end

--*******************
-- Setting up camera and rendering routine

local UP, TARGET = vec3( 0, 1, 0 ), vec3( 0, 0, 1 )

function render()
    updateFrustum()

    vec3set( UP, 0, 1, 0 )
    vec3set( TARGET, 0, 0, 1 ) -- Reset directions

    -- Setup Camera

    mat4identity( m_VIEW ) -- Reset marix
    local Ang = GetCamAng()

    mat4setSc( m_VIEW, GetCamScl() )

    -- Rotation

    mat4yrot( m_Y, Ang[2] ) -- Yaw
    mat4xrot( m_X, Ang[1] ) -- Pitch
    mat4zrot( m_Z, Ang[3] ) -- Roll

    mat4mul( m_VIEW, m_Y, m_MAT )
    mat4mul( m_MAT, m_Z, m_VIEW )
    mat4mul( m_VIEW, m_X, m_MAT ) -- Rotations

    mat4mulvec( TARGET, GetCamDir(), m_MAT )
    --vec3add( vec3set( TARGET, GetCamPos() ), GetCamDir() )

    mat4identity( m_MAT )

    -- Point at marix, transformations handled here
    local _, F, R, U = mat4pointto( m_MAT, GetCamPos(), GetCamDir(), UP )

    -- Directions of camera

    vec3set( CamForward(), F ) --Front
    vec3set( CamRight(), R ) --Right
    vec3set( CamUp(), U ) --Up

    mat4qinv( m_MAT, m_VIEW ) --Used to transform point to camera local

    mat4mul( GetCamProj(), m_VIEW, m_VIEWPROJ )

    stackclear( s_RENDER ) --Clear render stack

    for _, obj in ipairs( _OBJS ) do
        pushtorender( obj )
        -- modeltype[obj.rendermode or MDL_WIREFRAME](obj)
    end

    sortFaces()

    renderFaces()
end
