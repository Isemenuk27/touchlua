if ( not Inited ) then require( "init" ) return end
local cos, sin, tan, max, min = math.cos, math.sin, math.tan, math.max, math.min
local acos, asin, atan = math.acos, math.asin, math.atan
local abs, floor, ceil, rad, deg = math.abs, math.floor, math.ceil, math.rad, math.deg
local sqrt, random, pi = math.sqrt, math.random, math.pi
local white, black, green = draw.white, draw.black, draw.green
local red = draw.red
local fillrect, text = draw.fillrect, draw.text
local line, circle = draw.line, draw.circle

local w, h = Scr()
local hw, hh = HScr()

local padx, pady = hw * .5, h - hh * .5
local padbs = padx * .8
local pad = padx * .1
local maxdist = w * .2
local _pos, _dir, _temp, _mid = vec2(), vec2(), vec2(), vec2()
local _FORWARD, _RIGHT = vec3(), vec3()

local center = GUI.AddElement( "rect", padx, pady, padbs, padbs )
center.Think = function( self, pressed, hover )
    text( " ", self.x + self.w * .5, self.y + self.h * .5, white )

    if ( not pressed ) then return end

    local x, y = GUI.cursors[self._pressed].x, GUI.cursors[self._pressed].y
    vec2set( _pos, x, y )
    vec2set( _temp, self.x + self.w * .5, self.y + self.h * .5 )
    vec2set( _mid, _temp )
    vec2sub( _temp, _pos )

    local l = min( maxdist, vec2mag( _temp ) )

    vec2normalize( _temp )

    local ang = vec2atan( _temp )

    vec3set( _FORWARD, GetCamDir() )
    vec3set( _RIGHT, CamRight() )
    vec3mul( _FORWARD, -_temp[2] )
    vec3mul( _RIGHT, _temp[1] * ( CamLefthanded() and 1 or -1 ) )

    local _OFFSET = vec3add( _FORWARD, _RIGHT )

    vec3normalize( _OFFSET )

    vec3mul( _OFFSET, FrameTime )
    vec3mul( _OFFSET, CamMoveScale() )

    vec3add( GetCamPos(), _OFFSET )

    vec2mul( _temp, -l )

    vec2add( _temp, _mid )
    vec2set( _pos, _temp )

    line( _mid[1], _mid[2], _pos[1], _pos[2], white )
    circle( _pos[1], _pos[2], w * .1, white )
end

local Btn3 = GUI.AddElement( "rect", w * .5, h * .75, w * .2, w * .2 )

function Btn3:Think( pressed )
    text( "y+", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    vec3add( GetCamPos(), 0, CamYMoveScale() * FrameTime, 0 )
end

local Btn4 = GUI.AddElement( "rect", w * .5, h * .88, w * .2, w * .2 )

function Btn4:Think( pressed )
    text( "y-", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end

    vec3add( GetCamPos(), 0, -FrameTime * CamYMoveScale(), 0 )
end

local Btn7 = GUI.AddElement( "rect", 0, 0, w, h * .6 )

function Btn7:Moved( x, y )
    local ang = GetCamAng()
    local yaw = ang[2] + ( x * .001 * ( CamLefthanded() and -1 or 1 ) )
    local pitch = ang[1] + ( y * .001 )

    yaw = yaw % ( math.pi * 2 )

    pitch = clamp( pitch, -1.54, 1.54 )

    vec3set( ang, pitch, yaw, ang[3] )
end

