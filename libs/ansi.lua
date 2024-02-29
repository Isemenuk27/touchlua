local tANSI, tToANSI, tBytetoANSI = true, {}, {}

function string.toANSI( s )
    return tToANSI[s]
end

function string.ANSI( n )
    return tANSI[n]
end

function string.bytesToANSI( b1, b2, b3 )
    if ( not tBytetoANSI[b1] ) then
        print( b1, b2, b3, "SHIT" )
    end

    if ( b3 ) then
        return tBytetoANSI[b1][b2][b3]
    end

    return tBytetoANSI[b1][b2]
end

local function construct()
    for i, v in pairs( tANSI ) do
        tToANSI[v] = i
    end

    setmetatable( tANSI, { __index = function( t, k )
            return string.char( k )
    end } )

    setmetatable( tToANSI, { __index = function( t, k )
            return string.byte( k )
    end } )

    for i = 0x80, 0xFF do
        local a = string.ANSI( i )

        local t, nI = {}, 0

        for c in string.gmatch( a, "." ) do
            nI = nI + 1
            t[nI] = string.byte( c )
        end

        if ( not tBytetoANSI[t[1]] ) then
            tBytetoANSI[t[1]] = {}
        end

        if ( t[3] ~= nil ) then
            if ( not tBytetoANSI[t[1]][t[2]] ) then
                tBytetoANSI[t[1]][t[2]] = {}
            end
            tBytetoANSI[t[1]][t[2]][t[3]] = i

            --print( t[1], t[2], t[3], i, a )
        else
            tBytetoANSI[t[1]][t[2]] = i
            --print( t[1], t[2], i, a )
        end

        --[==[ if ( t[1] == 189 and t[2] == 195 ) then
            print( t[1], t[2], t[3], string.ANSI( i ) )
            print( tBytetoANSI[t[1]] )
        end ]==]--
    end
end

tANSI = {
    --[127] = '',
    [128] = '€',
    [129] = '',
    [130] = '‚',
    [131] = 'ƒ',
    [132] = '„',
    [133] = '…',
    [134] = '†',
    [135] = '‡',
    [136] = 'ˆ',
    [137] = '‰',
    [138] = 'Š',
    [139] = '‹',
    [140] = 'Œ',
    [141] = '',
    [142] = 'Ž',
    [143] = '',
    [144] = '',
    [145] = '‘',
    [146] = '’',
    [147] = '“',
    [148] = '”',
    [149] = '•',
    [150] = '–',
    [151] = '—',
    [152] = '˜',
    [153] = '™',
    [154] = 'š',
    [155] = '›',
    [156] = 'œ',
    [157] = '',
    [158] = 'ž',
    [159] = 'Ÿ',
    [160] = ' ',
    [161] = '¡',
    [162] = '¢',
    [163] = '£',
    [164] = '¤',
    [165] = '¥',
    [166] = '¦',
    [167] = '§',
    [168] = '¨',
    [169] = '©',
    [170] = 'ª',
    [171] = '«',
    [172] = '¬',
    [173] = '­',
    [174] = '®',
    [175] = '¯',
    [176] = '°',
    [177] = '±',
    [178] = '²',
    [179] = '³',
    [180] = '´',
    [181] = 'µ',
    [182] = '¶',
    [183] = '·',
    [184] = '¸',
    [185] = '¹',
    [186] = 'º',
    [187] = '»',
    [188] = '¼',
    [189] = '½',
    [190] = '¾',
    [191] = '¿',
    [192] = 'À',
    [193] = 'Á',
    [194] = 'Â',
    [195] = 'Ã',
    [196] = 'Ä',
    [197] = 'Å',
    [198] = 'Æ',
    [199] = 'Ç',
    [200] = 'È',
    [201] = 'É',
    [202] = 'Ê',
    [203] = 'Ë',
    [204] = 'Ì',
    [205] = 'Í',
    [206] = 'Î',
    [207] = 'Ï',
    [208] = 'Ð',
    [209] = 'Ñ',
    [210] = 'Ò',
    [211] = 'Ó',
    [212] = 'Ô',
    [213] = 'Õ',
    [214] = 'Ö',
    [215] = '×',
    [216] = 'Ø',
    [217] = 'Ù',
    [218] = 'Ú',
    [219] = 'Û',
    [220] = 'Ü',
    [221] = 'Ý',
    [222] = 'Þ',
    [223] = 'ß',
    [224] = 'à',
    [225] = 'á',
    [226] = 'â',
    [227] = 'ã',
    [228] = 'ä',
    [229] = 'å',
    [230] = 'æ',
    [231] = 'ç',
    [232] = 'è',
    [233] = 'é',
    [234] = 'ê',
    [235] = 'ë',
    [236] = 'ì',
    [237] = 'í',
    [238] = 'î',
    [239] = 'ï',
    [240] = 'ð',
    [241] = 'ñ',
    [242] = 'ò',
    [243] = 'ó',
    [244] = 'ô',
    [245] = 'õ',
    [246] = 'ö',
    [247] = '÷',
    [248] = 'ø',
    [249] = 'ù',
    [250] = 'ú',
    [251] = 'û',
    [252] = 'ü',
    [253] = 'ý',
    [254] = 'þ',
    [255] = 'ÿ',
}

construct()
