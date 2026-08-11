#!/usr/bin/env lua
-- xai-eg.lua: demos and tests for xai.lua. One eg sub-table
-- per library section, ordered simplest to hardest (lib
-- first, then the AI code). On the command line:
--
--     --key=val, -k val    set an option   
--     --lst, --tree, ...   run one section's tests   
--     --csv, --grow, ...   run one test   
--     --all                run every section   
--
-- Each test is reseeded, prints something a tutor can point
-- at, then asserts it: no crash = pass.
--
--      lua xai-eg.lua --seed=2 --tree --score
--
--[[
### How to run this course

(Easier read: this file, rendered --
[xai-eg.html](https://timm.github.io/src/xai/docs/xai-eg.html);
its library
[xai.html](https://timm.github.io/src/xai/docs/xai.html);
the shared dictionary
[glossary](https://timm.github.io/src/glossary.html).)

Install [lua 5.4+](https://lua.org) (mac:
`brew install lua`), then fetch the code and its data:

    git clone https://github.com/timm/src
    git clone https://github.com/timm/moot ~/gits/moot
    cd src/xai
    lua xai-eg.lua --all      # a minute; ends "all pass"

Then four levels of read, per lesson:

1. (skim) Read a lesson here beside its printed output in
   [xai-eg.out](xai-eg.out). Can you tell what is going
   on?
2. (run) Run that lesson's tests from the command line,
   e.g. `lua xai-eg.lua --items`. Change an input; rerun.
3. (dive) Fire up the REPL: `lua -i`, then
   `xai = require"xai"`, then retype any demo, line by
   line, printing as you go.
4. (deep dive) Port a lesson to your own favorite
   language (not lua) and reproduce its slice of
   xai-eg.out. This can take a little time, so best to
   start with the shorter functions within each
   lesson.

### Contents

The lessons in order, and the ideas each lands in the
[glossary](../glossary.md). Run `lua xai-eg.lua -h` for the
matching section/test map.

| lesson | section | core ideas |
|--------|---------|------------|
|  0 | Lua     | [truthy](../glossary.md#truthy) [onetable](../glossary.md#onetable) [closure](../glossary.md#closure) [patterns](../glossary.md#patterns) [bob](../glossary.md#bob) |
|  1 | Lst     | [lists](../glossary.md#lists) [dsu](../glossary.md#dsu) [bisect](../glossary.md#bisect) |
|  2 | Rnd     | [seed](../glossary.md#seed) [shuffle](../glossary.md#shuffle) [gauss](../glossary.md#gauss) [roulette](../glossary.md#roulette) |
|  3 | Str     | [coerce](../glossary.md#coerce) [csv](../glossary.md#csv) [ssot](../glossary.md#ssot) |
|  4 | Num     | [welford](../glossary.md#welford) [stream](../glossary.md#stream) [minus](../glossary.md#minus) |
|  5 | Sym     | [entropy](../glossary.md#entropy) [mode](../glossary.md#mode) [poly](../glossary.md#poly) [noir](../glossary.md#noir) |
|  6 | Cols    | [schema](../glossary.md#schema) [goals](../glossary.md#goals) [xy](../glossary.md#xy) |
|  7 | Tbl     | [tables](../glossary.md#tables) [clone](../glossary.md#clone) [centroid](../glossary.md#centroid) |
|  8 | Dist    | [norm](../glossary.md#norm) [minkowski](../glossary.md#minkowski) [missing](../glossary.md#missing) [heaven](../glossary.md#heaven) [knn](../glossary.md#knn) [anomaly](../glossary.md#anomaly) |
|  9 | Stats   | [effect](../glossary.md#effect) [ks](../glossary.md#ks) [same](../glossary.md#same) |
| 10 | Acquire | [budget](../glossary.md#budget) [active](../glossary.md#active) [poles](../glossary.md#poles) [explore](../glossary.md#explore) |
| 11 | Bins    | [bins](../glossary.md#bins) [cost](../glossary.md#cost) [closure](../glossary.md#closure) |
| 12 | Tree    | [tree](../glossary.md#tree) [predict](../glossary.md#predict) [explain](../glossary.md#explain) |
| 13 | Score   | [holdout](../glossary.md#holdout) [win](../glossary.md#win) [baseline](../glossary.md#baseline) [bets](../glossary.md#bets) [variability](../glossary.md#variability) |
]]
local xai = require"xai"
local the,lst,rnd,str = xai.the, xai.lst, xai.rnd, xai.str
local stats,acquire   = xai.stats, xai.acquire
local bins,adds       = xai.bins, xai.adds
local Num,Sym,Cols    = xai.Num, xai.Sym, xai.Cols
local Tbl,Tree        = xai.Tbl, xai.Tree

local eg    = {}
local order = {"lua","lst","rnd","str","num","sym","cols",
               "tbl","dist","stats","acquire","bins","tree",
               "score"}

-- ## Lua
--[[
### Lesson 0: lua for the impatient pythonista

You know python; lua needs a few small adjustments, all
listed under [lua](../glossary.md#lua) in the glossary.
The demos below are the ones that bite hardest: what
counts as false, the one-table-fits-all data structure,
home-made for loops (which is where closures enter),
patterns that are not regexes -- and a first SE rule,
checked against our own source code.

**Core ideas:** [lua](../glossary.md#lua),
[truthy](../glossary.md#truthy),
[onetable](../glossary.md#onetable),
[closure](../glossary.md#closure),
[patterns](../glossary.md#patterns), [bob](../glossary.md#bob)
]]
eg.lua = {}

-- - **type(x)** and truthiness: only nil and false are
--   falsy. `and/or` chains give ternaries and defaults.
eg.lua["--truthy"] = function(    x)
  print("0 is truthy:", 0 and "yes" or "no")
  assert(0 and "" and true)
  assert((false or nil) == nil)
  x = nil
  x = x or 42                          -- the default idiom
  assert(x == 42)
  assert((1 == 1 and "t" or "f") == "t") end

-- - **pairs(t)** walks every key, no fixed order;
--   **ipairs(t)** walks 1,2,3.. stopping at the first nil.
--   One table = python's list + dict + object, all at once.
eg.lua["--onetable"] = function(    t,n,m)
  t = {10, 20, 30, job="cook", 40}
  n = 0; for _ in ipairs(t) do n = n + 1 end
  m = 0; for _ in pairs(t)  do m = m + 1 end
  print("ipairs sees", n, " pairs sees", m)
  assert(n == 4 and m == 5)
  assert(t[1] == 10 and t.job == "cook")
  assert(t[0] == nil) end              -- lua counts from 1

-- - **lst.items(t)** is a home-made for loop: it returns an
--   iterator -- a closure that remembers how far it got --
--   yielding key,value in SORTED key order. When pairs'
--   wandering order hurts (printing, transcripts), roll
--   your own walk.
eg.lua["--items"] = function(    t,s)
  t = {c=3, a=1, b=2}
  s = ""
  for k,v in lst.items(t) do s = s .. k .. v end
  print("sorted walk:", s)
  assert(s == "a1b2c3") end

-- - **s:find(pat)**, **s:match(pat)**, **s:gsub(pat,new)**:
--   patterns, not regexes (%d %w %s classes, anchors ^ $),
--   and ("s"):method sugar works on any string.
eg.lua["--patterns"] = function(    s)
  s = "Lbs-"
  print("goal col?", s:find"-$" and "minimize" or "no")
  assert(s:find"-$")
  assert(("age=42"):match"%d+" == "42")
  assert(("a,b,c"):gsub(",", ";") == "a;b;c") end

-- - **io.lines(file)** plus patterns plus one counting
--   table = a tiny static analyzer. Uncle Bob's rule says
--   keep functions small. Count code lines per paragraph
--   of xai.lua (comments and blanks end a paragraph):
--   does that code practice what this lesson preaches?
eg.lua["--bob"] = function(    n,sizes,small,big)
  n, sizes = 0, {}
  for s in io.lines"xai.lua" do
    if s:find"%S" and not s:find"^%s*%-%-"
    then n = n + 1
    elseif n > 0 then
      sizes[n] = (sizes[n] or 0) + 1
      n = 0 end end
  if n > 0 then sizes[n] = (sizes[n] or 0) + 1 end
  small, big = 0, 0
  for size = 1, 99 do
    if sizes[size] then
      print(("%2d %s"):format(size, ("*"):rep(sizes[size])))
      if size <= 6 then small = small + sizes[size]
      else big = big + sizes[size] end end end
  print("small (<=6 lines):", small, " bigger:", big)
  assert(small > big) end              -- Bob would approve

--[[
**Exercises (lesson 0).**

0. In your own favorite language (not lua), write the
   `--bob` analyzer for that language's comment syntax,
   then run it on its own source. Is your code
   Bob-friendly?
1. (simple) Predict, then check: `0 and 1 or 2`,
   `nil and 1 or 2`, `#"xai"`, `("x"):rep(3)`.
2. Extend `--bob` to also report the largest paragraph
   and its first line. Which part of xai.lua most needs
   Uncle Bob's attention -- and would splitting it
   actually help a reader?
]]

-- ## Lst
--[[
### Lesson 1: lists are all you need

This system has one data structure: the Lua table, used as
a list. No classes of container, no iterators, no streams
library -- just a dozen ten-line verbs over lists. The deep
point of lesson 1 is that a tiny vocabulary, if the verbs
compose (push returns its item; sort returns its list),
covers everything the next twelve lessons need. Two verbs
deserve early respect: `keysort` computes its sort key once
per item (the decorate-sort-undecorate trick -- vital when
the key is an expensive distance calc), and `bisect` finds
positions in sorted lists in log time (lesson 9's statistics
lean on it).

**Core ideas:** [lists](../glossary.md#lists),
[dsu](../glossary.md#dsu), [bisect](../glossary.md#bisect)
]]
eg.lst = {}

-- - **lst.push(t,x)** appends x to t and returns x, so pushes
--   can sit inside larger expressions.
-- - **lst.sort(t,fn)** sorts in place and returns t, so sorts
--   chain into the next call.
-- - **lst.map(t,fn)** copies t, each item through fn.
-- - **lst.slice(t,lo,hi)** copies items lo..hi (defaults: all).
eg.lst["--basics"] = function(    t,u)
  t = {}
  for j = 5, 1, -1 do lst.push(t, j) end
  u = lst.map(lst.sort(t), function(x) return 10*x end)
  print("sorted, x10:", str.o(u))
  assert(u[1] == 10 and u[5] == 50)
  assert(#lst.slice(u, 2, 4) == 3) end

-- - **lst.keysort(t,fn)** sorts a copy by fn(item), computing
--   fn just once per item.
-- - **lst.argmax(t,fn)** returns the item maximizing fn.
-- - **lst.bisect(t,v,eq)** binary search of sorted t: smallest
--   j with v < t[j] (eq: v <= t[j]); so bisect-1 counts <= v.
eg.lst["--search"] = function(    t)
  t = lst.keysort({3,1,2}, function(x) return -x end)
  print("keysort by -x:", str.o(t))
  assert(t[1] == 3 and t[3] == 1)
  assert(lst.argmax({3,9,4}, function(x) return x end) == 9)
  t = {1,2,2,2,5}
  assert(lst.bisect(t, 2)       == 5)  -- 4 items <= 2
  assert(lst.bisect(t, 2, true) == 2)  -- 1 item  <  2
  assert(lst.bisect(t, 9)       == 6) end

--[[
**Exercises (lesson 1).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Using only `lst.map`, `lst.sort` and
   `lst.slice`, print the three largest squares of
   {7,2,9,4,5}. Predict the answer before running.
2. Write `argmin(t,fn)` as a one-liner that reuses
   `lst.argmax`. Then show `lst.bisect(t, argmin(t,id))`
   equals 1 on any sorted list (id = identity function).
]]

-- ## Rnd
--[[
### Lesson 2: reproducible randomness

Science requires rerunnable experiments, so this system
never calls the platform random. Instead: a 10-line Lehmer
generator (multiply by 16807, mod 2^31-1) that yields the
SAME stream on any machine, any lua. Everything stochastic
downstream -- shuffles, samples, mutation -- inherits
reproducibility from this one seed. Also here: turning
uniform bits into other shapes (Box-Muller for bells,
roulette wheels for weighted choice), which is most of what
"simulation" means.

**Core ideas:** [seed](../glossary.md#seed),
[shuffle](../glossary.md#shuffle), [gauss](../glossary.md#gauss),
[roulette](../glossary.md#roulette)
]]
eg.rnd = {}

-- - **rnd.seed(n)** resets the 16807 Lehmer generator (0 is
--   nudged to 1), so any run repeats on any lua.
-- - **rnd.n()** next float 0..1; **rnd.n(k)** integer 1..k.
eg.rnd["--lehmer"] = function(    a,b)
  rnd.seed(1); a = rnd.n()
  rnd.seed(1); b = rnd.n()
  print("same seed, same draw:", str.o(a), str.o(b))
  assert(a == b and a > 0 and a < 1)
  a = rnd.n(10)
  assert(a >= 1 and a <= 10 and a == a // 1) end

-- - **rnd.shuffle(t)** Fisher-Yates, in place.
-- - **rnd.some(t,k)** k items at random; t untouched.
eg.rnd["--some"] = function(    t,u)
  t = {10,20,30,40,50,60,70,80,90,100}
  u = rnd.some(t, 3)
  print("3 of 10:", str.o(u))
  assert(#u == 3 and #t == 10 and t[1] == 10)
  u = rnd.shuffle{1,2,3,4,5}          -- same members, new order
  assert(#u == 5 and lst.sort(u)[5] == 5) end

-- - **rnd.pick(dct)** returns a sampler weighted by the dict's
--   key -> weight pairs.
-- - **rnd.gauss(mu,sd)** Box-Muller bell (real tails).
eg.rnd["--gauss"] = function(    f,num)
  f = rnd.pick{a=1, b=0}
  assert(f() == "a")                     -- all weight on "a"
  num = Num.new()
  for _ = 1, 1000 do num:add(rnd.gauss(10, 2)) end
  print("1000 x gauss(10,2): mu", str.o(num:mid()),
        "sd", str.o(num:spread()))
  assert(9.5 < num:mid()    and num:mid()    < 10.5)
  assert(1.5 < num:spread() and num:spread() < 2.5) end

--[[
**Exercises (lesson 2).**

0. In your own favorite language (not lua), implement the
   generator: seed = (16807 * seed) % 2147483647, and
   rnd() = seed / 2147483647 (plain floats are exact here:
   16807 * 2^31 < 2^53). Self-check: from seed 1 the next
   three seeds are 16807, 282475249, 1622650073. Match
   that, then implement this section's examples -- and
   from now on every lesson's exercise 0 can self-grade by
   diffing its printed output (3 decimals) against the
   frozen transcript xai-eg.out.
1. (simple) Run `--lehmer` with `--seed=7`, twice. Then
   without the flag, twice. Explain the difference in one
   sentence.
2. Using `rnd.pick` over {win=7, lose=2, draw=1},
   draw 10,000 samples and count each key (a plain table
   of counts). How close are the ratios to 7:2:1, and why
   does rerunning give the exact same counts?
]]

-- ## Str
--[[
### Lesson 3: strings to things

Files hold strings; programs want things. One tiny coercer
(`what`) turns "42" into a number and "true" into a
boolean, and then two conventions do a lot of work. First:
settings live in the help text, so documentation and
defaults cannot drift apart (one source of truth). Second:
data files describe themselves -- lesson 6 will read column
roles straight out of the csv header. When parsing is this
cheap, there is no excuse for config files, schemas, or
YAML.

**Core ideas:** [coerce](../glossary.md#coerce),
[csv](../glossary.md#csv), [ssot](../glossary.md#ssot)
]]
eg.str = {}

-- - **str.trim(s)** strips outer whitespace.
-- - **str.what(s)** coerces to true | false | number, else the
--   trimmed string.
-- - **str.settings(s)** pulls any --key=val pairs into `the`.
eg.str["--coerce"] = function(    old)
  print("what:", str.what" 42 ", str.what"true", str.what" x ")
  assert(str.trim"  x  " == "x")
  assert(str.what" 42 "  == 42)
  assert(str.what"true"  == true)
  assert(str.what"false" == false)
  old = the.p
  str.settings"--p=4"
  assert(the.p == 4)
  the.p = old end

-- - **str.filename(s)** expands a leading $MOOT (env var, else
--   ~/gits/moot).
-- - **str.csv(file)** iterates a csv's rows, cells trimmed and
--   typed by str.what.
eg.str["--csv"] = function(    n,row1)
  assert(not str.filename(the.file):find"%$")
  n = 0
  for row in str.csv(the.file) do
    n = n + 1; row1 = row1 or row end
  print("rows (with header):", n, "header:", str.o(row1))
  assert(n > 1 and type(row1[1]) == "string")
  if the.file:find"auto93" then assert(n == 399) end end

-- - **str.o(x)** pretty print: numbers rounded to 3 decimals,
--   lists space-separated, dict keys sorted.
eg.str["--o"] = function()
  print("o:", str.o{3.14159, "hi", {b=2, a=1}})
  assert(str.o(3.14159)   == "3.142")
  assert(str.o{b=2, a=1}  == "{a=1 b=2}") end

--[[
**Exercises (lesson 3).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) `str.settings"--p=1 --seed=42"` -- print `the`
   before and after with `str.o`. Which keys changed?
   Restore them.
2. With `str.csv` and a plain counting table, report
   how many "?" cells appear in each column of auto93.csv
   (name the columns via the header row).
]]

-- ## Num
--[[
### Lesson 4: incremental statistics

Mean and sd without keeping the data: Welford's update
folds each value into three slots (n, mu, m2). Why care?
Streams -- a million numbers summarize in constant space.
And one more trick that pays off in lesson 11: summaries
built this way can be UN-folded, so `without` returns "all
of i's data except j's" in constant time, no second pass
over the rows. Columns also carry their goal here: a name
ending "-" means lower is better.

**Core ideas:** [welford](../glossary.md#welford),
[stream](../glossary.md#stream), [minus](../glossary.md#minus)
]]
eg.num = {}

-- - **Num.new(txt,at)** summarizes one numeric column; a name
--   ending "-" sets goal w=0 (minimize), else w=1.
-- - **Num.add(i,v,w)** folds v in by Welford (w<0 folds out).
-- - **Num.mid(i)**, **Num.spread(i)** = mean, std deviation.
-- - **adds(t,i)** folds a whole list into any summary.
eg.num["--welford"] = function(    n)
  n = adds{10,20,30,40}
  print("mu:", n:mid(), "sd:", str.o(n:spread()))
  assert(n:mid() == 25)
  assert(12.9 < n:spread() and n:spread() < 13)
  n:add(40, -1)                       -- fold the 40 back out
  assert(n.n == 3 and n:mid() == 20)
  assert(Num.new("Lbs-").w == 0 and Num.new("Mpg+").w == 1) end

-- - **Num.without(num1,num2)** Num of num1's data without num2's:
--   weighted add of -n2 values at mu2, then num2's spread comes
--   off m2. This trick lets bin scoring skip a second data pass.
-- - **Num.norm(i,v)** logistic z-score squash to 0..1, so the
--   mean lands near 0.5.
eg.num["--without"] = function(    a,b,c)
  a, b = adds{1,2,3,4,5,6}, adds{4,5,6}
  c = a:without(b)
  print("{1..6} minus {4,5,6}: mu", c:mid(),
        "sd", str.o(c:spread()))
  assert(c.n == 3 and c:mid() == 2 and c:spread() == 1)
  assert(a:norm(a:mid()) > 0.49 and a:norm(a:mid()) < 0.51) end

--[[
**Exercises (lesson 4).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Change `--welford`'s list to {10,20,30,400}.
   Predict mu and sd before running (hint: sd is hurt more
   than mu by one outlier). Then check with `adds`.
2. Write `merge(i,j)` -- the inverse of `without` --
   using only `Num.new` and `Num.add`. Prove it: for any
   two lists, `merge(a:without(b), b)` must match `a` on
   n, mu and m2 (to ten significant digits).
]]

-- ## Sym
--[[
### Lesson 5: counting and entropy

Not everything is a number. Symbolic columns summarize as
counts; their "middle" is the mode and their "spread" is
entropy -- the effort needed to describe what is in the
bag. The lesson's real point is the shared interface: Num
and Sym both answer add, mid, spread, without. Code that
talks only to that interface (all of lessons 11-13) never
asks a column its type. That is polymorphism doing the
work of a design pattern, in twenty lines. (Measurement
theory calls Num and Sym the two ends of the NOIR ladder:
nominal things get counted, ratio things get averaged.)

**Core ideas:** [entropy](../glossary.md#entropy),
[mode](../glossary.md#mode), [poly](../glossary.md#poly),
[noir](../glossary.md#noir)
]]
eg.sym = {}

-- - **Sym.new(txt,at)** summarizes one symbolic column: counts
--   in has{}.
-- - **Sym.add(i,v,w)** counts v in (w<0: out; dead keys die).
-- - **Sym.mid(i)** = mode; **Sym.spread(i)** = entropy.
eg.sym["--mode"] = function(    s)
  s = adds({"a","a","a","b","b","c"}, Sym.new())
  print("mode:", s:mid(), "entropy:", str.o(s:spread()))
  assert(s:mid() == "a")
  assert(1.45 < s:spread() and s:spread() < 1.47)
  s:add("c", -1)                      -- fold the c back out
  assert(s.n == 5 and s.has.c == nil) end

-- - **Sym.without(sym1,sym2)** counts of sym1 without sym2's,
--   same shape as Num.without: bin scoring never asks a
--   column its type.
eg.sym["--minus"] = function(    a,b,c)
  a = adds({"a","a","b"}, Sym.new())
  b = adds({"b"},         Sym.new())
  c = a:without(b)
  print("aab minus b:", str.o(c.has))
  assert(c.n == 2 and c.has.a == 2 and c.has.b == nil) end

--[[
**Exercises (lesson 5).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Build two Syms with `adds`: a fair coin
   {h,t,h,t} and a loaded one {h,h,h,t}. Predict which has
   higher entropy, then print both spreads.
2. Entropy of {a,a,b,b,c,c,d,d} is exactly 2 bits.
   Show this with `adds` + `Sym.spread`, then explain (three
   sentences max) why doubling every count leaves entropy
   unchanged -- checking your claim with `Sym.add(i,v,w)`
   and w=2.
]]

-- ## Cols
--[[
### Lesson 6: the header is the schema

Data should explain itself. In this system a csv header
line IS the schema: leading uppercase means numeric; a
trailing "-", "+" or "!" marks a goal to minimize,
maximize, or classify; trailing "X" means ignore. One
30-line factory reads those names and builds typed column
summaries, split into x (inputs) and y (goals). No config
file, no schema language -- rename a column and the
system's whole view of the data changes.

**Core ideas:** [schema](../glossary.md#schema),
[goals](../glossary.md#goals), [xy](../glossary.md#xy)
]]
eg.cols = {}

-- - **Cols.new(names)** types a header: leading uppercase =
--   Num; -,+,! suffix = y goal; X suffix = skip; else x.
-- - **Cols.add(i,row)** routes one row's cells to their
--   columns ("?" cells skipped).
eg.cols["--types"] = function(    c)
  c = Cols.new{"Age", "job", "SkipX", "Weight-"}
  print("all x y:", #c.all, #c.x, #c.y,
        " goal(Weight-):", c.all[4].w)
  assert(#c.all == 4 and #c.x == 2 and #c.y == 1)
  assert(c.all[4].w == 0)
  c:add{20, "cook", "?", 80}
  assert(c.all[1].mu == 20 and c.all[2].has.cook == 1) end

--[[
**Exercises (lesson 6).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Write a header for a used-car lot: two numeric
   inputs, one symbolic input, one column to ignore, price
   to minimize. Check x/y sizes with `Cols.new`.
2. Feed `Cols.add` ten rows where one numeric cell
   is "?" half the time. Show (via the col's n) that
   missing cells never corrupt the count, and say why that
   matters for the lesson-4 subtraction trick.
]]

-- ## Tbl
--[[
### Lesson 7: tables and clones

A Tbl is just rows plus the lesson-6 columns: the first row
builds the schema, every later row updates per-column
summaries as it is stored. The one non-obvious verb is
`clone`: a fresh, empty table wearing the same header.
Grow different row subsets inside clones and each subset
gets its own honest statistics -- which is how lesson 13
keeps its train and test data from contaminating each
other.

**Core ideas:** [tables](../glossary.md#tables),
[clone](../glossary.md#clone),
[centroid](../glossary.md#centroid)
]]
eg.tbl = {}

-- - **Tbl.new(src)** table from a csv file name or a list of
--   rows; first row makes the cols (**Tbl.add** does the rest).
eg.tbl["--load"] = function(    t)
  t = Tbl.new(the.file)
  print("rows:", #t.rows, "y:", str.o(lst.map(t.cols.y,
        function(c) return c.txt end)))
  assert(#t.rows > 0 and #t.cols.y > 0)
  if the.file:find"auto93" then assert(#t.rows == 398) end end

-- - **Tbl.clone(i,rows)** fresh Tbl over new rows, reusing the
--   header, so subsets get their own column summaries.
eg.tbl["--clone"] = function(    t,u)
  t = Tbl.new(the.file)
  u = t:clone(lst.slice(t.rows, 1, 10))
  print("clone of first 10 rows:", #u.rows)
  assert(#u.rows == 10)
  assert(u.cols.names == t.cols.names) end

-- - **Tbl.mids(i)** the table's centroid: every column's
--   mid, computed once then cached -- and any `add` wipes
--   the cache, since new rows move the middle.
eg.tbl["--mids"] = function(    t,u)
  t = Tbl.new(the.file)
  print("centroid:    ", str.o(t:mids()))
  u = t:clone(lst.slice(t.rows, 1, 20))
  print("20-row clone:", str.o(u:mids()))
  assert(#t:mids() == #t.cols.all)
  assert(t.middle)                    -- cached...
  t:add(t.rows[1])
  assert(t.middle == nil) end         -- ...until an add

--[[
**Exercises (lesson 7).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Clone the first 50 rows of auto93. Compare the
   clone's first y column mid to the full table's. Why do
   they differ?
2. Using `rnd.some` (lesson 2) and `Tbl.clone`, show
   that the mid of a 100-row random clone sits closer to
   the full table's mid than the first-50 clone from
   exercise 1. One sentence: why?
]]

-- ## Dist
--[[
### Lesson 8: distance is all you need

Once every value maps to 0..1 (`norm`), any two rows are a
number apart (`distx`, a Minkowski sum over x columns) and
any single row is a number from perfection (`disty`,
distance to the ideal goal corner -- "heaven"). Missing
values get the pessimistic treatment: assume the worst.
With just these two rulers we get clustering, nearest
neighbors, anomaly detection, and (lessons 10-13) cheap
optimization. Distance really is most of what "learning"
needs.

**Core ideas:** [norm](../glossary.md#norm),
[minkowski](../glossary.md#minkowski),
[missing](../glossary.md#missing),
[heaven](../glossary.md#heaven),
[knn](../glossary.md#knn), [anomaly](../glossary.md#anomaly)
]]
eg.dist = {}

-- - **Sym.dist/Num.dist(i,u,v)** gap 0..1 between two values of
--   one column; "?" gets the pessimistic, far-away treatment.
-- - **Tbl.distx(i,r1,r2)** p-norm of those gaps over the x cols.
eg.dist["--distx"] = function(    t,r,d)
  t = Tbl.new(the.file)
  r = t.rows[1]
  d = t:distx(r, t.rows[2])
  print("d(r1,r1):", t:distx(r,r), " d(r1,r2):", str.o(d))
  assert(t:distx(r, r) == 0)
  assert(d > 0 and d <= 1)
  assert(Sym.new():dist("a", "b") == 1)
  assert(Num.new():dist("?", "?") == 1) end -- "?" = far away

-- - **Tbl.disty(i,row)** distance to the ideal y goals;
--   0 = heaven, 1 = worst possible row.
eg.dist["--disty"] = function(    t,ds)
  t  = Tbl.new(the.file)
  ds = lst.sort(lst.map(t.rows,
                        function(r) return t:disty(r) end))
  print("disty lo mid hi:", str.o(ds[1]),
        str.o(ds[#ds // 2]), str.o(ds[#ds]))
  assert(ds[1] >= 0 and ds[#ds] <= 1 and ds[1] < ds[#ds]) end

-- - **Tbl.distx** + **lst.keysort** = k nearest neighbors: no
--   training step, the data IS the model. And a row far from
--   even its own nearest neighbor is an anomaly: once you
--   have distance, outlier detection is one argmax.
eg.dist["--near"] = function(    t,rows,near,gap,r,lone)
  t    = Tbl.new(the.file)
  rows = rnd.some(t.rows, 64)
  near = function(r1)               -- closest OTHER row
           return lst.keysort(rows, function(r2)
             return r1 == r2 and 2 or t:distx(r1,r2) end)[1] end
  gap  = function(r1) return t:distx(r1, near(r1)) end
  r    = rows[1]
  print("row:     ", str.o(r))
  print("neighbor:", str.o(near(r)))
  assert(near(r) ~= r)
  lone = lst.argmax(rows, gap)
  print("loneliest (anomaly?):", str.o(lone),
        "gap", str.o(gap(lone)))
  assert(gap(lone) >= gap(r)) end

--[[
**Exercises (lesson 8).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Rerun `--distx` with `--p=1` then `--p=4`.
   Which p makes distances bigger, and why (look at what
   the exponent does to sub-1 gaps)?
2. Write `near(t,row)`: the closest OTHER row, via
   `lst.keysort` over `Tbl.distx`. Print the best row by
   `disty` and its nearest neighbor -- are the neighbor's
   goals also good? Should they be?
]]

-- ## Stats
--[[
### Lesson 9: when are two results the same?

Lessons 10-13 will claim "method A beats method B". Such
claims need a stopping rule. This system calls two result
sets "the same" only when three cheap tests all agree: a
small effect size (Cohen), a small rank shift (Cliff's
delta), and close CDFs (Kolmogorov-Smirnov). Demanding
all three makes the equality conservative: we only shout
"different!" when it would take real effort to argue
otherwise. Note the lesson-1 payoff: all three run fast off
sorted lists and `bisect`.

**Core ideas:** [effect](../glossary.md#effect),
[ks](../glossary.md#ks), [same](../glossary.md#same)
]]
eg.stats = {}

-- - **stats.cliffs(xs,ys)** effect size 0..1 via lst.bisect
--   over pre-sorted lists (0 = identical).
-- - **stats.cohen(xs,ys)** |mean gap| <= 0.35 pooled sd?
-- - **stats.ks(xs,ys)** max gap between two sorted CDFs.
-- - **stats.same(xs,ys)** sorts copies once, then same unless
--   all three of the above see a difference.
eg.stats["--same"] = function(    a,b,c)
  a, b, c = {}, {}, {}
  for _ = 1, 32 do
    lst.push(a, rnd.n())
    lst.push(b, rnd.n())
    lst.push(c, 2 + rnd.n()) end
  print("same(a,b):", stats.same(a,b),
        " same(a,c):", stats.same(a,c))
  assert(stats.same(a, b) and not stats.same(a, c))
  a = lst.sort(a)                    -- cliffs,ks want sorted
  assert(stats.cohen(a, a))
  assert(stats.cliffs(a, a) == 0)
  assert(stats.ks(a, a) == 0) end

-- - **stats.top(dct,rev)** rank keys by their list's mean
--   (rev flips to descending); returns the leader plus every
--   key `same` as it.
eg.stats["--top"] = function(    t,got)
  t = {a={}, b={}, c={}}
  for _ = 1, 32 do
    lst.push(t.a, rnd.n())
    lst.push(t.b, 0.02 + rnd.n())
    lst.push(t.c, 2 + rnd.n()) end
  got = stats.top(t)
  print("top:", str.o(got))
  assert(#got == 2 and got[1] == "a" and got[2] == "b")
  got = stats.top(t, true)
  assert(#got == 1 and got[1] == "c") end

--[[
**Exercises (lesson 9).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Two 32-item samples of `rnd.n()`, the second
   shifted by +0.1, +0.5, +2. At which shift does
   `stats.same` first say false?
2. Repeat the previous exercise, but hunt the flip point: loop
   the shift from 0 upward in steps of 0.02 and report the
   smallest shift where same() fails, at n=32 and again at
   n=256. What does the difference teach about sample size?
]]

-- ## Acquire
--[[
### Lesson 10: labels cost money

The central economic fact of lesson 10: in most real tables,
the x values are cheap (they describe a thing) but the y
values are dear (someone must build, benchmark, or survey
the thing). So the game is to find good rows while LOOKING
AT as few y values as possible. The tactic here: project
rows onto a line between two far poles, keep the slice
nearest the good pole, repeat. A whole tree's worth of
labels for the price of a few dozen. The deeper game is
explore vs exploit: spend labels learning the landscape,
or harvesting its best-known corner?

**Core ideas:** [budget](../glossary.md#budget),
[active](../glossary.md#active), [poles](../glossary.md#poles),
[explore](../glossary.md#explore)
]]
eg.acquire = {}

-- - **acquire.project(rows,x,y)** maps rows onto the line
--   joining two far poles (good pole first): the heart of
--   every descent.
eg.acquire["--project"] = function(    t,x,y,rows,pr,p)
  t    = Tbl.new(the.file)
  y    = function(r) return t:disty(r) end
  x    = function(a,b) return t:distx(a,b) end
  rows = rnd.some(t.rows, 32)
  pr   = acquire.project(rows, x, y)
  p    = lst.keysort(rows, pr)
  print("y at the line's ends:", str.o(y(p[1])),
        str.o(y(p[#p])))
  assert(pr(p[1]) <= pr(p[#p])) end

-- - **acquire.top(tbl)** the labels, best first, spending at
--   most budget-check; inside, `sway3` repeats `descend`
--   (label a few, cull the slice nearest the bad pole) over
--   fresh shuffles till the budget spends.
eg.acquire["--top"] = function(    t,got,ys)
  t   = Tbl.new(the.file)
  got = acquire.top(t)
  ys  = lst.map(got, function(r) return t:disty(r) end)
  print("labels:", #got, " best:", str.o(ys[1]),
        " worst:", str.o(ys[#ys]))
  assert(#got <= the.budget - the.check)
  assert(ys[1] <= ys[#ys]) end

-- - **acquire.top(tbl)** with the.acquire=random is the
--   baseline: same budget, no steering.
eg.acquire["--random"] = function(    t,got,old)
  old, the.acquire = the.acquire, "random"
  t   = Tbl.new(the.file)
  got = acquire.top(t)
  print("random labels:", #got)
  assert(#got <= the.budget - the.check)
  the.acquire = old end

--[[
**Exercises (lesson 10).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Run `--top` with `--budget=20`, then 50, then
   100. Tabulate best disty against budget. Where do the
   gains flatten?
2. Twenty runs each (vary `--seed`): best disty from
   `--top` active vs `the.acquire=random`. Feed both lists
   to lesson 9's `stats.same`. Verdict: does steering beat
   luck on auto93, at budget 50?
]]

-- ## Bins
--[[
### Lesson 11: cut where it gets simpler

To explain y we chop x columns into bins, and score each
candidate chop by the size-weighted spread of the two
sides -- lower means the split made y easier to describe.
Two earlier ideas make this near-free: the lesson-4/5
`without` gives the far side of any cut in constant time,
and a tiny closure (`bins.keep`) remembers the best bin
seen so far, so all columns share one running competition.
Swap the y summary from Num to Sym and the same code stops
regressing and starts classifying.

**Core ideas:** [bins](../glossary.md#bins),
[cost](../glossary.md#cost), [closure](../glossary.md#closure)
]]
eg.bins = {}

-- - **bins.keep()** closure holding the running cheapest bin:
--   offer it (this,ys,at,v); call it bare for the winner.
-- - **Sym.bins/Num.bins(i,rows,y,yklass,keep)** offer bins
--   from one column (cost = size-weighted spread of the two
--   halves, the far half via `without`, never a second pass).
-- - **bins.split(tbl,rows,y,yklass)** cheapest {cost,at,v}
--   bin over all the x columns.
eg.bins["--split"] = function(    t,y,bin,col,keep,b1)
  t   = Tbl.new(the.file)
  y   = function(r) return t:disty(r) end
  bin = bins.split(t, t.rows, y, Num.new)
  col = t.cols.all[bin[2]]
  print("best bin:", col.txt, "at", str.o(bin[3]),
        "cost", str.o(bin[1]))
  assert(bin[1] >= 0 and col.at == bin[2])
  keep = bins.keep()             -- one column's private best
  t.cols.x[1]:bins(t.rows, y, Num.new, keep)
  b1 = keep()
  print("x1's own best:", t.cols.x[1].txt,
        "at", str.o(b1[3]), "cost", str.o(b1[1]))
  assert(b1[2] == t.cols.x[1].at)
  assert(bin[1] <= b1[1] + 1E-32) end  -- winner is no worse

--[[
**Exercises (lesson 11).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Call `col:bins(...)` per x column with a fresh
   `bins.keep()` each, printing every column's private best
   bin. Which column's winner matches `bins.split`'s?
2. Write `keep2()`, a closure like `bins.keep` that
   remembers the best TWO bins. Report whether first and
   second place come from the same column, and what that
   says about that column's importance.
]]

-- ## Tree
--[[
### Lesson 12: explanation as recursion

Apply lesson 11 once and rows split in two; apply it
recursively and a tree grows -- each node a readable test
(Volume <= 112), each leaf a small crowd of rows with a
prediction. Trees here serve two masters: prediction
(route a new row to a leaf, report its mid) and
EXPLANATION (print the branch conditions; a human can now
argue with the model). Note what we did not need: no
gradients, no pruning theory, just distance, bins, and
recursion.

**Core ideas:** [tree](../glossary.md#tree),
[predict](../glossary.md#predict),
[explain](../glossary.md#explain)
]]
eg.tree = {}

-- - **Tree.grow(tbl,rows,y,yklass)** recurses on the cheapest
--   bin while rows and depth allow; yklass=Num.new regresses,
--   yklass=Sym.new classifies.
-- - **Tree.leaf(i,row)** routes a row down to its leaf's mid.
-- - **Tree.leaves(i)** collects every leaf node.
-- - **Tree.show(i,tbl)** prints win, n, per-goal mids, then
--   indented branch conditions, best leaf flagged.
eg.tree["--grow"] = function(    t,tr)
  t  = Tbl.new(the.file)
  tr = Tree.grow(t, acquire.top(t))
  tr:show(t)
  assert(tr.col)                             -- root did split
  assert(#tr:leaves() > 1)
  assert(type(tr:leaf(t.rows[1])) == "number") end

--[[
**Exercises (lesson 12).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Grow with `--depth=2`, then `--depth=6`. Count
   leaves via `Tree.leaves`. Which tree would you hand to a
   manager, and what did the deeper one buy?
2. Write `path(tree,row)`: the list of "col op v"
   strings met walking a row to its leaf (reuse the node's
   col.txt, col.ops and v, as `Tree.show` does). Print the
   path of the best-disty row. That string IS the model's
   explanation of a good car.
]]

-- ## Score
--[[
### Lesson 13: grading the whole story

Capstone. `holdout` shuffles the rows, labels only the
train half under lesson 10's budget, grows lesson 12's tree,
lets the tree RANK the never-labelled test half, then
checks just the top few. `wins` grades the result: 100
means we found something as good as the best row in the
table; 0 means no better than the median. One number, tiny
budget, and every lesson of this course is inside it. Two
cautions: never trust one run (rerun across seeds, report
the spread), and remember that any such rig is a
falsifiable bet about your data's shape -- in recent
optimizer tournaments the winner changed with the budget.

**Core ideas:** [holdout](../glossary.md#holdout),
[win](../glossary.md#win), [baseline](../glossary.md#baseline),
[bets](../glossary.md#bets),
[variability](../glossary.md#variability)
]]
eg.score = {}

-- - **Tbl.wins(i)** grader: row -> % of the median-to-best gap
--   closed (100 = best seen, 0 = median).
-- - **Tbl.holdout(i)** the full rig: acquire labels on half the
--   rows, grow a tree, let it rank the unseen half, check only
--   the top few, return the best found.
eg.score["--holdout"] = function(    t,w)
  t = Tbl.new(the.file)
  w = t:wins()(t:holdout())
  print("holdout win:", w)
  assert(w >= -100 and w <= 100)
  if the.file:find"auto93" and the.seed == 1 then
    assert(w > 50) end end

-- - **Tbl.holdout/Tbl.wins** again, across five seeds: any
--   single run is a bet; the spread over reruns is the
--   learner's variability. Report distributions, not runs.
eg.score["--seeds"] = function(    t,num,w)
  t   = Tbl.new(the.file)
  num = Num.new()
  for seed = 1, 5 do
    rnd.seed(seed)
    w = t:wins()(t:holdout())
    io.write(w, " ")
    num:add(w) end
  print("| mu", str.o(num:mid()), "sd", str.o(num:spread()))
  assert(num.n == 5)
  assert(num:spread() >= 0)
  assert(num:mid() >= -100 and num:mid() <= 100) end

--[[
**Exercises (lesson 13).**

0. In your own favorite language (not lua), write
   just enough code to implement this section's
   examples.
1. (simple) Run `--holdout` at five seeds. Report the five
   wins. Stable? Fragile? One sentence on why holdouts
   need repeats.
2. The final exam: 20 holdout wins with active
   acquisition vs 20 with `the.acquire=random`. Compare via
   `stats.same` and print one verdict line, e.g.
   "active 88 random 74 DIFFERENT". Defend the verdict in
   a paragraph, citing lessons 9 and 10.
]]

-- ## Main
eg.main = {}

-- run one test, reseeded
local function run(fn) rnd.seed(the.seed); fn() end

-- flags of one section in SOURCE order, parsed from this
-- file: pairs() loses definition order, so tests would
-- otherwise run alphabetically, not in reading order.
local egsrc
local function keysof(name,    seen,out)
  egsrc = egsrc or io.open"xai-eg.lua":read"*a"
  seen, out = {}, {}
  for k in egsrc:gmatch('eg%.'..name..'%["(%-%-%w+)"%]') do
    if eg[name][k] and not seen[k] then
      seen[k] = true; lst.push(out, k) end end
  for k in pairs(eg[name]) do          -- any not found: append
    if not seen[k] then lst.push(out, k) end end
  return out end

-- run one section's tests, in source (reading) order
local function section(name)
  for _,k in ipairs(keysof(name)) do
    print("\n-- " .. k)
    run(eg[name][k]) end end

eg.main["-h"] = function()
  print(xai.help .. "\nSections (and their tests):\n")
  for _,n in ipairs(order) do
    print("  lua xai-eg.lua --" .. n .. "   # or: " ..
          table.concat(keysof(n), " ")) end
  print("\nAlso: --all -h --join --transcript --check")
  end

eg.main["--all"] = function()
  for _,n in ipairs(order) do
    print("\n---- " .. n .. " " .. ("-"):rep(40))
    section(n) end
  print("\nall pass") end

-- freeze the printed pedagogy: capture --all to xai-eg.out
-- (generated from a real run, never hand-edited). Student
-- ports self-grade against it; CI diffs it via --check.
eg.main["--transcript"] = function()
  assert(os.execute("lua xai-eg.lua --all > xai-eg.out"))
  print("xai-eg.out frozen") end

-- a fresh --all must reproduce the frozen transcript, so
-- any refactor that moves a graded number fails here first
eg.main["--check"] = function(    ok)
  ok = os.execute("lua xai-eg.lua --all | diff - xai-eg.out")
  print(ok and "transcript ok" or "TRANSCRIPT DRIFT")
  assert(ok) end

-- join checker: make the doc claims executable. Verifies
-- (1) every glossary link in a lesson lands on a matching
-- heading, and (2) every dot-list signature names a function
-- that exists in the module. The repo-wide "is every heading
-- taught by SOME course" check now lives in `make check`
-- (etc/join.py), since the glossary is shared across courses.
-- Also prints coverage: taught verbs / exported verbs.
-- walk "lst.push" through a table of tables; nil if absent
local function deref(root, name)
  for w in name:gmatch"[%w_]+" do
    root = type(root) == "table" and root[w] end
  return root end

eg.main["--join"] = function(    doc,src,keys,taught,
                                ok,n,total)
  doc = io.open"../glossary.md":read"*a"
  src = io.open"xai-eg.lua":read"*a"
  keys, taught, ok = {}, {}, true
  for k in doc:gmatch"\n## ([a-z]+)\n" do keys[k] = true end
  for k in src:gmatch"glossary%.md#([a-z]+)" do
    if not keys[k] then ok=false; print("no heading:",k) end end
  for line in src:gmatch"[^\n]+" do
    if line:find"^%-%- %- %*%*" then
      for sig in line:gmatch"%*%*([%w_./]+)%(" do
        for name in sig:gmatch"[%w_.]+" do
          if deref(xai, name) then taught[name] = true
          elseif not deref(_G, name) then    -- lua builtin?
            ok = false
            print("dot-list names missing fn:", name)
          end end end end end
  n, total = 0, 0
  for _ in pairs(taught) do n = n + 1 end
  for _,v in pairs(xai) do
    if type(v) == "function" then total = total + 1 end
    if type(v) == "table" and v ~= xai.the then
      for _,f in pairs(v) do
        if type(f) == "function" then
          total = total + 1 end end end end
  print(("coverage: %s taught / %s exported verbs"):format(
        n, total))
  assert(ok) end

-- cli, args left to right: --key=val (or "-x v", x = an
-- option's first letter) sets an option; --name runs a
-- section; other names run one test (--all and -h are
-- just tests in eg.main). Flags steer only the egs
-- that follow them.
local function cli(    k,v)
  for i,s in ipairs(arg) do
    k,v = s:match"^%-%-(%w+)=(%S+)$"
    if v then
      if the[k] == nil then error("unknown --" .. k) end
      the[k] = str.what(v) end
    for key,_ in pairs(the) do
      if s == "-" .. key:sub(1,1) then
        if not arg[i+1] then error(s .. " arg?") end
        the[key] = str.what(arg[i+1]) end end
    if eg[s:sub(3)] then section(s:sub(3))
    else
      for _,sect in pairs(eg) do
        if sect[s] then run(sect[s]) end end end end end

-- lua's "if __name__ == __main__": when run from the shell,
-- arg[0] is this script; when require'd, it is the caller's.
if arg and arg[0] and arg[0]:find"xai%-eg" then cli() end
return eg
