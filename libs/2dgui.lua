GUI = {}

GUI.cursors = {}
GUI.elements = {}
GUI.RegisteredElements = {}
GUI.TotalRegistered = 0

function GUI.Render()
    for i, e in ipairs( GUI.elements ) do
        e:Draw()
    end
end

function GUI.Touch( t )
    GUI.cursors[t.id] = { x = t.x, y = t.y, dx = 0, dy = 0 }

    for _, e in ipairs( GUI.elements ) do
        if ( not e._pressed ) then
            if ( e:Test( t.x, t.y ) ) then
                e._pressed = t.id
            end

            if ( e.Press ) then
                e:Press()
            end
        end
    end
end

function GUI.Moved( t )
    GUI.cursors[t.id].dx = t.x - GUI.cursors[t.id].x
    GUI.cursors[t.id].dy = t.y - GUI.cursors[t.id].y

    GUI.cursors[t.id].x = t.x
    GUI.cursors[t.id].y = t.y

    for _, e in ipairs( GUI.elements ) do
        if ( e._pressed and e.Moved ) then
            e:Moved( GUI.cursors[t.id].dx, GUI.cursors[t.id].dy )
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
    for _, e in ipairs( GUI.elements ) do
        if ( e._pressed and e._pressed == t.id ) then
            if ( e.Release ) then e:Release() end
            e._pressed = nil
        end
    end

    GUI.cursors[t.id] = nil
end

if ( callback ) then
    callback( "touch.start", GUI.Touch )
    callback( "touch.move", GUI.Moved )
    callback( "touch.end", GUI.Stop )
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
    table.remove( GUI.elements, element.id )
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
        draw.rect( self.x, self.y, self.x + self.w, self.y + self.h, ( self._hovered and col2 ) or ( self._pressed and col ) or draw.gray )
        --if ( not self._pressed ) then return end
        --draw.rect( self.x, self.y, self.x + self.w, self.y + self.h, col )
    end

    GUI.RegisterElement( "rect", rect )
end

return GUI
