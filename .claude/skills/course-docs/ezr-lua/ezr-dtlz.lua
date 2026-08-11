#!/usr/bin/env lua
local help = [[
ezr3-dtlz.lua: drive ezr3 with an EXTERNAL MODEL, no csv.
DTLZ1-7 rows are born with "?" goals; disty computes them
on demand, folding each new label into the column summaries
so normalization sharpens as spending grows. This file is
the seam where outsiders plug in their own (maybe very
expensive) models. Demos at the bottom; run with --all.

options:
  model=dtlz2   one of dtlz1..dtlz7
  M=2           objectives, all minimized
  Nx=6          decision variables, all in 0..1
  pool=1000     rows per fresh pool]]

local abs,cos,sin,pi = math.abs, math.cos, math.sin, math.pi

-- find ezr.lua beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
local _ENV = setmetatable({}, {__index = require"ezr"})
if setfenv then setfenv(1, _ENV) end

the = the:also(help)

--## models ----------------------------------------------------
-- Each maps x in [0,1]^Nx to M objectives to minimize. The
-- last Nx-M+1 x's (xm) set distance from the true front;
-- the first M-1 shape position along it. The signature
-- above each function is a reading aid, not a check: `x` is
-- the list of decision variables, `f` the list of
-- objectives, and names after the wide gap in an argument
-- list are LOCALS.

-- *`g1(xm:list) -> num`*  
-- Multi-modal distance (dtlz1, dtlz3).
function g1(xm)
  return 100 * (#xm + sum(xm, function(v)
    return (v-.5)^2 - cos(20*pi*(v-.5)) end)) end

-- *`g2(xm:list) -> num`*  
-- Unimodal distance (dtlz2, dtlz4, dtlz5).
function g2(xm)
  return sum(xm, function(v) return (v-.5)^2 end) end

-- *`g6(xm:list) -> num`*  
-- Biased distance (dtlz6).
function g6(xm)
  return sum(xm, function(v) return v^0.1 end) end

-- *`sphere(M:int, g:num, th:list) -> list`*  
-- The cos/sin product shared by dtlz2 through dtlz6.
function sphere(M,g,th,    f,v)
  f = {}
  for i = 0, M-1 do
    v = 1 + g
    for j = 1, M-1-i do v = v * cos(th[j]) end
    if i > 0 then v = v * sin(th[M-i]) end
    push(f, v) end
  return f end

-- *`dtlz1(x:list, M:int) -> list`*  
-- Linear front: the objectives sum to .5(1+g).
function dtlz1(x,M,    g,f,v)
  g, f = g1(slice(x, M)), {}
  for i = 0, M-1 do
    v = 0.5 * (1 + g)
    for j = 1, M-1-i do v = v * x[j] end
    if i > 0 then v = v * (1 - x[M-i]) end
    push(f, v) end
  return f end

-- *`dtlz2(x:list, M:int) -> list`*  
-- Spherical front.
function dtlz2(x,M)
  return sphere(M, g2(slice(x, M)),
           map(slice(x, 1, M-1), function(v)
             return v * pi/2 end)) end

-- *`dtlz3(x:list, M:int) -> list`*  
-- Spherical, multi-modal.
function dtlz3(x,M)
  return sphere(M, g1(slice(x, M)),
           map(slice(x, 1, M-1), function(v)
             return v * pi/2 end)) end

-- *`dtlz4(x:list, M:int) -> list`*  
-- Spherical, biased sampling.
function dtlz4(x,M)
  return sphere(M, g2(slice(x, M)),
           map(slice(x, 1, M-1), function(v)
             return v^100 * pi/2 end)) end

-- *`degen(x:list, M:int, g:num) -> list`*  
-- The degenerate curve behind dtlz5 and dtlz6.
function degen(x,M,g,    th)
  th = {x[1] * pi/2}
  for i = 2, M-1 do
    th[i] = pi/(4*(1+g)) * (1 + 2*g*x[i]) end
  return sphere(M, g, th) end

-- *`dtlz5(x:list, M:int) -> list`* -- degenerate, unimodal.
function dtlz5(x,M) return degen(x, M, g2(slice(x, M))) end

-- *`dtlz6(x:list, M:int) -> list`* -- degenerate, biased.
function dtlz6(x,M) return degen(x, M, g6(slice(x, M))) end

-- *`dtlz7(x:list, M:int) -> list`*  
-- Disconnected front.
function dtlz7(x,M,    k,g,f,h)
  k = #x - M + 1
  g = 1 + 9/k * sum(slice(x, M), function(v) return v end)
  f = slice(x, 1, M-1)
  h = M - sum(f, function(fi)
        return fi/(1+g) * (1 + sin(3*pi*fi)) end)
  push(f, (1+g) * h)
  return f end

--## seam ------------------------------------------------------
-- The lazy-label seam (t.model + TBL.label) lives in ezr3
-- now: all this file adds is pool-making and the models.

-- *`Dtlz() -> TBL`*  
-- A Tbl over one fresh, blank pool: x cells random, y cells
-- still "?".
function Dtlz(    u,r)
  u = {names()}
  for _ = 1, the.pool do
    r = {}
    for _ = 1, the.Nx do push(r, rand()) end
    for _ = 1, the.M  do push(r, "?") end
    push(u, r) end
  u = Tbl(u)
  u.model = _ENV[the.model]
  return u end

-- *`names() -> list`*  
-- The header: X1..XNx, then F1-..FM- (all minimized).
function names(    u)
  u = {}
  for j = 1, the.Nx do push(u, "X"..j) end
  for m = 1, the.M  do push(u, "F"..m.."-") end
  return u end

-- *`TBL:baseline() -> row`*  
-- Mean of every goal over the whole pool. These are raw
-- model calls: nothing folds into the summaries, so the
-- baseline never sharpens the ruler it is measured against.
function TBL.baseline(i,    nums,f)
  nums = map(i.cols.y, function() return Num() end)
  for _,r in ipairs(i.rows) do
    f = i.model(map(i.cols.x,
          function(c) return r[c.at] end), #i.cols.y)
    for j,v in ipairs(f) do nums[j]:add(v) end end
  return map(nums, "mid") end

-- *`instance(t:TBL, row:row)`*  
-- Print one row: its x, then its f, then its disty.
function instance(t,row)
  print("  x  " .. show(slice(row, 1, the.Nx)))
  print(("  f  %s   (disty %.3f, lower=better)"):format(
    show(slice(row, the.Nx + 1)), t:disty(row))) end

--## demos -----------------------------------------------------
-- Every demo reseeds, prints a line a tutor can point at,
-- then asserts. No crash means pass.
eg = {}

-- *`lua ezr-dtlz.lua --all`*  
-- All the demos; fail if any of them do.
eg["--all"] = function(    bad)
  bad = 0
  for _,k in ipairs(keys(eg)) do
    if k ~= "--all" and run(eg, k) == false then
      bad = bad + 1 end end
  print("failures: " .. bad)
  assert(bad == 0) end

-- *`lua ezr-dtlz.lua --fronts`*  
-- Known geometry: dtlz1 leaves sum f = .5(1+g); dtlz2
-- leaves sum f^2 = (1+g)^2.
eg["--fronts"] = function(    x,f,s,g)
  for _ = 1, 100 do
    x = {}
    for j = 1, 6 do x[j] = rand() end
    g = g1(slice(x, 2))
    f = dtlz1(x, 2)
    s = sum(f, function(v) return v end)
    assert(abs(s - 0.5*(1+g)) < 1e-9 * (1+g))
    g = g2(slice(x, 2))
    f = dtlz2(x, 2)
    s = sum(f, function(v) return v*v end)
    assert(abs(s - (1+g)^2) < 1e-9 * (1+g)^2) end
  print"100 rounds: dtlz1 linear, dtlz2 spherical: ok" end

-- *`lua ezr-dtlz.lua --label`*  
-- Goals appear on demand, and only on demand.
eg["--label"] = function(    t,r)
  t = Dtlz()
  r = t.rows[1]
  assert(r[t.cols.y[1].at] == "?")     -- born blank
  t:disty(r)                           -- the seam fires
  assert(r[t.cols.y[1].at] ~= "?")     -- now labelled
  print("labelled: " .. show(slice(r, the.Nx + 1)))
  assert(t.cols.y[1].n == 1) end       -- and folded in

-- *`lua ezr-dtlz.lua --models`*  
-- All 7 models run; 50 labels each, and the ruler sharpens
-- as they arrive.
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
    for _,y in ipairs(t.cols.y) do          -- finite, and
      assert(best[y.at] == best[y.at]       -- not negative
             and best[y.at] >= 0) end
    assert(0 <= lo and lo < hi and hi <= 1) -- real spread
    assert(t.cols.y[1].n == 50) end         -- 50 labels in
  the.model = "dtlz2" end -- restore the default

-- *`lua ezr-dtlz.lua --pure`*  
-- Rank the whole pool, with no train/test split.
eg["--pure"] = function(    t,lab)
  t   = Dtlz()
  lab = t:acquirer(the.budget - the.check)
  print("mean f, all " .. #t.rows .. " rows: "
        .. show(t:baseline()))
  print("best found (one instance):")
  instance(t, lab[1])
  assert(t:disty(lab[1]) <= t:disty(lab[#lab])) end

-- *`lua ezr-dtlz.lua --why`*  
-- Which x-ranges reach the good goals?
eg["--why"] = function(    t,lab)
  t   = Dtlz()
  lab = t:acquirer(the.budget - the.check)
  Tree(t, lab):show(t)
  assert(#lab <= the.budget) end

-- *`lua ezr-dtlz.lua --generalize`*  
-- The best pick, made on rows never seen before.
eg["--generalize"] = function(    t,best)
  t    = Dtlz()
  best = t:holdout()
  print("mean f, all " .. #t.rows .. " rows: "
        .. show(t:baseline()))
  instance(t, best)
  assert(t:disty(best) <= 1) end

-- *`lua ezr-dtlz.lua --wins`*  
-- Grade each search against the fully labelled pool:
-- 100 = the true best, 0 = the median row, negative = worse.
eg["--wins"] = function(    t,lab,W,w)
  for _,m in ipairs{"dtlz1","dtlz2","dtlz3","dtlz4",
                    "dtlz5","dtlz6","dtlz7"} do
    the.model = m
    t   = Dtlz()
    lab = t:acquirer(the.budget - the.check)
    W   = t:wins()          -- labels the whole pool
    w   = W(lab[1])
    print(("%-6s win %4.0f  (%s labels vs %s)"):format(
      m, w, #lab, #t.rows))
    assert(-100 <= w and w <= 100) end
  the.model = "dtlz2" end -- restore the default

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
