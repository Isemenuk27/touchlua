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

local _jdir = vec2()

IN_JUMP = 1
IN_DUCK = 2
IN_USE = 2 ^ 2
IN_FORWARD = 2 ^ 3
IN_BACKWARDS = 2 ^ 4
IN_RIGHT = 2 ^ 5
IN_LEFT = 2 ^ 6

local i_keys = 0

local center = GUI.AddElement( "rect", padx, pady, padbs, padbs )
center.Think = function( self, pressed, hover )
    text( " ", self.x + self.w * .5, self.y + self.h * .5, white )

    if ( not pressed ) then vec2set( _jdir, 0, 0 ) return end

    local x, y = GUI.cursors[self._pressed].x, GUI.cursors[self._pressed].y
    vec2set( _pos, x, y )
    vec2set( _temp, self.x + self.w * .5, self.y + self.h * .5 )
    vec2set( _mid, _temp )
    vec2sub( _temp, _pos )

    local l = min( maxdist, vec2mag( _temp ) )

    vec2normalize( _temp )

    local ang = vec2atan( _temp )

    vec2set( _jdir, _temp )

    vec2mul( _temp, -l )

    vec2add( _temp, _mid )
    vec2set( _pos, _temp )

    line( _mid[1], _mid[2], _pos[1], _pos[2], white )
    circle( _pos[1], _pos[2], w * .1, white )
end

function Joystick()
    return _jdir
end

local Btn3 = GUI.AddElement( "rect", w * .5, h * .75, w * .2, w * .2 )

function Btn3:Think( pressed )
    text( "y+", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    i_keys = i_keys + IN_JUMP
end

local Btn4 = GUI.AddElement( "rect", w * .5, h * .88, w * .2, w * .2 )

function Btn4:Think( pressed )
    text( "y-", self.x + self.w * .5, self.y + self.h * .5, white )
    if ( not pressed ) then return end
    i_keys = i_keys + IN_DUCK
end

local Btn7 = GUI.AddElement( "rect", 0, 0, w, h * .6 )

function Btn7:Moved( x, y )
    local ang = GetCamAng()
    local yaw = ang[2] + ( x * .001 * ( CamLefthanded() and -1 or 1 ) )
    local pitch = ang[1] - ( y * .001 )

    yaw = yaw % ( math.pi * 2 )

    pitch = clamp( pitch, -1.54, 1.54 )

    vec3set( ang, pitch, yaw, ang[3] )
end

function ResetKeys()
    i_keys = 0
end

function IsKeyDown( e_key )
    return ( i_keys & e_key ) == e_key
end
