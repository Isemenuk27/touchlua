GUI = {}

GUI.cursors = {}
GUI.elements = {}
GUI.RegisteredElements = {}
GUI.TotalRegistered = 0

local cursorplus = type( cursor ) == "table"

local white, black, green, red, gray = draw.white, draw.black, draw.green, draw.red, draw.gray
local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi, hpi = math.sqrt, math.random, math.pi, math.pi * .5
local drect, text = draw.rect, draw.text
local line, circle = draw.line, draw.circle
local ipairs, pairs = ipairs, pairs

function GUI.Render()
    for i, e in ipairs( GUI.elements ) do
        e:Draw()
    end
end

function GUI.Touch( t )
    local nTId, nX, nY

    if ( cursorplus ) then
        nTId = t.nTId
        nX, nY = cursor.pos2( t )
    else
        nTId, nX, nY = t.id, t.x, t.y
    end

    GUI.cursors[nTId] = { x = nX, y = nY, dx = 0, dy = 0 }

    for _, e in pairs( GUI.elements ) do
        if ( not e._pressed ) then
            if ( e:Test( nX, nY ) ) then
                e._pressed = nTId
                if ( e.Press ) then
                    e:Press()
                end
            end
        end
    end
end

function GUI.Moved( t )
    if ( cursorplus ) then
        nTId = t.nTId
        nX, nY = cursor.pos2( t )
    else
        nTId, nX, nY = t.id, t.x, t.y
    end

    GUI.cursors[nTId].dx = nX - GUI.cursors[nTId].x
    GUI.cursors[nTId].dy = nY - GUI.cursors[nTId].y

    GUI.cursors[nTId].x = nX
    GUI.cursors[nTId].y = nY

    for _, e in ipairs( GUI.elements ) do
        if ( e._pressed and e.Moved ) then
            e:Moved( GUI.cursors[nTId].dx, GUI.cursors[nTId].dy )
        end

        local hovered = nil

        for id, v in pairs( GUI.cursors ) do
            if ( e:Test( v.x, v.y ) ) then
                hovered = v.id
            end
        end

        e._hovered = hovered
    end
end

function GUI.Stop( t )
    if ( cursorplus ) then
        nTId = t.nTId
        nX, nY = cursor.pos2( t )
    else
        nTId, nX, nY = t.id, t.x, t.y
    end

    for _, e in ipairs( GUI.elements ) do
        if ( e._pressed and e._pressed == nTId ) then
            if ( e.Release ) then e:Release() end
            e._pressed = nil
        end
    end

    GUI.cursors[nTId] = nil
end

if ( callback ) then
    if ( not cursorplus ) then
        callback( "touch.start", GUI.Touch )
        callback( "touch.move", GUI.Moved )
        callback( "touch.end", GUI.Stop )
    else
        callback( cursor.tCallbacks.began, GUI.Touch )
        callback( cursor.tCallbacks.moved, GUI.Moved )
        callback( cursor.tCallbacks.ended, GUI.Stop )
    end
else
    draw.touchbegan = GUI.Touch
    draw.touchmoved = GUI.Moved
    draw.touchended = GUI.Stop
end

function GUI.AddElement( type, x, y, w, h )
    local element = {}
    setmetatable( element, GUI.RegisteredElements[type] )

    if ( element.Init ) then
        element:Init( x, y, w, h )
    end

    table.insert( GUI.elements, element )
    element.id = #GUI.elements
    return element
end

function GUI.KillElement( element )
    --table.remove( GUI.elements, element.id )
    for i = #GUI.elements, 1, -1 do
        if ( GUI.elements[i] == element ) then
            table.remove( GUI.elements, i )
            break
        end
    end

    element = nil
end

function GUI.RegisterElement( type, element )
    if ( not GUI.RegisteredElements[type] ) then
        GUI.TotalRegistered = GUI.TotalRegistered + 1
    end

    GUI.RegisteredElements[type] = element
end

local function diff2( x1, y1, x2, y2 )
    local dx, dy = x2 - x1, y2 -y1
    return dx * dx + dy * dy
end

function GUI.TestCursor( x, y, w, h )
    if ( not h ) then
        local r2 = w * w

        for _, c in pairs( GUI.cursors ) do
            if ( diff2( c.x, c.y, x ,y ) <= r2 ) then
                return true
            end
        end

        return false
    end

    local x1, x2 = x + w, y + h

    for _, c in pairs( GUI.cursors ) do
        local x = c.x > x and c.x < x1
        local y = c.y > y and c.y < y1

        if ( x and y ) then
            return true
        end
    end

    return false
end

do
    local rect = {}
    rect.__index = rect

    function rect:Init( x, y, w, h )
        self.x = x or 0
        self.y = y or 0
        self.w = w or 120
        self.h = h or 120

        self._pressed = false
        self._hovered = false

        self.text = false

        return self
    end

    function rect:Test( x, y )
        return x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h
    end

    local col = { .7, .7, 1, 1 }
    local col2 = { 1, .7, .7, 1 }

    function rect:SetText( t )
        self.text = tostring( t )
    end

    function rect:Draw()
        if ( self.Think ) then self:Think( self._pressed, self._hovered ) end

        drect( self.x, self.y, self.x + self.w, self.y + self.h, ( self._hovered and col2 ) or ( self._pressed and col ) or gray )

        if ( self.text ) then
            text( self.text, self.x + self.w * .5, self.y + self.h * .5, white )
        end
    end

    function rect:Press()
        print( self.text )
    end

    GUI.RegisterElement( "rectbutton", rect )
end

do
    local rect = {}
    rect.__index = rect

    function rect:Init( x, y, w, h )
        self.x = x or 0
        self.y = y or 0
        self.w = w or 120
        self.h = h or 120

        self._pressed = nil
        self._hovered = nil

        return self
    end

    function rect:Test( x, y )
        return x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h
    end

    local col = { .7, .7, 1, 1 }
    local col2 = { 1, .7, .7, 1 }

    function rect:Draw()
        if ( self.Think ) then self:Think( self._pressed, self._hovered ) end
        drect( self.x, self.y, self.x + self.w, self.y + self.h, ( self._hovered and col2 ) or ( self._pressed and col ) or draw.gray )
        --if ( not self._pressed ) then return end
        --draw.rect( self.x, self.y, self.x + self.w, self.y + self.h, col )
    end

    GUI.RegisterElement( "rect", rect )
end

return GUI
