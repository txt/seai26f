#!/usr/bin/env lua
-- ezr-eg5.lua: week 5 of ten. Active learning.
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
--     lua ezr-eg5.lua --egs     # list this week's demos
--     lua ezr-eg5.lua --all     # run them all; "failures: 0"
--     lua ezr-eg5.lua --acquire # run just one
--     luajit ezr-eg5.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Until now, every y value was free: the csv arrived with its
-- goals already filled in. Drop that. Suppose a label costs a
-- test drive, a clinical trial, a week of CPU -- and you get
-- fifty of them, ever. Where do you spend?
--
-- Week 3 said: label the two poles, keep the better half,
-- recurse. That is 2*log2(n) labels for a good leaf, and it
-- treats fastmap as gospel. This week hedges that bet.
-- `acquire` keeps `the.keepf` (0.66) of the pool per cull
-- instead of half, and spends `the.more` (4) labels per round
-- instead of two: a gentler cull, steadied by more evidence.
-- And since a log-n chop reaches a tiny pool long before the
-- budget runs dry, `acquirer` reshuffles and descends AGAIN,
-- anchored at the best and worst rows labelled so far -- so
-- every restart inherits everything paid for to date.
--
-- Then the honesty check. A search that picks a good row from
-- rows it has studied has proved nothing; the question is
-- whether what it learned transfers. `holdout` splits the data
-- in half, spends the budget on the train half, grows a tree
-- from those labels, ranks the UNSEEN test half with it, and
-- pays its last `the.check` labels to confirm the top of that
-- ranking. Everything is counted; nothing is peeked at.
--
-- ## Glossary
-- [active learning](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#active-learning),
-- [label](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#label),
-- [budget](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#budget),
-- [acquire](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#acquire),
-- [restart](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#restart),
-- [holdout](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#holdout),
-- [weak indicators](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#weakindicators),
-- [sway](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#sway-the-sampling-way)
--
-- ---

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- all defs below land here; reads fall through to ezr
-- (and, through it, to lib and _G)
local _ENV = setmetatable({}, {__index = require"ezr"})
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

-- A pool whose goals do not exist yet. Rows carry x cells and
-- two "?" goals; `t.model` is the oracle that computes them,
-- one row at a time, when someone finally asks.
local function Pool(    u,r)
  u = {{"X1","X2","X3","F1-","F2-"}}
  for _ = 1, 200 do
    r = {rand(), rand(), rand(), "?", "?"}
    push(u, r) end
  u = Tbl(u)
  u.model = function(xs,    a,b)  -- two goals, both minimized
    a = (xs[1] - 0.2)^2 + (xs[2] - 0.8)^2
    b = (xs[1] - 0.9)^2 + (xs[3] - 0.5)^2
    return {a, b} end
  return u end

-- *`lua ezr-eg5.lua --label`*
-- A label is a purchase. Rows are born "?"; asking disty is
-- what buys the goals, and the answer folds into the column
-- summaries, so the ruler sharpens as spending grows.
doc["--label"] = "goals bought on demand, one row at a time"
eg["--label"] = function(    t,r,y1)
  t  = Pool()
  y1 = t.cols.y[1]
  r  = t.rows[1]
  assert(r[y1.at] == "?")          -- born blank
  assert(y1.n == 0)                -- nothing known yet
  t:disty(r)                       -- the seam fires
  assert(r[y1.at] ~= "?")          -- now labelled
  assert(y1.n == 1)                -- and folded in
  t:disty(r)                       -- ask again: no new label
  print(("row 1 goals %s; labels bought so far %s")
        :format(show(slice(r, 4)), y1.n))
  assert(y1.n == 1) end            -- still one

-- *`lua ezr-eg5.lua --acquire`*
-- Spend `the.budget` labels on 398 rows and see how good the
-- best buy is. The whole pool is graded afterwards, which is
-- cheating for scoring but honest for teaching: it shows what
-- the search could NOT see.
doc["--acquire"] = "spend the budget; how good was the best buy"
eg["--acquire"] = function(    t,lab,all,best,mid)
  t   = Tbl(csv(the.file))
  lab = t:acquirer(the.budget - the.check)
  all = sorted(map(t.rows, t:Y()))
  best, mid = t:disty(lab[1]), all[floor(#all/2) + 1]
  print(("%s labels of %s rows: best %.3f, median row %.3f,"
         .." pool best %.3f"):format(#lab, #t.rows, best,
                                     mid, all[1]))
  assert(#lab <= the.budget - the.check)   -- budget respected
  assert(best < mid)                       -- and it paid off
  assert(t:disty(lab[1]) <= t:disty(lab[#lab])) end -- sorted

-- *`lua ezr-eg5.lua --holdout`*
-- The honest score. Labels are bought on the train half only;
-- the winner is chosen from rows the search never studied.
doc["--holdout"] = "train half buys labels; test half is judged"
eg["--holdout"] = function(    t,best,all,mid)
  t    = Tbl(csv(the.file))
  best = t:holdout()
  all  = sorted(map(t.rows, t:Y()))
  mid  = all[floor(#all/2) + 1]
  print(("holdout winner %.3f, median row %.3f, pool best %.3f")
        :format(t:disty(best), mid, all[1]))
  assert(t:disty(best) < mid) end

-- *`lua ezr-eg5.lua --holdouts`*
-- One holdout is an anecdote. Twenty of them, each on a fresh
-- shuffle, are a distribution -- and the distribution is the
-- result. (Whether two such distributions really differ is
-- next week's business.)
doc["--holdouts"] = "20 holdouts: report the spread, not one run"
eg["--holdouts"] = function(    t,all,mid,ds,n)
  t   = Tbl(csv(the.file))
  all = sorted(map(t.rows, t:Y()))
  mid = all[floor(#all/2) + 1]
  ds  = {}
  for _ = 1, 20 do push(ds, t:disty(t:holdout())) end
  ds  = sorted(ds)
  n   = 0
  for _,d in ipairs(ds) do if d < mid then n = n + 1 end end
  print(("20 holdouts: lo %.3f, mid %.3f, hi %.3f;"
         .." beat the median row %s/20"):format(
           ds[1], ds[floor(#ds/2)+1], ds[#ds], n))
  assert(ds[floor(#ds/2)+1] < mid)  -- typical run is useful
  assert(n >= 18) end               -- and it rarely misfires

--## homework 5 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg5.lua. For its demos (--label, --acquire,
--    --holdout, --holdouts), trace only the functions they
--    actually call, following the require chain into
--    [ezr.lua](ezr.html) and [ezr-lib.lua](ezr-lib.html). Print
--    that Lua source in two parts, split by a divider line:
--    above it, code I must hand-port to Python; below it, code
--    a Python builtin already handles, each function commented
--    with the module and function that replaces it. Near enough
--    is good enough."
-- 2. Port the above-the-line code to Python, on top of last
--    week's val, cuts and Tree, wiring each demo to a test_
--    function. Near enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers. Stuck on the ideas? Each function
--    here gets its own tiny lecture in [gloss5](gloss5.html).
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for acquire, acquirer and holdout. At the end
--    of that code, add comments answering the "check your port"
--    questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. acquire computes `more = min(the.more, cap - #lab)` each
--    round. Replace that with `more = the.more` and rerun
--    --acquire. Which assert fails, and why does a result whose
--    price is unknown say nothing at all?
-- 7. Rerun --acquire with --keepf=0.5 --more=2 (week 3's
--    strategy), then with the defaults (0.66 and 4). Run each
--    over five seeds (--seed=1 .. --seed=5). Which is better,
--    and by how much? Was the difference worth the words?
-- 8. acquirer restarts anchored at `t[1], t[#t]` -- the best
--    and worst rows labelled so far. Change that to
--    `t[1], t[2]` and explain, in terms of the projection
--    formula, why the next descent then wastes its labels.
-- 9. holdout asserts `#lab + the.check <= the.budget` before
--    it scores anything. Name two ways a careless active
--    learner could "win" by breaking that line -- and say what
--    each would look like in a paper you were reviewing.

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
