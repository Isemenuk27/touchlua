--[[
Example of usage 3d engine outside of it folder
]]

package.pathinit = "/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;/usr/local/lib/lua/5.3/?.lua;/usr/local/lib/lua/5.3/?/init.lua;./?.lua;./?/init.lua;../3DEngine/?.lua"
package.path = package.path .. ";../?.lua"

local cos, sin = math.cos, math.sin

require( "libs/callback" )

_LOOPCALLBACK = "Scene.Loop"
_INITCALLBACK = "Scene.Init"
_SKIPMENU = true

local function Init()
    local hw = 1
    local hh = 1

    for i = -hw, hw do
        for j = -hh, hh do
            local obj = createclass( C_POLY )
            obj:born()
            obj.form = loadobj( "cube.obj" )
            obj.scl = vec3( .5 )
            obj.ang = vec3( 0, 0, 0 )
            obj.pos = vec3( i, math.random( -3, 3 ), j )
            obj.solid = true
        end
    end
end

callback( _INITCALLBACK, Init )

local function Loop( CT, DT )

end

callback( _LOOPCALLBACK, Loop )

local function sunedit( sun )
    local dif = vec3( 248, 212, 171 )
    local amb = vec3( 85, 124, 173 )

    local pitch = -51
    local yaw = 69

    local dir = vec3( cos(yaw) * cos(pitch), sin(yaw)*cos(pitch), sin(pitch) )

    sun:setColor( vec3mul( dif, 1 / 255 ), vec3mul( amb, 1 / 255 ) )
    sun:setDir( dir )
    return true
end

callback( "sunborn", sunedit )

require(
  "3DEngine/init")
