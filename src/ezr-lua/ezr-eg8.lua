#!/usr/bin/env lua
-- ezr-eg8.lua: week 8 of ten. Optimizers, versus DTLZ.
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
--     lua ezr-eg8.lua --egs     # list this week's demos
--     lua ezr-eg8.lua --all     # run them all; "failures: 0"
--     lua ezr-eg8.lua --race    # run just one
--     luajit ezr-eg8.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Every week so far has learned from a csv, where the goals
-- were already filled in and free. Now the goals come from a
-- MODEL, and each one costs. DTLZ1-7 are the standard test
-- problems for exactly this: x in 0..1, objectives with a
-- KNOWN true front, and difficulty you can dial (dtlz1's
-- landscape is full of local traps; dtlz7 has disconnected
-- pieces). Our rows are born with "?" goals, and `disty` buys
-- them one row at a time -- so the label count IS the
-- experiment.
--
-- Against that, the classic search of the last fifty years:
-- `ga` (population, tournament, crossover, mutate), `de` (kids
-- by extrapolation: a + F*(b-c)), `sa` (accept some bad moves,
-- less often as things cool) and `ls` (better, or bust). They
-- work. They also spend evaluations like water, because they
-- were designed for models that are cheap to call.
--
-- So `--race` is the week's real question, and it is not "who
-- finds the best row" but "what did that row COST". Last
-- week's acquire buys about 45 labels. Watch what the classics
-- spend for their win, then decide which one you would take to
-- a client whose every label is a week of simulation.
--
-- ## Glossary
-- [dtlz](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#dtlz),
-- [model seam](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#model-seam),
-- [ga (genetic algorithm)](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#ga),
-- [de (differential evolution)](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#de),
-- [sa (simulated annealing)](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#sa),
-- [local search](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#local-search),
-- [snap and guess](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#snap),
-- [race](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#race)
--
-- ---

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- reads fall through to [ezr-dtlz](ezr-dtlz.html) (the models
-- and the pool) and, for the optimizers, to
-- [ezr-apps](ezr-apps.html); both chain on to ezr, lib, _G
require"ezr-apps"
local _ENV = setmetatable({}, {__index = require"ezr-dtlz"})
if setfenv then setfenv(1, _ENV) end

local floor = math.floor

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

-- A fresh, unlabelled pool of n rows (default: `the.pool`).
local function Pool(n,    b,t)
  b, the.pool = the.pool, n or the.pool
  t, the.pool = Dtlz(), b
  return t end

-- How many rows of t have had their goals bought so far.
local function spent(t) return t.cols.y[1].n end

-- Run one optimizer on its own fresh pool; report what it
-- found, and what it paid.
local function drive(how,name,    t,r)
  t = Pool(200)
  r = t[how](t)
  print(("%-3s best disty %.3f after %s labels of %s rows")
        :format(name, t:disty(r), spent(t), #t.rows))
  assert(0 <= t:disty(r) and t:disty(r) <= 1)
  return t:disty(r), spent(t) end

-- *`lua ezr-eg8.lua --models`*
-- All seven models run; 50 labels each, and the ruler sharpens
-- as those labels arrive.
doc["--models"] = "dtlz1..7: 50 labels each, and the spread"
eg["--models"] = function(    t,d,lo,hi,best)
  for _,m in ipairs{"dtlz1","dtlz2","dtlz3","dtlz4",
                    "dtlz5","dtlz6","dtlz7"} do
    the.model = m
    t = Dtlz()
    for j = 1, 50 do t:disty(t.rows[j]) end -- label 50, then
    lo, hi = 2, -1        -- rescore all on the warmed ruler
    for j = 1, 50 do
      d = t:disty(t.rows[j])
      if d < lo then lo, best = d, t.rows[j] end
      if d > hi then hi = d end end
    print(("%-6s disty %.3f .. %.3f  best f %s  mean f %s")
      :format(m, lo, hi, show(slice(best, the.Nx + 1)),
              show(t:baseline())))
    assert(0 <= lo and lo < hi and hi <= 1)
    assert(spent(t) == 50) end
  the.model = "dtlz2" end -- restore the default

-- *`lua ezr-eg8.lua --pure`*
-- Active learning against the model: 45 labels of 1000 rows.
doc["--pure"] = "acquire on a model: 45 labels, no train/test"
eg["--pure"] = function(    t,lab)
  t   = Dtlz()
  lab = t:acquirer(the.budget - the.check)
  print("mean f over all " .. #t.rows .. " rows: "
        .. show(t:baseline()))
  print("best found (one instance):")
  instance(t, lab[1])
  print(("labels bought: %s"):format(spent(t)))
  assert(t:disty(lab[1]) <= t:disty(lab[#lab]))
  assert(#lab <= the.budget) end

-- *`lua ezr-eg8.lua --generalize`*
-- The same budget, spent honestly: learn on half the pool,
-- pick from the half never seen.
doc["--generalize"] = "holdout on a model: pick unseen rows"
eg["--generalize"] = function(    t,best)
  t    = Dtlz()
  best = t:holdout()
  print("mean f over all " .. #t.rows .. " rows: "
        .. show(t:baseline()))
  instance(t, best)
  assert(t:disty(best) <= 1) end

-- *`lua ezr-eg8.lua --ga`*
-- Genetic algorithm: tournament, crossover, mutate.
doc["--ga"] = "genetic algorithm on a dtlz pool"
eg["--ga"] = function() drive("ga", "ga") end

-- *`lua ezr-eg8.lua --de`*
-- Differential evolution: kid = a + F*(b - c).
doc["--de"] = "differential evolution on a dtlz pool"
eg["--de"] = function() drive("de", "de") end

-- *`lua ezr-eg8.lua --sa`*
-- Simulated annealing: some bad moves, fewer as it cools.
doc["--sa"] = "simulated annealing on a dtlz pool"
eg["--sa"] = function() drive("sa", "sa") end

-- *`lua ezr-eg8.lua --ls`*
-- Greedy local search: better, or bust.
doc["--ls"] = "greedy local search on a dtlz pool"
eg["--ls"] = function() drive("ls", "ls") end

-- *`lua ezr-eg8.lua --race`*
-- The drag race, scored twice: how good, and how expensive.
-- The classics search well and pay dearly; acquire pays 45.
doc["--race"] = "all four optimizers vs acquire: quality, price"
eg["--race"] = function(    t,d,r,mid,t2,lab)
  t    = Pool(200)
  d, r = t:race(3)
  mid  = function(v) v = sorted(v); return v[floor(#v/2)+1] end
  for _,k in ipairs(keys(d)) do
    print(("%-4s median best disty %.3f"):format(k, mid(d[k]))) end
  print("rank 0: " .. show(sorted(r.winners)))
  print(("all four together spent %s labels of %s rows")
        :format(spent(t), #t.rows))
  t2  = Pool(200)
  lab = t2:acquirer(the.budget - the.check)
  print(("acquire best disty %.3f after %s labels of %s rows")
        :format(t2:disty(lab[1]), spent(t2), #t2.rows))
  assert(#r.winners >= 1)
  assert(spent(t2) <= the.budget)      -- the budget is a fact
  assert(spent(t) > 2 * spent(t2)) end -- the classics are not

--## homework 8 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg8.lua. For its demos (--models, --pure,
--    --generalize, --ga, --de, --sa, --ls, --race), trace only
--    the functions they actually call, following the require
--    chain into [ezr-dtlz.lua](ezr-dtlz.html),
--    [ezr-apps.lua](ezr-apps.html), [ezr.lua](ezr.html) and
--    [ezr-lib.lua](ezr-lib.html). Print that Lua source in two
--    parts, split by a divider line: above it, code I must
--    hand-port to Python; below it, code a Python builtin
--    already handles, each function commented with the module
--    and function that replaces it. Near enough is good
--    enough."
-- 2. Port the above-the-line code to Python, on top of the
--    weeks before, wiring each demo to a test_ function. Near
--    enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers. Stuck on the ideas? Each function
--    here gets its own tiny lecture in [gloss8](gloss8.html).
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for the dtlz seam (Dtlz, label) and for one
--    optimizer of your choice. At the end of that code, add
--    comments answering the "check your port" questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. --race prints quality AND price. Write the one sentence
--    you would say to a client whose every label costs a week
--    of simulation. Then write the sentence you would say to
--    one whose model runs in a millisecond.
-- 7. The optimizers never evaluate their mutants directly:
--    `guess` grades a made-up row by its nearest REAL row
--    (`snap`). Name one way that helps and one way it lies.
-- 8. Rerun --pure with --model=dtlz1 and --model=dtlz7. Which
--    is harder for acquire, and what about those landscapes
--    explains the gap? (dtlz1 is full of local traps; dtlz7's
--    front comes in disconnected pieces.)
-- 9. In --models, all seven models are scored AFTER 50 labels
--    have warmed the column summaries. Explain why scoring a
--    row before those labels arrive gives a different number,
--    and why that is a feature rather than a bug.

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
