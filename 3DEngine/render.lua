if ( not Inited ) then require( "init" ) return end

local _PRECOMPUTENORMALS = false
local _PRECOMPUTETRIORIGIN = false
local _DRAWOVERLAY = not false
--*******************
-- Localize variables

-- mat4 and vec3 functions
local mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot = mat4identity, mat4mulvec, mat4mul, mat4setTr, mat4setSc, mat4zrot, mat4yrot, mat4xrot
local vec3add, vec3sub, vec3set, vec3mul, vec3dot = vec3add, vec3sub, vec3set, vec3mul, vec3dot

local abs, max = math.abs, math.max

--Matrices and vectors
local m_VIEWPROJ, m_VIEW, m_OBJMAT = mat4(), mat4(), mat4()
local m_MAT, m_ROT, m_ROT2, m_VTEXMAT = mat4(), mat4(), mat4(), mat4()
local m_ROT, m_VTX, m_CRot = mat4(), mat4(), mat4()
local m_X, m_Y, m_Z = mat4(), mat4(), mat4()
local v_OBJPOS, v_OBJANG, v_OBJSCL, v_CAMDIR = vec3(), vec3( 0, 0, 0 ), vec3( 1 ), vec3()
local v_VTEX, v_VTEXTR = vec3(), vec3()
local v_CamPos

--Draw
local triangle, filltriangle, white, text = draw.triangle, draw.filltriangle, draw.white, draw.text

local function r_circle( pos, r, c )
    local x, y = vec3toscreen( pos )
    draw.circle( x, y, r, c or white )
end

--Camera functions
local GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj = GetCamPos, GetCamScl, GetCamDir, GetCamAng, GetCamProj

local s_RENDER, _Frustum = stack(), nil
local computeLighting, triStructsimple --function
local calcOrigin, pushtorender, pushAndCalcTri, pushAndCalcTriRaw, calcNormal

-- Clip planes stack

local _CLIPPLANES = stack()

function pushClipPlane( plane ) --{ q, n }
    push( _CLIPPLANES, plane )
end

function popClipPlane( plane )
    return pop( _CLIPPLANES )
end

--*******************
-- Detect if triangle behind, infront or intersects plane

local function planeTriangles( t_points, pos, normal )
    local c = 0

    for i = 1, 3 do
        local diff = vec3diffto( t_points[i], pos )
        local dot = vec3dot( normal, diff )

        if ( dot > 0 ) then
            c = c + 1
        end
    end

    return ( c == 3 and -1 ) or ( c > 0 and 1 ) or 0
end

local planeTrianglePoints
local planeRay

do
    local _V1, _V2 = vec3(), vec3()

    planeRay = function( q, n, p1, p2, out )
        vec3set( _V1, p1 )
        vec3sub( _V1, q )

        vec3set( _V2, p2 )
        vec3sub( _V2, q )

        local d1 = vec3dot( n, _V1 )
        local d2 = vec3dot( n, _V2 )

        if ( sign( d1 ) == sign( d2 ) ) then
            return false
        end

        local t = d1 / ( d2 - d1 )

        vec3set( out, p2 )
        vec3sub( out, p1 )
        vec3mul( out, -t )
        vec3add( out, p1 )

        return true, out
    end
end
do
    local t_Points, t_hit = { vec3(), vec3(), vec3() }, { false, false, false }
    local insert = table.insert

    planeTrianglePoints = function( q, n, tri )
        t_hit[1] = planeRay( q, n, tri[1], tri[2], t_Points[1] )
        t_hit[2] = planeRay( q, n, tri[2], tri[3], t_Points[2] )
        t_hit[3] = planeRay( q, n, tri[3], tri[1], t_Points[3] )

        local inside, outside = {}, {}

        for i = 1, 3 do
            local diff = vec3diffto( tri[i], q )

            local dot = vec3dot( n, diff )

            if ( dot > 0 ) then
                insert( outside, tri[i] )
            else
                insert( inside, tri[i] )
            end
        end

        local nrm = calcNormal( tri ) --HACK
        local origin = calcOrigin( tri )

        --[[
Triangle can be cliped and get in wrong order
For now it calculates original tri origin and normal
to be used in backface culling and lighting
]]--

        if ( #outside == 2 ) then
            local tri1 = triStructsimple( 0, 0, 0 )

            vec3set( tri1[1], inside[1] )
            planeRay( q, n, inside[1], outside[1], tri1[2] )
            planeRay( q, n, inside[1], outside[2], tri1[3] )

            vec3set( tri1.nr, nrm ) --HACK
            vec3set( tri1.og, origin )

            pushAndCalcTriRaw( tri1 )
        else
            local tri1 = triStructsimple( inside[1], inside[2], 0 )
            planeRay( q, n, inside[1], outside[1], tri1[3] )

            local tri2 = triStructsimple( 0, tri1[3], inside[2] )
            planeRay( q, n, inside[2], outside[1], tri2[1] )

            vec3set( tri1.nr, nrm ) --HACK
            vec3set( tri2.nr, nrm )
            vec3set( tri1.og, origin )
            vec3set( tri2.og, origin )

            pushAndCalcTriRaw( tri1 )
            pushAndCalcTriRaw( tri2 )
        end

        return true
    end
end

--*******************
-- Vertex struct

function vertex( pos, color )
    return { pos, color }
end

--*******************
-- Face struct

local _BA, _CA, _N, _O = vec3(), vec3(), vec3(), vec3()

local function triStruct( v1, v2, v3, normal, origin, color )
    return {
        vec3( v1 ), vec3( v2 ), vec3( v3 ),
        nr = vec3( normal ), og = vec3( origin ), col = vec3( color )
    }
end

triStructsimple = function( v1, v2, v3 )
    return {
        vec3( v1 ), vec3( v2 ), vec3( v3 ), og = vec3(), nr = vec3(), col = vec3()
    }
end

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

    return { verts = { p1, p2, p3 }, tformed = { vec3(), vec3(), vec3() }, origin = _O, normal = _N, tr = triStruct() }
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

do
    local t_transformed = { vec3(), vec3(), vec3() }
    -- List of 3 transformed vertecies
    local v_normal = vec3() -- rotated normal
    local v_origin = vec3()
    local v_CamToTri = vec3()

    calcNormal =  function( t_tristruct )
        if ( not _PRECOMPUTENORMALS ) then
            vec3sub( vec3set( _BA, t_tristruct[2] ), t_tristruct[1] )
            vec3sub( vec3set( _CA, t_tristruct[3] ), t_tristruct[1] )
            vec3cross( _BA, _CA, v_normal )
        end

        vec3normalize( v_normal )

        return v_normal
    end -- Should be changed/removed

    calcOrigin = function( t_tristruct )
        if ( _PRECOMPUTETRIORIGIN ) then
            mat4mulvec( t_tristruct.og, v_origin, m_OBJMAT )
        else
            vec3set( v_origin, t_tristruct[1] )
            vec3add( v_origin, t_tristruct[2] )
            vec3add( v_origin, t_tristruct[3] )
            vec3mul( v_origin, 1/3 )
        end

        return v_origin
    end -- Should be changed/removed

    pushAndCalcTri = function( t_tristruct, t_transformed )
        if ( not _PRECOMPUTENORMALS ) then
            vec3sub( vec3set( _BA, t_transformed[2] ), t_transformed[1] )
            vec3sub( vec3set( _CA, t_transformed[3] ), t_transformed[1] )
            vec3cross( _BA, _CA, v_normal )
        end

        vec3set( v_CamToTri, t_transformed[1] )
        vec3sub( v_CamToTri, v_CamPos )

        if ( vec3dot( v_normal, v_CamToTri ) > 0 ) then
            return --goto skipface
        end

        vec3set( t_tristruct.nr, v_normal )
        vec3normalize( t_tristruct.nr )

        if ( _PRECOMPUTETRIORIGIN ) then
            mat4mulvec( t_tristruct.og, v_origin, m_OBJMAT )
        else
            vec3set( v_origin, t_transformed[1] )
            vec3add( v_origin, t_transformed[2] )
            vec3add( v_origin, t_transformed[3] )
            vec3mul( v_origin, 1/3 )
            vec3set( t_tristruct.og, v_origin )
        end

        -- Write transformed vectors in stack

        vec3set( t_tristruct[1], t_transformed[1] )
        vec3set( t_tristruct[2], t_transformed[2] )
        vec3set( t_tristruct[3], t_transformed[3] )

        push( s_RENDER, t_tristruct )
    end

    pushAndCalcTriRaw = function( t_tristruct )
        vec3set( v_CamToTri, t_tristruct[1] )
        vec3sub( v_CamToTri, v_CamPos )

        if ( vec3dot( t_tristruct.nr, v_CamToTri ) > 0 ) then
            return
        end

        push( s_RENDER, t_tristruct )
    end -- Should be changed/removed

    pushtorender = function( obj )
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

        for i = 1, 8 do
            mat4mulvec( obj.form.rawpoints[i], obj.form.oobbpoints[i], m_OBJMAT )
        end

        for i = 1, 2 do
            mat4mulvec( obj.form.rawoobb[i], obj.form.oobb[i], m_OBJMAT )
        end

        --Loop though all object faces

        for faceid = 1, #obj.form do
            local face = obj.form[faceid]
            local t_verts = face.verts
            local t_tformed = face.tformed

            for j = 1, 3 do
                mat4mulvec( t_verts[j], t_tformed[j], m_OBJMAT )
                t_transformed[j] = t_tformed[j]
            end
            if ( _RAYCASTRENDER ) then
                ::skipface::
            end

            for i, clip in ipairs( _CLIPPLANES ) do
                local c1 = planeTriangles( t_transformed, clip[1], clip[2] )
                if ( c1 == -1 ) then
                    goto skipface
                elseif ( c1 == 1 ) then
                    planeTrianglePoints( clip[1], clip[2], t_transformed )
                    goto skipface
                end
            end

            pushAndCalcTri( face.tr, t_transformed )

            ::skipface::
        end
    end
end

do
    local _TEMPFACECOL = vec3()

    computeLighting = function( face )
        local dot = vec3dot( face.nr, _SUN.dir )

        vec3set( face.col, _SUN.diff )
        vec3mul( face.col, ( dot + 1 ) * .5 ) --remap [-1, 1] to [0, 1]
        vec3add( face.col, _SUN.ambient )

        for _, light in ipairs( _LIGHTS ) do
            GetPointLight( light, face.og, face.nr, _TEMPFACECOL )
            vec3add( face.col, _TEMPFACECOL )
        end
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

        computeLighting( face )

        local x1, y1, z1 = toscreen( face[1] )
        local x2, y2, z2 = toscreen( face[2] )
        local x3, y3, z3 = toscreen( face[3] )

        vec3set( t_Drawcol, face.col )
        clamp01( t_Drawcol )

        filltriangle( x1, y1, x2, y2, x3, y3, t_Drawcol )

        --triBarycentric( x1, y1, x2, y2, x3, y3, t_Drawcol )

        --if ( _DRAWOVERLAY ) then
        --triangle( x1, y1, x2, y2, x3, y3, white )
        --end

        --[[text( 1, x1, y1, white )
        text( 2, x2, y2, white )
        text( 3, x3, y3, white )]]--
        --debug overlay
    end
end

--*******************
-- Setting up camera and rendering routine

local UP, TARGET = vec3( 0, 1, 0 ), vec3( 0, 0, 1 )

function render( CT, DT )
    _Frustum = CamFrustum()

    v_CamPos = GetCamPos()

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

    --[[    mat4setupangles( m_CRot, Ang )
    mat4mul( m_VIEW, m_CRot, m_MAT )]]--

    mat4mulvec( TARGET, GetCamDir(), m_MAT )
    --vec3add( vec3set( TARGET, GetCamPos() ), GetCamDir() )

    mat4identity( m_MAT )

    -- Point at marix, transformations handled here
    local _, F, R, U = mat4pointto( m_MAT, GetCamPos(), GetCamDir(), UP )

    -- Directions of camera

    vec3set( CamForward(), F ) --Front
    vec3set( CamRight(), R ) --Right
    vec3set( CamUp(), U ) --Up

    if ( _Frustum and not _Frustum.frozen ) then
        updateFrustum(CT, DT)
    end

    mat4qinv( m_MAT, m_VIEW ) --Used too transform point to camera local

    mat4mul( GetCamProj(), m_VIEW, m_VIEWPROJ )

    stackclear( s_RENDER ) --Clear render stack

    for _, obj in ipairs( _OBJS ) do
        pushtorender( obj )
    end

    if ( not _SUPRESSRENDER ) then
        sortFaces()

        renderFaces()
    end

end
