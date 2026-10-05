title: Glossary 6: SE for AI
icon: 📊
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 6

## Week 6: statistics and ranking

#### By [Tim Menzies](https://timm.fyi), published 2026-10-05, updated 2026-10-05

**Summary:** *Last week ended with twenty holdouts and a
spread. This week asks the only question that matters about a
spread: is that gap real, or is it noise? Three cheap tests
(means, ranks, shapes), all three of which must agree; a rank
table where ties share a rank; and the row-versus-row
comparison (domination) that refuses to speak when the goals
disagree. Demos in [ezr-eg6.lua](ezr-eg6.html); machinery
verbatim from [ezr.lua](ezr.html) and
[ezr-apps.lua](ezr-apps.html).*

--- #week6

### Is that gap real?

---

New acronyms: KS (Kolmogorov-Smirnov).

-

**cohen**: The mean gap, measured in pooled standard deviations. If two
bags differ by less than about a third of their own spread,
nobody will ever notice the difference in practice &mdash; so
*the* default is 0.35. This is an EFFECT SIZE, not a p-value:
it asks "how big" rather than "how surprising", which is the
right question when your sample size is whatever you could
afford.

<pre><span class=k>function</span> <span class=f>cohen</span>(xs,ys,    x,y,n,m,sd)<br>  x, y = adds(xs), adds(ys)<br>  n, m = x.n, y.n<br>  sd = sqrt(((n-1)*x:div()^2 + (m-1)*y:div()^2)/(n+m-2))<br>  <span class=k>return</span> abs(x.mu - y.mu) / (sd + TINY) <span class=k>end</span></pre>

-

**cliffs delta**: Forget the means; count the comparisons. Of all pairs (x,y),
how many have x above y, and how many below? The imbalance,
scaled to 0..1, is Cliff's delta, and the default threshold
(0.195) is the standard "small effect" line. Because it reads
only ranks, no outlier can drag it around &mdash; the complaint that
kills *cohen* on skewed data.

<pre><span class=k>function</span> <span class=f>cliffs</span>(xs,ys,    gt,lt,j,k)<br>  gt, lt, j, k = 0, 0, 0, 0<br>  <span class=k>for</span> _, x <span class=k>in</span> ipairs(xs) <span class=k>do</span><br>    <span class=k>while</span> j &lt; #ys <span class=k>and</span> ys[j+1] &lt;  x <span class=k>do</span> j = j + 1; k = j <span class=k>end</span><br>    <span class=k>while</span> k &lt; #ys <span class=k>and</span> ys[k+1] == x <span class=k>do</span> k = k + 1 <span class=k>end</span><br>    gt = gt + j; lt = lt + #ys - k <span class=k>end</span><br>  <span class=k>return</span> abs(gt - lt) / (#xs * #ys) <span class=k>end</span></pre>

-

**ks (Kolmogorov-Smirnov)**: Compare the SHAPES. Walk both *cdfs* together, one
distinct value at a time, and record the widest vertical gap
between them. Divide by the critical value
&radic;((n<sub>x</sub>+n<sub>y</sub>)/(n<sub>x</sub>n<sub>y</sub>)) and the answer reads as
"how many critical units apart" &mdash; above 1.36 means different
at the usual 5% line. Two bags can share a mean and a median
and still fail this test, because one is a lump and the other
is two humps.

<pre><span class=k>function</span> <span class=f>ks</span>(xs,ys,    nx,ny,d,p,q,v)<br>  nx, ny  = #xs, #ys<br>  d, p, q = 0, 0, 0<br>  <span class=k>while</span> p &lt; nx <span class=k>and</span> q &lt; ny <span class=k>do</span><br>    v = min(xs[p+1], ys[q+1])<br>    <span class=k>while</span> p &lt; nx <span class=k>and</span> xs[p+1] == v <span class=k>do</span> p = p + 1 <span class=k>end</span><br>    <span class=k>while</span> q &lt; ny <span class=k>and</span> ys[q+1] == v <span class=k>do</span> q = q + 1 <span class=k>end</span><br>    d = max(d, abs(p / nx - q / ny)) <span class=k>end</span><br>  <span class=k>return</span> d / ((nx + ny) / (nx * ny)) ^ 0.5 <span class=k>end</span></pre>

At 5%, this test cries wolf on about one comparison in twenty
even when both bags come from the same generator. That is not
a bug in the code; it is the price of the threshold, and it is
why one test alone should never decide anything.

-

**same**: Three tests, three different questions &mdash; means, ranks, shapes.
Two samples count as the same only when all three agree, so a
method that fools one test still has to fool the others. Note
the ordering: *and* is lazy, so the cheapest test runs first
and usually decides.

<pre><span class=k>function</span> <span class=f>same</span>(xsort,ysort,Cohen,Ks,Cliffs)<br>  <span class=k>return</span> cohen( xsort,ysort) &lt;= (Cohen  <span class=k>or</span> .35)<br>     <span class=k>and</span> cliffs(xsort,ysort) &lt;= (Cliffs <span class=k>or</span> .195)<br>     <span class=k>and</span> ks(    xsort,ysort) &lt;= (Ks     <span class=k>or</span> 1.36) <span class=k>end</span></pre>

-

**ranks**: The table a paper actually prints. Sort the treatments by
median, walk down the sorted list, and give a treatment a NEW
rank only when it is not *same* as the one above it.
Ties therefore share a rank, and rank 0 is a SET of winners,
not a name. Reporting a single winner when four methods tie is
the most common statistical lie in this field.

<pre><span class=k>function</span> <span class=f>ranks</span>(d,big,    mid,dd,sign,out,win,rank,best)<br>  mid = <span class=k>function</span>(t) <span class=k>return</span> t[floor(#t / 2) + 1] <span class=k>end</span><br>  dd  = {}; <span class=k>for</span> k,v <span class=k>in</span> pairs(d) <span class=k>do</span> dd[k] = sorted(v) <span class=k>end</span><br>  sign = big <span class=k>and</span> -1 <span class=k>or</span> 1<br>  out, win, rank, best = {}, {}, -1, <span class=k>nil</span><br>  <span class=k>for</span> _, k <span class=k>in</span> ipairs(keysort(keys(dd),<br>                <span class=k>function</span>(k) <span class=k>return</span> sign * mid(dd[k]) <span class=k>end</span>)) <span class=k>do</span><br>    <span class=k>if</span> best == <span class=k>nil</span> <span class=k>or</span> <span class=k>not</span> same(dd[best], dd[k]) <span class=k>then</span><br>      rank, best = rank + 1, k <span class=k>end</span><br>    <span class=k>if</span> rank == 0 <span class=k>then</span> win[1+#win] = k <span class=k>end</span><br>    out[k] = rank <span class=k>end</span><br>  <span class=k>return</span> {winners=win, ranks=out} <span class=k>end</span></pre>

-

**dominates**: Comparing rows, not samples &mdash; and with no weights anywhere in
it. Row *a* dominates *b* when *a* is no worse on every goal
and better on at least one. That is the honest multi-goal
comparison, and its honesty is also its weakness: most pairs
are incomparable (better here, worse there), so domination
often refuses to speak. Hence *disty*, which buys a
total order with one assumption (all goals weigh the same).

<pre><span class=k>function</span> <span class=f>TBL.dominates</span>(i,r1,r2,    d1,d2,better,worse)<br>  <span class=k>if</span> i.model <span class=k>then</span> i:disty(r1); i:disty(r2) <span class=k>end</span><br>  better, worse = <span class=k>false</span>, <span class=k>false</span><br>  <span class=k>for</span> _,y <span class=k>in</span> ipairs(i.cols.y) <span class=k>do</span><br>    d1 = abs(y:norm(r1[y.at]) - y.heaven)<br>    d2 = abs(y:norm(r2[y.at]) - y.heaven)<br>    <span class=k>if</span> d1 &lt; d2 <span class=k>then</span> better = <span class=k>true</span> <span class=k>end</span><br>    <span class=k>if</span> d1 &gt; d2 <span class=k>then</span> worse  = <span class=k>true</span> <span class=k>end</span> <span class=k>end</span><br>  <span class=k>return</span> better <span class=k>and</span> <span class=k>not</span> worse <span class=k>end</span></pre>

-

**front**: The rows nothing dominates: the *Pareto frontier*
of whatever sample you hold. Two facts about real fronts, both
visible in *ezr-eg6.lua --fronts*: they are small (a handful of
64 rows), and their mean disty is far better than everything
else &mdash; which is why the one-number shortcut usually lands in
about the right place. Remember the *Pareto zoom
effect*: the good region is rare and
clumped, so zooming beats wandering.

-

**wins**: A score a stranger can read. Label the whole pool (cheating,
but this is scoring, not searching), then rescale: 100 = the
best row in the pool, 0 = the median row, negative = worse than
doing nothing. Reporting raw disty invites "is 0.31 good?";
reporting wins answers it.

<pre><span class=k>function</span> <span class=f>TBL.wins</span>(i,rows,    ys,lo,b4)<br>  ys = sorted(map(rows <span class=k>or</span> i.rows, i:Y()))<br>  lo, b4 = ys[1], ys[floor(#ys/2)+1]<br>  <span class=k>return</span> <span class=k>function</span>(r)<br>    <span class=k>return</span> max(-100, min(100,<br>      100*(1 - (i:disty(r)-lo) / (b4-lo+TINY)))) <span class=k>end</span> <span class=k>end</span></pre>

@ [Cohen: Statistical power analysis for the behavioral sciences](https://doi.org/10.4324/9780203771587). Jacob Cohen. 2nd edition, Lawrence Erlbaum, 1988.

@ [Cliff: Dominance statistics: Ordinal analyses to answer ordinal questions](https://doi.org/10.1037/0033-2909.114.3.494). Norman Cliff. Psychological Bulletin 114(3), 1993, 494-509.

@ [Massey: The Kolmogorov-Smirnov test for goodness of fit](https://doi.org/10.1080/01621459.1951.10500769). Frank J. Massey Jr. JASA 46(253), 1951, 68-78.

@ [Arcuri & Briand: A practical guide for using statistical tests to assess randomized algorithms in software engineering](https://doi.org/10.1145/1985793.1985795). Andrea Arcuri, Lionel Briand. ICSE 2011.

.
