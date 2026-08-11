#!/usr/bin/env lua
local help = [[
ezr3.lua: multi-goal trees, XAI, active learning, optimization.
(c) 2026 Tim Menzies <timm@ieee.org>, MIT license.

A holdout score rig, and the stats
that police it. Demos live next door in ezr-eg.lua; the
batteries below, in lib.lua.

usage:
  ezr [-h] [--key=val ..] [--demo ..]

or, adding demos from your own script:
  local ezr = require"ezr-eg"
  ezr.eg["--myDemo"] = function() print(ezr.the.seed) end
  ezr.go(ezr.eg)

inference options:
  budget=50    acquire: max labels
  cap=1024     holdout: max rows kept
  check=5      holdout: test rows labelled
  few=128      sample size for cheap guesses
  keepf=0.66   acquire: pool kept per cull
  leaf=3       tree: min rows in one leaf
  maxd=4       tree: max depth
  more=4       acquire: labels per round
  p=2          minkowski coefficient
  stop=32      min rows before a split halts]]

local abs,exp,log,sqrt = math.abs,math.exp,math.log,math.sqrt
local max,min,floor    = math.max,math.min,math.floor
local huge             = math.huge
local TINY             = 1e-32
-- utf8 by byte, so no wide glyph sits in this source
local UP               = string.char(0xE2,0x96,0xB2) -- U+25B2
local DOWN             = string.char(0xE2,0x96,0xBC) -- U+25BC

-- find lib.lua beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- all defs below land here; reads fall through to lib
-- (and, through lib, to _G)
local _ENV = setmetatable({}, {__index = require"ezr-lib"})
if setfenv then setfenv(1, _ENV) end

the = the:also(help)
NUM, SYM, COLS, TBL, NODE, TREE = {},{},{},{},{},{}

--## columns ---------------------------------------------------
-- Every column is a NUM or a SYM, picked by the first letter
-- of its name, and both answer the same five questions: add,
-- mid, div, norm, dist. Nothing downstream asks which kind it
-- is holding. The signature above each function is a
-- reading aid, not a check; note that the names after the
-- wide gap in an argument list are LOCALS, not arguments,
-- so they never appear in a type. Read `col` as "a NUM or
-- a SYM", `row` as "a list of cells, one per column",
-- `list` as a table used as an array, and `dict` as one
-- used as a map.

-- *`Col(name:str, at:int) -> col`*  
-- Column kind from the first letter: lowercase makes a SYM,
-- uppercase a NUM.
function Col(name,at)
  return (name:find"^%l" and Sym or Num)(name,at) end

-- *`Num(name?:str, at?:int) -> NUM`*  
-- Summary of a numeric column. A trailing "-" in the name
-- means the goal is to minimize it.
function Num(name,at)
  name = name or ""
  return new(NUM, {at=at or 1, name=name, n=0, mu=0, m2=0,
                   heaven = name:find"-$" and 0 or 1}) end

-- *`Sym(name?:str, at?:int) -> SYM`*  
-- Summary of a symbolic column: just the counts.
function Sym(name,at)
  return new(SYM, {at=at or 1, name=name or "", n=0, has={}}) end

-- *`SYM:add(v:any, inc?:int) -> any`*  
-- Update the symbol counts. `inc` can be -1, which forgets v.
function SYM.add(i,v,inc)
  if v == "?" then return v end
  inc = inc or 1
  i.n = i.n + inc
  i.has[v] = inc + (i.has[v] or 0)
  if i.has[v] <= 0 then i.has[v] = nil end
  return v end

-- *`NUM:add(v:num, inc?:int) -> num`*  
-- One-pass update of mu and m2, forwards (inc=1) or in
-- reverse (inc=-1).
function NUM.add(i,v,inc,    d)
  if v == "?" then return v end
  inc  = inc or 1
  i.n  = i.n + inc
  d    = v - i.mu
  i.mu = i.mu + inc * d / i.n
  i.m2 = i.m2 + inc * d * (v - i.mu); return v end

-- *`SYM:mid() -> any`*  
-- Center: the mode.
function SYM.mid(i,    hi,out)
  hi = -1
  for k, n in pairs(i.has) do
    if n > hi then hi, out = n, k end end
  return out end

-- *`NUM:mid() -> num`*  
-- Center: the mean.
function NUM.mid(i) return i.mu end

-- *`SYM:div() -> num`*  
-- Diversity: entropy of the counts. One-arg log only: the
-- two-arg form is LuaJIT and 5.2+, and 5.1 drops the base.
function SYM.div(i)
  return sum(i.has, function(n,    p)
    p = n / i.n
    return -p * log(p) / log(2) end) end

-- *`NUM:div() -> num`*  
-- Diversity: standard deviation.
function NUM.div(i)
  return i.n < 2 and 0 or sqrt(max(i.m2,0) / (i.n-1)) end

-- *`SYM:norm(v:any) -> any`*  
-- Syms have no cdf, so v comes back untouched.
function SYM.norm(i,v) return v end

-- *`NUM:norm(v:num) -> num`*  
-- v's cdf, via a logistic; 0..1.
function NUM.norm(i,v,    z)
  if v == "?" then return v end
  z = (v - i.mu) / (i:div() + TINY)
  return 1 / (1 + exp(-1.702 * max(-3, min(3, z)))) end

--## Columns test ----------------------------------------------
-- Does a cell fall on the "yes" side of a cut? An unknown
-- cell says yes to everything, so no row is ever lost.

-- *`SYM:holds(x:any, v:any) -> bool`*  
-- Symbols split by equality.
function SYM.holds(i,x,v) return x == "?" or x == v  end

-- *`NUM:holds(x:num, v:num) -> bool`*  
-- Numbers split at a threshold.
function NUM.holds(i,x,v) return x == "?" or x <= v  end


--## tables ----------------------------------------------------
-- A TBL is rows plus the column summaries those rows built.
-- Row 1 of any source is the header, and the header alone
-- decides each column's kind and role.

-- *`Tbl(src:list|fun) -> TBL`*  
-- Fold rows into fresh columns; row 1 is the header.
function Tbl(src)
  src = iter(src)
  return adds(src, new(TBL, {rows={}, mid=nil,
                             cols=Cols(src())})) end

-- *`Cols(names:list) -> COLS`*  
-- Sort the header names into their roles: a trailing "!" is
-- the class, "+" or "-" a goal, "X" is ignored, the rest are
-- the x (independent) columns.
function Cols(names,    all,x,y,klass)
  all, x, y = {}, {}, {}
  for at, s in ipairs(names) do
    all[at] = Col(s, at)
    if s:find"!$" then klass = all[at]
    elseif s:find"[+-]$" then y[#y+1] = all[at]
    elseif s:sub(-1) ~= "X" then x[#x+1] = all[at] end end
  return new(COLS, {names=names,all=all,x=x,y=y,klass=klass}) end

-- *`COLS:add(row:row, inc?:int) -> row`*  
-- Fold a row into every column.
function COLS.add(i,row,inc)
  for _, c in ipairs(i.all) do c:add(row[c.at], inc) end
  return row end

-- *`TBL:add(row:row) -> row`*  
-- Keep the row; update the summaries.
function TBL.add(i,row)
  i.rows[#i.rows+1] = i.cols:add(row)
  i.mid = nil
  return row end

-- *`TBL:clone(rows?:list) -> TBL`*  
-- Same header, fresh summaries. Clones of a live model stay
-- live, so labels still arrive on demand.
function TBL.clone(i,rows,    u)
  u = adds(rows, Tbl{i.cols.names})
  u.model = i.model
  return u end

-- *`TBL:mids() -> row`*  
-- Centroid of this table: every column's middle, cached.
function TBL.mids(i)
  i.mid = i.mid or map(i.cols.all, "mid")
  return i.mid end

--## Forgetting -----------------------------------------------
-- Summaries subtract as well as add, so a row can leave a
-- table as cheaply as it arrived. That is what lets one pass
-- over sorted data score every possible split (see
-- `discretize`) without rebuilding anything.

-- *`NUM - NUM -> NUM`*  
-- tot - v: a new NUM holding what is left.
function NUM.__sub(i,j,    n,d)
  n = i.n - j.n
  if n < 1 then return Num(i.name, i.at) end
  d = j.mu - i.mu
  return new(NUM, {name=i.name, at=i.at, heaven=i.heaven,
                   n=n, mu=(i.n*i.mu - j.n*j.mu) / n,
                   m2=max(0, i.m2 - j.m2
                             - d*d*i.n*j.n/n)}) end

-- *`SYM - SYM -> SYM`*  
-- tot - v: a new SYM holding what is left of the counts.
function SYM.__sub(i,j,    out,n)
  out = Sym(i.name, i.at)
  for k,v in pairs(i.has) do
    n = v - (j.has[k] or 0)
    if n > 0 then out.has[k] = n; out.n = out.n + n end end
  return out end

-- *`NUM:reset()`* -- back to empty.
function NUM.reset(i) i.n, i.mu, i.m2 = 0, 0, 0 end

-- *`SYM:reset()`* -- back to empty.
function SYM.reset(i) i.n, i.has = 0, {} end

-- *`TBL:sub(row:row) -> row`*  
-- Forget a row. All resets happen here, so an emptied table
-- ends up with genuinely fresh columns, not drifted ones.
function TBL.sub(i,row)
  i.cols:add(row, -1)
  i.mid = nil
  for j,r in ipairs(i.rows) do
    if r == row then table.remove(i.rows, j); break end end
  if #i.rows == 0 then map(i.cols.all, "reset") end
  return row end

-- *`adds(src?:list|fun, i?:col|TBL) -> col|TBL`*  
-- Fold a list or an iterator into a summary; a Num by
-- default.
function adds(src,i)
  i = i or Num()
  for v in iter(src or {}) do i:add(v) end
  return i end

--## distance --------------------------------------------------
-- Two rows, one number. Gaps per column are 0..1, and
-- minkowski folds them into one 0..1 distance: `distx` over
-- the independent columns, `disty` from the goals to heaven
-- (0 = best). `disty` is also the seam where an external
-- model gets asked for a label.

-- *`SYM:dist(a:any, b:any) -> num`*  
-- Gap between two symbols; 0..1.
function SYM.dist(i,a,b)
  if a == "?" and b == "?" then return 1 end
  return a ~= b and 1 or 0 end

-- *`NUM:dist(a:num, b:num) -> num`*  
-- Gap between two numbers; 0..1. An unknown cell is pushed
-- to whichever end is further away.
function NUM.dist(i,a,b)
  if a == "?" and b == "?" then return 1 end
  a, b = i:norm(a), i:norm(b)
  if a == "?" then a = b > 0.5 and 0 or 1 end
  if b == "?" then b = a > 0.5 and 0 or 1 end
  return abs(a - b) end

-- *`minkowski(cols:list, f:fun) -> num`*  
-- p-norm mean of f(col), with p from `the.p`.
function minkowski(cols,f,    d,n)
  d, n = 0, TINY
  for _, c in ipairs(cols) do n, d = n+1, d + f(c) ^ the.p end
  return (d / n) ^ (1 / the.p) end

-- *`TBL:distx(row1:row, row2:row) -> num`*  
-- Gap over the x columns; 0..1.
function TBL.distx(i,row1,row2)
  return minkowski(i.cols.x, function(c)
           return c:dist(row1[c.at], row2[c.at]) end) end

-- *`TBL:label(row:row) -> row`*  
-- Ask `i.model` for this row's goals, then fold them in.
function TBL.label(i,row,    f)
  f = i.model(map(i.cols.x,
        function(c) return row[c.at] end), #i.cols.y)
  for j, y in ipairs(i.cols.y) do
    row[y.at] = y:add(f[j]) end
  return row end

-- *`TBL:disty(row:row) -> num`*  
-- Gap to heaven; 0 = best. Rows born "?" get labelled on
-- demand, right here.
function TBL.disty(i,row)
  if i.model and row[i.cols.y[1].at] == "?" then
    i:label(row) end
  return minkowski(i.cols.y, function(y)
           return abs(y:norm(row[y.at]) - y.heaven) end) end

-- *`TBL:Y() -> fun`*  
-- disty as a first-class key function, for keysort and map.
function TBL.Y(i)
  return function(r) return i:disty(r) end end

--## clusters --------------------------------------------------
-- Recursive halving on two far-apart poles. One projection
-- per split, no centroids, no matrix: cheap enough to run on
-- a pool nobody has labelled yet.

-- *`TBL:poles(rows:list, lo?:row, hi?:row) -> fun, row, row`*  
-- Find two far poles and return the projector that ranks any
-- row between them, best pole first.
function TBL.poles(i,rows,lo,hi,    far,c)
  far = function(r,    t)
          t = keysort(rows, function(z) return i:distx(z, r) end)
          return t[#t] end
  lo = lo or far(rows[rand(#rows)])
  hi = hi or far(lo)
  if i:disty(lo) > i:disty(hi) then lo, hi = hi, lo end
  c = i:distx(lo, hi) + TINY
  return function(r) return (i:distx(lo,r)^2 + c*c
                              - i:distx(hi,r)^2) / (2*c) end,
         lo, hi end

-- *`TBL:halve(rows?:list) -> row, row, list, list`*  
-- Split on the far poles, best half first.
function TBL.halve(i,rows,    fun,a,b,n)
  rows = rows or i.rows
  fun, a, b = i:poles(some(rows, the.few))
  rows = keysort(rows, fun)
  n = floor(#rows / 2)
  return a, b, slice(rows, 1, n), slice(rows, n + 1) end

-- *`Node(tbl:TBL, rows?:list) -> NODE`*  
-- Tree of halves, halving until a node is too small to
-- bother splitting.
function Node(tbl,rows,    recurse)
  function recurse(rows,    node,a,b,lo,hi)
    node = new(NODE, {here=tbl:clone(rows),
                      a=nil, b=nil, lo=nil, hi=nil})
    if #rows >= 2 * the.stop then
      a, b, lo, hi = tbl:halve(rows)
      node.a, node.b = a, b
      if #lo > 0 and #hi > 0 then
        node.lo, node.hi = recurse(lo), recurse(hi) end end
    return node
  end -- recurse
  return recurse(rows or tbl.rows) end

-- *`NODE:leaf(row:row) -> NODE`*  
-- Walk a row down to its leaf, going to whichever pole is
-- nearer at each level.
function NODE.leaf(i,row,    t)
  while i.lo do
    t = i.here
    i = t:distx(row, i.a) <= t:distx(row, i.b)
        and i.lo or i.hi end
  return i end

--## acquire ---------------------------------------------------
-- Label few rows, cull the pool toward the good pole, loop.
-- lab is a plain list of labelled rows; acquire rebuilds its
-- private seen set (keyed by row ref) on each entry. When a
-- pool dries with budget left, acquirer reshuffles and goes
-- again, anchored at the best and worst labels seen so far.

-- *`TBL:acquire(rows:list, cap:int, lab:list, lo?:row,
-- hi?:row) -> list`*  
-- One sweep: spend up to `the.more` labels per round, then
-- keep the `the.keepf` fraction of the pool nearest the good
-- pole. Stops when the budget is gone or the pool is small.
function TBL.acquire(i,rows,cap,lab,lo,hi,
                     seen,more,new)
  seen = {}
  for _,r in ipairs(lab) do seen[r] = true end
  while #rows >= 2*the.leaf do
    more, new = min(the.more, cap - #lab), {}
    for _,r in ipairs(rows) do -- new = labels in this pool
      if seen[r] then push(new, r)
      elseif more > 0 then
        more, seen[r] = more - 1, true
        push(new, push(lab, r)) end end
    if #lab >= cap then return lab end -- budget spent
    rows = slice(keysort(rows, (i:poles(new, lo, hi))),
               1, max(1, floor(the.keepf * #rows))) end
  return lab end

-- *`TBL:acquirer(cap:int) -> list`*  
-- Sweep until the budget is spent or no sweep makes
-- progress. Returns the labelled rows, best first.
function TBL.acquirer(i,cap,    lab,lo,hi,t,b4)
  lab = {}
  while true do
    b4  = #lab
    lab = i:acquire(shuffle(i.rows), cap, lab, lo, hi)
    if #lab >= cap or #lab >= #i.rows or
       #lab == b4 then break end -- full, or no progress
    t = keysort(lab, i:Y())
    lo, hi = t[1], t[#t] end -- best+worst seen
  return keysort(lab, i:Y()) end

--## discretize ------------------------------------------------
-- Find good cuts: places where splitting the x values most
-- purifies some y summary. All candidates feed one `least`
-- reducer; no cut lists are ever built.

-- *`val(a:col, b:col) -> num`*  
-- Mean diversity of two summaries, weighted by their sizes.
function val(a,b)
  return (a:div()*a.n + b:div()*b.n) / (a.n + b.n + TINY) end

-- *`big(lo:int, n:int) -> bool`*  
-- True when both sides of a cut hold at least `the.leaf`.
function big(lo,n)
  return the.leaf <= lo and lo <= n - the.leaf end

-- *`SYM:cuts(xy:list, tot:col, acc:fun, best:fun)`*  
-- One cut per key; each is offered to `best`.
function SYM.cuts(c,xy,tot,acc,best,    d,b)
  d = {}
  for _,p in ipairs(xy) do
    b = d[p[1]] or acc()
    b:add(p[2]); d[p[1]] = b end
  if #keys(d) > 1 then
    for k,v in pairs(d) do
      if big(v.n, #xy) then
        best{val(v, tot - v), c.at, k} end end end end

-- *`NUM:cuts(xy:list, tot:col, acc:fun, best:fun)`*  
-- Cuts between each distinct, sorted x. One pass: the left
-- summary grows, the right is `tot` minus it.
function NUM.cuts(c,xy,tot,acc,best,    here)
  table.sort(xy, function(a,b) return a[1] < b[1] end)
  here = acc()
  for j,p in ipairs(xy) do
    here:add(p[2])
    if j < #xy and p[1] ~= xy[j+1][1] and big(j, #xy) then
      best{val(here, tot - here),c.at,p[1]} end end end

-- *`TBL:cuts(rows:list, c:col, Y:fun, acc:fun, best:fun)`*  
-- Column c feeds its splits to `best`, skipping "?" cells.
function TBL.cuts(i,rows,c,Y,acc,best,    xy,tot)
  xy = {}
  for _,r in ipairs(rows) do
    if r[c.at] ~= "?" then push(xy, {r[c.at], Y(r)}) end end
  tot = adds(map(xy, 2), acc())
  c:cuts(xy, tot, acc, best) end

-- *`TBL:bestcut(rows:list, Y:fun, acc:fun,
--  best:fun) -> list?`*  
-- Champion cut over all x columns, as {val, at, v}.
function TBL.bestcut(i,rows,Y,acc,best)
  for _,c in ipairs(i.cols.x) do i:cuts(rows,c,Y,acc,best) end
  return best() end

-- *`TBL:divide(rows:list, c:col, v:any) -> list, list`*  
-- Rows that hold c<=v (or c==v), and rows that do not.
function TBL.divide(i,rows,c,v,    yes,no)
  yes, no = {}, {}
  for _,r in ipairs(rows) do
    push(c:holds(r[c.at], v) and yes or no, r) end
  return yes, no end

--## trees -----------------------------------------------------
-- Recursive best-cut trees over the discretizer above, plus
-- walk/sides: visit every pruning of a grown tree.

-- *`Tree(tbl:TBL, rows:list, Y?:fun, acc?:fun) -> TREE`*  
-- Grow to `the.maxd`, splitting on the best cut each time.
-- Each node carries its rows, its loss, and the best loss
-- anywhere below it.
function Tree(tbl,rows,Y,acc,    recurse)
  function recurse(rows,lvl,    ys,t,b,c,yes,no)
    ys = adds(map(rows, Y), acc())
    t  = new(TREE, {at=nil, v=nil, mu=ys:mid(), leafs=1,
                    here = tbl:clone(rows),
                    loss = ys.has and ys:div() or ys:mid()})
    t.val = t.loss
    if #rows >= 2*the.leaf and lvl < the.maxd then
      b = tbl:bestcut(rows, Y, acc, least())
      if b then
        c = tbl.cols.all[b[2]]
        yes, no = tbl:divide(rows, c, b[3])
        if #yes > 0 and #no > 0 then
          t.at, t.v = b[2], b[3]
          t.yes   = recurse(yes, lvl+1)
          t.no    = recurse(no,  lvl+1)
          t.val   = min(t.yes.val, t.no.val)
          t.leafs = t.yes.leafs + t.no.leafs end end end
    return t
  end -- recurse
  Y   = Y or tbl:Y()
  acc = acc or Num
  return recurse(rows, 0) end

-- *`TREE:leafed() -> TREE`*  
-- x, collapsed to one leaf.
function TREE.leafed(x)
  return new(TREE, {at=nil, mu=x.mu, loss=x.loss,
                    val=x.loss, leafs=1, here=x.here}) end

-- *`TREE:walk(fun:fun)`*  
-- Call fun on every pruning of tree t.
function TREE.walk(t,fun)
  if t.at == nil then return fun(t) end
  t.yes:sides(function(yes)
    t.no:sides(function(no)
      fun(new(TREE, {at=t.at, v=t.v, here=t.here,
                     yes=yes, no=no,
                     val=min(yes.val, no.val),
                     leafs=yes.leafs + no.leafs})) end) end) end

-- *`TREE:sides(fun:fun)`*  
-- t as one leaf, then all of t's prunings.
function TREE.sides(t,fun)
  fun(t:leafed())
  if t.at ~= nil then t:walk(fun) end end

-- *`TREE:leaf(tbl:TBL, row:row) -> num`*  
-- Walk a row to its leaf; the leaf's mean is the guess.
function TREE.leaf(t,tbl,row,    c)
  while t.at do
    c = tbl.cols.all[t.at]
    t = c:holds(row[t.at], t.v) and t.yes or t.no end
  return t.mu end

--## tree show -------------------------------------------------
-- One row per node: n, d2h, then each goal's mean under its
-- own header column; tree structure trails on the right.

-- *`TREE:leaves(fun:fun)`*  
-- Call fun on every leaf below t.
function TREE.leaves(t,fun)
  if t.at then t.yes:leaves(fun)
               t.no:leaves(fun)
  else fun(t) end end

-- *`TREE:gstr() -> str`*  
-- This node's goal means, as aligned columns.
function TREE.gstr(t)
  return table.concat(map(t.here.cols.y, function(g)
    return ("%9s"):format(show(g:mid())) end)) end

-- *`TREE:show(tbl:TBL)`*
-- Print the whole tree. The best and worst leaves are marked
-- UP and DOWN. Siblings print lower `mu` first, so the best
-- branch is always the one above.
function TREE.show(t,tbl,    lo,hi,recurse)
  function recurse(t,pre,txt,    c,say,m,a,b)
    m = (t.at == nil and t.mu == lo and UP) or -- best leaf
        (t.at == nil and t.mu == hi and DOWN) or " " -- worst
    print(("%s%4d %5.2f%s  %s"):format(
      m, #t.here.rows, t.mu, t:gstr(), pre .. txt))
    if t.at then                     -- structure right
      c   = tbl.cols.all[t.at]
      say = function(op)
              return c.name .. op .. show(t.v) end
      pre = pre .. (txt == "" and "" or "|  ")
      a = {t.yes, c.has and " == " or " <= "}
      b = {t.no,  c.has and " ~= " or " >  "}
      if b[1].mu < a[1].mu then a, b = b, a end -- best first
      recurse(a[1], pre, say(a[2]))
      recurse(b[1], pre, say(b[2]))
    end
  end -- recurse
  lo, hi = huge, -huge     -- leaf extremes,
  t:leaves(function(l)               -- then a header
    lo, hi = min(lo, l.mu), max(hi, l.mu) end)
  print((" %4s %5s"):format("n", "d2h") ..
    table.concat(map(t.here.cols.y, function(g)
      return ("%9s"):format(g.name) end)))
  recurse(t, "", "") end

--## score -------------------------------------------------
-- How good was that answer, honestly? `wins` grades a row
-- against an oracle pass over the whole pool, and `holdout`
-- makes the method earn its grade on rows it never saw.

-- *`TBL:wins(rows?:list) -> fun`*  
-- Grader: row -> percent of the gap to the pool best that
-- was closed. Closed to [-100,100]; 100 = the pool best,
-- 0 = no better than the median row.
function TBL.wins(i,rows,    ys,lo,b4)
  ys = sorted(map(rows or i.rows, i:Y()))
  lo, b4 = ys[1], ys[floor(#ys/2)+1]
  return function(r)
    return max(-100, min(100,
      100*(1 - (i:disty(r)-lo) / (b4-lo+TINY)))) end end

-- *`TBL:holdout(how?:fun) -> row`*  
-- Label the train half via `how`, grow a tree, use it to
-- rank the unseen test half, then label the best
-- `the.check` of that ranking and return the winner.
function TBL.holdout(i,how,    rows,n,train,test,lab,t,top)
  how  = how or function(t2,cap) return t2:acquirer(cap) end
  rows = shuffle(i.rows)
  n    = floor(#rows/2)
  train= slice(rows, 1, n)
  test = slice(rows, n+1)
  lab  = how(i:clone(train), the.budget - the.check)
  assert(#lab + the.check <= the.budget) -- spend, counted
  t    = Tree(i, lab)
  top  = slice(keysort(test, function(r) return t:leaf(i, r) end),
           1, the.check)
  return keysort(top, i:Y())[1] end

--## statistics ------------------------------------------------
-- Is that gap real, or is it noise? Three cheap tests, each
-- asking a different question, and `same` only says yes when
-- all three agree. `ranks` then turns a bag of treatments
-- into ranks, where ties share a number.

-- *`cohen(xs:list, ys:list) -> num`*  
-- Mean gap, in pooled-sd units.
function cohen(xs,ys,    x,y,n,m,sd)
  x, y = adds(xs), adds(ys)
  n, m = x.n, y.n
  sd = sqrt(((n-1)*x:div()^2 + (m-1)*y:div()^2)/(n+m-2))
  return abs(x.mu - y.mu) / (sd + TINY) end

-- *`ks(xs:list, ys:list) -> num`*  
-- Max cdf gap, in critical units. Walks both cdfs, one
-- distinct value at a time. Sorted lists in.
function ks(xs,ys,    nx,ny,d,p,q,v)
  nx, ny  = #xs, #ys
  d, p, q = 0, 0, 0
  while p < nx and q < ny do
    v = min(xs[p+1], ys[q+1])
    while p < nx and xs[p+1] == v do p = p + 1 end
    while q < ny and ys[q+1] == v do q = q + 1 end
    d = max(d, abs(p / nx - q / ny)) end
  return d / ((nx + ny) / (nx * ny)) ^ 0.5 end

-- *`cliffs(xs:list, ys:list) -> num`*  
-- Rank imbalance; 0..1. As x ascends, j and k (the count of
-- ys below and at-or-below x) only ever advance. Sorted
-- lists in.
function cliffs(xs,ys,    gt,lt,j,k)
  gt, lt, j, k = 0, 0, 0, 0
  for _, x in ipairs(xs) do
    while j < #ys and ys[j+1] <  x do j = j + 1; k = j end
    while k < #ys and ys[k+1] == x do k = k + 1 end
    gt = gt + j; lt = lt + #ys - k end
  return abs(gt - lt) / (#xs * #ys) end

-- *`same(xsort:list, ysort:list, Cohen?:num, Ks?:num,
-- Cliffs?:num) -> bool`*  
-- All three tests must agree before two samples count as the
-- same. `and` is lazy, so the cheap test runs first. Sorted
-- lists in.
function same(xsort,ysort,Cohen,Ks,Cliffs)
  return cohen( xsort,ysort) <= (Cohen  or .35)
     and cliffs(xsort,ysort) <= (Cliffs or .195)
     and ks(    xsort,ysort) <= (Ks     or 1.36) end

-- *`ranks(d:dict, big?:bool) -> {winners:list, ranks:dict}`*  
-- Rank the treatments in d (name -> list of results) by
-- their medians, best first. A treatment that is `same` as
-- the one above it shares its rank. Returns the rank-0
-- winners and the whole rank table.
function ranks(d,big,    mid,dd,sign,out,win,rank,best)
  mid = function(t) return t[floor(#t / 2) + 1] end
  dd  = {}; for k,v in pairs(d) do dd[k] = sorted(v) end
  sign = big and -1 or 1
  out, win, rank, best = {}, {}, -1, nil
  for _, k in ipairs(keysort(keys(dd),
                function(k) return sign * mid(dd[k]) end)) do
    if best == nil or not same(dd[best], dd[k]) then
      rank, best = rank + 1, k end
    if rank == 0 then win[1+#win] = k end
    out[k] = rank end
  return {winners=win, ranks=out} end

--## the end  ---------------------------------------------------
return _ENV
