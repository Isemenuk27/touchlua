local Vector = require "Vector"
local math = require "Math"
local hook = require "hook"

local PressHook = "MousePressed"
local ReleaseHook = "MouseReleased"
local MoveHook = "MouseMoven"

local Cursor = {
    Pressed = false,
    Time = 0,
    [1] = Vector:New2D(0,0)
}

function Cursor:GetPos(id)
    local t = self[ id or 1 ]
    return t
end

function Cursor:IsDown()
    return #self.Pressed > 0
end

function Cursor:SetPos(x, y, id)
    local i = id or 1
    if self[i] then
        self[i]:Set(x, y)
    else
        self[i] = Vector:New2D(x, y)
    end
end

function Cursor.Begin(t)
    local x, y, id = t.x, t.y, t.id
    if hook:Call(PressHook, x, y, id) then return end
    Cursor:SetPos(x, y, id)
end

function Cursor.Move(t)
    local x, y, id = t.x, t.y, t.id
    if hook:Call(MoveHook, x, y, id) then return end
    Cursor:SetPos(x, y, id)
end

function Cursor.End(t)
    local x, y, id = t.x, t.y, t.id
    hook:Call(ReleaseHook, x, y, id)
end

function Cursor:Get()
    return {self.Begin, self.Move, self.End}
end

do
    local ct = Cursor:Get()
    draw.touchbegan = ct[1]
    draw.touchmoved = ct[2]
    draw.touchended = ct[3]
end

return Cursor
