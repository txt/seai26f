#!/usr/bin/env lua
-- ezr-eg0.lua: week 0 of ten. The port, warm-up.
--
-- ---
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
local _ENV = setmetatable({}, {__index = require"ezr"})
if setfenv then setfenv(1, _ENV) end

--## the port, warm-up -----------------------------------------
-- **Part 1.** Next week you start porting this system to
-- Python. Warm up here. The demos of
-- [ezr-eg1.lua](ezr-eg1.html) lean on the
-- [ezr-lib.lua](ezr-lib.html) functions at right, and every
-- one is covered by a Python builtin. For each, write the
-- Python equivalent -- most are one line. Check your answers
-- against
-- [101.py](https://github.com/txt/seai26f/blob/main/src/101.py).
local floor = math.floor

function new(kl,t)
  kl.__index=kl; kl.__tostring=show
  return setmetatable(t,kl) end

function iter(src,    at)
  if type(src) == "function" then return src end
  at = 0
  return function() at = at + 1; return src[at] end end

function fun(f)
  if type(f)=="string" then
    return function(v,...) return v[f](v,...) end end
  if type(f)=="number" then
    return function(v) return v[f] end end
  return f end

function map(t,f,    u)
  f = fun(f)
  u = {}
  for _,v in ipairs(t) do u[1+#u]=f(v) end
  return u end

function kap(t,f,    u)
  u = {}
  for k,v in pairs(t) do u[1+#u] = f(k,v) end
  return u end

function copy(t)
  return map(t, function(v) return v end) end

function sum(t,f,    n)
  n = 0
  for _, v in pairs(t) do n = n + f(v) end
  return n end

function sorted(t,f,    s)
  s = copy(t); table.sort(s, f); return s end

function round(v,n)
  if v % 1 == 0 then return floor(v) end
  n = 10 ^ (n or the.round)
  v = floor(v * n + 0.5) / n
  return v % 1 == 0 and floor(v) or v end

function show(t,    u)
  if type(t) ~= "table" then
    return tostring(type(t)=="number" and round(t) or t) end
  u = #t > 0 and map(t, show) or
      sorted(kap(t, function(k,v)
        if tostring(k):sub(1,1) ~= "_" then
          return ":"..k.." "..show(v) end end))
  return "{"..table.concat(u, " ").."}" end

-- One exception to "near enough is good enough": the RNG must
-- match EXACTLY ([rand.py](https://github.com/txt/seai26f/blob/main/src/rand.py)),
-- so that `diff <(lua rand.lua) <(python3 ../rand.py)` prints
-- nothing. That diff is how ports get graded all semester.
Seed = 1234567891

function srand(n)
  Seed = floor(n or 1234567891) % 2147483647
  if Seed <= 0 then Seed = Seed + 2147483646 end end

function rand(lo,hi,    x)
  Seed = (16807 * Seed) % 2147483647
  x = Seed / 2147483647
  if not lo then return x end
  if not hi then lo, hi = 1, lo end
  return lo + floor(x * (hi - lo + 1)) end

-- **Part 2.** Settings drive the randoms. In your copy of
-- [101.py](https://github.com/txt/seai26f/blob/main/src/101.py),
-- add a test that prints ten random numbers:
--
--     def test_rand():
--       for _ in range(10): print(f"{random.random():.6f}")
--
-- Then run it three times:
--
--     python3 101.py rand
--     python3 101.py --seed=42 rand
--     python3 101.py --seed=42 rand
--
-- Same seed, same ten numbers; new seed, new numbers. (Read
-- `main` in 101.py to see why: it calls `random.seed(the.seed)`
-- before every test, and `--seed=42` resets `the.seed` first.)
-- That reset-and-replay is how every experiment in this course
-- is made repeatable.
--
-- **Part 3.** Future weeks hand in code on paper: two columns,
-- tiny font, syntax highlighted. Prove your
-- [Claude Code](https://claude.com/claude-code) can typeset
-- that now. Give it this prompt, then open the result in a
-- browser and print to PDF:
-- "Read 101.py. Write print.html: my code syntax-highlighted
-- (no external CDNs), two CSS columns (column-count:2), 6pt
-- monospace, about 70 chars per column, black on white. I
-- will open it in a browser and print it."

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
eg = {}
go(eg)

return _ENV
