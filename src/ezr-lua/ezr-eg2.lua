#!/usr/bin/env lua
-- ezr-eg2.lua: week 2 of ten. Tables, distance, gap to heaven.
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
--     lua ezr-eg2.lua --egs     # list this week's demos
--     lua ezr-eg2.lua --all     # run them all; "failures: 0"
--     lua ezr-eg2.lua --distx   # run just one
--     luajit ezr-eg2.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Last week, single columns. This week, rows of columns: a
-- Tbl folds rows into fresh Num and Sym summaries, and row 1
-- (the header) alone decides each column's kind and role --
-- uppercase = number, trailing "+"/"-" = goal, "X" = ignore,
-- the rest are the x (independent) columns.
--
-- Then, geometry. Each column measures the gap between two of
-- its values as a number 0..1 (Syms: same or not; Nums: the
-- gap between two cdfs; an unknown "?" assumes the worst).
-- minkowski folds those per-column gaps into one 0..1 number.
-- Fold over the x columns and that is `distx`, how far apart
-- two rows sit. Fold over the goal columns, measuring each
-- goal's gap to its best value (heaven: 0 for "-" goals, 1
-- for "+"), and that is `disty`, how far one row sits from
-- heaven (0 = best). No model, no weights, no training: sort
-- rows by disty and the best rows float to the top.
--
-- ## Glossary
-- [Tbl](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#tbl),
-- [distx](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#distx),
-- [disty](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#disty),
-- [heaven](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#heaven),
-- [minkowski](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#minkowski),
-- [cdf](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#cdf),
-- [noir](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#noir)
--
-- ---

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

-- *`lua ezr-eg2.lua --distx`*  
-- A row is zero from itself, and the far pair beats the
-- near one.
doc["--distx"] = "gaps between rows: self, near, far"
eg["--distx"] = function(    t,d)
  t = Tbl(csv(the.file))
  d = function(a,b) return t:distx(a, b) end
  print(show{self=d(t.rows[1], t.rows[1]),
             near=d(t.rows[1], t.rows[2]),
             far =d(t.rows[1], t.rows[398])})
  assert(d(t.rows[1], t.rows[1]) == 0)
  assert(d(t.rows[1], t.rows[2]) <
         d(t.rows[1], t.rows[398])) end

-- *`lua ezr-eg2.lua --disty`*  
-- Sort the rows by their gap to heaven; print the top and
-- bottom three. Note the goal columns (the last three): good
-- rows are light, quick and thrifty, all at once.
doc["--disty"] = "sort rows by gap to heaven; ends shown"
eg["--disty"] = function(    t,d,rows)
  t = Tbl(csv(the.file))
  d = t:Y()
  rows = keysort(t.rows, d)
  for at, r in ipairs(rows) do
    if at <= 3 or at > #rows - 3 then
      print(("%.3f  %s"):format(d(r), show(r)))
    elseif at == 4 then print"..." end end
  assert(d(rows[1]) <= d(rows[#rows])) end

-- *`lua ezr-eg2.lua --laws`*  
-- Distance must behave: 100 random probes of four laws.
doc["--laws"] = "100 random probes of four distance laws"
eg["--laws"] = function(    t,a,b,v)
  t = Tbl(csv(the.file))
  for _ = 1, 100 do
    a = t.rows[rand(#t.rows)]
    b = t.rows[rand(#t.rows)]
    assert(t:distx(a, a) == 0)               -- self is zero
    assert(t:distx(a, b) == t:distx(b, a))   -- symmetry
    v = t:distx(a, b)
    assert(0 <= v and v <= 1)                -- bounded x gap
    v = t:disty(a)
    assert(0 <= v and v <= 1) end            -- bounded y gap
  print"100 rounds, 4 laws: ok" end

--## homework 2 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg2.lua. For its demos (--distx, --disty,
--    --laws), trace only the functions they actually call,
--    following the require chain into [ezr.lua](ezr.html)
--    and [ezr-lib.lua](ezr-lib.html). Print that Lua source
--    in two parts, split by a divider line: above it, code
--    I must hand-port to Python; below it, code a Python
--    builtin already handles, each function commented with
--    the module and function that replaces it. Near enough
--    is good enough."
-- 2. Port the above-the-line code to Python, on top of last
--    week's Num and Sym, wiring each demo to a test_
--    function. Near enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers.
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for the Tbl (and Cols) class plus distx and
--    disty. At the end of that code, add comments answering
--    the "check your port" questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. auto93.csv has "?" cells, and SYM.dist("?","?") is 1,
--    yet the self-is-zero law never fails. Find the "?"
--    cells. Which column are they in, and why does that
--    column never reach distx?
-- 7. Where does the code decide that heaven for "Lbs-" is 0
--    but for "Acc+" is 1? One line; find it.
-- 8. Rerun --distx with --p=1, then --p=4. What happens to
--    the near and far gaps? Why do bigger p's care more
--    about the single worst column?
-- 9. disty needs no learned model, yet --disty sorts the
--    cars from best to worst. So what, exactly, do we still
--    need machine learning for? (Hint: what did disty read
--    from each row that, next week, will cost money?)

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
