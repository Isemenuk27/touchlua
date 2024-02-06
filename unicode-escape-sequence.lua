--[[https://www.mobilefish.com/services/unicode_escape_sequence_converter/unicode_escape_sequence_converter.php
Тест! -> \u0422\u0435\u0441\u0442!
]]

local sFormat = "\\u%04x"

::start::

do
    local sText = tostring( io.read() ) or "nil"
    local sNew = ""

    for _, nCode in utf8.codes( sText ) do
        if ( nCode < 128 ) then -- convert only if above ASCII limit
            sNew = sNew .. utf8.char( nCode )

            goto skip
        end

        sNew = sNew .. string.format( sFormat, nCode )
        ::skip::
    end

    print( "->" )
    print( sNew )
    print()
end

goto start
