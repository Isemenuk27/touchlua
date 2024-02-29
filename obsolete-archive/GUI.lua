local hook = require "hook"
local gui = {}
gui.Elements = {}
gui.RegisteredNum = 0
local freeslots = {}
local fillrect = draw.fillrect

local PressHook = "MousePressed"
local ReleaseHook = "MouseReleased"
local MoveHook = "MouseMoven"

function CRASHERROR(msg)
    print(msg)
    return deeznuts + ligmaballs * dygetatwgw
end

function gui:Register( tab )
    if not tab then CRASHERROR("[GUI] - Registering invalid table for " .. class) end

    local class = tab.Class
    if not class then CRASHERROR("[GUI] - Class isn't set properly!!") end
    if not gui.Elements[class] then gui.RegisteredNum = gui.RegisteredNum + 1 end

    gui.Elements[class] = tab
end

do --Basic Frame
    local PANEL = {}
    PANEL.Class = "Panel"
    local panelgray = { .9, .9, .9, 1 }

    function PANEL:Create( id )
        self.id = id
        self:SetPos( 0, 0 )
        self:SetSize( 150, 100 )
        self.bHold = false
        self:Init()
    end

    function PANEL:Init()

    end

    function PANEL:Remove()
        freeslots[#freeslots + 1] = self.id
        self = nil
    end

    function PANEL:Draw( x, y, w, h )
        fillrect(x, y, w, h, panelgray)
    end

    function PANEL:SetSize( w, h )
        self.w = w or self.w
        self.h = h or self.h
    end

    function PANEL:SetPos( x, y )
        self.x = x or self.x
        self.y = y or self.y
    end

    function PANEL:AddPos( x, y )
        self.x = (x and self.x + x) or self.x
        self.y = (y and self.y + y) or self.y
    end

    function PANEL:SubPos( x, y )
        self.x = (x and self.x - x) or self.x
        self.y = (y and self.y - y) or self.y
    end

    function PANEL:GetPos()
        return self.x, self.y
    end

    function PANEL:GetSize()
        return self.w, self.h
    end

    function PANEL:GetBounds()
        return self.x, self.y, self.w, self.h
    end

    function PANEL:GetPoints()
        local ox, oy = self.ox or 0, self.oy or 0
        local x, y = self.x + ox, self.y + oy
        return x, y, x + self.w, y + self.h
    end

    function PANEL:Pressed( x, y, dx, dy )
        self:SetPos( x, y )
    end

    function PANEL:MouseMoven( dx, dy )

    end

    function PANEL:Parent( panel, removeoffset )
        if not removeoffset then self.ox, self.oy = panel.x - self.x, panel.y - self.y end
        self.parent = panel
        panel.childs = {} or panel.childs
        local i = #panel.childs + 1
        panel.childs[i] = self
        self.parentid = i
    end

    PANEL.__index = PANEL

    gui:Register( PANEL )
end

gui.ActiveElements = {}

function gui.Create( class, parrent )
    local element = gui.Elements[class]
    if not element then
        print("[GUI] - Class " .. class .. " not found!!!")
        local err = deeznuts + ligmaballs
        return
    end
    local fs, i = next(freeslots), nil
    if fs then
        i = fs
        freeslots[#freeslots] = nil
    else
        i = #gui.ActiveElements + 1
    end
    gui.ActiveElements[i] = {}
    setmetatable( gui.ActiveElements[i], element )
    gui.ActiveElements[i]:Create()
    return gui.ActiveElements[i]
end

local function GuiItarator()
    local i = 0
    local n = table.getn(t)
    return function ()
        i = i + 1
        if i <= n then return t[i] end
    end
end

local function RenderPanels()
    for _, pnl in pairs(gui.ActiveElements) do
        pnl:Draw(pnl:GetPoints())
    end
end

local function InBounds( xmin, ymin, xmax, ymax, x, y )
    return (x > xmin) and (x < xmax) and (y > ymin) and (y < ymax)
end

local ox, oy = 0, 0

local function Press(pnl, curPress, prevPress )
    local pnlPress = pnl.bHold
    if pnl.WhenPressed and curPress and prevPress and pnlPress then
        pnl:WhenPressed()
    elseif pnl.OnRelease and not curPressed and prevPress and pnlPress then
        pnl:OnRelease()
        pnl.bHold = false
    elseif pnl.OnPress and curPressed and not prevPress then
        pnl:OnPress()
        pnl.bHold = true
    end
end

local heldPanels = {}
--[[
ButtonsTable = ButtonsTable or {}
local function Think(x, y, id)
    for _, b in pairs(ButtonsTable) do
        if b:Test(TempCurV) then
            SimulateButton(b, true)
            HeldButtons[id] = b
        elseif HeldButtons[id] == b then
            SimulateButton(b, false)
            HeldButtons[id] = nil
        end
    end
end]]--

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

hook:New(PressHook, "GUI.MouseStart", Think)
hook:New(MoveHook, "GUI.MouseMove", Think)
hook:New(ReleaseHook, "GUI.MouseRelease", Release)

--hook:New( "DrawGUI", "GUI.DRAW", RenderPanels)

gui.RenderPanels = RenderPanels


return gui
