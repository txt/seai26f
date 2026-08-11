#!/usr/bin/env lua
local help = [[
ezr3-apps.lua: skills built on the ezr3 substrate, one
short function per book chapter. Residents: knn prediction
(Fortune Teller), anomaly (Bouncer), naive bayes (ER
Nurse), kmeans/kpp (Curator), ga/de/sa/ls/race (Drag Race:
the ch22 shootout, ported from attic/luamine/lapps.lua).
Demos at the bottom; run with --all.

options:
  k=5         knn: neighbours polled per guess
  kluster=8   kmeans, kpp: clusters wanted
  iter=10     kmeans: assign/recentre passes
  L=1         nb: Laplace smoothing on syms
  m=2         nb: m-estimate prior weight
  wait=10     nb: rows seen before scoring starts
  np=20       ga/de: population size
  gens=10     ga/de: generations
  muts=2      mutants: x cells re-picked per kid
  F=0.5       de: extrapolation scale
  cr=0.9      de: crossover rate, per dim
  budget1=200 sa/ls: evals per run
  repeats=5   race: runs per optimizer]]

local abs,exp,log,pi = math.abs, math.exp, math.log, math.pi
local min,max,floor  = math.min, math.max, math.floor

-- find ezr.lua beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
local _ENV = setmetatable({}, {__index = require"ezr"})
if setfenv then setfenv(1, _ENV) end

the = the:also(help)

--## predict (the Fortune Teller) ------------------------------
-- Guess a row's goals from the rows it looks like. No model
-- is fitted; the neighbours are the model. The signature
-- above each function is a reading aid, not a check: `row`
-- is a list of cells, `col` is a NUM or a SYM, and names
-- after the wide gap in an argument list are LOCALS, never
-- arguments.

-- *`TBL:around(row:row, rows?:list) -> list`*  
-- The rows, sorted nearest first.
function TBL.around(i,row,rows)
  return keysort(rows or i.rows,
           function(r) return i:distx(row, r) end) end

-- *`TBL:knn(row:row, k?:int) -> num`*  
-- Guess row's disty from its k nearest neighbours.
function TBL.knn(i,row,k,    t)
  t = i:around(row)
  return adds(map(slice(t, 1, k or the.k), i:Y())).mu end

--## anomaly (the Bouncer) -------------------------------------
-- Who does not belong? Loneliness is the whole test: how far
-- is the nearest other row?

-- *`TBL:anomaly() -> fun`*  
-- Score rows 0..1; 1 = loneliest. The gap being scored is
-- the distance to the nearest other row.
function TBL.anomaly(i,    dn,gap)
  gap = function(r,    lo,d)
    lo = 1e32
    for _,z in ipairs(i.rows) do
      if z ~= r then
        d = i:distx(r, z); if d < lo then lo = d end end end
    return lo end
  dn = Num()
  for _,r in ipairs(i.rows) do dn:add(gap(r)) end
  return function(r) return dn:norm(gap(r)) end end

--## bayes (the ER Nurse) --------------------------------------
-- Sort arrivals into classes, fast, one row at a time. Test
-- then train: every row is guessed before it is learned, so
-- the accuracy needs no held-out split.

-- *`like(col:col, v:any, prior:num) -> num`*  
-- P(v|col): an m-estimate for syms, a gaussian pdf for nums.
function like(col,v,prior,    z)
  if not col.mu then
    return ((col.has[v] or 0) + the.L*prior)
           / (col.n + the.L) end
  z = 2 * col:div()^2 + 1e-32
  return exp(-(v - col.mu)^2 / z) / (pi * z)^0.5 end

-- *`TBL:likes(row:row, nrows:int, nh:int) -> num`*  
-- Log likelihood of row under this klass-table.
function TBL.likes(h,row,nrows,nh,    prior,out,v)
  prior = (#h.rows + the.m) / (nrows + the.m*nh)
  out   = log(prior)
  for _,c in ipairs(h.cols.x) do
    v = row[c.at]
    if v ~= "?" then
      v = like(c, v, prior)
      if v > 0 then out = out + log(v) end end end
  return out end

-- *`mostlikes(h:dict, row:row, nrows:int, nh:int) -> any`*  
-- Which klass-table likes this row the most?
function mostlikes(h,row,nrows,nh,    best,bs,s)
  bs = -1e32
  for k,hk in pairs(h) do
    s = hk:likes(row, nrows, nh)
    if s > bs then bs, best = s, k end end
  return best end

-- *`TBL:classify(wait?:int) -> list`*  
-- Test, then train: one pass, no held-out split. Scoring
-- starts once `wait` rows have been seen. Returns a list of
-- {got, want} pairs.
function TBL.classify(i,wait,    at,h,seen,nh,want)
  wait, at = wait or the.wait, i.cols.klass.at
  h, seen, nh = {}, {}, 0
  for j,row in ipairs(i.rows) do
    want = row[at]
    if j >= wait and nh > 0 then
      push(seen, {mostlikes(h, row, #i.rows, nh), want}) end
    if not h[want] then h[want] = i:clone(); nh = nh + 1 end
    h[want]:add(row) end
  return seen end

-- *`acc(seen:list) -> num`*  
-- Fraction of the {got,want} pairs that agree.
function acc(seen,    n)
  n = 0
  for _,p in ipairs(seen) do
    if p[1] == p[2] then n = n + 1 end end
  return n / (#seen + 1e-32) end

--## cluster (the Curator) -------------------------------------
-- Group the rows without labelling any of them. kmeans finds
-- the groups; kpp picks the starting centroids far apart, so
-- kmeans does not start in a corner.

-- *`nearest(i:TBL, cents:list, r:row) -> int`* -- local.  
-- Index of r's closest centroid.
local function nearest(i,cents,r,    lo,d,at)
  lo = 1e32
  for j,c in ipairs(cents) do
    d = i:distx(c, r)
    if d < lo then lo, at = d, j end end
  return at end

-- *`assign(i:TBL, cents:list) -> list`* -- local.  
-- Each row into its centroid's clone.
local function assign(i,cents,    out)
  out = map(cents, function() return i:clone() end)
  for _,r in ipairs(i.rows) do
    out[nearest(i, cents, r)]:add(r) end
  return out end

-- *`recentre(clusters:list) -> list`* -- local.  
-- Middles of the non-empty clusters.
local function recentre(clusters,    cents)
  cents = {}
  for _,c in ipairs(clusters) do
    if #c.rows > 0 then push(cents, c:mids()) end end
  return cents end

-- *`TBL:kmeans(k?:int, iter?:int) -> list`*  
-- k clusters: iter rounds of assign, then recentre.
function TBL.kmeans(i,k,iter,    cents)
  cents = some(i.rows, k or the.kluster)
  for _ = 1, iter or the.iter do
    cents = recentre(assign(i, cents)) end
  return assign(i, cents) end

-- *`d2(i:TBL, cents:list, r:row) -> num`* -- local.  
-- Squared distance from r to its nearest centroid.
local function d2(i,cents,r,    lo,d)
  lo = 1e32
  for _,c in ipairs(cents) do
    d = i:distx(r, c); lo = min(lo, d*d) end
  return lo end

-- *`wpick(ws:list) -> int`* -- local.  
-- Index j, with chance ws[j]/sum(ws).
local function wpick(ws,    all,r,c)
  all = sum(ws, function(w) return w end)
  r, c = rand() * all, 0
  for j,w in ipairs(ws) do
    c = c + w
    if r <= c then return j end end
  return #ws end

-- *`TBL:kpp(k?:int) -> list`*  
-- k centroids, far apart: d^2-weighted picks from random
-- pools.
function TBL.kpp(i,k,    cents,pool,ws)
  cents = {some(i.rows, 1)[1]}
  while #cents < (k or the.kluster) do
    pool = some(i.rows, min(the.few, #i.rows))
    ws   = map(pool, function(r) return d2(i, cents, r) end)
    push(cents, pool[wpick(ws)]) end
  return cents end

--## optimize (the Drag Race) ----------------------------------
-- Classic optimizers, racing. Mutants invent x values, so
-- their y cells are unknown: `snap` grades a mutant by its
-- nearest real row, and `guess` is that neighbour's disty.

-- *`TBL:dominates(r1:row, r2:row) -> bool`*  
-- True when r1 is no worse on all goals and better on at
-- least one.
function TBL.dominates(i,r1,r2,    d1,d2,better,worse)
  better, worse = false, false
  for _,y in ipairs(i.cols.y) do
    d1 = abs(y:norm(r1[y.at]) - y.heaven)
    d2 = abs(y:norm(r2[y.at]) - y.heaven)
    if d1 < d2 then better = true end
    if d1 > d2 then worse  = true end end
  return better and not worse end

-- *`TBL:snap(row:row) -> row`*  
-- The nearest real row to a made-up one.
function TBL.snap(i,row,    lo,d,out)
  lo = 1e32
  for _,r in ipairs(i.rows) do
    d = i:distx(row, r)
    if d < lo then lo, out = d, r end end
  return out end

-- *`TBL:guess(row:row) -> num`*  
-- A mutant's worth: its neighbour's disty.
function TBL.guess(i,row)
  return i:disty(i:snap(row)) end

-- *`gauss() -> num`* -- local.  
-- Unit normal, the cheap way (Irwin-Hall).
local function gauss(    g)
  g = -6; for _ = 1, 12 do g = g + rand() end; return g end

-- *`wkey(d:dict) -> any`* -- local.  
-- A key, picked with a chance weighted by its count.
local function wkey(d,    all,r,c)
  all = sum(d, function(n) return n end)
  r, c = rand() * all, 0
  for _,k in ipairs(keys(d)) do
    c = c + d[k]
    if r <= c then return k end end end

-- *`pick(col:col, v:any) -> any`*  
-- A new cell value, near v: syms by frequency, nums by a
-- gaussian step, clamped to +-3sd.
function pick(col,v,    sd)
  if col.has then return wkey(col.has) end
  v  = v ~= "?" and v or col.mu
  sd = col:div()
  return max(col.mu - 3*sd,
             min(col.mu + 3*sd, v + sd * gauss())) end

-- *`TBL:mutate(row:row, n?:int) -> row`*  
-- Copy row, then re-pick n random x cells.
function TBL.mutate(i,row,n,    out,xs)
  out, xs = copy(row), shuffle(i.cols.x)
  for j = 1, min(n or the.muts, #xs) do
    out[xs[j].at] = pick(xs[j], out[xs[j].at]) end
  return out end

-- *`TBL:extrapolate(a:row, b:row, c:row) -> row`*  
-- A de kid: a + F*(b - c), per dimension, with probability
-- cr. Numbers wrap inside +-4sd.
function TBL.extrapolate(i,a,b,c,    out,keep,va,vb,vc,v,lo,s)
  out  = copy(a)
  keep = i.cols.x[rand(#i.cols.x)]
  for _,col in ipairs(i.cols.x) do
    if col ~= keep and rand() < the.cr then
      va, vb, vc = a[col.at], b[col.at], c[col.at]
      if va == "?" then out[col.at] = "?"
      elseif col.has then
        out[col.at] = rand() < the.F and vb or va
      elseif vb == "?" or vc == "?" then out[col.at] = va
      else
        v  = va + the.F * (vb - vc)
        lo = col.mu - 4*col:div()
        s  = 8*col:div() + 1e-32
        out[col.at] = lo + (v - lo) % s end end end
  return out end

-- *`tourn(i:TBL, pop:list) -> row`* -- local.  
-- 2-way select: keep the dominator.
local function tourn(i,pop,    a,b)
  a, b = pop[rand(#pop)], pop[rand(#pop)]
  return i:dominates(i:snap(b), i:snap(a)) and b or a end

-- *`cross(i:TBL, mum:row, dad:row) -> row`* -- local.  
-- One-point crossover.
local function cross(i,mum,dad,    kid,cut)
  kid, cut = copy(mum), rand(#i.cols.x)
  for j,c in ipairs(i.cols.x) do
    if j > cut then kid[c.at] = dad[c.at] end end
  return kid end

-- *`TBL:ga() -> row`*  
-- Evolve np rows, gens times: domination tournament, cross,
-- mutate.
function TBL.ga(i,    pop,kids)
  pop = slice(shuffle(i.rows), 1, the.np)
  for _ = 1, the.gens do
    kids = {}
    for _ = 1, the.np do
      push(kids, i:mutate(cross(i, tourn(i, pop),
                                    tourn(i, pop)))) end
    pop = kids end
  return i:snap(keysort(pop, function(r)
                          return i:guess(r) end)[1]) end

-- *`TBL:de() -> row`*  
-- de/rand/1: a kid replaces its parent, but only when it is
-- better.
function TBL.de(i,    pop,es,t,kid,d,at)
  pop = slice(shuffle(i.rows), 1, the.np)
  es  = map(pop, function(r) return i:guess(r) end)
  for _ = 1, the.gens do
    for j = 1, #pop do
      t   = some(pop, 3)
      kid = i:extrapolate(t[1], t[2], t[3])
      d   = i:guess(kid)
      if d < es[j] then pop[j], es[j] = kid, d end end end
  at = 1
  for j = 2, #es do if es[j] < es[at] then at = j end end
  return i:snap(pop[at]) end

-- *`climb(i:TBL, accept:fun) -> row`* -- local.  
-- The (1+1) loop: mutate s, maybe accept the mutant, and
-- keep the best mutant ever seen.
local function climb(i,accept,    s,e,b,eb,kid,d)
  s = i.rows[rand(#i.rows)]
  e = i:guess(s)
  b, eb = s, e
  for h = 1, the.budget1 do
    kid = i:mutate(s)
    d   = i:guess(kid)
    if d < eb then b, eb = kid, d end
    if accept(e, d, h) then s, e = kid, d end end
  return i:snap(b) end

-- *`TBL:ls() -> row`*  
-- Greedy local search: better, or bust.
function TBL.ls(i)
  return climb(i, function(e,d) return d < e end) end

-- *`TBL:sa() -> row`*  
-- Simulated annealing: metropolis says yes to some bad
-- moves, and more rarely as the budget cools.
function TBL.sa(i)
  return climb(i, function(e,d,h)
    return d < e or rand() < exp((e - d) /
      (1 - h/the.budget1 + 1e-32)) end) end

-- *`TBL:race(repeats?:int) -> dict, dict`*  
-- All four optimizers, plus best-of-np random rows, ranked
-- by same/ranks.
function TBL.race(i,repeats,    d)
  d = {ga={}, de={}, sa={}, ls={}, any={}}
  for _ = 1, repeats or the.repeats do
    push(d.ga,  i:disty(i:ga()))
    push(d.de,  i:disty(i:de()))
    push(d.sa,  i:disty(i:sa()))
    push(d.ls,  i:disty(i:ls()))
    push(d.any, i:disty(
      keysort(some(i.rows, the.np), i:Y())[1])) end
  return d, ranks(d) end

--## demos -----------------------------------------------------
-- Every demo reseeds, prints a line a tutor can point at,
-- then asserts. No crash means pass.
eg = {}

-- *`lua ezr-apps.lua --all`*  
-- All the demos; fail if any of them do.
eg["--all"] = function(    bad)
  bad = 0
  for _,k in ipairs(keys(eg)) do
    if k ~= "--all" and run(eg, k) == false then
      bad = bad + 1 end end
  print("failures: " .. bad)
  assert(bad == 0) end

-- *`lua ezr-apps.lua --knn`*  
-- Neighbours beat the global mean as a guess.
eg["--knn"] = function(    t,y,mu,e1,e2,r)
  t  = Tbl(csv())
  y  = t:Y()
  mu = adds(map(t.rows, y)).mu
  e1, e2 = 0, 0
  for _ = 1, 32 do
    r  = t.rows[rand(#t.rows)]
    e1 = e1 + abs(t:knn(r) - y(r))
    e2 = e2 + abs(mu       - y(r)) end
  print(("knn err %.3f  vs mean-guess err %.3f")
        :format(e1/32, e2/32))
  assert(e1 < e2) end

-- *`lua ezr-apps.lua --detect`*  
-- Anomaly scores: someone in here is lonely.
eg["--detect"] = function(    t,det,ss)
  t   = Tbl(csv())
  det = t:anomaly()
  ss  = sorted(map(t.rows, det))
  print(show{lo=ss[1], mid=ss[floor(#ss/2)+1], hi=ss[#ss]})
  assert(0 <= ss[1] and ss[#ss] <= 1)
  assert(ss[#ss] > 0.5) end

-- *`lua ezr-apps.lua --nb`*  
-- Test-then-train naive bayes, on diabetes.
eg["--nb"] = function(    t,seen,a)
  t    = Tbl(csv"$MOOT/classify/diabetes.csv")
  seen = t:classify()
  a    = acc(seen)
  print(("diabetes: acc %.2f over %s guesses"):format(
    a, #seen))
  assert(a > 0.65) end

-- *`lua ezr-apps.lua --kmeans`*  
-- Clustering conserves rows.
eg["--kmeans"] = function(    t,cs,n)
  t  = Tbl(csv())
  cs = t:kmeans()
  n  = 0
  for _,c in ipairs(cs) do n = n + #c.rows end
  print("cluster sizes " ..
    show(sorted(map(cs, function(c) return #c.rows end))))
  assert(n == #t.rows and #cs <= the.kluster) end

-- *`lua ezr-apps.lua --kpp`*  
-- The seeds come out spread out.
eg["--kpp"] = function(    t,cents,d)
  t     = Tbl(csv())
  cents = t:kpp()
  d = 1e32
  for j = 1, #cents do
    for k = j+1, #cents do
      d = min(d, t:distx(cents[j], cents[k])) end end
  print(("%s kpp seeds, min gap %.3f"):format(#cents, d))
  assert(#cents == the.kluster and d > 0) end

-- *`lua ezr-apps.lua --dominate`*  
-- If a dominates b then a's d2h is less; and often, nobody
-- wins.
eg["--dominate"] = function(    t,y,n,tie,a,b,w)
  t, y = Tbl(csv()), nil
  y = t:Y()
  n, tie = 0, 0
  for _ = 1, 64 do
    a = t.rows[rand(#t.rows)]
    b = t.rows[rand(#t.rows)]
    if     t:dominates(a, b) then w = y(a) < y(b)
    elseif t:dominates(b, a) then w = y(b) < y(a)
    else w, tie = true, tie + 1 end
    if w then n = n + 1 end end
  print(("dominate agrees with d2h %s/64; "..
         "indecisive on %s pairs"):format(n, tie))
  assert(n == 64 and tie > 0) end

-- *`lua ezr-apps.lua --ga`*  
-- The evolved best beats the median row, easily.
eg["--ga"] = function(    t,mid)
  t   = Tbl(csv())
  mid = sorted(map(t.rows, t:Y()))[floor(#t.rows/2)]
  print("ga best d2h " .. show(t:disty(t:ga())))
  assert(t:disty(t:ga()) < mid) end

-- *`lua ezr-apps.lua --de`*  
-- Same test, differential evolution.
eg["--de"] = function(    t,mid)
  t   = Tbl(csv())
  mid = sorted(map(t.rows, t:Y()))[floor(#t.rows/2)]
  print("de best d2h " .. show(t:disty(t:de())))
  assert(t:disty(t:de()) < mid) end

-- *`lua ezr-apps.lua --sa`*  
-- Same test, simulated annealing.
eg["--sa"] = function(    t,mid)
  t   = Tbl(csv())
  mid = sorted(map(t.rows, t:Y()))[floor(#t.rows/2)]
  print("sa best d2h " .. show(t:disty(t:sa())))
  assert(t:disty(t:sa()) < mid) end

-- *`lua ezr-apps.lua --ls`*  
-- Same test, greedy local search.
eg["--ls"] = function(    t,mid)
  t   = Tbl(csv())
  mid = sorted(map(t.rows, t:Y()))[floor(#t.rows/2)]
  print("ls best d2h " .. show(t:disty(t:ls())))
  assert(t:disty(t:ls()) < mid) end

-- *`lua ezr-apps.lua --race`*  
-- The ch22 dragrace: 5 repeats each, ranked by same/ranks.
eg["--race"] = function(    t,d,r,mid,mids)
  t    = Tbl(csv())
  d, r = t:race()
  mid  = sorted(map(t.rows, t:Y()))[floor(#t.rows/2)]
  mids = kap(d, function(k,v)
    return k .. "=" .. show(sorted(v)[floor(#v/2)+1]) end)
  print("median best d2h: " ..
        table.concat(sorted(mids), " "))
  print("rank 0: " .. show(sorted(r.winners)))
  assert(#r.winners >= 1)
  for _,v in pairs(d) do
    assert(sorted(v)[floor(#v/2)+1] < mid) end end

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
