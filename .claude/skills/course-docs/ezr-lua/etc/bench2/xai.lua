#!/usr/bin/env lua
-- xai.lua: explainable multi-objective optimization, tiny-ly.
-- Polymorphic Num/Sym summaries feed distance, labelling,
-- binning and tree code that never asks a column its type.
local help = [[
   
xai: explainable multi-objective optimization, tiny-ly
(c) 2026 Tim Menzies <timm@ieee.org>, MIT license

Samples a data landscape under a small labelling budget,
grows a regression tree over the labels, then picks good
rows and shows which x-ranges explain them.
  
USAGE: local xai = require"xai"      
(demos and tests: lua xai-eg.lua [OPTIONS] [eg ...])   
          
OPTIONS:
  -a  --acquire=active  labelling: active or random
  -b  --budget=50       labelling cap
  -c  --check=5         rows checked by the tree
  -d  --depth=4         tree max depth
  -f  --file=$MOOT/optimize/misc/auto93.csv  data
  -k  --keepf=0.66      rows kept per cull
  -l  --leaf=3          tree min leaf size
  -m  --more=4          labels added per round
  -p  --p=2             minkowski exponent
  -s  --seed=1          random seed
  -h                    show this help ]]
     
local abs,exp,floor,log = math.abs, math.exp, math.floor,math.log
local sqrt,max,min = math.sqrt, math.max, math.min
local fmt = string.format
local BIG,the     = 1e32, {}
local lst,rnd,str = {},{},{}       -- lib; at end of file
local Num,Sym,Cols,Tbl,Tree = {},{},{},{},{}
local acquire,bins,stats    = {},{},{}

-- new makes instances; shared metatables give polymorphism
local function new(mt,t)
  mt.__index = mt return setmetatable(t,mt) end


-- ## Num

-- One numeric column, summarized by Welford (n,mu,m2).
-- `mid`/`spread` = mean/sd; `norm` squashes to 0..1 via a
-- logistic z-score; `sub` = i's data without j's. A name
-- ending "-" sets w=0 (minimize); else w=1 (maximize).

-- make; goal w=0 if the name ends "-", else w=1
function Num.new(txt,at)
  txt = txt or ""
  return new(Num, {txt=txt, at=at or 1, n=0, mu=0, m2=0,
                   w = txt:find"-$" and 0 or 1}) end

-- fold v in (w=1) or out (w<0) by Welford; return v
function Num.add(i,v,w,    d)
  w   = w or 1
  i.n = i.n + w
  if i.n >= 1 then
    d    = v - i.mu
    i.mu = i.mu + w*d/i.n
    i.m2 = i.m2 + w*d*(v - i.mu) end
  return v end

-- mid of a Num = its mean
function Num.mid(i) return i.mu end

-- spread of a Num = its standard deviation
function Num.spread(i)
  return i.n < 2 and 0 or (max(0, i.m2)/(i.n - 1))^0.5 end

-- map v to 0..1 via a logistic over its z-score ("?" passes through)
function Num.norm(i,v,    z)
  if v == "?" then return v end
  z = (v - i.mu)/(i:spread() + 1E-32)
  return 1/(1 + exp(-1.7*max(-3, min(3, z)))) end

-- Num summarizing num1's data without num2's: weighted add
-- of -n2 values at mu2, then num2's own spread comes off m2
function Num.without(num1,num2,    n1,mu1,m21,n2,mu2,m22,k)
  n1,mu1,m21 = num1.n, num1.mu, num1.m2
  n2,mu2,m22 = num2.n, num2.mu, num2.m2
  k = Num.new(num1.txt, num1.at)
  if n2 < n1 then
    k.n, k.mu, k.m2 = n1, mu1, m21
    k:add(mu2, -n2)
    k.m2 = max(0, k.m2 - m22) end
  return k end


-- ## Sym
-- One symbolic column: counts in has{}. `mid` = mode;
-- `spread` = entropy; `sub` as per Num.

-- ctor; value counts kept in has{}
function Sym.new(txt,at)
  return new(Sym, {txt=txt or " ", at=at or 1,
                   n=0, has={}}) end

-- count v in (w=1) or out (w<0); dead keys deleted
function Sym.add(i,v,w,    c)
  w   = w or 1
  i.n = i.n + w
  c   = w + (i.has[v] or 0)
  i.has[v] = c > 0 and c or nil
  return v end

-- mid of a Sym = its mode (ties: lexically first, so the
-- answer never depends on hash iteration order)
function Sym.mid(i,    most,out)
  most = 0
  for k,n in pairs(i.has) do
    if n > most or (n == most and k < out) then
      most,out = n,k end end
  return out end

-- spread of a Sym = entropy of its counts
function Sym.spread(i,    e)
  e = 0
  for _,n in pairs(i.has) do
    e = e - n/i.n * log(n/i.n, 2) end
  return e end

-- Sym summarizing sym1's data without sym2's
function Sym.without(sym1,sym2,    k)
  k = Sym.new(sym1.txt, sym1.at)
  for v,n in pairs(sym1.has) do k:add(v,  n) end
  for v,n in pairs(sym2.has) do k:add(v, -n) end
  return k end

-- fold a list into a summary (Num unless told otherwise)
local function adds(t,i)
  i = i or Num.new()
  for _,v in ipairs(t) do i:add(v) end
  return i end


-- ## Cols
-- Header names typed into columns: leading uppercase =
-- Num; trailing -,+,! = y goals; X = skip; else x.
-- `add` routes one row's cells to their cols ("?" skipped).

-- header names -> {names, all, x, y} typed columns
function Cols.new(names,    i,col)
  i = new(Cols, {names=names, all={}, x={}, y={}, 
                 klass=nil, protect={}})
  for at,s in ipairs(names) do
    col = (s:find"^%u" and Num or Sym).new(s,at)
    lst.push(i.all, col)
    if not s:find"X$" then
      lst.push(s:find"[-+!]$" and i.y or i.x, col) 
      if s:find"!$" then i.klass=col end
      if s:find"~$" then lst.push(i.protect, col) end end end
  return i end

-- route one row's cells to their columns, weight w (w<0
-- folds them back out); "?" skipped
function Cols.add(i,row,w)
  for c,v in lst.cells(i.all,row) do c:add(v,w) end
  return row end


-- ## Tbl
-- Rows plus a Cols, plus centroid `mids`.
-- First row makes the cols; later rows
-- update them. `clone` reuses a header over new rows.

-- table from a csv file name or a list of rows
function Tbl.new(src,    i)
  i = new(Tbl, {cols=nil, rows={}, middle=nil})
  if type(src) == "string"
  then for   row in str.csv(src)      do i:add(row) end
  else for _,row in ipairs(src or {}) do i:add(row) end end
  return i end

-- fresh Tbl, same header, over new rows
function Tbl.clone(i,rows)
  return adds(rows or {}, Tbl.new{i.cols.names}) end

-- add a row; w<0 folds it back out and drops it from rows,
-- so column summaries stay honest under removal. The very
-- first row instead builds the cols.
function Tbl.add(i,row,w)
  if not i.cols then i.cols = Cols.new(row); return row end
  i.middle = nil                       -- centroid now outdated
  i.cols:add(row, w)
  if w and w < 0
  then for j,r in ipairs(i.rows) do
         if r == row then table.remove(i.rows, j); break end end
  else lst.push(i.rows, row) end
  return row end

-- return the current centroid
function Tbl.mids(i)
  i.middle = i.middle or lst.map(i.cols.all, 
                           function(col) return col:mid() end)
  return i.middle end


-- ## Dist
-- `dist` = gap 0..1 between two values of one column (each
-- class owns its pessimistic "?" rules). `distx` = p-norm
-- over the x cols; `disty` = distance to the ideal y goals
-- (0 = best possible row).

-- gap between two sym values (0 = same, 1 = not)
function Sym.dist(i,u,v)
  if u == "?" and v == "?" then return 1 end
  return u == v and 0 or 1 end

-- gap between two num values; missing = far pole
function Num.dist(i,u,v)
  u, v = i:norm(u), i:norm(v)
  if u == "?" and v == "?" then return 1 end
  if u == "?" then u = v < 0.5 and 1 or 0 end
  if v == "?" then v = u < 0.5 and 1 or 0 end
  return abs(u - v) end

-- p-norm of fn(col) over cols; nil results are skipped
local function minkowski(cols,fn,    d,n,v)
  d, n = 0, 0
  for _,c in ipairs(cols) do
    v = fn(c)
    if v then n, d = n + 1, d + v^the.p end end
  return (d/max(1, n))^(1/the.p) end

-- distance between two rows over the x columns
function Tbl.distx(i,r1,r2)
  return minkowski(i.cols.x, function(c)
    return c:dist(r1[c.at], r2[c.at]) end) end

-- row's distance to the ideal y goals (0 = best). Rows
-- pass through the optional `label` hook first: the one
-- place any evaluation is ever spent.
function Tbl.disty(i,row)
  if i.label then row = i.label(row) end
  return minkowski(i.cols.y, function(c)
    if row[c.at] ~= "?" then
      return abs(c:norm(row[c.at]) - c.w) end end) end


-- ## Score
-- `wins` grades a row: 100 = best seen, 0 = no better
-- than the median. `holdout` is the evaluation rig: label
-- half the rows via acquire, grow a tree, let it rank the
-- unseen half, check only the top few, return the best.
-- (Both lean on acquire and Tree, defined below.)

-- grader: row -> % of the median-to-best gap closed
function Tbl.wins(i,rows,    ys,lo,b4)
  ys = lst.sort(lst.map(rows or i.rows,
                function(r) return i:disty(r) end))
  lo, b4 = ys[1], ys[floor((#ys + 1)/2)]
  return function(r)
    return max(-100, min(100, floor(100 *
      (1 - (i:disty(r) - lo)/(b4 - lo + 1E-32))))) end end

-- budget rig: acquire train -> tree -> best test row
function Tbl.holdout(i,    rows,half,got,t,top)
  rows = rnd.shuffle(lst.slice(i.rows))
  half = floor(#rows/2)
  got  = acquire.top(i:clone(lst.slice(rows, 1, half)))
  t    = Tree.grow(i, got)
  top  = lst.slice(
           lst.keysort(lst.slice(rows, half + 1),
             function(r) return t:leaf(r) end),
           1, the.check)
  return lst.keysort(top,
           function(r) return i:disty(r) end)[1] end


-- ## Acquire
-- The active learner (after ezr2.py). `project` maps rows
-- onto the line joining two far labelled poles; `descend`
-- labels a few, culls the slice nearest the bad pole,
-- repeats; `sway3` re-runs descend on fresh shuffles,
-- anchored at the best and worst labels so far, till the
-- budget spends. `top` returns the labels, best first.

-- row -> position on the line east-west (x=dist, y=goal)
function acquire.project(rows,x,y,east,west,    far,c)
  far  = function(r)
           return lst.argmax(rows,
                    function(z) return x(z,r) end) end
  east = east or far(rows[1])
  west = west or far(east)
  if y(east) > y(west) then east,west = west,east end
  c = x(east,west) + 1E-32
  return function(r)
    return (x(east,r)^2 + c*c - x(west,r)^2)/(2*c) end end

-- one descent: label a few, cull toward the good pole, till
-- the pool dries or the budget spends. lab doubles as set
-- (lab[row]) and list (lab[1..n])
function acquire.descend(rows,y,x,cap,lab,east,west,
                         more,less,fresh)
  while #rows >= 2*the.leaf do
    more  = min(the.more, cap - #lab)
    less  = max(1, floor(the.keepf * #rows))
    fresh = {}
    for _,r in ipairs(rows) do
      if lab[r] then lst.push(fresh,r)
      elseif more > 0 then
        more   = more - 1
        lab[r] = true
        lst.push(lab, lst.push(fresh,r)) end end
    if #lab >= cap then return lab end    -- budget spent
    rows = lst.slice(
             lst.keysort(rows,
               acquire.project(fresh,x,y,east,west)),1,less) end
  return lab end

-- descend on fresh shuffles, anchored at the best and worst
-- labels so far, till the budget spends
function acquire.sway3(rows,y,x,cap,    lab,seen)
  lab = acquire.descend(lst.slice(rows), y, x, cap, {})
  while #lab < cap and #lab < #rows do
    seen = lst.keysort(lst.slice(lab), y)
    lab  = acquire.descend(rnd.shuffle(lst.slice(rows)), y, x,
                           cap, lab, seen[1], seen[#seen]) end
  return lab end

-- label at most budget-check rows; best first
function acquire.top(tbl,    y,x,cap,rows)
  y    = function(r)   return tbl:disty(r)   end
  x    = function(a,b) return tbl:distx(a,b) end
  cap  = the.budget - the.check
  rows = the.acquire == "random" and rnd.some(tbl.rows, cap)
         or acquire.sway3(rnd.shuffle(lst.slice(tbl.rows)),
                          y, x, cap)
  return lst.keysort(rows, y) end


-- ## Bins
-- One split = simplest bin over all x cols; simplicity = size-
-- weighted spread of the two halves, the far half found by
-- `without`, never a second pass. `bins.keep` (after
-- tiny-xai.lisp) is a closure holding the running best:
-- offer it (this,ys,at,v); call it bare for the winner.
-- yklass = Num.new regresses; yklass = Sym.new classifies.

-- closure: offer (this,ys,at,v); call bare -> best bin
function bins.keep(    lo,kept)
  lo = BIG
  return function(this,ys,at,v,    there,c)
    if this and the.leaf <= this.n
            and this.n <= ys.n - the.leaf then
      there = ys:without(this)
      c = (this:spread()*this.n + there:spread()*there.n)
          / (ys.n + 1E-32)
      if c < lo then lo,kept = c,{c,at,v} end end
    return kept end end

-- offer each value's y summary as a candidate bin
function Sym.bins(i,rows,y,yklass,keep,    ys,has,x)
  ys, has = yklass(), {}
  for _,r in ipairs(rows) do
    x = r[i.at]
    if x ~= "?" then
      has[x] = has[x] or yklass()
      has[x]:add(ys:add(y(r))) end end
  for v,this in pairs(has) do keep(this, ys, i.at, v) end end

-- offer a candidate bin at each change in sorted x
function Num.bins(i,rows,y,yklass,keep,    xy,ys,this)
  xy, ys = {}, yklass()
  for _,r in ipairs(rows) do
    if r[i.at] ~= "?" then
      lst.push(xy, {r[i.at], ys:add(y(r))}) end end
  lst.sort(xy, function(a,b) return a[1] < b[1] end)
  this = yklass()
  for j,p in ipairs(xy) do
    this:add(p[2])
    if xy[j+1] and p[1] ~= xy[j+1][1] then
      keep(this, ys, i.at, p[1]) end end end

-- cheapest {cost,at,v} bin over all the x columns
function bins.split(tbl,rows,y,yklass,keep)
  keep = keep or bins.keep()
  for _,col in ipairs(tbl.cols.x) do
    col:bins(rows, y, yklass, keep) end
  return keep() end


-- ## Tree
-- `Tree.grow` recurses on the best bin while rows and
-- depth allow; nodes keep their split col, their rows and
-- a `mid` prediction. `holds` picks a row's side of a bin
-- ("?" = yes); `leaf` routes a row down; `show` prints
-- win, size, y mids and branch conditions (via `ops`),
-- flagging the best and worst leaves.

-- does w sit on the yes-side of bin v? ("?" = yes)
function Sym.holds(i,w,v) return w == "?" or w == v end
function Num.holds(i,w,v) return w == "?" or w <= v end

-- printable ops: [1] = yes side, [2] = no side
Sym.ops = {"==", "~="}
Num.ops = {"<=", ">"}

-- recursively split rows on the cheapest bin
function Tree.grow(tbl,rows,y,yklass,lvl,  i,bin,col,yes,no)
  y      = y or function(r) return tbl:disty(r) end
  yklass = yklass or Num.new
  lvl    = lvl or 0
  i      = new(Tree, {n=#rows, rows=rows, col=nil,
                      mid=adds(lst.map(rows,y), yklass()):mid()})
  if #rows >= 2*the.leaf and lvl < the.depth then
    bin = bins.split(tbl, rows, y, yklass)
    if bin then
      col, yes, no = tbl.cols.all[bin[2]], {}, {}
      for _,r in ipairs(rows) do
        lst.push(col:holds(r[col.at], bin[3]) and yes or no,
                 r) end
      if #yes > 0 and #no > 0 then
        i.col, i.v = col, bin[3]
        i.yes = Tree.grow(tbl, yes, y, yklass, lvl + 1)
        i.no  = Tree.grow(tbl, no,  y, yklass, lvl + 1) end end end
  return i end

-- walk a row down to its leaf; return the leaf's mid
function Tree.leaf(i,row)
  while i.col do
    i = i.col:holds(row[i.col.at], i.v) and i.yes or i.no end
  return i.mid end

-- every leaf node below i
function Tree.leaves(i,out)
  out = out or {}
  if i.col
  then i.yes:leaves(out); i.no:leaves(out)
  else lst.push(out, i) end
  return out end

-- print tree: win, n, per-goal mids (y names on top), then
-- indented branch conditions, best kid first. Best leaf
-- marked with a triangle up, worst down; marks built from
-- ints since literal utf glyphs upset make-pdf (a2ps).
function Tree.show(i,tbl,    up,down,W,win,ws,ymid,branch)
  up, down = string.char(226,150,178), string.char(226,150,188)
  W    = tbl:wins(i.rows)
  win  = function(rows)
           return floor(adds(lst.map(rows, W)):mid()) end
  ws   = lst.sort(lst.map(i:leaves(),
           function(leaf) return win(leaf.rows) end))
  ymid = function(rows)
           return table.concat(lst.map(tbl.cols.y,
             function(c,    ys)
               ys = getmetatable(c).new()
               for _,r in ipairs(rows) do
                 if r[c.at] ~= "?" then ys:add(r[c.at]) end end
               return fmt("%8s", str.o(ys:mid())) end), " ") end
  branch = function(t,pad,edge,    w,m,kids)
    w = win(t.rows)
    m = t.col and " "
        or w == ws[#ws] and up
        or w == ws[1] and down or " "
    print((fmt("%s %4d %5d  %s  %s%s",
           m, w, t.n, ymid(t.rows), pad, edge):gsub("%s+$","")))
    if t.col then
      pad  = edge == "" and pad or pad .. "|  "
      kids = lst.keysort({{t.yes,1}, {t.no,2}},
               function(p) return p[1].mid end)
      for _,p in ipairs(kids) do
        branch(p[1], pad, fmt("%s %s %s", t.col.txt,
               t.col.ops[p[2]], str.o(t.v))) end end end
  print(fmt("%s %4s %5s  %s", " ", "win", "n",
        table.concat(lst.map(tbl.cols.y,
          function(c) return fmt("%8s", c.txt) end), " ")))
  branch(i, "", "") end


-- ## Stats
-- `same` = conservative difference: `cohen` AND `cliffs`
-- AND `ks` must all see a gap before two sets differ.

-- Cliff's delta effect size in 0..1 (0 = identical); ys sorted
function stats.cliffs(xs,ys,    m,gt,lt)
  m, gt, lt = #ys, 0, 0
  for _,x in ipairs(xs) do
    gt = gt + lst.bisect(ys, x, true) - 1    -- # ys < x
    lt = lt + m - lst.bisect(ys, x) + 1 end  -- # ys > x
  return abs(gt - lt)/(#xs * m + 1E-32) end

-- Kolmogorov-Smirnov: max gap between the CDFs; xs,ys sorted
function stats.ks(xs,ys,    cdf,d)
  cdf = function(v,t) return (lst.bisect(t,v) - 1)/#t end
  d = 0
  for _,t in ipairs{xs,ys} do
    for _,v in ipairs(t) do
      d = max(d, abs(cdf(v,xs) - cdf(v,ys))) end end
  return d end

-- small effect: |mean gap| <= 0.35 * pooled sd
function stats.cohen(xs,ys,    a,b,sd)
  a, b = adds(xs), adds(ys)
  sd = (((a.n - 1)*a:spread()^2 + (b.n - 1)*b:spread()^2)
        / (a.n + b.n - 2))^0.5
  return abs(a.mu - b.mu) <= 0.35*(sd + 1E-32) end

-- true unless every test sees a difference: "different!"
-- only when it would take real effort to argue otherwise
function stats.same(xs,ys,    n,m)
  xs = lst.sort(lst.slice(xs))
  ys = lst.sort(lst.slice(ys))
  n, m = #xs, #ys
  return stats.cohen(xs,ys) or stats.cliffs(xs,ys)<=0.195
      or stats.ks(xs,ys) <= 1.36*((n + m)/(n*m))^0.5 end

-- keys of dct (key -> list of nums), ranked by list mean
-- (rev flips to descending): the leader, plus every key
-- `same` as the leader
function stats.top(dct,rev,    keys,out)
  keys = lst.keysort(
           lst.sort(lst.kap(dct, function(k) return k end)),
           function(k,    mu)
             mu = adds(dct[k]).mu
             return rev and -mu or mu end)
  out = {keys[1]}
  for i = 2, #keys do
    if not stats.same(dct[keys[1]], dct[keys[i]]) then break end
    lst.push(out, keys[i]) end
  return out end


-- ## Lst
-- List basics. Lib (lst, rnd, str) comes last so the AI
-- code above reads unobstructed.

-- append x to t; return x
function lst.push(t,x) t[1 + #t] = x; return x end

-- sort t in place; return t
function lst.sort(t,fn) table.sort(t,fn); return t end

-- copy of t, each item passed through fn
function lst.map(t,fn,    u)
  u={}; for _,v in ipairs(t) do u[1 + #u] = fn(v) end
  return u end

-- copy of t, each keym item passed through fn
function lst.kap(t,fn,    u)
  u={}; for k,v in pairs(t) do u[1 + #u] = fn(k,v) end
  return u end

-- copy of items lo..hi of t (defaults: all)
function lst.slice(t,lo,hi,    u)
  u={}; for j = lo or 1, min(hi or #t, #t) do
          lst.push(u, t[j]) end
  return u end

-- sort a copy of t by fn(item), computing fn once per item.
-- Ties keep arrival order (stable), so runs repeat exactly.
function lst.keysort(t,fn,    u)
  u = {}
  for j,v in ipairs(t) do u[j] = {fn(v), j, v} end
  lst.sort(u, function(a,b)
    return a[1] < b[1] or
           (a[1] == b[1] and a[2] < b[2]) end)
  return lst.map(u, function(p) return p[3] end) end

-- t ascending; smallest j with v < t[j] (eq: v <= t[j]).
-- So count(t <= v) = bisect(t,v)-1; count(t < v) via eq.
function lst.bisect(t,v,eq,    lo,hi,mid)
  lo, hi = 1, #t + 1
  while lo < hi do
    mid = floor((lo + hi)/2)
    if v < t[mid] or eq and v == t[mid] then hi = mid
    else lo = mid + 1 end end
  return lo end

-- item of t maximizing fn(item)
function lst.argmax(t,fn,    hi,v,out)
  hi = -BIG
  for _,z in ipairs(t) do
    v = fn(z)
    if v > hi then hi,out = v,z end end
  return out end

-- iterate over key,items in sorted key order
function lst.items(t,     i,keys)
  i,keys = 0,lst.sort(lst.kap(t, function(k,_) return k end))
  return function()
    i=i+1; if keys[i] then return keys[i], t[keys[i]] end end end

-- iterate col,row[col.at] over cols, skipping "?" cells
function lst.cells(cols,row,    i)
  i = 0
  return function(    c,v)
    while true do
      i = i + 1; c = cols[i]
      if not c then return end
      v = row[c.at]
      if v ~= "?" then return c,v end end end end


-- ## Rnd
-- Seeded random, so runs reproduce on any lua.

local Seed = 1
-- reset the generator (0 nudged to 1)
function rnd.seed(n)
  Seed = (n or 1) % 2147483647
  if Seed == 0 then Seed = 1 end end

-- 16807 Lehmer generator: same runs on any lua.
-- rnd.n() = float 0..1; rnd.n(n) = integer 1..n
function rnd.n(n,    r)
  Seed = (16807 * Seed) % 2147483647
  r = Seed / 2147483647
  return n and floor(r * n) + 1 or r end

-- Fisher-Yates, in place; return t
function rnd.shuffle(t,    j)
  for i = #t, 2, -1 do
    j = rnd.n(i); t[i],t[j] = t[j],t[i] end
  return t end

-- k items picked at random (t untouched)
function rnd.some(t,k)
  return lst.slice(rnd.shuffle(lst.slice(t)), 1, k) end

-- weighted sampler over a dict of key -> weight
function rnd.pick(dct,    keys,s)
  keys, s = {}, 0
  for k,w in pairs(dct) do lst.push(keys, k); s = s + w end
  return function(    r)
    r = s * rnd.n()
    for _,k in ipairs(keys) do
      r = r - dct[k]; if r <= 0 then return k end end
    return keys[#keys] end end

-- Box-Muller bell: mean mu, sd sd (real tails)
function rnd.gauss(mu,sd,    u1,u2)
  mu, sd, u1, u2 = mu or 0, sd or 1, rnd.n(), rnd.n()
  return mu + sd*sqrt(-2*log(u1))*math.cos(2*math.pi*u2) end


-- ## Str
-- Strings and files.

-- strip leading and trailing whitespace
function str.trim(s) return s:match"^%s*(.-)%s*$" end

-- string -> true | false | number | trimmed string
function str.what(s)
  s = str.trim(s)
  return s=="true" or (s ~= "false" and (tonumber(s) or s)) end

-- set `the` from any "--key=val" patterns in s
function str.settings(s)
  for k,v in s:gmatch"%-%-(%w+)=(%S+)" do
    the[k] = str.what(v) end end

-- expand a leading ~ or $MOOT (env, else ~/gits/moot)
function str.filename(s)
  return (s:gsub("^~", os.getenv"HOME")
           :gsub("^%$MOOT", os.getenv"MOOT" or
                 os.getenv"HOME" .. "/gits/moot")) end

-- iterate a csv's rows, cells trimmed and typed
function str.csv(file,    f)
  f = assert(io.open(str.filename(file)), "no " .. file)
  return function(    u)
    for s0 in f:lines() do
      local s = s0:gsub("\239\187\191","")
      if s:find"%S" then
        u={}
        for x in (s..","):gmatch"(.-)," do
          lst.push(u, x=="" and "?" or str.what(x)) end
        return u end end
    f:close() end end

-- pretty print: ints bare, floats %.3f, lists spaced, dicts sorted
function str.o(x,    u,y)
  if type(x) == "number" then
    y = floor(x)
    return x == y and tostring(y) or fmt("%.3f",x) end
  if type(x) ~= "table" then return tostring(x) end
  u = lst.map(x,str.o) -- for non-arrays, returns '{}'
  if #u == 0 then
    for k,v in lst.items(x) do u[1+#u] = k.."="..str.o(v) end end
  return "{" .. table.concat(u, " ") .. "}" end

-- ## Start
-- Parse help's --key=val defaults into `the`, seed, and
-- hand back the module (demos and cli live in xai-eg.lua).

str.settings(help)
rnd.seed(the.seed)

return {the=the, help=help, new=new, adds=adds,
        Num=Num, Sym=Sym, Cols=Cols, Tbl=Tbl, Tree=Tree,
        acquire=acquire, bins=bins, stats=stats,
        lst=lst, rnd=rnd, str=str}
