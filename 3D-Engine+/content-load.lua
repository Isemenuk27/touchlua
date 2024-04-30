if ( not bInitialized ) then
    require( "init" )
    return
end

local tTextures = {
    "cat.bmp",
    "cat2.bmp",
}

local tModels = {
    "cube.mdl",
    "triangle.mdl",
    "plane.mdl",
}

do
    printf( "Loading content...\n" )

    local nTime, nGCCount = sys.gettime(), collectgarbage( "count" )
    local nTexturesSize = 0

    for _, sName in ipairs( tTextures ) do
        local nSize = render.loadTexture( sName )
        printf( "%s, %s", sName, string.NiceSize( nSize ) )
        nTexturesSize = nTexturesSize + nSize
    end

    printf( "\nTextures loaded, total of: %s\n", string.NiceSize( nTexturesSize ) )

    local nModelsSize = 0

    for _, sName in ipairs( tModels ) do
        local nSize = mdl.load( sName )
        printf( "%s, %s", sName, string.NiceSize( nSize ) )
        nModelsSize = nModelsSize + nSize
    end

    printf( "\nModels loaded, total of: %s\n", string.NiceSize( nModelsSize ) )

    printf( "Content loaded, total of: %s", string.NiceSize( nModelsSize + nTexturesSize ) )
    printf( "Done in %.03f seconds\n", sys.gettime() - nTime )

    printf( "Garbage collector count difference: %s", string.NiceSize( ( collectgarbage( "count" ) - nGCCount ) * 1024 ) )

    collectgarbage()
end
