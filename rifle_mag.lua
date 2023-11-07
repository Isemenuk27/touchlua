::retry::

local clipsize = 30
local chamber = true

print("Current amount of ammo in mag:")
curammo = tonumber(io.read("*n"))

print("Ammo in reserve:")
resammo = tonumber(io.read("*n"))

print("")
print("Reloading...")
print("")

local clip = curammo

local take = clipsize - clip

if clip > 0 and chamber then
    take = take + 1
end

if take > resammo then take = resammo end

local ramn = clip + take
print("Amount of ammo in rifle", ramn)

print("")

resammo = resammo - take
print("Amount taken", take)
print("Ammo left in reserve", resammo)
print("")
print("")
print("")


goto retry
