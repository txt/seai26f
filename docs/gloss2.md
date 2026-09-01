title: Glossary 2: SE for AI
icon: ⚙️
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 2

## The machinery under the weekly demos

#### By [Tim Menzies](https://timm.fyi), published 2026-08-31, updated 2026-08-31

**Summary:** *[Glossary 1](gloss1.html) says what weeks one and
two compute: Num, Sym, Tbl, distx, disty. This page is the
machinery those demos ride on. Every term here was found the
same way homework 1 and 2 find code: start at the demos in
[ezr-eg1.lua](ezr-eg1.html) and [ezr-eg2.lua](ezr-eg2.html),
trace only the functions they actually call, down the require
chain into [ezr.lua](ezr.html) and
[ezr-lib.lua](ezr-lib.html). Same deal as before: each entry is
a tiny lecture &mdash; a hook, the idea, the math if any, then
the code, verbatim from the source.*

--- #under

### Lua under the hood

---

Four language tricks that every file in this code leans on.
New acronyms: none.

-

**closure**: A function that remembers where it was born.
*csv* opens a file, then returns a function that takes no
arguments &mdash; yet each call yields the next row. How? The
returned function *captures* the variable *f* (the line
iterator) from its birthplace, and *f* stays alive between
calls. Code plus captured variables: that is a closure &mdash;
an object with one method, no class required.

<pre><span class=k>function</span> <span class=f>csv</span>(file,    f)<br>  f = io.lines(pathname(file))<br>  <span class=k>return</span> <span class=k>function</span>(    t,l)<br>    <span class=k>for</span> line <span class=k>in</span> f <span class=k>do</span><br>      l = line:gsub(<span class=s>"\239\187\191"</span>,<span class=s>""</span>)   <span class=c>-- strip any BOM</span><br>              :gsub(<span class=s>"%%.*"</span>,<span class=s>""</span>):match<span class=s>"^%s*(.-)%s*$"</span><br>      <span class=k>if</span> l ~= <span class=s>""</span> <span class=k>then</span><br>        t={}                        <span class=c>-- (.-), keeps empty cells</span><br>        <span class=k>for</span> s <span class=k>in</span> (l..<span class=s>","</span>):gmatch<span class=s>"(.-),"</span> <span class=k>do</span> t[#t+1]=thing(s) <span class=k>end</span><br>        <span class=k>return</span> t <span class=k>end</span> <span class=k>end</span> <span class=k>end</span> <span class=k>end</span></pre>

Closures are everywhere here. *TBL.Y* wraps a whole table into
a one-argument key function (used by *--disty* to sort rows):

<pre><span class=k>function</span> <span class=f>TBL.Y</span>(i)<br>  <span class=k>return</span> <span class=k>function</span>(r) <span class=k>return</span> i:disty(r) <span class=k>end</span> <span class=k>end</span></pre>

Python gets the same effect from *yield* (a generator is a
closure the language wrote for you) &mdash; see the streaming
*csv* in your port.

-

**iterator**: What does *for row in csv(the.file) do* actually
do? Lua's generic *for* just calls the function once per lap
and stops when it returns nil. Anything that returns a
function can be looped. *iter* makes plain lists loop the same
way, so *adds* and *Tbl* accept a list or a live stream, no
flag needed:

<pre><span class=k>function</span> <span class=f>iter</span>(src,    at)<br>  <span class=k>if</span> type(src) == <span class=s>"function"</span> <span class=k>then</span> <span class=k>return</span> src <span class=k>end</span><br>  at = 0; <span class=k>return</span> <span class=k>function</span>() at = at + 1; <span class=k>return</span> src[at] <span class=k>end</span> <span class=k>end</span></pre>

Python's *for* loop is programmable in exactly the same way:
it loops over anything answering *__iter__*/*__next__*, and
the quickest way to write one is a generator &mdash; *yield*
turns an ordinary function into a resumable stream, so the
Lua *csv* above is four lines of Python:

<pre><span class=k>def</span> <span class=f>csv</span>(file):<br>  <span class=k>for</span> line <span class=k>in</span> open(file):<br>    <span class=k>yield</span> [thing(s) <span class=k>for</span> s <span class=k>in</span> line.strip().split(<span class=s>","</span>)]<br><br><span class=k>for</span> row <span class=k>in</span> csv(<span class=s>"auto93.csv"</span>): ...   <span class=c># same shape as the Lua</span></pre>

Either way the moral is the same: the for loop is not magic
syntax over lists &mdash; it is an open protocol, and your own
code can join it.

-

**metatable (colon calls, __index)**: *n:mid()* is sugar for
*n.mid(n)*: the receiver rides in as the first argument, which
is why every method's first parameter is *i*. But *n* is a
plain table holding only *{n=5, mu=3, m2=10}* &mdash; there is
no *mid* inside it. When a lookup misses, Lua tries the
table's *metatable*, field *__index*. The whole trick, in the
simplest possible example &mdash; methods live in one table,
data in another, and *__index* joins them:

<pre>NUM = {}<br><span class=k>function</span> <span class=f>NUM.mid</span>(i) <span class=k>return</span> i.mu <span class=k>end</span><br><span class=k>function</span> <span class=f>NUM.div</span>(i) <span class=k>return</span> (i.m2/(i.n-1))^0.5 <span class=k>end</span><br><br>n = setmetatable({n=5, mu=3, m2=10}, {__index=NUM})<br>print(n:mid())  <span class=c>-- 3: no mid in n, so Lua asks NUM</span><br>print(n:div())  <span class=c>-- 1.58: same story</span></pre>

*new* wires that up for every object in this system, and it
is the entire class system:

<pre><span class=k>function</span> <span class=f>new</span>(kl,t)<br>  kl.__index=kl;kl.__tostring=show; <span class=k>return</span> setmetatable(t,kl) <span class=k>end</span></pre>

-

**metamethod (operator overloading)**: The *--without* demo
subtracts one summary from another with a minus sign: *w =
adds(...) - b*. Minus, on tables? Metatable keys starting
*__* are metamethods: *__index* answers a lookup miss (the
previous entry), *__sub* answers the *-* operator,
*__tostring* answers *print*. Define *NUM.__sub* and
summaries become subtractable algebra. Seen in action,
straight from the *--without* demo: pour
{10,20,30} on top of a summary of {1,2,3,4,5}, then subtract
a summary of {10,20,30} with a minus sign, and the first
summary comes back:

<pre>a, b = adds{1,2,3,4,5}, adds{10,20,30}<br>w = adds({10,20,30}, adds{1,2,3,4,5}) - b<br>print(show{mu=w.mu, sd=w:div()})   <span class=c>-- {:mu 3 :sd 1.58}</span></pre>

As a picture, that minus sign is one gaussian leaving
another. When the curves overlap, subtraction moves BOTH
moments: take a narrow curve out of a wide one and what
remains has an in-between spread &mdash; and a different
middle. Here a = {4,8,12,16} and b = {18,20,22}:

<pre> a+b: mu=14.3 sd=6.6       b: mu=20 sd=2      a: mu=10 sd=5.2<br>        ****                     *<br>     **********        -        ***      =        ****<br> ******************            *****          **********<br>---------+---------          ----+----       ------+-------<br>        14.3                     20                10</pre>

Check it with the pool equations (next section): pulling b's
60 out of the total 100 drags mu from 14.3 back to 10, and
removing a tight clump parked off-center shrinks the spread
from 6.6 to only 5.2 &mdash; not to 2's neighborhood, because
much of the combined width WAS the gap between the two
middles.

How the subtraction actually works &mdash; the counts and the
algebra &mdash; is the pool entry, below. Python spells the
same idea with dunders:
*__sub__*, *__repr__*. Overload only when the algebra is real
&mdash; here, summaries genuinely subtract, so *a - b* reads
as the mathematics it is.

.

--- #verbs

### The little verbs

---

ezr-lib is not batteries-included; it is batteries-handmade.
Four verbs carry most of the weight. New acronyms: DSU.

-

**fun (map, kap)**: Glossary 1's minkowski entry showed the
style: pass little functions into bigger ones. *fun*
generalizes it &mdash; a function stays a function, but a
string becomes "call that method" and a number becomes "grab
that field", so callers write *map(cols, "mid")* or
*map(xy, 2)* instead of a closure:

<pre><span class=k>function</span> <span class=f>fun</span>(f)<br>  <span class=k>if</span> type(f)==<span class=s>"string"</span> <span class=k>then</span><br>    <span class=k>return</span> <span class=k>function</span>(v,...) <span class=k>return</span> v[f](v,...) <span class=k>end</span> <span class=k>end</span><br>  <span class=k>if</span> type(f)==<span class=s>"number"</span> <span class=k>then</span> <span class=k>return</span> <span class=k>function</span>(v) <span class=k>return</span> v[f]<span class=k>end</span> <span class=k>end</span><br>  <span class=k>return</span> f <span class=k>end</span><br><br><span class=k>function</span> <span class=f>map</span>(t,f,    u)<br>  f = fun(f)<br>  u = {}; <span class=k>for</span> _,v <span class=k>in</span> ipairs(t) <span class=k>do</span> u[1+#u]=f(v) <span class=k>end</span>; <span class=k>return</span> u <span class=k>end</span><br><br><span class=k>function</span> <span class=f>kap</span>(t,f,    u)<br>  u = {}<br>  <span class=k>for</span> k,v <span class=k>in</span> pairs(t) <span class=k>do</span> u[1+#u] = f(k,v) <span class=k>end</span>; <span class=k>return</span> u <span class=k>end</span></pre>

*map* walks values in array order; *kap* walks key-value
pairs in any order (Python's *d.items()*), and since a nil
result simply vanishes, *kap* also filters. This is the
open-closed principle by hand: *map* never changes, yet every
caller re-aims it.

-

**keysort (DSU: decorate, sort, undecorate)**: *--disty* must
rank 398 rows by their gap to heaven. Sorting with a
comparator would call *disty* O(n log n) times; the classic
fix (Perl folk call it the Schwartzian transform) is decorate
each row as a {key, row} pair, sort the pairs, then undecorate
back to bare rows. Python's *sorted(key=f)* is the same
contract. Fun fact: set up your functions right and the third
step vanishes. *keysort* decorates into SIDE tables (*px*:
row to key; *ix*: row to input position), then sorts the
original rows in place, with a comparator that just reads the
cache &mdash; nothing was wrapped, so there is nothing to
unwrap:

<pre><span class=k>function</span> <span class=f>keysort</span>(t,f,    px,ix)<br>  px, ix = {}, {}<br>  <span class=k>for</span> at, v <span class=k>in</span> ipairs(t) <span class=k>do</span> px[v], ix[v] = f(v), at <span class=k>end</span><br>  <span class=k>return</span> sorted(t, <span class=k>function</span>(u,v)<br>           <span class=k>if</span> px[u] == px[v] <span class=k>then</span> <span class=k>return</span> ix[u] &lt; ix[v] <span class=k>end</span><br>           <span class=k>return</span> px[u] &lt; px[v] <span class=k>end</span>) <span class=k>end</span></pre>

Two details that matter. Once-per-row is not just style: in
later weeks the key function costs money (*disty* reads
labels), so calling it once is budget discipline. And the *ix*
table breaks ties by input order &mdash; Lua's *table.sort* is
unstable, and an unstable sort prints different lines on
different Lua versions, rotting every frozen transcript (see
show, below).

-

**thing (coercion)**: Every cell in every csv file enters the
system through one gate:

<pre><span class=k>function</span> <span class=f>thing</span>(s)<br>  s = s:match<span class=s>"^%s*(.-)%s*$"</span><br>  <span class=k>return</span> tonumber(s) <span class=k>or</span> s==<span class=s>"True"</span> <span class=k>or</span> (s~=<span class=s>"False"</span> <span class=k>and</span> s) <span class=k>end</span></pre>

Trim, then: a number if it parses, *true*/*false* for
"True"/"False", else the string. Note what survives untouched:
"?" stays a string, which is why every column method opens
with *if v == "?"*. One gate means one place to change &mdash;
your Python port calls it *atom*.

-

**show (the transcript is the test)**: The whole system prints
through one function:

<pre><span class=k>function</span> <span class=f>show</span>(t,    u)<br>  <span class=k>if</span> type(t) ~= <span class=s>"table"</span> <span class=k>then</span><br>    <span class=k>return</span> tostring(type(t) == <span class=s>"number"</span> <span class=k>and</span> round(t) <span class=k>or</span> t) <span class=k>end</span><br>  u = #t &gt; 0 <span class=k>and</span> map(t, show) <span class=k>or</span><br>      sorted(kap(t, <span class=k>function</span>(k,v)<br>        <span class=k>if</span> tostring(k):sub(1,1) ~= <span class=s>"_"</span> <span class=k>then</span><br>          <span class=k>return</span> <span class=s>":"</span>..k..<span class=s>" "</span>..show(v) <span class=k>end</span> <span class=k>end</span>))<br>  <span class=k>return</span> <span class=s>"{"</span>..table.concat(u, <span class=s>" "</span>)..<span class=s>"}"</span> <span class=k>end</span></pre>

Lists print in order; dictionaries print sorted by key; keys
starting "_" stay hidden; numbers pass through *round*, which
drops float noise and re-floors whole results so 15.0 prints
as 15 on every Lua version. Why the fuss? Deterministic
printing turns a transcript into a test: same seed plus same
*show* means the output diffs clean &mdash; across runs,
across Lua versions, and across your Lua-to-Python port, which
is graded exactly that way.

.

--- #laws

### The laws the demos swear by

---

Weeks one and two end in three asserts that are really three
pieces of mathematics. New acronyms: PBT.

-

**pool (the algebra of summaries)**: The *--without* demo
pours {10,20,30} into a summary of {1,2,3,4,5}, subtracts a
summary of {10,20,30}, and the mean and sd of {1..5} come back
to nine decimals &mdash; with no stored data anywhere. That
works because moments pool. For two groups a and b, with
d = &mu;<sub>b</sub> - &mu;<sub>a</sub>:

- n<sub>ab</sub> = n<sub>a</sub> + n<sub>b</sub>
- &mu;<sub>ab</sub> = (n<sub>a</sub>&mu;<sub>a</sub> + n<sub>b</sub>&mu;<sub>b</sub>) / n<sub>ab</sub>
- m2<sub>ab</sub> = m2<sub>a</sub> + m2<sub>b</sub> + d&sup2; n<sub>a</sub>n<sub>b</sub> / n<sub>ab</sub>

The Sym side is the easy half &mdash; histograms subtract one
count at a time:

<pre><span class=k>function</span> <span class=f>SYM.__sub</span>(i,j,    out,n)<br>  out = Sym(i.name, i.at)<br>  <span class=k>for</span> k,v <span class=k>in</span> pairs(i.has) <span class=k>do</span><br>    n = v - (j.has[k] <span class=k>or</span> 0)<br>    <span class=k>if</span> n &gt; 0 <span class=k>then</span> out.has[k] = n; out.n = out.n + n <span class=k>end</span> <span class=k>end</span><br>  <span class=k>return</span> out <span class=k>end</span></pre>

The Num side is the three pooling lines above, solved
backwards &mdash; given the whole and one part, recover the
other part, O(1):

<pre><span class=k>function</span> <span class=f>NUM.__sub</span>(i,j,    n,d)<br>  n = i.n - j.n<br>  <span class=k>if</span> n &lt; 1 <span class=k>then</span> <span class=k>return</span> Num(i.name, i.at) <span class=k>end</span><br>  d = j.mu - i.mu<br>  <span class=k>return</span> new(NUM, {name=i.name, at=i.at, heaven=i.heaven,<br>                   n=n, mu=(i.n*i.mu - j.n*j.mu) / n,<br>                   m2=max(0, i.m2 - j.m2<br>                             - d*d*i.n*j.n/n)}) <span class=k>end</span></pre>

Note the guards: fewer than one row left returns a fresh Num,
and *max(0, ...)* exists because float error can push m2 a
hair below zero. Welford (glossary 1) forgets one value at a
time; *__sub* forgets a whole group at once. Together they are
why later code can score every split of a column in one linear
pass.

@ [Chan, Golub & LeVeque: Algorithms for computing the sample variance: analysis and recommendations](https://doi.org/10.1080/00031305.1983.10483115). T.F. Chan, G.H. Golub, R.J. LeVeque. The American Statistician 37, 3 (1983), 242-247.

-

**metric (the distance laws)**: A distance you cannot trust
poisons everything built on it &mdash; clusters, poles, trees.
Mathematicians call a trustworthy one a *metric*: it obeys

| law          | says                                        |
|--------------|---------------------------------------------|
| identity     | d(a,a) = 0                                  |
| symmetry     | d(a,b) = d(b,a)                             |
| non-negative | d &ge; 0 (and here, d &le; 1)               |
| triangle     | d(a,c) &le; d(a,b) + d(b,c)                 |

The *--laws* demo probes the first three on 100 random pairs.
The one at risk is identity: unknowns assume the worst, so
*SYM.dist("?","?")* is 1 &mdash; a row holding a "?" would sit
at nonzero distance from itself, making distx strictly a
*pseudometric*. So why does self-is-zero never fail on
auto93? Its only "?" cells live in *HpX*, and a trailing "X"
means ignored: that column never reaches distx (homework 2,
question 6). The design trade is deliberate, and it has a name:
the **Aha heuristic**, from the instance-based learning
literature (see the distx entry in [glossary 1](gloss1.html)) &mdash;
maximum ignorance maps to maximum distance, buying robustness to
missing data at the price of textbook metric-hood. Note also what tames the
ruler itself: gaps are measured between *norm*'d values (the
cdf, glossary 1), so one wild outlier cannot stretch the scale
for everyone else.

-

**PBT (property-based testing)**: *--col* asserts an example:
the mid of {1,2,3,4,5} is 3. *--laws* asserts a *property*:
for ALL rows a and b, distx(a,b) equals distx(b,a) &mdash;
then goes hunting for a counterexample with 100 random probes.
Example tests catch the regressions you foresaw; property
tests catch the ones you did not. QuickCheck made the recipe
famous: state the law, generate random inputs, shrink any
failure. This code keeps the cheap half of that recipe, and
adds the RNG discipline of glossary 1: since *run* reseeds
before every demo, a failing probe replays exactly, every
time. *--without* and *--sub* are the same idea wearing
algebra: (a+b)-b == a, asserted to 1e-9. When code claims
mathematics &mdash; distance, probability, algebra &mdash;
test the law, not the instance.

@ [Claessen & Hughes: QuickCheck: a lightweight tool for random testing of Haskell programs](https://doi.org/10.1145/351240.351266). Koen Claessen, John Hughes. ICFP 2000, 268-279.

.
