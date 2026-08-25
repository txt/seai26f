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
-- Nominal, Ordinal, Interval, Ratio (Stevens 1946): the four
-- scales of measurement, collapsed here to two — symbols you can
-- only count, and numbers you can subtract. One header letter
-- decides which. The header row is the entire schema: policy as
-- one line of data, mechanism in the code.
-- [more](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#noir)
-- </details>
function Col(name,at)
  return (name:find"^%l" and Sym or Num)(name,at) end

-- <details><summary><b>heaven</b></summary>
-- A goal's best <i>normalized</i> value: 0 for a minimized goal
-- (<code>Lbs-</code>), 1 for a maximized one (<code>Mpg+</code>).
-- Careful: flip this one token and nothing crashes, every test
-- passes — and the optimizer hunts the heaviest, thirstiest car.
-- Goal bugs steer perfect machinery toward the wrong objective.
-- [more](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#heaven)
-- </details>
function Num(name,at)
  name = name or ""
  return new(NUM, {at=at or 1, name=name, n=0, mu=0, m2=0,
                   heaven = name:find"-$" and 0 or 1}) end

function Sym(name,at)
  return new(SYM, {at=at or 1, name=name or "", n=0, has={}}) end

-- <details><summary><b>welford</b>, and the
-- <b>columnProtocol</b></summary>
-- Welford's 1962 one-pass update: mean and variance from a
-- stream, no stored data. Run with <code>inc=-1</code> the
-- algebra inverts — that is the forgetting trick. And note the
-- twinned shape: Num and Sym answer the same eight questions
-- (add, sub, mid, div, norm, dist, holds, reset) — one
-- polymorphic protocol, two implementations. Everything
-- downstream talks to the protocol, never to the type.
-- [more](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#welford)
-- </details>
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
-- Every protocol slot names a question; each type answers in its
-- own dialect. Central tendency: mean, mode. Diversity: sd,
-- entropy. Trees built on <code>div</code> therefore handle
-- numeric and symbolic goals with the same code.
-- [more](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#mid-mode-mean)
-- </details>
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
-- A summary you can update — and un-update — one datum at a
-- time, in constant memory. <code>(a+b)-b == a</code> is a
-- testable law: see <code>--without</code> and <code>--sub</code>
-- in ezr-eg1.
-- [more](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#stream)
-- </details>
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
