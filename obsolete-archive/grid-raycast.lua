local Map = {}
local DGR = math.rad(1)

draw.showdrawscreen()

local DeltaTime = 0
width, height = draw.getdrawsize()

local MapSize = 160

local GridSize = width / MapSize

local MapScale = (MapSize - 1) * GridSize

local mx, my, mdown = 0, 0, false
MousePos = {["x"] = 0, ["y"] = 0}

local BrickColor = { .7, .7, .7, 1 }
local WaterColor = { .0, .0, .9, 1 }

local function GridToScreen(x, y)
    return x * GridSize, y * GridSize
end

local function ScreenToGrid(x, y)
    return x / GridSize, y / GridSize
end

local MapDrawFuncs = {
    [1] = function(x,y)
        local sx, sy = GridToScreen(x, y)
        local ex, ey = sx + GridSize, sy + GridSize
        draw.fillrect(sx, sy, ex, ey, BrickColor)
    end,
    [2] = function(x,y)
        local sx, sy = GridToScreen(x, y)
        local ex, ey = sx + GridSize, sy + GridSize
        draw.fillrect(sx, sy, ex, ey, WaterColor)
    end,
}


local function CurTime()
    return sys.gettime()
end

local function FrameTime()
    return DeltaTime
end

function math.Clamp( inval, minval, maxval )
    if (inval < minval) then return minval end
    if (inval > maxval) then return maxval end
    return inval
end

function math.Approach( cur, target, inc )
    inc = math.abs( inc )
    if ( cur < target ) then
        return math.min( cur + inc, target )
    elseif ( cur > target ) then
        return math.max( cur - inc, target )
    end
    return target
end

function math.dist(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx+dy*dy)
end

local function inside(button, x, y)
    local cx = button.x - x
    local cy = button.y - y
    return math.abs( (cx * cx) + (cy * cy) ) < button.r * button.r
end

--------------------------------
function touchBegan(t)
    MousePos:Set(t.x, t.y)
    mdown = true
end

function touchMoved(t)
    MousePos:Set(t.x, t.y)
end

function touchEnded(t)
    MousePos:Set(t.x, t.y)
    mdown = false
end

draw.touchbegan = touchBegan
draw.touchmoved = touchMoved
draw.touchended = touchEnded
---------------------------------

local CButton = {}

function CButton:New(x, y, r, dir, num, func)
    self.pos = Vector2D(x, y)
    self.r = r
    self.dir = dir
    self.f = func
    self.n = num
    self.down = false
    return self
end

function CButton:Test()
    if not mdown then self.down = false return false end
    self.down = MousePos:InCircle(self.pos, self.r)
    if not self.down then return false end
    self.f()
    return true
end

function CButton:Draw()
    local color = self.down and draw.blue or draw.white

    draw.circle(self.pos.x, self.pos.y, self.r, color)
    draw.text(self.n, self.pos.x, self.pos.y, draw.white)
end

CButton.__index = CButton

---------------------------------------

local CPlayer = {}

function CPlayer:Spawn(x, y)
    self.pos = Vector2D(x, y)
    self.ang = 0
    --self.rect = Rect( x + (x - x * playerprop.bodyScaleX), y + (y - y * playerprop.bodyScaleX), GridSize * playerprop.bodyScaleX, GridSize * playerprop.bodyScaleY)
end

local linelen = 15
local hh = height * .5
function CPlayer:Draw()
    self:Think()
    local drawposx, drawposy = self.pos.x, self.pos.y + MapScale
    draw.fillcircle(drawposx, drawposy, GridSize * .3, draw.blue)
    local rad = math.rad(self.ang)
    local p1 = self.pos.x + math.cos(rad) * linelen
    local p2 = self.pos.y + math.sin(rad) * linelen
    draw.line(self.pos.x, self.pos.y + MapScale, p1, p2 + MapScale, draw.yellow)
end

function CPlayer:Think()

end

function CPlayer:GetPos()
    return self.pos
end

function CPlayer:SetPos(x, y)
    self.pos.x, self.pos.y = x, y
end

function CPlayer:AddAng(d)
    self.ang = (self.ang + d) % 360
end

function CPlayer:Move(d)
    local rad = math.rad(self.ang)
    local p1 =  math.cos(rad) * d
    local p2 = math.sin(rad) * d
    self:AddPos(p1, p2)
end

function CPlayer:AddPos(x, y)
    local speed = 16 / MapSize
    local sx, sy = self.pos.x, self.pos.y
    --local rx, ry, len, hit = CastRay(sx, sy, ex, ey)

    self.pos.x = sx + x * speed
    self.pos.y = sy + y * speed
end

CPlayer.__index = CPlayer

---------------------------------------

local CVector2D = {}

function CVector2D:New( x, y )
    self.x = x
    self.y = y
end

function CVector2D:Add( x, y )
    self.x = self.x + x
    self.y = self.y + y
end

function CVector2D:Sub( x, y )
    self.x = self.x - x
    self.y = self.y - y
end

function CVector2D:Mul( x, y )
    y = y or x
    self.x = self.x * x
    self.y = self.y * y
end

function CVector2D:Div( x, y )
    y = y or x
    self.x = self.x / x
    self.y = self.y / y
end

function CVector2D:Set(x, y)
    self.x, self.y = x, y
end

function CVector2D:LenghtFast()
    return (self.x * self.x) + (self.y * self.y)
end

function CVector2D:Lenght()
    return math.sqrt(self:LenghtFast())
end

CVector2D.Magnitude = CVector2D.Lenght

function CVector2D:Normalize()
    local m = math.sqrt(self.x * self.x + self.y * self.y)
    self.x = self.x / m
    self.y = self.y / m
    return self
end

function CVector2D:GetNormalized()
    local m = math.sqrt(self.x * self.x + self.y * self.y)
    return self.x / m, self.y / m
end

function CVector2D:InAABB( vmin, vmax )
    return (self.x >= vmin.x) and (self.y >= vmin.y) and (self.x < vmax.x) and (self.y < vmax.y)
end

function CVector2D:InCircle(cv, r)
    local cx = cv.x - self.x
    local cy = cv.y - self.y
    return math.abs( (cx * cx) + (cy * cy) ) < r * r
end

CVector2D.__index = CVector2D

function CVector2D:__add(vec)
    return { ["x"] = self.x + vec.x, ["y"] = self.y + vec.y }
end

function CVector2D:__sub(vec)
    return { ["x"] = self.x - vec.x, ["y"] = self.y - vec.y }
end

function CVector2D:__mul(num)
    return { ["x"] = self.x * num, ["y"] = self.y * num }
end

function CVector2D:__div(num)
    return { ["x"] = self.x / num, ["y"] = self.y / num }
end

function Vector2D( x, y )
    local Vtable = {}
    setmetatable(Vtable, CVector2D)
    Vtable:New( x, y )
    return Vtable
end

---------------------------------------

local CRect = {}

local randcolors ={
    draw.white, draw.red,
    draw.green, draw.blue,
    draw.cyan, draw.magenta,
    draw.orange, draw.purple,
    draw.yellow, draw.brown,
    draw.gray
}

function CRect:New(x, y, w, h, col)
    self.pos = Vector2D(x, y)
    self.dim = Vector2D(w, h)
    self.col = col or randcolors[math.random(1, #randcolors)]
end

function CRect:SetPos(x, y)
    self.pos.x, self.pos.y = x, y
end

function CRect:AddPos(x, y)
    self:SetPos(self.pos.x + x, self.pos.y + y)
end

function CRect:Draw()
    draw.fillrect(self.pos.x, self.pos.y, self.pos.x + self.dim.x, self.pos.y + self.dim.y, self.col)
end

function CRect:TestPoint(p)
    return p:InAABB( self.pos, self.pos + self.dim )
end

function CRect:TestRect(rect)
    local x, y = self.pos.x, self.pos.y
    local mx, my = x + self.dim.x, y + self.dim.y

    local rx, ry = rect.pos.x, rect.pos.y
    local rmx, rmy = rx + rect.dim.x, ry + rect.dim.y

    local dx, dy = 0, 0

    if x > rx and x < rmx then
        dx = -(rmx - x)
    end

    if mx > rx and mx < rmx then
        dx = mx - rx
    end

    if dx ~= 0 then

        if y > ry and y < rmy then
            dy = -(rmy - y)
        end

        if my > ry and my < rmy then
            dy = my - ry
        end
    end

    if dy ~= 0 then return true, dx, dy end

    if rx > x and rx < mx then
        dx = mx - rx
    end

    if rmx > x and rmx < mx then
        dx = -(rmx - x)
    end

    if dx == 0 then return false, 0, 0 end

    if ry > y and ry < my then
        dy = my - ry
    end

    if rmy > y and rmy < my then
        dy = -(rmy - y)
    end


    return dy ~= 0, dx, dy
end
local abs = math.abs
function CRect:CollideRect(rect)
    local collide, dx, dy = self:TestRect(rect)
    if not collide then return end
    if abs(dx) > abs(dy) then
        self:AddPos(0, -dy)
        return true
    end
    self:AddPos(-dx, 0)
    return true
end

CRect.__index = CRect

local ObjectTable = {}

function Rect(x, y, w, h, color)
    local index = #ObjectTable + 1
    ObjectTable[index] = {}
    local Rtable = ObjectTable[index]
    setmetatable(Rtable, CRect)
    Rtable:New( x, y, w, h, color )
    return Rtable
end

---------------------------------------

function CastRay(sx, sy, ex, ey)
    local dx, dy = ex - sx, ey - sy
    local lensqr = dx * dx + dy * dy
    local len = math.sqrt(lensqr)
    local nx, ny = dx / len, dy / len
    local rx, ry = nx / ny, ny / nx
    local stx = math.sqrt( 1 + ry * ry )
    local sty = math.sqrt( 1 + rx * rx )

    local rlx, rly
    local stepx, stepy
    local fx, fy = math.floor(sx), math.floor(sy)
    local cx, cy = fx + 1, fy + 1

    if dx < 0 then
        stepx = -1
        rlx = (sx - fx) * stx
    else
        stepx = 1
        rlx = ((fx + 1) - sx) * stx
    end
    if dy < 0 then
        stepy = -1
        rly = (sy - fy) * sty
    else
        stepy = 1
        rly = ((fy + 1) - sy) * sty
    end

    local FoundTile = false
    local maxdist = len
    local dist = 0
    while not FoundTile and dist < maxdist do
        if rlx < rly then
            cx = math.floor(cx + stepx)
            dist = rlx
            rlx = rlx + stx
        else
            cy = math.floor(cy + stepy)
            dist = rly
            rly = rly + sty
        end
        if Map[cy] and Map[cy][cx] and Map[cy][cx] > 0 then FoundTile = true end
    end
    local ix, iy
    if FoundTile then
        ix = sx + nx * dist
        iy = sy + ny * dist
        local rx, ry = GridToScreen(ix, iy)
        return rx, ry, dist, true
    end
    local rx, ry = GridToScreen(ex, ey)
    return rx, ry, maxdist, false
end

--------

local rad = 120
local btnposx, btnposy = width * .5, height - rad * 3.1

MousePos = Vector2D(0, 0)

local TButtons = {}

local TPlayers = {}

TPlayers[1] = {}

local Player = TPlayers[1]
setmetatable(Player, CPlayer)
Player:Spawn( GridToScreen(1, 1) )

--local moverect = Rect( 500, 400, 3, 3, draw.blue )

local speed, angspeed = 200, 100

local buttonfuncs = {
    [1] = function() Player:Move(-(speed * DeltaTime)) end,
    [2] = function() Player:AddAng(angspeed * DeltaTime) end,
    [3] = function() Player:Move(speed * DeltaTime) end,
    [4] = function() Player:AddAng(-angspeed * DeltaTime) end,
}

local function CreateButtons()
    for i = 1, 4 do
        TButtons[i] = {}
        local t = TButtons[i]
        setmetatable(t, CButton)
        local dir = -i * 90
        local dirr = math.rad(dir)
        local r2 = rad * 2
        local ax, ay = math.cos(dirr) * r2, math.sin(dirr) * r2
        t:New(btnposx + ax, btnposy - ay, rad, dir, i, buttonfuncs[i])
    end
end

local function Initialize()
    CreateButtons()
end

Initialize()

local function DrawWorldTiles()
    for y = 0, #Map - 1 do
        for x = 0, #Map[y + 1] do
            local Tile = Map[y + 1][x + 1]
            local drawfunc = MapDrawFuncs[Tile]
            if drawfunc then
                drawfunc(x, y + MapSize - 1)
            end
        end
    end
end

groundtile = 'Draw Examples/image examples/images/GroundTile.png'

local rects = {}

local id = -1

for y = 1, MapSize do
    Map[y] = {}
    id = id + 1
    for x = 1, MapSize do
        id = id + 1
        if x == 1 or x == MapSize then
            Map[y][x] = 1
        elseif y == 1 or y == MapSize then
            Map[y][x] = 1
        elseif math.random(0, 100) > 90 then
            local p1, p2 = GridToScreen(x - 1, y - 1)
            Map[y][x] = 1--Rect(p1, p2, GridSize, GridSize)
            --rects[id] = Map[y][x]
        else
            Map[y][x] = 0
        end
    end
end
local FOV = 60
local linew = width / FOV

local hhh = hh / 2
local curdrawcol = {1, 1, 1, 1}
local q = 1

local function Think()
    local st = CurTime()
    draw.doevents()
    draw.clear(draw.black)

    draw.fillrect(0, hh, width, height, draw.black)

    --DrawWorldTiles()

    for _, btn in ipairs(TButtons) do
        btn:Test()
        btn:Draw()
    end

    for _, r in pairs(rects) do
        moverect:CollideRect(r)
    end

    local px, py = Player.pos.x, Player.pos.y

    local HFov = FOV * .5
    local i = 0
    for a = -HFov, HFov do
        for c = 1, q do
            local rad = math.rad( (a + (1 / c)) - Player.ang + 90)
            local p1, p2 = ScreenToGrid(px, py)
            local p3, p4 = ScreenToGrid(px + math.sin(rad) * 1000, py + math.cos(rad) * 1000)
            local rayx, rayy, rayl = CastRay(p1, p2, p3, p4)

            draw.line(px, py + MapScale, rayx, rayy + MapScale, draw.red)

            local dist = rayl--*math.cos(rad)
            local lineH = hhh * 2 / dist
            if lineH > hhh then lineH = hhh end
            --local lw = linew - (c / linew)

            --do break end
            local x = i * linew
            local br = math.Clamp(lineH / hhh, 0, 1)
            for k, v in ipairs(curdrawcol)do
                if k > 3 then break end
                curdrawcol[k] = br / k
            end
            draw.fillrect(x, hhh - lineH, x + linew, lineH + hhh, curdrawcol)
        end
        --  draw.text(lineH, x + 10, hh + i * 15, draw.blue)
        i = i + 1
    end

    for _, obj in ipairs(ObjectTable) do
        obj:Draw()
    end

    Player:Draw()

    --draw.circle(rayx, rayy, 5, draw.black)
    draw.text(string.format("FT:%s   ang:%s", FrameTime(), Player.ang), 20, 20, draw.red)
    draw.post()
    DeltaTime = CurTime() - st
end

while true do
    Think()
end
