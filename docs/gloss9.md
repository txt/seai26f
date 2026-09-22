title: Glossary 9: SE for AI
icon: 🛰️
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 9

## Week 9: models and the seam

#### By [Tim Menzies](https://timm.fyi), published 2026-11-09, updated 2026-11-09

**Summary:** *The last piece: replace the csv with a MODEL.
Rows are born with "?" goals and disty buys them, one row at a
time, so the label count IS the experiment. DTLZ1-7 give us
problems whose true answers are known, so a search can be
graded exactly. Then the week's punchline: the classics spend
the whole pool; acquire spends 45 and lands in the same place.
Demos in [ezr-eg8.lua](ezr-eg8.html); machinery verbatim from
[ezr-dtlz.lua](ezr-dtlz.html).*

--- #week9

### When the goals cost money

---

New acronyms: DTLZ (Deb-Thiele-Laumanns-Zitzler test suite).

-

**model seam**: Everything so far read goals from a csv. The seam swaps that
for a FUNCTION: set *t.model* and rows may be born with *"?"*
goals, which *label* fills in on demand. Nothing
upstream changes &mdash; trees, acquire, holdout, the optimizers all
keep asking *disty* &mdash; which is the point of a seam.
This is where outsiders plug in their own (maybe very
expensive) simulator.

<pre><span class=k>function</span> <span class=f>Dtlz</span>(    u,r)<br>  u = {names()}<br>  <span class=k>for</span> _ = 1, the.pool <span class=k>do</span><br>    r = {}<br>    <span class=k>for</span> _ = 1, the.Nx <span class=k>do</span> push(r, rand()) <span class=k>end</span><br>    <span class=k>for</span> _ = 1, the.M  <span class=k>do</span> push(r, <span class=s>"?"</span>) <span class=k>end</span><br>    push(u, r) <span class=k>end</span><br>  u = Tbl(u)<br>  u.model = _ENV[the.model]<br>  <span class=k>return</span> u <span class=k>end</span></pre>

-

**dtlz**: The standard multi-objective test problems (Deb, Thiele,
Laumanns & Zitzler, 2002): x lives in [0,1]<sup>Nx</sup>, the
objectives have a KNOWN true front, and the difficulty is
dialable. The last Nx-M+1 variables set DISTANCE from the
front (make them zero and you are on it); the first M-1 set
POSITION along it. dtlz1's front is the plane &sum;f = 0.5,
approached across a landscape full of local traps; dtlz2's is
the unit sphere &sum;f<sup>2</sup> = 1; dtlz7's comes in disconnected
pieces. Because the answer is known, a search can be graded
exactly &mdash; which is what makes these problems the field's
measuring stick.

<pre><span class=k>function</span> <span class=f>dtlz1</span>(x,M,    g,f,v)<br>  g, f = g1(slice(x, M)), {}<br>  <span class=k>for</span> i = 0, M-1 <span class=k>do</span><br>    v = 0.5 * (1 + g)<br>    <span class=k>for</span> j = 1, M-1-i <span class=k>do</span> v = v * x[j] <span class=k>end</span><br>    <span class=k>if</span> i &gt; 0 <span class=k>then</span> v = v * (1 - x[M-i]) <span class=k>end</span><br>    push(f, v) <span class=k>end</span><br>  <span class=k>return</span> f <span class=k>end</span></pre>

-

**lazy labels (the sharpening ruler)**: A subtle consequence of buying goals one at a time: *disty*
normalizes each goal against the column summary, and that
summary only knows the labels bought so far. So the SAME row
can score differently early and late &mdash; the ruler sharpens as
spending grows. This is a feature, not a bug: with five labels
you do not know the range of the world, and pretending
otherwise is how leakage sneaks in. It also means any reported
score must say how many labels were in hand when it was taken.

-

**baseline**: What does doing nothing get you? *baseline* calls the model on
every row and reports each goal's mean &mdash; deliberately NOT
folding those calls into the column summaries, so the baseline
never sharpens the ruler it is measured against. Every claim in
this course is "better than X"; *baseline* is the cheapest
honest X.

<pre><span class=k>function</span> <span class=f>TBL.baseline</span>(i,    nums,f)<br>  nums = map(i.cols.y, <span class=k>function</span>() <span class=k>return</span> Num() <span class=k>end</span>)<br>  <span class=k>for</span> _,r <span class=k>in</span> ipairs(i.rows) <span class=k>do</span><br>    f = i.model(map(i.cols.x,<br>          <span class=k>function</span>(c) <span class=k>return</span> r[c.at] <span class=k>end</span>), #i.cols.y)<br>    <span class=k>for</span> j,v <span class=k>in</span> ipairs(f) <span class=k>do</span> nums[j]:add(v) <span class=k>end</span> <span class=k>end</span><br>  <span class=k>return</span> map(nums, <span class=s>"mid"</span>) <span class=k>end</span></pre>

-

**pure vs generalize**: Two ways to report the same search. PURE (*--pure*): spend the
budget over the whole pool and report the best row found &mdash; the
right number when you own every row and just want the best one
(config tuning, say). GENERALIZE (*--generalize*): spend on
half, then pick from the half never seen &mdash; the right number
when tomorrow's rows are not today's. Pure scores flatter.
Say which one you ran; papers that do not are hiding the
difference.

-

**the price of a label**: The week's punchline, from *ezr-eg8.lua --race* on a 200-row
DTLZ2 pool: the four classic optimizers between them buy
around 200 labels &mdash; effectively the whole pool &mdash; while
*acquire* buys 45 and lands at the same place or
better. Neither result says the classics are bad; they say the
classics were designed for cheap models. The question to carry
into any project is not "which optimizer is best" but "what
does one evaluation cost here, and how many can I afford?"

@ [Deb, Thiele, Laumanns & Zitzler: Scalable multi-objective optimization test problems](https://doi.org/10.1109/CEC.2002.1007032). Kalyanmoy Deb, Lothar Thiele, Marco Laumanns, Eckart Zitzler. CEC 2002, 825-830.

@ [Chen, Nair, Krishna & Menzies: Sampling as a baseline optimizer for search-based software engineering](https://doi.org/10.1109/TSE.2018.2790925). IEEE TSE 45(6), 2019, 597-614.

.
