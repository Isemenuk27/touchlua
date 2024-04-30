local nM = 1 / 255
local function rgb( nR, nG, nB )
    return { nM * nR, nM * nG, nM * nB, 1 }
end

tTheme = {
    OutlineBright = rgb(126,126,125),
    OutlineDark = rgb(42,48,35),
    Foreground = rgb(76,88,68),
    Background = rgb(62,70,55),
    TextSelected = rgb(172,173,78),
    TextActive = rgb(250,250,250 ),
    TextInactive = rgb(143,153,127),
}
