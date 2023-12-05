if ( not Inited ) then require( "init" ) return end

local btns = {}

local function killbuttons()
    for i, b in ipairs( btns ) do
        GUI.KillElement( b )
    end
end

local function menucreate( w, h )
    for _, f in ipairs( sys.dir( "scenes" ) ) do
        if ( not string.EndsWith( f, ".lua" ) ) then
            goto skipsceneload
        end

        local file = string.StripExtension( f )

        local Btn = GUI.AddElement( "rectbutton", w * .05, ( h * .01 ) + #btns * ( h * .11 ), w * .9, h * .1 )
        Btn:SetText( file )
        Btn.file = file

        Btn.Press = function( self )
            _SCENETOLOAD = self.file
            killbuttons()
        end

        table.insert( btns, Btn )

        ::skipsceneload::
    end
end

callback( "firstmenuframe", menucreate )
