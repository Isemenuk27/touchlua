local Primitive = {}
local Vector = require "Vector"
local math = require "Math"

local sqrt, atan = math.sqrt, math.atan
local next, setmetatable = next, setmetatable
local line, fillcircle, circle = draw.line, draw.fillcircle, draw.circle
local CLine = {}

function CLine:New(x1, y1, x2, y2, id)
    self.Start = Vector:New2D(x1, y1)
    self.End = Vector:New2D(x2, y2)
    self.id = i
end

function CLine:Draw(col)
    line(self.Start.x, self.Start.y, self.End.x, self.End.y, col or draw.white)
end

function CLine:GetAng()
    local dx, dy = self.End.x - self.Start.x, self.End.y - self.Start.x
    return atan(dx, dy)
end

function CLine:LengthSqr()
    local dx, dy = self.End.x - self.Start.x, self.End.y - self.Start.y
    return dx * dx + dy * dy
end

function CLine:Length()
    local dx, dy = self.End.x - self.Start.x, self.End.y - self.Start.y
    return sqrt(dx * dx + dy * dy), dx, dy
end

function CLine:GetNormalized()
    local len, x, y = self:Length()
    local il = 1 / len
    return x * il, y * il, len
end

CLine.__index = CLine

Primitive.LinesTable = {}
local freelinesi = {}
local lastx, lasty = 0, 0

function Primitive:Line(x, y, x2, y2)
    local i = next(freelinesi) or #Primitive.LinesTable + 1
    freelinesi[i] = nil
    Primitive.LinesTable[i] = {}

    local l = Primitive.LinesTable[i]
    setmetatable(l, CLine)

    if not x2 then
        l:New(lastx, lasty, x, y, i)
        lastx, lasty = x, y
    else
        l:New(x, y, x2, y2, i)
        lastx = x2
        lasty = y2
    end
    return l
end

local CCircle = {}

function CCircle:New(x, y, r, col, fill, id)
    self.x, self.y, self.r, self.col, self.fill = x, y, r, col, fill
    self.id = id
end

function CCircle:Draw(col)
    local f = (self.fill and fillcircle) or circle
    f(self.x, self.y, self.r, self.col)
end

CCircle.__index = CCircle

Primitive.CirclesTable = {}
local freecirci = {}

function Primitive:Circle(x, y, r, col)
    local i = next(freecirci) or #Primitive.CirclesTable + 1
    freecirci[i] = nil
    Primitive.CirclesTable[i] = {}
    local c = Primitive.CirclesTable[i]
    setmetatable(c, CCircle)
    c:New(x, y, r, col, i)
    return c
end

function Primitive:GetTable()
    return self.ObjTable
end

return Primitive
