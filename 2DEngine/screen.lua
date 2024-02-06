if ( not Inited ) then require( "init" ) return end

local w, h, hw, hh, ratio, ratio2

function showscreen()
    draw.showdrawscreen()
    w, h = draw.getdrawsize()
    hw, hh = w  * .5, h * .5
    ratio  = h / w
    ratio2 = w / h

    exec( "screen" )
end

function ScrW( m )
    return w * ( m or 1 )
end

function ScrH( m )
    return h * ( m or 1 )
end

function HScrW( m )
    return hw * ( m or 1 )
end

function HScrH( m )
    return hh * ( m or 1 )
end

function Scr()
    return w, h
end

function HScr()
    return hw, hh
end

function ScrRatio()
    return ratio
end

function ScrRatio2()
    return ratio2
end
