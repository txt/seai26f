title: Glossary 4: SE for AI
icon: 🌳
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 4

## Week 4: cuts, trees, and explanation

#### By [Tim Menzies](https://timm.fyi), published 2026-09-07, updated 2026-09-07

**Summary:** *Week 3 grouped rows by geometry
([glossary 3](gloss3.html)). This week we ask a business
question of the groups: WHICH single test &mdash; which column,
cut where &mdash; best separates good from bad? Answer that
recursively and you get a decision tree small enough to read
aloud, which is this course's idea of explainable AI. Machinery
verbatim from [ezr.lua](ezr.html) and
[ezr-lib.lua](ezr-lib.html); each entry a tiny lecture: hook,
idea, math if any, then the code.*

--- #week4

### Cuts, trees, XAI

---

New acronyms: XAI.

-

**cut**: One test on one x column: numbers split at a threshold
(*x &le; v*), symbols split by equality (*x == v*) &mdash; the
*holds* slot of the columnProtocol (glossary 1). A good cut is
one whose two sides are each more SETTLED about y than the
whole was: split on "cylinders &le; 4" and maybe the light,
thrifty cars land on one side and the tanks on the other. The
craft is scoring thousands of candidate cuts, cheaply.

-

**val (expected diversity)**: How good is a cut? Summarize y on
each side, ask each summary its diversity (*div*: sd for
numbers, entropy for symbols &mdash; glossary 1), and take the
size-weighted mean. Lower is better: a low val says both sides
have (mostly) made up their minds.

<pre><span class=k>function</span> <span class=f>val</span>(a,b)<br>  <span class=k>return</span> (a:div()*a.n + b:div()*b.n) / (a.n + b.n + TINY) <span class=k>end</span></pre>

Note what this does NOT ask: whether y is numeric or symbolic.
Any summary answering *div* can play, so the same tree code
will handle regression, classification, and (via disty)
multi-objective optimization. The protocol keeps paying.

@ [Quinlan: Induction of decision trees](https://doi.org/10.1007/BF00116251). J.R. Quinlan. Machine Learning 1 (1986), 81-106.

-

**one-pass cuts**: A numeric column with n distinct values
offers n-1 cuts. Score each by rebuilding two summaries and
that is O(n&sup2;). Instead: sort the (x,y) pairs once, then
walk left to right, ADDING each y to a growing left summary
&mdash; and the right summary is just *tot - here*, by the pool
algebra of glossary 2. Every cut scored in one linear pass;
this is why week 1 insisted summaries must subtract.

<pre><span class=k>function</span> <span class=f>NUM.cuts</span>(c,xy,tot,acc,best,    here)<br>  table.sort(xy, <span class=k>function</span>(a,b) <span class=k>return</span> a[1] &lt; b[1] <span class=k>end</span>)<br>  here = acc()<br>  <span class=k>for</span> j,p <span class=k>in</span> ipairs(xy) <span class=k>do</span><br>    here:add(p[2])<br>    <span class=k>if</span> j &lt; #xy <span class=k>and</span> p[1] ~= xy[j+1][1] <span class=k>and</span> big(j, #xy) <span class=k>then</span><br>      best{val(here, tot - here),c.at,p[1]} <span class=k>end</span> <span class=k>end</span> <span class=k>end</span></pre>

Two guards ride along: cuts only fall between DISTINCT sorted
values, and *big* refuses any cut leaving fewer than *the.leaf*
rows on either side &mdash; tiny splits are memorization
wearing a costume.

<pre><span class=k>function</span> <span class=f>big</span>(lo,n)<br>  <span class=k>return</span> the.leaf &lt;= lo <span class=k>and</span> lo &lt;= n - the.leaf <span class=k>end</span></pre>

-

**least (the champion closure)**: Thousands of candidate cuts,
and no list of them is ever built. *least* returns a closure
holding one thing: the best candidate seen so far. Call it with
a candidate to offer one; call it empty to read the winner.

<pre><span class=k>function</span> <span class=f>least</span>(    lo)<br>  <span class=k>return</span> <span class=k>function</span>(x)<br>    <span class=k>if</span> x <span class=k>and</span> (lo == <span class=k>nil</span> <span class=k>or</span> x[1] &lt; lo[1]) <span class=k>then</span> lo = x <span class=k>end</span><br>    <span class=k>return</span> lo <span class=k>end</span> <span class=k>end</span></pre>

Every column feeds its cuts to the same reducer; the champion
rides in the closure (glossary 2, again). Streaming style: O(1)
memory over any number of candidates.

<pre><span class=k>function</span> <span class=f>TBL.bestcut</span>(i,rows,Y,acc,best)<br>  <span class=k>for</span> _,c <span class=k>in</span> ipairs(i.cols.x) <span class=k>do</span> i:cuts(rows,c,Y,acc,best) <span class=k>end</span><br>  <span class=k>return</span> best() <span class=k>end</span></pre>

-

**tree**: Take the champion cut, divide the rows into yes and
no, recurse on each side; stop at *the.maxd* levels or when a
side gets small. Each node remembers its cut, its rows, and its
loss. By default *Y* is disty, so this tree does multi-objective
optimization &mdash; but hand it any Y and any accumulator and
the same dozen lines do classification or regression.

<pre><span class=k>function</span> <span class=f>Tree</span>(tbl,rows,Y,acc,    recurse)<br>  <span class=k>function</span> <span class=f>recurse</span>(rows,lvl,    ys,t,b,c,yes,no)<br>    ys = adds(map(rows, Y), acc())<br>    t  = new(TREE, {at=<span class=k>nil</span>, v=<span class=k>nil</span>, mu=ys:mid(), leafs=1,<br>                    here = tbl:clone(rows),<br>                    loss = ys.has <span class=k>and</span> ys:div() <span class=k>or</span> ys:mid()})<br>    t.val = t.loss<br>    <span class=k>if</span> #rows &gt;= 2*the.leaf <span class=k>and</span> lvl &lt; the.maxd <span class=k>then</span><br>      b = tbl:bestcut(rows, Y, acc, least())<br>      <span class=k>if</span> b <span class=k>then</span><br>        c = tbl.cols.all[b[2]]<br>        yes, no = tbl:divide(rows, c, b[3])<br>        <span class=k>if</span> #yes &gt; 0 <span class=k>and</span> #no &gt; 0 <span class=k>then</span><br>          t.at, t.v = b[2], b[3]<br>          t.yes   = recurse(yes, lvl+1)<br>          t.no    = recurse(no,  lvl+1)<br>          t.val   = min(t.yes.val, t.no.val)<br>          t.leafs = t.yes.leafs + t.no.leafs <span class=k>end</span> <span class=k>end</span> <span class=k>end</span><br>    <span class=k>return</span> t<br>  <span class=k>end</span> <span class=c>-- recurse</span><br>  Y   = Y <span class=k>or</span> tbl:Y()<br>  acc = acc <span class=k>or</span> Num<br>  <span class=k>return</span> recurse(rows, 0) <span class=k>end</span></pre>

To predict for a new row, walk it down and answer the leaf's
mean:

<pre><span class=k>function</span> <span class=f>TREE.leaf</span>(t,tbl,row,    c)<br>  <span class=k>while</span> t.at <span class=k>do</span><br>    c = tbl.cols.all[t.at]<br>    t = c:holds(row[t.at], t.v) <span class=k>and</span> t.yes <span class=k>or</span> t.no <span class=k>end</span><br>  <span class=k>return</span> t.mu <span class=k>end</span></pre>

-

**XAI (explainable AI)**: An explanation is a model small
enough to argue with. A tree of depth four is a paragraph:
"under these tests, these rows; the best leaf is here." ezr's
tree printer works for that arguability: one row per node,
each goal's mean in its own column, best leaf marked with a
triangle, and siblings printed better-branch-first so the top
of the page is always the way to heaven. Contrast the rival
offer &mdash; a black box plus an after-the-fact rationale.
When the model itself is small, the model IS the explanation,
and a business user can push back on any line of it ("three
developers, not seven" is an arguable sentence; a weight
matrix is not).

@ [Rudin: Stop explaining black box machine learning models for high stakes decisions and use interpretable models instead](https://doi.org/10.1038/s42256-019-0048-x). Cynthia Rudin. Nature Machine Intelligence 1 (2019), 206-215.

.
