local nW, nH, nHW, nHH, ratio, ratio2

function showscreen()
    draw.showdrawscreen()
    nW, nH = draw.getdrawsize()
    nHW, nHH = nW  * .5, nH * .5
    ratio  = nH / nW
    ratio2 = nW / nH

    RunCallback( "ShowScreen" )
end

function ScrW( m )
    return nW * ( m or 1 )
end

function ScrH( m )
    return nH * ( m or 1 )
end

function HScrW( m )
    return nHW * ( m or 1 )
end

function HScrH( m )
    return nHH * ( m or 1 )
end

function Scr( m )
    return ScrW( m ), ScrH( m )
end

function HScr()
    return nHW, nHH
end

function ScrRatio()
    return ratio
end

function ScrRatio2()
    return ratio2
end
