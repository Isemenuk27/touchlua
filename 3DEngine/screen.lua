if ( not Inited ) then require( "init" ) return end

local w, h, hw, hh, ratio, ratio2

function showscreen()
    draw.showdrawscreen()
    w, h = draw.getdrawsize()
    hw, hh = w  * .5, h * .5
    ratio  = w / h
    ratio2  = h / w

    exec( "screen" )
end

function ScrW()
    return w
end

function ScrH()
    return h
end

function HScrW()
    return hw
end

function HScrH()
    return hh
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
