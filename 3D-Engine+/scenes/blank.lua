if ( not bInitialized ) then
    sSceneFile = string.match( debug.getinfo(1, "S").source, "@(.*)" )
    sHomeDir = "../"; dofile( "../init.lua" )
else
    tAdditionalRequire = {
        --sFolder .. "/bsp",
    }
end

local eEnt1, eEnt2

local function initialize()
    eEnt1 = ents.spawn( "ent_prop" )
    eEnt2 = ents.spawn( "ent_prop" )

    eEnt1:SetPos( vec3( .2, .5, -.3 ) )

    eEnt1:SetModel( "cube.mdl" )
    eEnt1:SetTexture( "cat.bmp" )

    eEnt2:SetModel( "cube.mdl" )
    eEnt2:SetTexture( "bird2.bmp" )
end

local function loop( nTime, nFrameTime )
    vec3set( eEnt1.vAng, 0, nTime, 0 )
end

AddCallback( "Init", initialize )
AddCallback( "Loop", loop )
