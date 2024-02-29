local Vector = require "Vector"
local math = require "Math"
local hook = require "hook"
local Cursor = require "Cursor"
local Buttons = require "Buttons"
local Primitive = require "Primitive"

draw.showdrawscreen()
local width, height = draw.getdrawsize()
local hwidth, hheight = width * .5, height * .5
local hhheight = hheight * .5

local SysTime = sys.gettime

--Назви хуків
local PressHook = "MousePressed"
local ReleaseHook = "MouseReleased"
local MoveHook = "MouseMoven"
local DrawHook = "2DRender"
local ThinkHook = "Think"

--Локалізація math
local abs, min, max = math.abs, math.min, math.max
local ceil, floor = math.ceil, math.floor
local cos, sin, sqrt = math.cos, math.sin, math.sqrt
local acos, deg, rad = math.acos, math.deg, math.rad
local InRange, InBounds = math.InRange, math.InBounds
local Clamp = math.Clamp
--Draw
local clear, post = draw.clear, draw.post
local line, fillcircle = draw.line, draw.fillcircle
local fillrect = draw.fillrect
local doevents, text = draw.doevents, draw.text
local text = draw.text
--Кольори
local black, white = draw.black, draw.white
local blue, red = draw.blue, draw.red
local green, yellow = draw.green, draw.yellow
local pink, dwhite = draw.magenta, { 1, 1, 1, 0.5 }
local tryellow, trgreen = {1, .3, 0, .2}, {0, 1, 0, .1}

--Опції рейкасту
local q = .5 --Менше число більше перевірок!!!
local aq = 1 --Більше число - менша точність

local CreateMap = not false --Генерувати об'єкти на карті

--Далі нічого такого щоб його змінювати
local FrameTime = 0
local CurTime = 0
local Remap, clamp = math.Remap, math.Clamp

local emptyf = function() end
local debugrect = emptyf
local debugline = emptyf

local RenderScene = true

local DrawMode = false
local px, py = 700, 500
local ang, len = 90, 200

--Тут змінні "гравця"
local ViewAngle = 90
local MoveNormal = Vector:New2D(0,0)
local MoveNormalPerp = Vector:New2D(0,0)
local ViewNormal = Vector:New2D(0,0)
local MoveSpeed = 100
local ViewSpeed = 30
local lookspeed = 0 --Множиться на час кадру
local Fov = 40
local ViewLenght = 500

local HFov = Fov * .5

local T1 = Vector:New2D(px, py)
local T2 = Vector:New2D(px + cos(rad(ang)) * len, py + sin(rad(ang)) * len)

local NormalA, NormalB = Vector:New2D(0,0,0), Vector:New2D(0,0,0)

local CursorPos = Vector:New2D(T1.x, T1.y)

local lastpos = Vector:New2D(0, 0)

local Debug = false

local function Debbuttonsfunc()
    Debug = not Debug
    debugrect = not Debug and emptyf or draw.rect
    debugline = not Debug and emptyf or draw.line
    return true
end

local function DrawButtonfunc()
    DrawMode = not DrawMode
    return true
end

local function RenderButtonfunc()
    RenderScene = not RenderScene
    return true
end

local function touchBegin(x, y, id)
    lastpos.x = x
    lastpos.y = y
end

local function touchMoved(x, y, id)
    if DrawMode then
        local pos = Cursor:GetPos()
        if (pos - lastpos):Lenght() > 40 then
            Primitive:Line(pos.x, pos.y, lastpos.x, lastpos.y)
            lastpos.x = pos.x
            lastpos.y = pos.y
        end
    end
end

hook:New(PressHook, "DrawMode.Hook", touchBegin)
hook:New(MoveHook, "DrawMkde.Hook", touchMoved)
--hook:New(ReleaseHook, "ButtonsThinkRelease", Release)

do
    local ct = Cursor:Get()
    draw.touchbegan = ct[1]
    draw.touchmoved = ct[2]
    draw.touchended = ct[3]
end

local t = Vector:New2D(0,0) --Щоби в память не срати

local bcol = {1, 1, 1, .2}

local function LineVsLine(las, lae, lbs, lbe, lineinfo)
    --генеруємо 2 AABB прямокункики

    local r1x1, r1y1 = min(las.x, lae.x), min(las.y, lae.y)
    local r1x2, r1y2 = r1x1 + abs(lae.x - las.x), r1y1 + abs(lae.y - las.y)
    local r2x1, r2y1, r2x2, r2y2

    debugrect(r1x1, r1y1, r1x2, r1y2, dwhite)
    --Провіряємо чи вони перетинаються
    local c = false

    for _, t in ipairs(lineinfo.rects) do

        x1, y1, x2, y2 = t[1], t[2], t[3], t[4]
        r2x1, r2y1 = min(x1, x2), min(y1, y2)
        r2x2, r2y2 = r2x1 + abs(x2 - x1), r2y1 + abs(y2 - y1)

        local x1 = InRange(r1x1, r1x2, r2x1)
        local x2 = InRange(r1x1, r1x2, r2x2)

        local x3 = InRange(r2x1, r2x2, r1x1)
        local x4 = InRange(r2x1, r2x2, r1x2)

        -- по Y
        local y1 = InRange(r1y1, r1y2, r2y1)
        local y2 = InRange(r1y1, r1y2, r2y2)

        local y3 = InRange(r2y1, r2y2, r1y1)
        local y4 = InRange(r2y1, r2y2, r1y2)

        if (x1 or x2 or x3 or x4) and (y1 or y2 or y3 or y4) then c = true break end
    end

    if not c then return nil end

    debugrect(r1x1, r1y1, r1x2, r1y2, dwhite)

    t.x, t.y = lae.x - las.x, lae.y - las.y
    --local lalensqr = t:LenghtSqr() --Довжина відрізку в квадраті
    local lalen = t:Lenght()

    local nx, ny, lblen, lblensqr

    if lineinfo then
        nx = lineinfo.nx
        ny = lineinfo.ny
        lblen = lineinfo.lblen
        lblensqr = lineinfo.lblensqr
    else
        t.x, t.y = lbe.x - lbs.x, lbe.y - lbs.y
        lblensqr = t:LenghtSqr() --Довжина другого відрізку

        --nx ny - напрямок, lblen довжина!!!
        nx, ny, lblen = t:GetNormalized()
        --local lblen = t:Lenght()
    end
    local dlen
    local px, py = lbs.x, lbs.y --Початкові к-рди тестування
    --[[
    --Виставимо точку початку перевірки на краї бокса лінії
    if not InBounds(r1x1, r1y1, r1x2, r1y2, px, py) then --воно не буде працювати без цього
        local mx = min(px - r1x1, px - r1x2) --Мінімальна відстань до баунда
        local my = min(py - r1y1, py - r1y2)

        local mx2 = max(px - r1x1, px - r1x2) --Мінімальна відстань до баунда
        local my2 = max(py - r1y1, py - r1y2)

        --коли нам відомо дельти до точки, треба взяти довжину
        --local dlen1 = sqrt(mx * mx + my * my) --бридота
        --local dlen2 = sqrt(mx2 * mx2 + my2 * my2)
        --є нормалі, тому робимо це



        px = px + mx
        py = py + my

        debugline(px, py, r1x1, r1y1, yellow)
        debugline(px, py, r1x2, r1y2, yellow)

        draw.circle(px, py, 7, red)
    end
]]--
    local f = 0
    local step = q / (dlen or lblen) --Число кроку

    while f <= 1 do
        local lsp, lep
        t.x = las.x - px
        t.y = las.y - py

        lsp = t:Lenght() --Довжина початку першого відрізку до точки
        t.x = lae.x - px
        t.y = lae.y - py
        lep = t:Lenght() --Теж саме но з другої
        local a = lsp + lep --Сума
        --a = a * a --Ми перевіряємо довжину в квадраті
        --тому необхідно це значення також взяти в степінь

        if a < (lalen + aq) and a > (lalen - aq) then
            local dx = lbs.x - px
            local dy = lbs.y - py
            local raylen = sqrt(dx * dx + dy * dy)
            --do return 400, 400, 1, 1, 500 end
            return px, py, nx, ny, raylen
        end

        f = f + step
        local fl = lblen * f
        px, py = lbs.x + nx * fl, lbs.y + ny * fl --Просуваємо точку далі по напрямку
    end
    return false --Кінець циклу, колізії не було
end

local tempt = {}
local t = Vector:New2D(0,0)

local linediv = 30 --Трейслайн розділиться на бокси по 30
local drect = {}

local function TraceLine(StartPos, EndPos)
    local lbs, lbe = StartPos, EndPos

    local r2x1, r2y1 = min(lbs.x, lbe.x), min(lbs.y, lbe.y)
    local r2x2, r2y2 = r2x1 + abs(lbe.x - lbs.x), r2y1 + abs(lbe.y - lbs.y)

    t.x, t.y = lbe.x - lbs.x, lbe.y - lbs.y
    local lblensqr = t:LenghtSqr()

    local nx, ny, lblen = t:GetNormalized()

    tempt.rects = {}
    tempt.lblensqr = lblensqr
    tempt.nx = nx
    tempt.ny = ny
    tempt.lblen = lblen

    local step = lblen / linediv
    local times = floor(step)
    local prx, pry

    for _ = 0, times do
        local nxl, nyl = nx, ny
        local x1, y1, x2, y2
        if prx then
            x1 = prx
            y1 = pry
        else
            x1 = T1.x + (_ * linediv) * nxl
            y1 = T1.y + (_ * linediv) * nyl
        end
        if _ >= times then
            x2, y2 = T2.x, T2.y
        else
            x2 = T1.x + (_ * linediv + linediv) * nxl
            y2 = T1.y + (_ * linediv + linediv) * nyl
        end
        prx, pry = x2, y2
        tempt.rects[_ + 1] = {x1, y1, x2, y2}
        debugrect(x1, y1, x2, y2, dwhite)
    end

    local tracetables = {}

    for _, l in ipairs(Primitive.LinesTable) do

        local px, py, nx, ny, len = LineVsLine(l.Start, l.End, T1, T2, tempt)

        if len then
            tracetables[len] = { px, py, len }
        end
    end

    local px, py
    local closer = lblen

    for _, t in pairs(tracetables) do
        closer = min(closer, _)
    end
    if closer >= lblen then return false end
    return tracetables[closer][1], tracetables[closer][2], tracetables[closer][3]
end

local RectW = width / Fov
local rectcol = {1, 1, 1, 1}

local fpsi = 1
local fpst = {}
local fpslen = 10

local function Think()
    local ft = SysTime()
    doevents()
    hook:Call(ThinkHook, FrameTime, CurTime)
    clear(black)
    text( "FrameTime: " .. FrameTime, 30, height - 20, white )
    local sum = 0
    for _, val in ipairs(fpst)do
        sum = sum + val
    end

    local fps = sum / fpslen

    text( "FPS: " .. fps, 30, height - 40, white )

    fpst[fpsi] = 1 / FrameTime

    fpsi = (fpsi % fpslen) + 1
    --text( tostring(T1), 30, 210, white )
    --text( ViewAngle, 30, 240, white )
    do
        local FrameTime = Clamp(FrameTime, .01, .1)
        local s = MoveSpeed * FrameTime
        local vrad = rad(ViewAngle)
        MoveNormal:Set(cos(vrad) * s, sin(vrad) * s)
        local vrad2 = rad(ViewAngle + 90)
        MoveNormalPerp:Set(cos(vrad2) * s, sin(vrad2) * s)

        lookspeed = ViewSpeed * FrameTime
    end
    --T2.x = floor(T2.x / 10) * 10
    --T2.y = floor(T2.y / 10) * 10

    do
        local g = (RenderScene and trgreen) or green
        local y = (RenderScene and tryellow) or yellow
        local r = rad(ViewAngle + HFov)
        T2:Set(T1.x + cos(r) * ViewLenght, T1.y + sin(r) * ViewLenght)
        line(T1.x, T1.y, T2.x, T2.y, y)
        r = rad(ViewAngle - HFov)
        T2:Set(T1.x + cos(r) * ViewLenght, T1.y + sin(r) * ViewLenght)
        line(T1.x, T1.y, T2.x, T2.y, y)

        for _, l in ipairs(Primitive.LinesTable) do
            l:Draw( g )
        end
    end
    for cang = 0, Fov do
        local FDC = cang - HFov
        local rang = ViewAngle + FDC

        local theta = rad(rang)
        local dang = ViewAngle - rang --дельта кута гравця і рей'а
        local ViewLenght = ViewLenght * cos(rad(dang)) --виправлення рибячого ока

        T2:Set(T1.x + cos(theta) * ViewLenght, T1.y + sin(theta) * ViewLenght)

        draw.point(T2.x, T2.y, red)
        local tx, ty, tlen = TraceLine(T1, T2)
        if tx and ty then
            px = tx
            py = ty
            --fillcircle(px, py, 2, yellow)
            if RenderScene then
                local h = (ViewLenght / tlen) * 40

                drect.x1 = RectW * cang
                drect.y1 = max(-hhheight, -h) + hhheight
                drect.x2 = drect.x1 + RectW
                drect.y2 = min(hhheight, h) + hhheight
                local c = Remap(tlen, 0, ViewLenght, 1, 0)

                for ci = 1, 3 do
                    rectcol[ci] = c
                end

                fillrect(drect.x1, drect.y1, drect.x2, drect.y2, rectcol)
            end
        end
    end

    hook:Call(DrawHook)

    post()
    FrameTime = SysTime() - ft
    CurTime = FrameTime + CurTime
end

do
    --Buttons:NewCircle(200, 200, 80, nil, Debbuttonsfunc)
    Buttons:NewRect(0, 0, 200, 100, nil, Debbuttonsfunc)
    Buttons:NewRect(width - 200, 0, 200, 100, nil, DrawButtonfunc)
    Buttons:NewRect(hwidth - 100, 0, 200, 100, nil, RenderButtonfunc)

    local function r1()
        T1:Sub(MoveNormalPerp)
    end
    local function r2()
        T1:Add(MoveNormalPerp)
    end

    Buttons:NewRect(0, height - 600, 150, 600, r1)
    Buttons:NewRect(width - 150, height - 600, 150, 600, r2)

    local ftable = {
        function()
            T1:Sub(MoveNormal)
        end,
        function()
            ViewAngle = ViewAngle - lookspeed
        end,
        function()
            T1:Add(MoveNormal)
        end,
        function()
            ViewAngle = ViewAngle + lookspeed
        end
    }

    local brad = 120
    local radius = brad * 2
    local ox, oy = width * .5, height - radius - brad - 10

    for _ = 1, 4  do
        local a = rad(_ * 90)
        local cx, cy

        cx = ox + cos(a) * radius
        cy = oy + sin(a) * radius

        Buttons:NewCircle(cx, cy, brad, ftable[_], nil, nil, _ .. "")
    end
end
if CreateMap then
    do
        local sides = 10
        local radius = 120
        local ox, oy = 500, 800
        local nx, ny
        local sa = 360 / sides

        for _ = 0, sides - 1 do
            local a = rad(_ * sa)
            local cx, cy
            if nx then
                cx = nx
                cy = ny
            else
                cx = ox + cos(a) * radius
                cy = oy + sin(a) * radius
            end

            local a2 = rad(_ * sa + sa)
            nx = ox + cos(a2) * radius
            ny = oy + sin(a2) * radius

            Primitive:Line(cx, cy, nx, ny)
        end
    end
    do
        local sides = 10
        local radius = 60
        local ox, oy = 800, 200
        local nx, ny
        local sa = 360 / sides

        for _ = 0, sides - 1 do
            local a = rad(_ * sa)
            local cx, cy
            if nx then
                cx = nx
                cy = ny
            else
                cx = ox + cos(a) * radius
                cy = oy + sin(a) * radius * 1.7
            end

            local a2 = rad(_ * sa + sa)
            nx = ox + cos(a2) * radius
            ny = oy + sin(a2) * radius * 1.7

            Primitive:Line(cx, cy, nx, ny)
        end
    end

    do
        local sides = 4
        local radius = 120
        local ox, oy = 200, 100
        local nx, ny
        local sa = 360 / sides

        for _ = 0, sides  do
            local a = rad(_ * sa)
            local cx, cy
            if nx then
                cx = nx
                cy = ny
            else
                cx = ox + cos(a) * radius
                cy = oy + sin(a) * radius
            end

            local a2 = rad(_ * sa + sa)
            nx = ox + cos(a2) * radius
            ny = oy + sin(a2) * radius

            Primitive:Line(cx, cy, nx, ny)
        end
    end
    do
        local p = {
            {0, 1000},
            {400, 1200},
            {600, 1800},
            {700, 1600}
        }

        for i, t in ipairs(p) do
            local li = i-1
            if p[li] then
                local lt = p[li]
                Primitive:Line( lt[1], lt[2], t[1], t[2])
            end
        end
    end
end
while true do Think() end
