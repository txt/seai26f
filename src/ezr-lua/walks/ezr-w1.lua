-- ezr, week 1: columns, streaming, forgetting.
-- One weekly-sized chunk of [ezr.lua](ezr.html), verbatim, with
-- glossary notes folded in (click a &#9654; to open one) and this
-- week's exercises at the bottom.
--
-- ## This week's story
-- A column watches values stream past and keeps a tiny summary:
-- a Num holds mean and standard deviation, a Sym holds counts,
-- mode and entropy. Nothing stores the values themselves. The
-- stats also run backwards: subtract a value and they roll back,
-- so a table can forget rows as cheaply as it learned them.
--
-- ---
--
-- <details><summary><b>noir</b></summary>
-- <p>Nominal, Ordinal, Interval, Ratio (Stevens 1946): the four
-- scales of measurement. This code collapses them to two: symbols
-- you can only count (nominal) and numbers you can subtract
-- (interval and up). One header letter decides which: lowercase
-- makes a SYM, uppercase a NUM. The header row is the entire
-- schema — policy as one line of data, mechanism in the
-- code.</p></details>
function Col(name,at)
  return (name:find"^%l" and Sym or Num)(name,at) end

-- <details><summary><b>Num, Sym, heaven</b></summary>
-- <p><b>Num</b>: the summary of a numeric column — count
-- <code>n</code>, mean <code>mu</code>, and <code>m2</code> (the
-- sum of squared deviations, from which sd falls out). Nothing
-- else is stored: not the data, just three numbers.</p>
-- <p><b>Sym</b>: the summary of a symbolic column — count
-- <code>n</code> and a table of counts <code>has</code>. Again no
-- data kept, just the histogram.</p>
-- <p><b>heaven</b>: the best value a goal can hope for, in
-- normalized 0..1 space: 0 for a minimize goal (trailing
-- <code>-</code>), 1 for maximize (trailing <code>+</code>).
-- Decided in one line, at column birth. Careful: flip that one
-- token and nothing crashes, every test passes — and the
-- optimizer hunts the heaviest, thirstiest car. Goal bugs steer
-- perfect machinery toward the wrong objective.</p></details>
function Num(name,at)
  name = name or ""
  return new(NUM, {at=at or 1, name=name, n=0, mu=0, m2=0,
                   heaven = name:find"-$" and 0 or 1}) end

function Sym(name,at)
  return new(SYM, {at=at or 1, name=name or "", n=0, has={}}) end

-- <details><summary><b>welford</b>, and the
-- <b>columnProtocol</b></summary>
-- <p><b>Welford</b>'s 1962 one-pass update: mean and variance
-- from a stream, no stored data, no catastrophic cancellation.
-- After each value v:</p>
-- <pre>n' = n+1
-- d  = v - mu
-- mu'= mu + d/n'
-- m2'= m2 + d*(v - mu')</pre>
-- <p>then sd = sqrt(m2/(n-1)). The NUM.add code at right is
-- exactly these four lines. Run with <code>inc=-1</code> the
-- algebra inverts, which is what makes summaries
-- subtractable.</p>
-- <p><b>columnProtocol</b>: Num and Sym answer the same eight
-- questions — one polymorphic protocol, two implementations.
-- Everything downstream (tables, distance, trees, cuts) talks to
-- the protocol, never to the type:</p>
-- <table>
-- <tr><th>question</th><th>Num answers</th><th>Sym answers</th></tr>
-- <tr><td>add</td><td>welford update of mu, m2</td><td>bump a count in has</td></tr>
-- <tr><td>sub</td><td>welford, run backwards</td><td>drop a count</td></tr>
-- <tr><td>mid</td><td>mean</td><td>mode</td></tr>
-- <tr><td>div</td><td>standard deviation</td><td>entropy</td></tr>
-- <tr><td>norm</td><td>cdf position, 0..1</td><td>identity</td></tr>
-- <tr><td>dist</td><td>gap of normed values</td><td>0 if same else 1</td></tr>
-- <tr><td>holds</td><td>x &lt;= v</td><td>x == v</td></tr>
-- <tr><td>reset</td><td>zero mu, m2</td><td>empty has</td></tr>
-- </table>
-- <p>Note the shared conventions: <code>"?"</code> (missing) is
-- ignored on the way in, and <code>inc=-1</code> runs the summary
-- backwards.</p></details>
function SYM.add(i,v,inc)
  if v == "?" then return v end
  inc = inc or 1
  i.n = i.n + inc
  i.has[v] = inc + (i.has[v] or 0)
  if i.has[v] <= 0 then i.has[v] = nil end
  return v end

function NUM.add(i,v,inc,    d)
  if v == "?" then return v end
  inc  = inc or 1
  i.n  = i.n + inc
  d    = v - i.mu
  i.mu = i.mu + inc * d / i.n
  i.m2 = i.m2 + inc * d * (v - i.mu); return v end

-- <details><summary><b>mid, div</b> (mode, mean; entropy,
-- sd)</summary>
-- <p><b>mid</b>: the most frequent symbol is a Sym's answer to
-- "what is typical here?" The mean is the same question asked of
-- numbers — both are one value standing in for the whole column.
-- That is why mid is one protocol slot, not two functions with
-- different names.</p>
-- <p><b>div</b> (diversity): Shannon 1948 — the spread of a
-- symbol column, in bits, the mean surprise of drawing from
-- counts p<sub>k</sub> = n<sub>k</sub>/n:</p>
-- <pre>e = -&Sigma; p&#8342; log&#8322; p&#8342;</pre>
-- <p>All-same symbols: 0 bits. Uniform over k symbols:
-- log&#8322;&nbsp;k bits. Variance (or sd) is the same question
-- asked of numbers — "how far is this column from settled?" —
-- which is why div is one slot with two spellings.</p>
-- <p>The two analogies are one design rule: every protocol slot
-- names a question; each type answers in its own dialect. Trees
-- built on div therefore handle numeric and symbolic goals with
-- the same code.</p></details>
function SYM.mid(i,    hi,out)
  hi = -1
  for k, n in pairs(i.has) do
    if n > hi then hi, out = n, k end end
  return out end

function NUM.mid(i) return i.mu end

function SYM.div(i)
  return sum(i.has, function(n,    p)
    p = n / i.n
    return -p * log(p) / log(2) end) end

function NUM.div(i)
  return i.n < 2 and 0 or sqrt(max(i.m2,0) / (i.n-1)) end

-- <details><summary><b>stream</b> (subtraction, and
-- forgetting)</summary>
-- <p>A summary you can update — and un-update — one datum at a
-- time, in constant memory. Adding costs O(1); so does
-- forgetting (sub). That is why a table can watch data flow
-- past, and forget rows as cheaply as it learned them; and why
-- <code>(a+b)-b == a</code> is a testable law
-- (<code>--without</code>, <code>--sub</code> in
-- <a href="ezr-eg1.html">ezr-eg1</a>).</p></details>
function NUM.__sub(i,j,    n,d)
  n = i.n - j.n
  if n < 1 then return Num(i.name, i.at) end
  d = j.mu - i.mu
  return new(NUM, {name=i.name, at=i.at, heaven=i.heaven,
                   n=n, mu=(i.n*i.mu - j.n*j.mu) / n,
                   m2=max(0, i.m2 - j.m2
                             - d*d*i.n*j.n/n)}) end

function NUM.reset(i) i.n, i.mu, i.m2 = 0, 0, 0 end
function SYM.reset(i) i.n, i.has = 0, {} end

--## exercises -------------------------------------------------
-- <div class=ex>
--
-- **Exercises, week 1**
--
-- 1. Port this page's code to Python, wiring each demo of
--    [ezr-eg1](ezr-eg1.html) to a test_ function.
-- 2. Add {10,20,30} to a Num one value at a time, printing mu
--    and sd after each add. Watch Welford converge.
-- 3. What is the entropy of a Sym fed "a","a","a"? Fed
--    "a","b","c"? Predict first, then run it.
-- 4. In `NUM.__sub`, why does `m2` get clamped with `max(0,...)`?
--    What does that say about floats?
-- 5. Flip `heaven` to `and 1 or 0`. Every test still passes.
--    What breaks, and how would you ever notice?
--
-- </div>
local _ = "week 1 ends here"
