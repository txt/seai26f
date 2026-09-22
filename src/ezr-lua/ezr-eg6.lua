#!/usr/bin/env lua
-- ezr-eg6.lua: week 6 of ten. Statistics and ranking.
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
--     lua ezr-eg6.lua --egs     # list this week's demos
--     lua ezr-eg6.lua --all     # run them all; "failures: 0"
--     lua ezr-eg6.lua --ranks   # run just one
--     luajit ezr-eg6.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Last week ended with twenty holdouts and a spread. This week
-- asks the only question that matters about a spread: is that
-- gap real, or is it noise?
--
-- Three cheap tests, each asking it differently. `cohen` asks
-- about the MEANS (how many pooled standard deviations apart?).
-- `cliffs` asks about the RANKS (how lopsided are the pairwise
-- comparisons?). `ks` asks about the SHAPES (what is the widest
-- gap between the two cdfs?). A method that is fooled by one
-- test is rarely fooled by all three, so `same` reports "no
-- real difference" only when all three agree -- and `and` is
-- lazy, so the cheapest test runs first and usually decides.
--
-- `ranks` then turns that into the table a paper actually
-- prints: sort treatments by median, walk down the list, and
-- give a treatment a NEW rank only when it is not `same` as
-- the one above it. Ties share a rank; rank 0 is the set of
-- winners, and it is usually a set, not a single name.
--
-- The other half of the week is comparing ROWS, not samples.
-- `dominates` is the multi-goal comparison with no weights in
-- it: a beats b when a is no worse on every goal and better on
-- at least one. Most pairs are incomparable, which is why the
-- non-dominated rows form a front rather than a winner -- and
-- why `disty` (one number, week 2) exists at all. Finally
-- `wins` grades a search on a scale anyone can read: 100 = the
-- best row in the pool, 0 = the median row, negative = worse
-- than doing nothing.
--
-- ## Glossary
-- [cohen](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#cohen),
-- [cliffs delta](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#cliffs-delta),
-- [ks (Kolmogorov-Smirnov)](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#ks),
-- [same](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#same),
-- [ranks](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#ranks),
-- [dominates](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#dominates),
-- [front](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#front),
-- [wins](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#wins),
-- [Pareto frontier](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#pareto-frontier)
--
-- ---

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- reads fall through to [ezr-apps](ezr-apps.html) (for
-- `dominates`, the one row-vs-row test this week needs) and,
-- through it, to ezr, lib and _G
local _ENV = setmetatable({}, {__index = require"ezr-apps"})
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

-- n numbers in 0..1, each shifted by `add`.
local function bag(n,add,    t)
  t = {}
  for _ = 1, n do push(t, rand() + (add or 0)) end
  return sorted(t) end

-- The same bag, measured again by a shakier instrument:
-- every value jiggled by up to +/- `e`, then shifted by `add`.
local function again(xs,e,add)
  return sorted(map(xs, function(v)
    return v + (add or 0) + e*(2*rand() - 1) end)) end

-- *`lua ezr-eg6.lua --same`*
-- Measurement noise is not news: jiggle every value a little
-- and all three tests shrug. Shift the whole bag by 0.3 and
-- all three notice.
doc["--same"] = "three tests; all must agree before 'same'"
eg["--same"] = function(    xs,ys,zs)
  xs = bag(256)
  ys, zs = again(xs, 0.02), again(xs, 0.02, 0.3)
  print(("x vs y: cohen %.2f cliffs %.2f ks %.2f -> same=%s")
        :format(cohen(xs,ys), cliffs(xs,ys), ks(xs,ys),
                same(xs,ys)))
  print(("x vs z: cohen %.2f cliffs %.2f ks %.2f -> same=%s")
        :format(cohen(xs,zs), cliffs(xs,zs), ks(xs,zs),
                same(xs,zs)))
  assert(same(xs, ys))          -- noise is not news
  assert(not same(xs, zs)) end  -- but a real gap is

-- *`lua ezr-eg6.lua --ranks`*
-- Four treatments, two of them secretly identical. Ties must
-- share a rank -- anything else invents differences.
doc["--ranks"] = "rank treatments; same-as-above shares a rank"
eg["--ranks"] = function(    xs,d,r)
  xs = bag(256)
  d  = {a = xs,                   b = again(xs, 0.02),
        c = again(xs, 0.02, 0.25), d = again(xs, 0.02, 0.6)}
  r = ranks(d)
  print("ranks: " .. show(r.ranks))
  print("rank 0: " .. show(sorted(r.winners)))
  assert(#r.winners == 2)                    -- a and b tie
  assert(r.ranks.a == 0 and r.ranks.b == 0)
  assert(r.ranks.c > 0 and r.ranks.d > r.ranks.c) end

-- *`lua ezr-eg6.lua --dominate`*
-- Row versus row, with no weights: better on one goal, worse
-- on none. Note how often nobody wins.
doc["--dominate"] = "pairwise domination; and how often it ties"
eg["--dominate"] = function(    t,y,n,tie,a,b,w)
  t, y = Tbl(csv(the.file)), nil
  y = t:Y()
  n, tie = 0, 0
  for _ = 1, 64 do
    a, b = t.rows[rand(#t.rows)], t.rows[rand(#t.rows)]
    if     t:dominates(a, b) then w = y(a) < y(b)
    elseif t:dominates(b, a) then w = y(b) < y(a)
    else w, tie = true, tie + 1 end
    if w then n = n + 1 end end
  print(("dominate agrees with disty %s/64;"
         .." indecisive on %s pairs"):format(n, tie))
  assert(n == 64)     -- when it speaks, it agrees with disty
  assert(tie > 0) end -- but often it will not speak

-- *`lua ezr-eg6.lua --fronts`*
-- Collect the rows nothing dominates. That front is the honest
-- multi-goal answer; disty is the one-number shortcut through
-- it, and the two should mostly agree.
doc["--fronts"] = "the non-dominated front, vs the disty ranking"
eg["--fronts"] = function(    t,pool,front,rest,ok,mu)
  t    = Tbl(csv(the.file))
  pool = some(t.rows, 64)
  front, rest = {}, {}
  for _,r in ipairs(pool) do
    ok = true
    for _,r2 in ipairs(pool) do
      if t:dominates(r2, r) then ok = false; break end end
    push(ok and front or rest, r) end
  mu = function(rows)
    return adds(map(rows, t:Y())).mu end
  print(("front %s of %s rows: mean disty %.3f vs %.3f")
        :format(#front, #pool, mu(front), mu(rest)))
  assert(#front >= 1 and #front < #pool)
  assert(mu(front) < mu(rest))          -- front is the good end
  for _,r in ipairs(front) do           -- and nothing beats it
    for _,r2 in ipairs(pool) do
      assert(not t:dominates(r2, r)) end end end

-- *`lua ezr-eg6.lua --wins`*
-- A score a stranger can read: 100 = the pool's best row,
-- 0 = its median row, negative = worse than guessing.
doc["--wins"] = "grade a search: 100 = best, 0 = median row"
eg["--wins"] = function(    t,lab,W,w,w2)
  t   = Tbl(csv(the.file))
  lab = t:acquirer(the.budget - the.check)
  W   = t:wins()
  w   = W(lab[1])
  w2  = W(t.rows[rand(#t.rows)])
  print(("acquire wins %.0f (%s labels of %s rows);"
         .." a random row wins %.0f")
        :format(w, #lab, #t.rows, w2))
  assert(-100 <= w and w <= 100)
  assert(w > 50)        -- a good search lands near the best
  assert(w > w2) end    -- and beats a lucky dip

--## homework 6 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg6.lua. For its demos (--same, --ranks,
--    --dominate, --fronts, --wins), trace only the functions
--    they actually call, following the require chain into
--    [ezr-apps.lua](ezr-apps.html), [ezr.lua](ezr.html) and
--    [ezr-lib.lua](ezr-lib.html). Print that Lua source in two
--    parts, split by a divider line: above it, code I must
--    hand-port to Python; below it, code a Python builtin
--    already handles, each function commented with the module
--    and function that replaces it. Near enough is good
--    enough."
-- 2. Port the above-the-line code to Python, on top of last
--    week's acquire and holdout, wiring each demo to a test_
--    function. Near enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers. Stuck on the ideas? Each function
--    here gets its own tiny lecture in [gloss6](gloss6.html).
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for cohen, cliffs, ks, same and ranks. At the
--    end of that code, add comments answering the "check your
--    port" questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. `same` runs cohen, then cliffs, then ks, joined by `and`.
--    Reorder them and the answer never changes -- but one
--    ordering is cheaper. Which, and why does laziness pay?
-- 7. Rerun --same with bags of 16 instead of 256. Does the
--    0.3 shift still register? Say what that means for anyone
--    reporting a result from three repeats.
-- 8. In --ranks, treatments a and b share rank 0. Now shrink
--    the gap for c (try 0.05). At what gap does c join the
--    winners, and what have you just measured?
-- 9. --dominate is indecisive on many pairs, and --fronts
--    returns a front rather than a winner. Given that, argue
--    for and against collapsing the goals into one disty
--    number. (Reread the Pareto zoom entry in
--    [gloss1](gloss1.html) before you answer.)

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
