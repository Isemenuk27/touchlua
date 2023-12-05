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

    --if ( distance > light.maxradius ) then
    --    return out, false
    --end

    vec3mul( lightDir, 1 / distance)
    distance = distance * distance

    --Intensity of the diffuse light. Saturate to keep within the 0-1 range.
    local NdotL = vec3dot( normal, lightDir )
    local intensity = clamp( NdotL, 0, 1 ) --( 1 + NdotL ) * .5 --

    -- Calculate the diffuse light factoring in light color, power and the attenuation
    --[[    vec3set( out, light.diff )
    vec3mul( out, intensity )
    vec3mul( out, light.power )
    vec3mul( out, 1 / distance )
    vec3add( out, light.ambient )]]--

    vec3set( out, light.diffuse )
    vec3mul( out, intensity )
    vec3mul( out, light.power )
    vec3mul( out, 1 / distance )

    --clamp01( out )

    -- Calculate the half vector between the light vector and the view vector.
    -- This is typically slower than calculating the actual reflection vector
    -- due to the normalize function's reciprocal square root
    --float3 H = normalize(lightDir + viewDir);

    --Intensity of the specular light
    --float NdotH = dot(normal, H);
    --intensity = pow(saturate(NdotH), specularHardness);

    --Sum up the specular light factoring
    --OUT.Specular = intensity * light.specularColor * light.specularPower / distance;
    return out, true
end

do
    local white = { 1, 1, 1, 1 }
    local color = { 1, 1, 1, 1 }

    local function interp( u, v, w, colorA, colorB, colorC)
        local r = u * colorA[1] + v * colorB[1] + w * colorC[1]
        local g = u * colorA[2] + v * colorB[2] + w * colorC[2]
        local b = u * colorA[3] + v * colorB[3] + w * colorC[3]

        color[1] = r
        color[2] = g
        color[3] = b
    end

    local function coords( x1, y1, x2, y2, x3, y3, x, y )
        local xsx3 = x - x3
        local ysy3 = y - y3

        local d = (y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3)
        local id = 1 / d

        local u = ( (y2 - y3) * xsx3 + (x3 - x2) * ysy3 ) * id
        local v = ( (y3 - y1) * xsx3 + (x1 - x3) * ysy3 ) * id

        return u, v, 1 - u - v
    end

    local point = draw.point
    local min, max = math.min, math.max

    function triBarycentric( x1, y1, x2, y2, x3, y3, c1, c2, c3 )
        c1 = c1 or white
        c2 = c2 or white
        c3 = c3 or white

        local minx = min(x1, x2, x3)
        local maxx = max(x1, x2, x3)

        local miny = min(y1, y2, y3)
        local maxy = max(y1, y2, y3)

        for x = minx, maxx do
            for y = miny, maxy do
                local u, v, w = coords( x1, y1, x2, y2, x3, y3, x, y )

                if u >= 0 and v >= 0 and w >= 0 then
                    interp( u, v, w, c1, c2, c3 )

                    point( x, y, color )
                end
            end
        end
    end
end
