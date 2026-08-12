#!/usr/bin/env lua
-- rand.lua: Park-Miller (1988) random numbers, on their own.
-- Run this file to print 20 of them; require it to get
-- {srand=srand, rand=rand}.
local Seed,srand,rand
local floor = math.floor

Seed = 1234567891

-- Reseed with any integer; lands in 1..2^31-2.
function srand(n)
  Seed = floor(n or 1234567891) % 2147483647
  if Seed <= 0 then Seed = Seed + 2147483646 end end

-- No args: a float in [0,1). One arg n: an int in 1..n.
-- Two args: an int in lo..hi.
function rand(lo,hi,    x)
  Seed = (16807 * Seed) % 2147483647
  x = Seed / 2147483647
  if not lo then return x end
  if not hi then lo, hi = 1, lo end
  return lo + floor(x * (hi - lo + 1)) end

if arg and arg[0] and arg[0]:find"rand%.lua$" then
  srand()
  for _ = 1, 20 do print(("%.6f"):format(rand())) end end

return {srand=srand, rand=rand}
