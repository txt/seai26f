<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951&bp=s"><img 
      src="https://img.shields.io/badge/491%20Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=13665&bp=sfroge"><img 
      src="https://img.shields.io/badge/591%20Moodle-%23f98012?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://ncsu.hosted.panopto.com/Panopto/Pages/Sessions/List.aspx#folderID=a8560b36-2071-4a70-8c3a-b4a4017e9ff5"><img 
      src="https://img.shields.io/badge/Recordings-%236f42c1?style=flat-square&logo=youtube&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

# Week 2 lecture: every code example, with notes

Reconstructed from the Aug 24 transcript. Two sections: the
Python examples, then the Lua. Each: the code as spoken (or as
it lives in the repo), plus the tutorial point it carried.

## Python examples

**P1. Generator expressions: one pass, O(1) memory.**

```python
max(x/2 for x in [10, 20, 30])     # 15.0 -- no [] needed
```

Looks like a typo (where are the square brackets?) but Python
accepts a bare generator. A list comprehension builds the whole
list, then maxes it: two passes, memory for everything. The
generator hands `max` one value at a time: one traversal,
memory for one item — so it can process an infinite stream.

**P2. Streaming a file with yield.**

```python
def csv(file):
  for line in open(file):
    yield line
```

Same trick at file scale: return the whole file and you need
memory for the whole file; `yield` reads it line by line by
line. This is how you stream a 100,000-line file — or an
infinite source.

**P3. List comprehensions: newbie vs old person.**

```python
# newbie
out = []
for i in [10, 20, 30]:
  out.append(i/2)
return max(out)

# old person (they don't have much time left)
max(i/2 for i in [10, 20, 30])

# with a filter
[i/2 for i in [10, 20, 30] if i < 25]   # [5.0, 10.0]
```

No initialization, no append ceremony; the filter clause reads
almost like a specification. Homework was literal: go home
tonight and look up list comprehensions.

**P4. Walking a dictionary three ways.**

```python
d = {"a": 1, "b": 2}
for k    in d:          ...   # keys:   a, b
for v    in d.values(): ...   # values: 1, 2
for k, v in d.items():  ...   # pairs:  ("a",1), ("b",2)
```

`items()` is Python's nearest thing to the Lua `kap` (map over
keys AND values, not just values).

**P5. copy vs deepcopy: the horror of hidden references.**

```python
import copy
b = a[:]               # shallow: new list, same items
b = copy.deepcopy(a)   # recursive: new everything
```

A list of people is a list of pointers to people; copy the list
and both lists point at the same people — mutate through one,
the other sees it. Shallow copies the top; deepcopy recurses
(and costs the memory). The slice `a[:]` is the idiomatic cheap
shallow copy.

**P6. Lambda: functions are values.**

```python
f = lambda x: 2*x
f(3)                        # 6
sum(f(x) for x in [1,2,3])  # 12
```

An anonymous function in a variable — a first-class function.
(Python's lambda bodies are impoverished: one expression only.
Lua's are not; see L2.)

**P7. sorted, and the open-closed principle.**

```python
sorted(l, reverse=True)
sorted(l, key=lambda x: -x)          # same, via the key
sorted(emps, key=lambda e: e.age)    # sort employees by age
sorted(emps, key=lambda e: e.salary) # ...by salary: sort unchanged
```

`sorted` is closed (highly optimized — Timsort; do not mess
with it) but open to control through the key function. Passing
a function into a function is how you re-aim machinery you must
not modify.

**P8. round — and reporting numbers like an adult.**

```python
round(0.87655, 2)   # 0.88
```

Your lecturer gets very angry at tables full of 0.83765555. You
do not have that level of experimental control; everything past
two-ish digits is spurious. Round before you report.

**P9. Mode of a dictionary — "a work of art".**

```python
max(d, key=d.get)
```

The mode is the key with the biggest count: `max` walks the
keys, ranking each by `d.get(key)`. If you get this one, give
yourself a tick and buy Python dinner. (Same job in Lua takes a
loop: L10.)

**P10. Heaven from a boolean.**

```python
heaven = 1 - (name[-1] == "-")   # True is 1, False is 0
```

Python booleans really are 0/1, so arithmetic on a comparison
is legal: trailing `-` (minimize) gives heaven 0, else 1.

**P11. The 101.py machine: docstring, regx, argv, seed.**

```python
pat = r"--(\w+)\s+[^=\n]*=\s*(\S+)"    # scrape the docstring

for a in sys.argv[1:]:
  if a[:2]=="--" and "=" in a:
    k,v = a[2:].split("=",1)
    if k in vars(the): setattr(the, k, thing(v))
for a in sys.argv[1:]:
  if (n := "test_"+a) in funs:
    random.seed(the.seed); funs[n]()
```

One string is help text, config, and documentation (SSOT); a
regx scrapes `key = default` pairs out of it (mechanism reads
policy). argv walks twice: flags update settings, then names
run tests — and the seed resets before every test.

**P12. environ: config from outside the code.**

```python
os.environ.get("MOOT")
```

Never hardwire `/Users/timm`; talk to `$HOME`, `$PATH`, `$MOOT`.
One default can live per-machine, outside the code.

## Lua examples

**L1. Append, the Lua way.**

```lua
u[1+#u] = v
```

`#u` is the list's size; empty list, `#u` is 0, so the next item
lands at 1. That one expression is Lua's `append`.

**L2. fun: a name or an index becomes a function.**

```lua
function fun(f)
  if type(f)=="string" then
    return function(v,...) return v[f](v,...) end end
  if type(f)=="number" then return function(v) return v[f] end end
  return f end
```

Map `"fred"` down a list of records and get everyone's fred;
map `6` down nested lists and get each sixth item. Higher-order
functions plus the open-closed principle, home-made.

**L3. map vs kap.**

```lua
map(t, f)   -- f(v)   over the values
kap(t, f)   -- f(k,v) over keys and values
```

kap's Python cousin is a comprehension over `d.items()` (P4).

**L4. sum through a function.**

```lua
function sum(t,f,    n)
  n = 0; for _,v in pairs(t) do n = n + f(v) end; return n end
```

Lua is not batteries-included: no built-in sum, so you write
your four-liner once. Some people prefer Python for its vast
libraries; some prefer Lua for exactly the same reason.

**L5. The pretty-printer that keeps Menzies sane.**

```lua
function round(v,n)
  if v % 1 == 0 then return floor(v) end
  n = 10 ^ (n or the.round)
  v = floor(v * n + 0.5) / n
  return v % 1 == 0 and floor(v) or v end
```

Lua has no rounding builtin, so this exists — a descent through
nested tables shortening every number it finds (3.0 prints as
3). Written so no student ever hands in 0.83765555 (see P8).

**L6. Tables: arrays, dictionaries, and the # trap.**

```lua
t = {10, 20, 30}          -- t[1]==10; #t == 3; 1-indexed
u = {name="tim", age=9}   -- u[1]==nil; #u == 0
```

Consecutive integer keys: `#` gives the size you expect. Symbol
keys: `#` says 0. Mix them and `#` lies. Please do not mix your
dictionaries and your arrays.

**L7. The eg table: demos as data.**

```lua
eg["--col"] = function(_) ... end
```

A table of lambda bodies keyed by command-line flags: find the
key in argv, run the function. Beautifully succinct. Your
Python port spells the same idea `def test_col()` found by name
— same dispatch, different dialect (P11).

**L8. run: reseed, trap, dump, continue.**

```lua
function run(funs,w,    ok,msg)
  srand(the.seed)
  if funs[w] then
    ok, msg = xpcall(funs[w], debug.traceback)
    if not ok then print(msg) end
    return ok end end
```

Two lessons. (1) The seed resets before EVERY example — put
that reset two lines too high, outside the loop, and you can
lose two years of experiments to accidentally-identical
"random" runs. (2) `xpcall` is Lua's try/except: a crashing
test prints its stack dump and the suite keeps going.

**L9. Scraping settings with Lua patterns.**

```lua
for k,v in help:gmatch("[-][-]([%a%d]+)[^=]+= ([%S]+)") do
  the[k] = coerce(v) end
```

Lua patterns use `%` where Python uses `\`: `%w`≈`\w`,
`%s`≈`\s`, `%S`≈`\S`; `^`/`$` anchor, `[^=]` means "not an
equals". One line turns the help text into the config table —
the same SSOT trick as P11, in the other language.

**L10. Column kinds, and heaven, off row 1.**

```lua
function Col(name,at)
  return (name:find"^%l" and Sym or Num)(name,at) end

heaven = name:find"-$" and 0 or 1
```

Lowercase first letter: Sym; uppercase: Num (noir, collapsed to
two scales). Trailing `-`: minimize, so heaven (best normalized
value) is 0; else 1. The header row is the entire schema —
mechanism reads policy.

**L11. Num and Sym: three numbers, or a histogram.**

```lua
function Num(name,at)
  name = name or ""
  return new(NUM, {at=at or 1, name=name, n=0, mu=0, m2=0,
                   heaven = name:find"-$" and 0 or 1}) end

function Sym(name,at)
  return new(SYM, {at=at or 1, name=name or "", n=0, has={}}) end
```

A Num keeps count, mean, second moment — never the data. A Sym
keeps counts of what it saw. Both know their column position
and name.

**L12. Welford: the mean walks toward each newcomer.**

```lua
function NUM.add(i,v,inc,    d)
  if v == "?" then return v end
  inc  = inc or 1
  i.n  = i.n + inc
  d    = v - i.mu
  i.mu = i.mu + inc * d / i.n
  i.m2 = i.m2 + inc * d * (v - i.mu); return v end
```

The intuition: each new person through the door pulls the mean
toward themselves by the gap divided by n — the millionth
barely moves it. The second moment updates the same one-pass
way (the textbook sd formula needs two passes: one for the
mean, one for the gaps). And `inc=-1` runs it backwards:
streams you can remember AND forget, which is why this code
runs orders faster than learners that rebuild from scratch.
`"?"` (missing) aborts early, everywhere.

**L13. SYM.add and the incremental mode.**

```lua
function SYM.add(i,v,inc)
  if v == "?" then return v end
  inc = inc or 1
  i.n = i.n + inc
  i.has[v] = inc + (i.has[v] or 0)
  if i.has[v] <= 0 then i.has[v] = nil end
  return v end
```

Bump a count (or, with `inc=-1`, un-bump it). Mid of a Sym is
the biggest count's key — one loop in Lua, one work-of-art line
in Python (P9).

**L14. Entropy: the effort to find the elephants.**

```lua
function SYM.div(i)
  return sum(i.has, function(n,    p)
    p = n / i.n
    return -p * log(p) / log(2) end) end
```

Fold a paper strip until each animal is isolated: something
filling p of the strip takes log2(1/p) folds to find, and you
look for it with probability p. Sum that over the symbols:
Shannon's entropy, the mean effort to recreate the signal — the
most beautiful mathematics of the 20th century, and a Sym's
answer to "how diverse are you?" (a Num answers sd).

**L15. norm: the CDF as a universal 0..1 ruler.**

```lua
function NUM.norm(i,v,    z)
  if v == "?" then return v end
  z = (v - i.mu) / (i:div() + TINY)
  return 1 / (1 + exp(-1.702 * max(-3, min(3, z)))) end
```

The PDF says how likely each value is; the CDF says how much of
the distribution you have met by x (0 below the min, 1 above
the max). This logistic approximates the normal CDF; the
max/min clamp to ±3 sd tames crazy tails ("dude, chill").
Later, discretization rides free: floor(bins * norm(x)) gives
roughly equal-frequency bins.

**L16. csv, five lines — the homework.**

```lua
function csv(file,    f)
  f = io.open(file)
  return function(    s)
    s = f:read()
    if s then return cells(s) else f:close() end end end
```

Pandas is amazing — but do you always need it? (Likewise: LLMs
are amazing, but do you always need them?) Week-2 homework:
have Claude pull the ~80 lines of Lua this needs from Tim's
600, port to Python classes Num and Sym, wire `test_` functions
until `--all` runs clean.
