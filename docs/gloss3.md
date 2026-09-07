title: Glossary 3: SE for AI
icon: 🧭
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 3

## Week 3: clustering by poles

#### By [Tim Menzies](https://timm.fyi), published 2026-09-07, updated 2026-09-07

**Summary:** *Week 2 built distance ([glossary 1](gloss1.html));
this week distance buys structure, found without labels. Two
sweeps find the far poles of the data; the cosine rule projects
every row onto the line between them; a median split makes two
halves; recursion makes a tree. The demos are
[ezr-eg3.lua](ezr-eg3.html); the machinery below is verbatim
from [ezr.lua](ezr.html). Same deal as always: each entry is a
tiny lecture &mdash; hook, idea, math if any, then the code.*

--- #week3

### Clustering by poles

---

New acronyms: none.

-

**cluster**: Learning without labels. Before anyone will pay
for a single y value, the x columns are already free &mdash; so
group rows by x-distance and structure appears: rows that sit
together tend to behave together. Clustering is how this code
spends its unlabelled riches; the only question is how to split
a table cheaply. The classic answers (k-means and friends)
sweep the data many times chasing centroids. This code splits
once, on two rows.

-

**fastmap**: How do you find the two most separated rows? The
honest way compares everything to everything: O(n&sup2;)
distance calls. The fastmap trick gets close for O(2n): pick
any row at random; its farthest neighbor is pole one; pole
one's farthest neighbor is pole two. Two sweeps, and you hold
(roughly) the longest line through the data.

<pre><span class=k>function</span> <span class=f>TBL.poles</span>(i,rows,lo,hi,    far,c)<br>  far = <span class=k>function</span>(r,    t)<br>          t = keysort(rows, <span class=k>function</span>(z) <span class=k>return</span> i:distx(z, r) <span class=k>end</span>)<br>          <span class=k>return</span> t[#t] <span class=k>end</span><br>  lo = lo <span class=k>or</span> far(rows[rand(#rows)])<br>  hi = hi <span class=k>or</span> far(lo)<br>  <span class=k>if</span> i:disty(lo) &gt; i:disty(hi) <span class=k>then</span> lo, hi = hi, lo <span class=k>end</span><br>  c = i:distx(lo, hi) + TINY<br>  <span class=k>return</span> <span class=k>function</span>(r) <span class=k>return</span> (i:distx(lo,r)^2 + c*c<br>                              - i:distx(hi,r)^2) / (2*c) <span class=k>end</span>,<br>         lo, hi <span class=k>end</span></pre>

Note the middle line: after finding the poles, ONE comparison
sorts them by disty, so *lo* is always the pole nearer heaven.
That costs two labels &mdash; the only two this whole chapter
spends &mdash; and it means every split knows which side is the
good side. Remember that thrift: it grows into active learning.

@ [Faloutsos & Lin: FastMap: a fast algorithm for indexing, data-mining and visualization of traditional and multimedia datasets](https://doi.org/10.1145/223784.223812). Christos Faloutsos, King-Ip Lin. SIGMOD 1995, 163-174.

-

**projection**: Where does a row *r* sit on the line between
the poles? High-school geometry answers. With *a* = the gap
from *lo* to *r*, *b* = the gap from *hi* to *r*, and *c* = the
gap between the poles:

<pre>              r<br>             /|<br>          a / |     x = (a&sup2; + c&sup2; - b&sup2;) / (2c)<br>           /  |<br>          /   |          \ b<br>  lo ----+----+----------- hi<br>         x<br>         &lt;------- c -------&gt;</pre>

That is the cosine rule, solved for the foot of the
perpendicular. *x* near 0: the row sits with the good pole
(*lo*); *x* near *c*: with the bad one; *x* below 0 or beyond
*c*: outside the poles entirely, which fastmap's approximation
happily allows. And look at what *poles* returns: not a number
&mdash; a FUNCTION, carrying *lo*, *hi* and *c* in its closure
(glossary 2). One line of geometry, wrapped so keysort can use
it as a key.

-

**halve**: Project every row, sort by projection, cut at the
median: two halves, better half first. The sort key calls
distx twice per row, so this is exactly the slow-key situation
from the DSU notes &mdash; keysort computes each projection
once. One more thrift: the poles are picked from
*some(rows, the.few)*, a random sample of 128 rows, because
the longest-line estimate barely improves with more.

<pre><span class=k>function</span> <span class=f>TBL.halve</span>(i,rows,    fun,a,b,n)<br>  rows = rows <span class=k>or</span> i.rows<br>  fun, a, b = i:poles(some(rows, the.few))<br>  rows = keysort(rows, fun)<br>  n = floor(#rows / 2)<br>  <span class=k>return</span> a, b, slice(rows, 1, n), slice(rows, n + 1) <span class=k>end</span></pre>

-

**node**: Recurse the halving and a tree falls out: each node
holds its rows (as a fresh cloned table) and its two poles;
splitting stops when a node is too small to bother
(fewer than 2 &middot; *the.stop* rows). auto93's 398 rows,
with stop=32: 398 &rarr; 199 &rarr; ~100 &rarr; ~50, then
stop &mdash; three levels, eight leafs. A binary chop through
data space: no centroids, no k, no distance matrix, and label
cost of two poles per split.

<pre><span class=k>function</span> <span class=f>Node</span>(tbl,rows,    recurse)<br>  <span class=k>function</span> <span class=f>recurse</span>(rows,    node,a,b,lo,hi)<br>    node = new(NODE, {here=tbl:clone(rows),<br>                      a=<span class=k>nil</span>, b=<span class=k>nil</span>, lo=<span class=k>nil</span>, hi=<span class=k>nil</span>})<br>    <span class=k>if</span> #rows &gt;= 2 * the.stop <span class=k>then</span><br>      a, b, lo, hi = tbl:halve(rows)<br>      node.a, node.b = a, b<br>      <span class=k>if</span> #lo &gt; 0 <span class=k>and</span> #hi &gt; 0 <span class=k>then</span><br>        node.lo, node.hi = recurse(lo), recurse(hi) <span class=k>end</span> <span class=k>end</span><br>    <span class=k>return</span> node<br>  <span class=k>end</span> <span class=c>-- recurse</span><br>  <span class=k>return</span> recurse(rows <span class=k>or</span> tbl.rows) <span class=k>end</span></pre>

To place a NEW row, walk down: at each level, go to whichever
pole is nearer. Log-many distance checks and the stranger has
an address:

<pre><span class=k>function</span> <span class=f>NODE.leaf</span>(i,row,    t)<br>  <span class=k>while</span> i.lo <span class=k>do</span><br>    t = i.here<br>    i = t:distx(row, i.a) &lt;= t:distx(row, i.b)<br>        <span class=k>and</span> i.lo <span class=k>or</span> i.hi <span class=k>end</span><br>  <span class=k>return</span> i <span class=k>end</span></pre>

.
