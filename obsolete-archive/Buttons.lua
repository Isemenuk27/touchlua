local math = require "Math"
local hook = require "hook"
local Cursor = require "Cursor"
local Vector = require "Vector"
local Buttons = {}

local PressHook = "MousePressed"
local ReleaseHook = "MouseReleased"
local MoveHook = "MouseMoven"
local DrawHook = "2DRender"
local ThinkHook = "Think"

local text, circle = draw.text, draw.circle
local rect, fillrect = draw.rect, draw.fillrect
local white, black = draw.white, draw.black
local whiteblend = {1, 1, 1, .3}

local inrange = math.InRange
local inbounds = math.InBounds
local incircle = math.InCircle

local CBCircle = {}

function CBCircle:New(x, y, r, fHold, fPullDown, fPullUp, text )
    self.x = x
    self.y = y
    self.r = r

    self.hold = fHold
    self.press = fPullDown
    self.relese = fPullUp

    self.text = text

    self.pressed = false
end

function CBCircle:Test(V)
    local p = incircle(self.x, self.y, self.r, V.x, V.y)
    return p
end

function CBCircle:Draw()
    circle(self.x, self.y, self.r, whiteblend)
    if self.text then
        text( self.text, self.x + (#self.text * 3) * .5, self.y, whiteblend)
    end
end

CBCircle.__index = CBCircle

local CBRect = {}

function CBRect:New(x, y, w, h, fHold, fPullDown, fPullUp, text )
    self.x = x
    self.y = y
    self.x2 = self.x + w
    self.y2 = self.y + h

    self.hold = fHold
    self.press = fPullDown
    self.relese = fPullUp

    self.text = text

    self.pressed = false
end

function CBRect:Test(V)
    local p = inbounds(self.x, self.y, self.x2, self.y2, V.x, V.y)
    return p
end

function CBRect:Draw()
    rect(self.x, self.y, self.x2, self.y2, whiteblend)
    if self.text then
        text( self.text, self.x + (#self.text * 3) * .5, self.y, whiteblend)
    end
end

CBRect.__index = CBRect


local ButtonsTable = {}

function Buttons:NewCircle(x, y, r, think, press, release, text)
    local i = #ButtonsTable + 1
    ButtonsTable[i] = {}
    setmetatable(ButtonsTable[i], CBCircle)
    ButtonsTable[i]:New(x, y, r, think, press, release, text)
    return ButtonsTable[i]
end

function Buttons:NewRect(x, y, w, h, think, press, release, text)
    local i = #ButtonsTable + 1
    ButtonsTable[i] = {}
    setmetatable(ButtonsTable[i], CBRect)
    ButtonsTable[i]:New(x, y, w, h, think, press, release, text)
    return ButtonsTable[i]
end

local function SimulateButton(self, pressed)
    local r
    if pressed and not self.pressed and self.press then
        r = self.press()
    elseif not pressed and self.pressed and self.relese then
        self.pressed = false
        return self.relese()
    end
    if pressed and self.pressed and self.hold then
        r = self.hold()
    end
    self.pressed = pressed
    return r
end

local TempCurV = Vector:New2D(0,0)
local HeldButtons = {}

local function Think(x, y, id)
    TempCurV:Set(x,y)
    for _, b in ipairs(ButtonsTable) do
        if b:Test(TempCurV) then
            SimulateButton(b, true)
            HeldButtons[id] = b
        elseif HeldButtons[id] == b then
            SimulateButton(b, false)
            HeldButtons[id] = nil
        end
    end
end

local function Release(x, y, id)
    if not HeldButtons[id] then return end
    TempCurV:Set(x,y)
    SimulateButton(HeldButtons[id], false)
    HeldButtons[id] = nil
end

local function RenderButtons()
    for _, b in ipairs(ButtonsTable) do
        b:Draw()
    end
end

local function ThinkReal(FrameTime, CurTime)
    for id, b in ipairs(HeldButtons)do
        SimulateButton(b, true)
    end
end

hook:New(DrawHook, "ButtonsDraw", RenderButtons)
hook:New(PressHook, "ButtonsThinkBegin", Think)
hook:New(MoveHook, "ButtonsThink", Think)
hook:New(ReleaseHook, "ButtonsThinkRelease", Release)
hook:New(ThinkHook, "ButtonsThinkReal", ThinkReal)

return Buttons
