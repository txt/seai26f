title: Glossary 5: SE for AI
icon: 🎯
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 5

## Week 5: active learning

#### By [Tim Menzies](https://timm.fyi), published 2026-09-28, updated 2026-09-28

**Summary:** *Weeks 1-4 got the goals for free. Now suppose a
single y value costs a test drive, a trial, a week of CPU
&mdash; and you get fifty, ever. This week is how to spend
them: label only the poles, cull gently, restart when the pool
dries, and count every purchase. Then the honesty check: a
holdout that picks from rows the search never studied. Demos in
[ezr-eg5.lua](ezr-eg5.html); machinery verbatim from
[ezr.lua](ezr.html). Each entry is a tiny lecture &mdash; hook,
idea, math if any, then the code.*

--- #week5

### Labels cost money

---

New acronyms: none.

-

**active learning**: Until now every y value was free: the csv arrived with its
goals filled in. Drop that. Suppose one label costs a test
drive, a clinical trial, a week of CPU &mdash; and you get fifty,
ever. Active learning is the discipline of choosing WHICH rows
to label, using only the free x columns to choose, and counting
every label you spend. The counting is the science: a result
whose price is unknown says nothing.

-

**label**: Where the money is spent. A row born with *"?"* goals stays
blank until someone asks; *label* calls the model, writes the
answers into the row, and folds each answer into its goal
column &mdash; so the summaries used for normalization sharpen as
spending grows. Note the seam: everything upstream just asks
for *disty*, and never knows whether the number was
looked up or bought.

<pre><span class=k>function</span> <span class=f>TBL.label</span>(i,row,    f)<br>  f = i.model(map(i.cols.x,<br>        <span class=k>function</span>(c) <span class=k>return</span> row[c.at] <span class=k>end</span>), #i.cols.y)<br>  <span class=k>for</span> j, y <span class=k>in</span> ipairs(i.cols.y) <span class=k>do</span><br>    row[y.at] = y:add(f[j]) <span class=k>end</span><br>  <span class=k>return</span> row <span class=k>end</span></pre>

-

**budget**: Four numbers run the economy: *budget=50* (labels, total),
*check=5* (labels held back to confirm the final pick),
*more=4* (labels per round) and *keepf=0.66* (fraction of the
pool kept per cull). Read them as a sentence: spend four
labels, throw away a third of what is left, repeat; keep five
in your pocket for the final exam. Any experiment that quietly
exceeds these is not measuring what it claims.

-

**acquire**: One sweep of *sway3*, in code. Label up
to *the.more* rows in the current pool, sort the pool by the
projection onto poles drawn from those labelled rows, keep the
best *the.keepf* of it, repeat until the pool is small or the
budget is gone. Nothing here builds a model; the geometry does
all the work, and the goals are only ever read for the few rows
we paid for.

<pre><span class=k>function</span> <span class=f>TBL.acquire</span>(i,rows,cap,lab,lo,hi,<br>                     seen,more,new)<br>  seen = {}<br>  <span class=k>for</span> _,r <span class=k>in</span> ipairs(lab) <span class=k>do</span> seen[r] = <span class=k>true</span> <span class=k>end</span><br>  <span class=k>while</span> #rows &gt;= 2*the.leaf <span class=k>do</span><br>    more, new = min(the.more, cap - #lab), {}<br>    <span class=k>for</span> _,r <span class=k>in</span> ipairs(rows) <span class=k>do</span> <span class=c>-- new = labels in this pool</span><br>      <span class=k>if</span> seen[r] <span class=k>then</span> push(new, r)<br>      <span class=k>elseif</span> more &gt; 0 <span class=k>then</span><br>        more, seen[r] = more - 1, <span class=k>true</span><br>        push(new, push(lab, r)) <span class=k>end</span> <span class=k>end</span><br>    <span class=k>if</span> #lab &gt;= cap <span class=k>then</span> <span class=k>return</span> lab <span class=k>end</span> <span class=c>-- budget spent</span><br>    rows = slice(keysort(rows, (i:poles(new, lo, hi))),<br>               1, max(1, floor(the.keepf * #rows))) <span class=k>end</span><br>  <span class=k>return</span> lab <span class=k>end</span></pre>

-

**restart**: A log-n chop reaches a tiny pool long before fifty labels are
spent. So when the pool dries with budget left, reshuffle and
descend again &mdash; but anchored at *lo, hi*, the best and worst
rows labelled SO FAR. Every restart inherits everything paid
for to date, which is why the second descent is sharper than
the first. The loop stops when the budget is gone, or when a
whole sweep buys nothing new.

<pre><span class=k>function</span> <span class=f>TBL.acquirer</span>(i,cap,    lab,lo,hi,t,b4)<br>  lab = {}<br>  <span class=k>while</span> <span class=k>true</span> <span class=k>do</span><br>    b4  = #lab<br>    lab = i:acquire(shuffle(i.rows), cap, lab, lo, hi)<br>    <span class=k>if</span> #lab &gt;= cap <span class=k>or</span> #lab &gt;= #i.rows <span class=k>or</span><br>       #lab == b4 <span class=k>then</span> <span class=k>break</span> <span class=k>end</span> <span class=c>-- full, or no progress</span><br>    t = keysort(lab, i:Y())<br>    lo, hi = t[1], t[#t] <span class=k>end</span> <span class=c>-- best+worst seen</span><br>  <span class=k>return</span> keysort(lab, i:Y()) <span class=k>end</span></pre>

-

**holdout**: The honesty check. Finding a good row among rows you have
studied proves nothing; the question is whether what you
learned TRANSFERS. So: split the rows in half, spend the budget
on the train half, grow a *tree* from those labels, use
that tree to rank the unseen test half, then spend the last
*the.check* labels confirming the top of that ranking. The
assert on line five is the whole ethic of the course &mdash; the
spend is counted before anything is scored.

<pre><span class=k>function</span> <span class=f>TBL.holdout</span>(i,how,    rows,n,train,test,lab,t,top)<br>  how  = how <span class=k>or</span> <span class=k>function</span>(t2,cap) <span class=k>return</span> t2:acquirer(cap) <span class=k>end</span><br>  rows = shuffle(i.rows)<br>  n    = floor(#rows/2)<br>  train= slice(rows, 1, n)<br>  test = slice(rows, n+1)<br>  lab  = how(i:clone(train), the.budget - the.check)<br>  assert(#lab + the.check &lt;= the.budget) <span class=c>-- spend, counted</span><br>  t    = Tree(i, lab)<br>  top  = slice(keysort(test, <span class=k>function</span>(r) <span class=k>return</span> t:leaf(i, r) <span class=k>end</span>),<br>           1, the.check)<br>  <span class=k>return</span> keysort(top, i:Y())[1] <span class=k>end</span></pre>

One holdout is an anecdote; twenty of them are a distribution,
and the distribution is the result. Which raises next week's
question: when is one distribution really better than another?

@ [Settles: Active learning literature survey](https://minds.wisconsin.edu/handle/1793/60660). Burr Settles. Univ. Wisconsin-Madison, Computer Sciences TR 1648, 2009.

@ [Chen, Nair, Krishna & Menzies: Sampling as a baseline optimizer for search-based software engineering](https://doi.org/10.1109/TSE.2018.2790925). IEEE TSE 45(6), 2019, 597-614.

.
