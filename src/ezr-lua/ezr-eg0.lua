#!/usr/bin/env lua
-- ezr-eg0.lua: week 0 of ten. Boot: run, settings, read data.
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
--     lua ezr-eg0.lua --egs     # list this week's demos
--     lua ezr-eg0.lua --all     # run them all; "failures: 0"
--     lua ezr-eg0.lua --the     # run just one
--     luajit ezr-eg0.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Nothing clever yet: this week just proves your toolchain
-- works. Three things boot everything that follows. Settings
-- live in one table `the`, parsed from the help text at the
-- top of each file (change them from the shell:
-- `--seed=1 --round=3`). Data arrives as a csv stream, one
-- row at a time, never all in memory. And a REPL lets you
-- poke at both.
--
-- ## Glossary
-- [noir](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#noir)
--
-- ---
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

-- *`lua ezr-eg0.lua --the`*  
-- One table holds every setting, parsed from the help text.
-- The command line can update any of them before a demo runs.
doc["--the"] = "the settings, all in one table"
eg["--the"] = function()
  print(show(the))
  assert(the.seed == 1234567891 and the.round == 2) end

-- *`lua ezr-eg0.lua --csv`*  
-- Stream a table off disk, one row at a time. Row one is the
-- header: uppercase = number, lowercase = symbol, trailing
-- "-"/"+" = goal, "X" = ignore (see the glossary's noir).
doc["--csv"] = "stream rows from the default csv file"
eg["--csv"] = function(    n)
  n = 0
  for row in csv(the.file) do
    n = n + 1
    if n <= 3 then print(show(row)) end end
  print(n .. " rows")
  assert(n == 399) end

--## homework 0 ------------------------------------------------
-- Nothing to hand in. This week only checks that your Lua AND
-- your Python both run, so the real work can start next week.
--
-- 1. Install Lua and LuaJIT (see Install, above). Then:
--    `lua ezr-eg0.lua --all` must end "failures: 0".
--    Run it again under `luajit`: SAME output, byte for byte.
-- 2. Install Python 3. Run
--    `python3 ../101.py -h`
--    ([101.py](https://github.com/txt/seai26f/blob/main/src/101.py)
--    is the basis for the port you start next week); you
--    should see its options: file, seed, round.
-- 3. The two languages must agree on "random". Run
--    `lua rand.lua` and `python3 ../rand.py`: each prints 20
--    numbers, and they must be the SAME 20
--    (`diff <(lua rand.lua) <(python3 ../rand.py)` prints
--    nothing). That diff is how ports get graded all
--    semester.
-- 4. Install [Claude Code](https://claude.com/claude-code).
--    Open a terminal split: Claude on the left, a shell on
--    the right -- ideally in [Ghostty](https://ghostty.org),
--    but [VS Code](https://code.visualstudio.com) is ok.
-- 5. Bring the working laptop to class.

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
