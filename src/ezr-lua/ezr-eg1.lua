#!/usr/bin/env lua
-- ezr-eg1.lua: week 1 of ten. Columns, streaming, forgetting.
-- Tutorial and tests in one file: prose lives in these
-- comments, each demo is one eg[] function that reseeds,
-- prints, then asserts; no crash means pass.
--
-- ## Install
--     sudo apt install lua5.4 luajit         # Debian, Ubuntu
--     brew install lua luajit                # macOS
--     sudo ln -sf /usr/bin/lua5.4 /usr/local/bin/lua # Debian
--
-- ## Run
--     lua ezr-eg1.lua --egs     # list this week's demos
--     lua ezr-eg1.lua --all     # run them all; "failures: 0"
--     lua ezr-eg1.lua --col     # run just one
--     luajit ezr-eg1.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- A column watches values stream past and keeps a tiny
-- summary: a Num holds mean and standard deviation (by
-- Welford's method), a Sym holds counts, mode and entropy.
-- Nothing stores the values themselves. Welford also runs
-- backwards: subtract a value and the stats roll back, so a
-- table can forget rows as cheaply as it learned them.
--
-- Num and Sym answer the same questions -- add, sub, mid,
-- div, norm, dist, holds, reset -- one polymorphic protocol,
-- two implementations (mid is mu or mode; div is sd or
-- entropy). Everything downstream (tables, distance, trees)
-- talks to that protocol, never to the type.
--
-- ## Glossary
-- [Num](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#num),
-- [Sym](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#sym),
-- [columnProtocol](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#columnprotocol)
-- (add, sub, mid, div, norm, dist, holds, reset),
-- [protocol](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#protocol),
-- [noir](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#noir),
-- [welford](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#welford),
-- [stream](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#stream),
-- [mode](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#mode),
-- [entropy](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#entropy)
--
-- ---
local abs = math.abs

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- all defs below land here; reads fall through to ezr
-- (and, through it, to lib and _G)
local _ENV = setmetatable({}, {__index = require"ezr"})
if setfenv then setfenv(1, _ENV) end

--## demos -----------------------------------------------------
eg, doc = {}, {}

doc["--egs"] = "list this week's demos"
eg["--egs"] = function()
  for _,k in ipairs(keys(eg)) do
    print(("%-10s %s"):format(k, doc[k] or "")) end end

doc["--repl"] = "an interactive prompt; bare names resolve"
eg["--repl"] = function() repl(_ENV) end

doc["--all"] = "all the demos; fail if any of them do"
eg["--all"] = function(    bad)
  bad = 0
  for _,k in ipairs(keys(eg)) do
    if k ~= "--all" and k ~= "--egs" and k ~= "--repl" and
       run(eg, k) == false then bad = bad + 1 end end
  print("failures: " .. bad)
  assert(bad == 0) end

-- *`lua ezr-eg1.lua --col`*  
-- Five numbers in, two stats out; three symbols in, a mode
-- and an entropy. adds() drives any column's add() in a loop.
doc["--col"] = "Num and Sym summaries"
eg["--col"] = function(    n,s)
  n = adds{1,2,3,4,5}
  s = adds({"a","a","b"}, Sym())
  print(show{mu=n:mid(), sd=n:div(),
             mode=s:mid(), ent=s:div()})
  assert(n:mid() == 3 and s:mid() == "a") end

-- *`lua ezr-eg1.lua --without`*  
-- Column subtraction: pour b into a, then pour it out again.
-- What is left must be a, to within float noise.
doc["--without"] = "(a+b) minus b == a"
eg["--without"] = function(    a,b,w)
  a, b = adds{1,2,3,4,5}, adds{10,20,30}
  w = adds({10,20,30}, adds{1,2,3,4,5}) - b
  print(show{mu=w.mu, sd=w:div()})
  assert(abs(w.mu - a.mu) < 1e-9) end

-- *`lua ezr-eg1.lua --sub`*  
-- The same trick, one value at a time: watch a hundred
-- numbers, remember the stats, then add fifty more and
-- forget them again. The stats round-trip.
doc["--sub"] = "add, then forget: the stats round-trip"
eg["--sub"] = function(    c,n1,mu1,xtra)
  c = Num()
  for _ = 1, 100 do c:add(rand()) end
  n1, mu1 = c.n, c.mu
  xtra = {}
  for j = 1, 50 do xtra[j] = rand(); c:add(xtra[j]) end
  for _,v in ipairs(xtra) do c:add(v, -1) end
  print(show{n=c.n, mu=c.mu, was=mu1})
  assert(c.n == n1 and abs(c.mu - mu1) < 1e-9) end

--## homework 1 ------------------------------------------------
-- 1. Install [Claude Code](https://claude.com/claude-code).
--    Open a terminal split: Claude on the left, a shell on
--    the right -- ideally in [Ghostty](https://ghostty.org),
--    but [VS Code](https://code.visualstudio.com) is ok.
-- 2. Give Claude this prompt:
--    "Read ezr-eg1.lua. For its demos (--col, --without,
--    --sub), trace only the functions they actually call,
--    following the require chain into [ezr.lua](ezr.html)
--    and [ezr-lib.lua](ezr-lib.html). Print that Lua source
--    in two parts, split by a divider line: above it, code
--    I must hand-port to Python; below it, code a Python
--    builtin already handles, each function commented with
--    the module and function that replaces it. Near enough
--    is good enough."
-- 3. Port the above-the-line code to Python, wiring each
--    demo to a test_ function, using
--    [101.py](https://github.com/txt/seai26f/blob/main/src/101.py)
--    as a basis.
-- 4. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 5. Make that Python perform like the Lua: same demos, same
--    printed numbers (same seed, same precision).
-- 6. Hand in: one side of one piece of paper, showing
--    your Python code for the Num and Sym classes. At the
--    end of that code, add comments answering the
--    "check your port" questions below.
--
-- Check your port:
--
-- 7. Add {10,20,30} to a Num one value at a time, printing
--    mu and sd after each add. Watch Welford converge.
-- 8. What is the entropy of a Sym fed "a","a","a"? Fed
--    "a","b","c"? Predict first, then run it.
-- 9. In --sub, why must the assert use < 1e-9 rather
--    than ==? What does that say about floats?
-- 10. Drop the random number generator into its own file:
--    copy `Seed`, `srand` and `rand` from
--    [ezr-lib.lua](ezr-lib.html); start that file with
--    `local Seed,srand,rand`; end it with
--    `return {srand=srand, rand=rand}`. Print 20 random
--    numbers. Then port that file to Python: same seed,
--    SAME 20 numbers, or the port is wrong.

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
