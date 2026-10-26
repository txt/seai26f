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

# Mid-term exam (24 marks)

**Mon Oct 12. 60 minutes. Eight questions; do ALL EIGHT** (about
7 minutes each).

Each question is worth 3 marks:

- **(a) 1 mark** — a short recall answer.
- **(b) 2 marks** — the code shown contains one bug. Name the bug
  and say what happens if it persists — what the program does,
  and what that does to any results built on it (1 mark); then,
  **in English, no code**, say how to fix it (1 mark).

The code is Lua, in the style of the weekly ezr files. If you did
the weekly ports, you have met every function here.

**On every page you submit**, write at the top right: your name,
the last digits of your student ID, and "page M of N" (where N is
the total number of pages you hand in).

**Q1 — the optimistic unknown**

a) When a distance function meets a missing value, what does this
course assume about it, and why assume the worst rather than
something typical?

b) An LLM flips the assumption, arguing "an unknown is probably
an ordinary value":

```lua
function NUM.dist(i,a,b)
  if a == "?" and b == "?" then return 1 end
  a, b = i:norm(a), i:norm(b)
  if a == "?" then a = b > 0.5 and 1 or 0 end
  if b == "?" then b = a > 0.5 and 1 or 0 end
  return abs(a - b) end
```

Which rows now look like everybody's near neighbor, and what
happens to every structure built on top of them?

**Q2 — the repeat that never varied**

a) What does `srand(the.seed)` guarantee about the numbers that
follow it, and why does this course's harness reset the seed
before every demo?

b) A student wraps their optimizer so every call is "reproducible",
then runs 20 repeats to measure variability:

```lua
function run(opt, data)
  srand(the.seed)
  return opt(data) end

for r = 1, 20 do
  out[r] = run(opt, data) end

sd = Num(); for _,v in pairs(out) do sd:add(v) end
print("variability:", sd:div())
```

**Q3 — the forget that remembered**

a) Welford's incremental update lets a Num do two things that a
rebuild-from-scratch summary cannot. What are they?

b) One token is missing:

```lua
function NUM.add(i,v,inc,    d)
  if v == "?" then return v end
  inc  = inc or 1
  i.n  = i.n + inc
  d    = v - i.mu
  i.mu = i.mu + inc * d / i.n
  i.m2 = i.m2 + d * (v - i.mu)
  return v end
```

(Hint: check it against the law `(a + b) - b == a`.)

**Q4 — the distance that peeked**

a) Which columns may `distx` read, and which does `disty` read?
Why does this course treat those two groups of columns so
differently?

b) An LLM "generalizes" the distance function:

```lua
function TBL.distx(i,row1,row2)
  return minkowski(i.cols.all, function(c)
           return c:dist(row1[c.at], row2[c.at]) end) end
```

Nothing crashes, and clustering scores IMPROVE. Explain.

**Q5 — the pole picked from nowhere**

a) Describe how fastmap finds its two poles, and say how many
labels one call to `poles` spends.

b) A student simplifies the pole hunt:

```lua
function TBL.poles(i,rows,    lo,hi)
  lo = i:far(rows[rand(#rows)], rows)
  hi = rows[rand(#rows)]
  if i:disty(lo) > i:disty(hi) then lo, hi = hi, lo end
  return i:project(lo, hi) end
```

**Q6 — the entropy that went under zero**

a) In the twenty-questions reading of entropy: what is the
entropy of the bag {a,a,a,a}, and of the bag {a,b,c,d}, in bits?

b) A port drops one character. What does this return for a fair
coin, and — since the tree keeps the cut whose `val` is LOWEST —
which cuts does the tree now prefer?

```lua
function SYM.div(i)
  return sum(i.has, function(n,    p)
    p = n / i.n
    return p * log(p) / log(2) end) end
```

**Q7 — the restart that aimed at second place**

a) In active learning, why does `acquirer` restart its descent
several times instead of descending once?

b) Each restart is anchored at the best and worst rows labelled
so far (`lab`, sorted below by distance-to-heaven; `lo` must be
the anchor nearer heaven). Two indexes got swapped. Which half
does every descent now keep, and what does the final "best"
answer look like?

```lua
t = keysort(lab, i:Y())
lo, hi = t[#t], t[1]
return i:descend(lo, hi)
```

**Q8 — the holdout that held still**

a) In a holdout experiment, why must the model never be scored on
rows it trained on?

b) A hospital data set lists one clinic's patients, then the
next clinic's, and so on. A student measures their learner:

```lua
function holdout(rows,    train,test)
  train = slice(rows, 1, 256)
  test  = slice(rows, 257, #rows)
  return train, test end

for r = 1, 20 do
  train, test = holdout(t.rows)
  score[r] = eval(learn(train), test) end
```

## Marker's key

**A1.**
a) Unknowns assume the worst: a missing value is pushed to
whichever end is further from the known one, so ignorance can
only make rows look farther apart (the Aha heuristic). Assuming
a typical value manufactures similarity there is no evidence
for.
b) The bug: the comparisons are flipped, so the unknown is
pushed to the NEAR end — its distance contribution is now always
small. Rows dense with "?" cells look close to everything, so
they become everyone's near neighbor: they get chosen as poles,
they glue clusters together, and splits form around shared
ignorance rather than shared structure. Nothing crashes; the
data just looks friendlier than it is, and every tree, cluster
and ranking built on those distances is fantasy. Fix, in
English: push the unknown to whichever extreme is FURTHER from
the known value, so missing data can only ever increase a
distance, never shrink it.

**A2.**
a) Same seed, same stream of "random" numbers, same result —
experiments become replayable, debugging becomes replay, and a
port can be graded by diff. The harness resets per demo so each
demo's result is independent of which demos ran before it.
b) The bug: the reseed sits inside `run`, so every one of the 20
repeats replays an identical stream. All 20 "repeats" return the
same number, the reported variability is 0, and any statistics
over those repeats (sd, significance tests, "our method is
stable") are fiction. Fix, in English: seed once, before the
repeat loop, so each repeat continues the stream and gives an
independent sample; keep per-demo reseeding only at the harness
level.

**A3.**
a) One pass over a stream (no stored data — just n, mu, m2), and
it runs backwards: `inc=-1` forgets a value in O(1), which is
what makes pool algebra (subtracting summaries, one-pass cut
scoring) possible.
b) The bug: the `m2` line lost its `inc`. Adding still works
(`inc=1` multiplies by 1), but on forget, n and mu roll back
while m2 GROWS — both `d` and `(v - i.mu)` have the same sign, so
the increment is positive either way. sd inflates every time
anything is forgotten: `(a+b)-b == a` fails, the `--sub`
round-trip fails, and every tree built with subtract-style cut
scoring (right = total − left) ranks cuts with wrong
diversities. Fix, in English: multiply the second-moment
increment by `inc` as well, so m2 rolls back by exactly what it
rolled forward.

**A4.**
a) `distx` reads only the x columns (cheap observables, free with
every row); `disty` reads only the y columns (goals — labels that
cost money: a test drive, an interview, a build-and-test run).
The whole economics of the course is spending many x operations
to avoid a few y ones.
b) The bug: mapping over `cols.all` means the "x" distance now
reads the goal columns. Scores improve because that is leakage —
the clustering consults the answers, so structure lines up with
the labels we claim not to have paid for. Every result is
inflated and unreproducible in deployment, where new rows arrive
with `"?"` goals — and there the Aha rule pushes every
unknown-goal distance to maximum, so the geometry that looked
great in training quietly changes shape in use. Fix, in English:
the distance must map over the x columns only; goals may be read
by disty alone, and only when a label has been paid for.

**A5.**
a) Pick a random row; the row furthest from it is the first pole.
The row furthest from the FIRST POLE is the second pole. Two far
sweeps, then one disty comparison per pole to point `lo` at
heaven: two labels per call.
b) The bug: the second pole is a random row, not the row furthest
from the first pole. The poles can be neighbors — even the same
row — so the pole-to-pole distance c is tiny, the projection
divides by almost nothing, and the sort order of rows along the
line is noise. Nothing crashes: halving still "works", but each
level culls a near-random half while still spending two real
labels, so the search pays full price for guesses. Fix, in
English: after the first far sweep finds pole one, run the
second far sweep FROM pole one; the second pole must be the row
furthest from the first.

**A6.**
a) 0 bits (nothing to ask) and 2 bits (two yes/no questions).
b) The bug: the minus sign is gone. Every term `p·log2(p)` is
zero or negative, so a fair coin scores −1 bit and the most
mixed bags score LOWEST. Since the tree keeps the lowest `val`,
it now prefers the muddiest cuts it can find: trees actively
seek confusion, and training quality falls apart while nothing
crashes. Fix, in English: restore the sign convention — negate
the sum (or equivalently take the log of 1/p), one or the
other, never both.

**A7.**
a) Because the pool dries out before the budget does: each
descent is a log-n chop that reaches a tiny leaf with labels
still in hand, so the search reshuffles and descends again,
reusing every label paid for so far.
b) The bug: the anchors are swapped — `lo` (the pole the descent
keeps) is now `t[#t]`, the WORST row labelled so far. Every
restart confidently culls toward hell: each level keeps the half
nearer the worst pole, so the search spends its whole label
budget walking away from heaven, and the final "best" is among
the worst rows in the data — reported with a straight face,
since nothing crashes. Fix, in English: point `lo` at the front
of the sorted list and `hi` at the back, so the kept half leans
toward heaven; better, keep the disty guard that re-swaps the
poles if they ever arrive backwards.

**A8.**
a) Because a model scored on its own training rows describes the
past, not the future: it can memorize those rows, so the score
says nothing about new data. Train and test must stay apart.
b) The bug: no shuffle before the split. Two consequences: (1)
with the file grouped clinic by clinic, train is some clinics
and test is others, so the score measures the gap between
clinics, not the learner; (2) every one of the 20 "repeats"
makes the identical split, so the variability across repeats is
0 and any statistics over them are fiction. Fix, in English:
shuffle the rows — with the seeded random number generator, so
the experiment stays replayable — before every split, so each
repeat gets a different, representative train/test pair.
