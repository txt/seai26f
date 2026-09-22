title: Glossary 7: SE for AI
icon: 🧰
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 7

## Week 7: applications

#### By [Tim Menzies](https://timm.fyi), published 2026-10-26, updated 2026-10-26

**Summary:** *Textbooks give a chapter each to prediction,
anomaly detection, Bayes classifiers and clustering. This week
is the claim that those chapters are synonyms: given distance
and column summaries, each one is a dozen lines. Count the new
lines per chapter; that falling count is the whole argument of
this course, and of the undergraduate project. Demos in
[ezr-eg7.lua](ezr-eg7.html); machinery verbatim from
[ezr-apps.lua](ezr-apps.html).*

--- #week7

### One substrate, four chapters

---

New acronyms: knn, NB (naive Bayes), kpp (k-means++).

-

**knn**: The Fortune Teller. To guess a row's goals, sort everything by
distance to it and average the goals of the nearest *the.k*.
Nothing is fitted; the neighbours ARE the model. It is also the
cheapest possible regression &mdash; and on auto93 it beats guessing
the global mean by about four times.

<pre><span class=k>function</span> <span class=f>TBL.knn</span>(i,row,k,    t)<br>  t = i:around(row)<br>  <span class=k>return</span> adds(map(slice(t, 1, k <span class=k>or</span> the.k), i:Y())).mu <span class=k>end</span></pre>

-

**anomaly detection**: The Bouncer. Loneliness is the whole test: how far is the
nearest OTHER row? Score every row that way, normalize to
0..1, and 1 is the loneliest thing in the data. Wrap this
around any learner and you have the
*certification envelope*: the guess,
plus a red light when the question is unlike anything the
model was built from. The same code, pointed at a reference
population instead of your own history, is BENCHMARKING &mdash; is
this car yard near the good cluster, or far from every
cluster? (*synonyms*, again.)

<pre><span class=k>function</span> <span class=f>TBL.anomaly</span>(i,    dn,gap)<br>  gap = <span class=k>function</span>(r,    lo,d)<br>    lo = 1e32<br>    <span class=k>for</span> _,z <span class=k>in</span> ipairs(i.rows) <span class=k>do</span><br>      <span class=k>if</span> z ~= r <span class=k>then</span><br>        d = i:distx(r, z); <span class=k>if</span> d &lt; lo <span class=k>then</span> lo = d <span class=k>end</span> <span class=k>end</span> <span class=k>end</span><br>    <span class=k>return</span> lo <span class=k>end</span><br>  dn = Num()<br>  <span class=k>for</span> _,r <span class=k>in</span> ipairs(i.rows) <span class=k>do</span> dn:add(gap(r)) <span class=k>end</span><br>  <span class=k>return</span> <span class=k>function</span>(r) <span class=k>return</span> dn:norm(gap(r)) <span class=k>end</span> <span class=k>end</span></pre>

-

**naive bayes**: The ER Nurse: sort arrivals into classes, fast, one row at a
time. Each class keeps its own column summaries; the score for
a row is the log of the class prior plus the logs of
P(value | column), summed over the x columns. "Naive" means
the columns are assumed independent &mdash; plainly false, and it
wins anyway, because a wrong-but-consistent bias still ranks
the classes correctly. Note the protocol at work: symbols get
an m-estimate, numbers get a gaussian pdf, and *likes* never
asks which is which.

<pre><span class=k>function</span> <span class=f>like</span>(col,v,prior,    z)<br>  <span class=k>if</span> <span class=k>not</span> col.mu <span class=k>then</span><br>    <span class=k>return</span> ((col.has[v] <span class=k>or</span> 0) + the.L*prior)<br>           / (col.n + the.L) <span class=k>end</span><br>  z = 2 * col:div()^2 + 1e-32<br>  <span class=k>return</span> exp(-(v - col.mu)^2 / z) / (pi * z)^0.5 <span class=k>end</span></pre>

The rig is test-then-train: every row is GUESSED before it is
learned, so the accuracy needs no held-out split and the model
is always as current as the last row seen.

<pre><span class=k>function</span> <span class=f>TBL.classify</span>(i,wait,    at,h,seen,nh,want)<br>  wait, at = wait <span class=k>or</span> the.wait, i.cols.klass.at<br>  h, seen, nh = {}, {}, 0<br>  <span class=k>for</span> j,row <span class=k>in</span> ipairs(i.rows) <span class=k>do</span><br>    want = row[at]<br>    <span class=k>if</span> j &gt;= wait <span class=k>and</span> nh &gt; 0 <span class=k>then</span><br>      push(seen, {mostlikes(h, row, #i.rows, nh), want}) <span class=k>end</span><br>    <span class=k>if</span> <span class=k>not</span> h[want] <span class=k>then</span> h[want] = i:clone(); nh = nh + 1 <span class=k>end</span><br>    h[want]:add(row) <span class=k>end</span><br>  <span class=k>return</span> seen <span class=k>end</span></pre>

-

**kmeans**: The Curator, textbook edition: pick k centroids, assign every
row to its nearest, move each centroid to the middle of what it
caught, repeat. Compare with week 3's *node*: kmeans
needs k, needs a full pass per iteration, and needs a distance
to every centroid &mdash; while node splits on two rows and gives you
an index for free. Both cluster; they do not cost the same.

<pre><span class=k>function</span> <span class=f>TBL.kmeans</span>(i,k,iter,    cents)<br>  cents = some(i.rows, k <span class=k>or</span> the.kluster)<br>  <span class=k>for</span> _ = 1, iter <span class=k>or</span> the.iter <span class=k>do</span><br>    cents = recentre(assign(i, cents)) <span class=k>end</span><br>  <span class=k>return</span> assign(i, cents) <span class=k>end</span></pre>

-

**kpp**: k-means++: start the centroids far apart, or kmeans starts in a
corner and stays there. Each new centre is drawn with a chance
proportional to its SQUARED distance from the centres chosen so
far &mdash; random, but biased toward the empty regions. Week 3's
poles made the same bet with two rows and no randomness.

<pre><span class=k>function</span> <span class=f>TBL.kpp</span>(i,k,    cents,pool,ws)<br>  cents = {some(i.rows, 1)[1]}<br>  <span class=k>while</span> #cents &lt; (k <span class=k>or</span> the.kluster) <span class=k>do</span><br>    pool = some(i.rows, min(the.few, #i.rows))<br>    ws   = map(pool, <span class=k>function</span>(r) <span class=k>return</span> d2(i, cents, r) <span class=k>end</span>)<br>    push(cents, pool[wpick(ws)]) <span class=k>end</span><br>  <span class=k>return</span> cents <span class=k>end</span></pre>

@ [Aha, Kibler & Albert: Instance-based learning algorithms](https://doi.org/10.1007/BF00153759). David W. Aha, Dennis Kibler, Marc K. Albert. Machine Learning 6, 1991, 37-66.

@ [Domingos & Pazzani: On the optimality of the simple Bayesian classifier under zero-one loss](https://doi.org/10.1023/A:1007413511361). Pedro Domingos, Michael Pazzani. Machine Learning 29, 1997, 103-130.

@ [Arthur & Vassilvitskii: k-means++: The advantages of careful seeding](https://dl.acm.org/doi/10.5555/1283383.1283494). David Arthur, Sergei Vassilvitskii. SODA 2007, 1027-1035.

.
