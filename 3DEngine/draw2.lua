if ( not Inited ) then require( "init" ) return end

local line, white = draw.line, draw.white

local _a, _b, _c, _d = vec3(), vec3(), vec3(), vec3()

function draw.plane( pos, _ang, w, h, col )
    mat4toworld( pos, _ang, vec3( -w, 0, h ), _a )
    mat4toworld( pos, _ang, vec3( -w, 0, -h ), _b )
    mat4toworld( pos, _ang, vec3( w, 0, -h ), _c )
    mat4toworld( pos, _ang, vec3( w, 0, h ), _d )

    local x1, y1 = vec3toscreen( _a )
    local x2, y2 = vec3toscreen( _b )
    local x3, y3 = vec3toscreen( _c )
    local x4, y4 = vec3toscreen( _d )

    line( x1, y1, x2, y2, col or white )
    line( x2, y2, x3, y3, col or white )
    line( x3, y3, x4, y4, col or white )
    line( x4, y4, x1, y1, col or white )
end

local lightDir = vec3()

function GetPointLight( light, pos, normal, out )
    if (light.power < 0) then return out, false end

    vec3diff( pos, light.pos, lightDir )
    local distance = vec3mag( lightDir )

    vec3mul( lightDir, 1 / distance)
    distance = distance * distance

    local NdotL = vec3dot( normal, lightDir )
    local intensity = clamp( NdotL, 0, 1 ) --( 1 + NdotL ) * .5 --

    vec3set( out, light.diffuse )
    vec3mul( out, intensity )
    vec3mul( out, light.power )
    vec3mul( out, 1 / distance )

    return out, true
end
