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

# Glossary

Terms from the weekly demo files, in discovery order: the order
week 1 first meets each idea. Code samples are verbatim from
[ezr.lua](https://github.com/txt/seai26f/blob/main/src/ezr-lua/ezr.lua)
and
[ezr-lib.lua](https://github.com/txt/seai26f/blob/main/src/ezr-lua/ezr-lib.lua).

## noir

Nominal, Ordinal, Interval, Ratio (Stevens 1946): the four scales
of measurement. This code collapses them to two: symbols you can
only count (nominal) and numbers you can subtract (interval and
up). One header letter decides which:

```lua
-- Column kind from the first letter: lowercase makes a SYM,
-- uppercase a NUM.
function Col(name,at)
  return (name:find"^%l" and Sym or Num)(name,at) end
```

<a name="pdf"></a>

## pdf (probability density function)

The bell curve, or any curve like it: the relative likelihood of
each value. For a normal with mean $\mu$ and deviation $\sigma$:

$$f(x) = \frac{1}{\sigma\sqrt{2\pi}}\;
e^{-\frac{(x-\mu)^2}{2\sigma^2}}$$

This code never evaluates a pdf directly — only areas under it
matter, and those come from the [cdf](#cdf). First met in
[a little maths](../attic/l0.md) (Lecture 0).

<a name="cdf"></a>

## cdf (cumulative distribution function)

The fraction of a population at or below a value: the area under
the [pdf](#pdf) up to $x$. Monotone, 0..1 — which makes it a
natural normalizer: `norm` maps any cell to "what fraction of
this column sits below you?". The normal cdf has no closed form,
so ezr uses a logistic approximation (good to about ±1%), with
the z-score clamped to ±3:

$$cdf(z) \approx \frac{1}{1 + e^{-1.702\,z}}$$

```lua
function NUM.norm(i,v,    z)
  if v == "?" then return v end
  z = (v - i.mu) / (i:div() + TINY)
  return 1 / (1 + exp(-1.702 * max(-3, min(3, z)))) end
```

## Num

The summary of a numeric column: count `n`, mean `mu`, and `m2`
(the sum of squared deviations from the mean, from which the
standard deviation falls out). Nothing else is stored — not the
data, just three numbers. A trailing `-` in the name means "goal:
minimize".

```lua
function Num(name,at)
  name = name or ""
  return new(NUM, {at=at or 1, name=name, n=0, mu=0, m2=0,
                   heaven = name:find"-$" and 0 or 1}) end
```

## Sym

The summary of a symbolic column: count `n` and a table of counts
`has`. Again, no data kept — just the histogram.

```lua
function Sym(name,at)
  return new(SYM, {at=at or 1, name=name or "", n=0, has={}}) end
```

## columnProtocol

Num and Sym answer the same eight questions — one polymorphic
protocol, two implementations. Everything downstream (tables,
distance, trees, cuts) talks to the protocol, never to the type:

| question | Num answers          | Sym answers        |
| -------- | -------------------- | ------------------ |
| `add`    | [welford](#welford) update of mu, m2 | bump a count in `has` |
| `sub`    | welford, run backwards | drop a count       |
| `mid`    | [mean](#mode)        | [mode](#mode)      |
| `div`    | [standard deviation](#entropy) | [entropy](#entropy) |
| `norm`   | [cdf](#cdf) position, 0..1 | identity     |
| `dist`   | gap of normed values | 0 if same else 1   |
| `holds`  | `x <= v`             | `x == v`           |
| `reset`  | zero mu, m2          | empty `has`        |

Two samples, both sides of `add`:

```lua
function NUM.add(i,v,inc,    d)
  if v == "?" then return v end
  inc  = inc or 1
  i.n  = i.n + inc
  d    = v - i.mu
  i.mu = i.mu + inc * d / i.n
  i.m2 = i.m2 + inc * d * (v - i.mu); return v end

function SYM.add(i,v,inc)
  if v == "?" then return v end
  inc = inc or 1
  i.n = i.n + inc
  i.has[v] = inc + (i.has[v] or 0)
  if i.has[v] <= 0 then i.has[v] = nil end
  return v end
```

Note the shared conventions: `"?"` (missing) is ignored on the way
in, and `inc=-1` runs the summary backwards (see
[stream](#stream)).

## protocol

A set of method names that many types agree to answer, so callers
need never ask which type they hold. Duck typing with a contract.
The [columnProtocol](#columnprotocol) is this course's main one;
`dist` alone is another (any object answering `dist` can sit in a
cluster).

## welford

Welford's 1962 one-pass update: mean and variance from a stream,
no stored data, no catastrophic cancellation. After each value
$v$:

$$n' = n+1,\quad d = v - \mu,\quad \mu' = \mu + d/n',\quad
m_2' = m_2 + d\,(v - \mu')$$

then $sd = \sqrt{m_2/(n-1)}$. The `NUM.add` code above is exactly
these four lines. Run with `inc=-1` the algebra inverts, which is
what makes summaries subtractable.

## stream

A summary you can update — and un-update — one datum at a time,
in constant memory. Adding costs O(1); so does forgetting
(`sub`). That is why a Tbl can watch data flow past, and why
`(a+b)-b == a` is a testable law (`--without`, `--sub` in
ezr-eg1).

```lua
function NUM.reset(i) i.n, i.mu, i.m2 = 0, 0, 0 end
function SYM.reset(i) i.n, i.has = 0, {} end
```

<a name="mode"></a><a name="mean"></a>

## mid (mode, mean)

The most frequent symbol: a Sym's answer to `mid` ("what is
typical here?"). The **mean is the same question asked of
numbers** — both are one value standing in for the whole column.
That is why `mid` is one protocol slot, not two functions with
different names:

```lua
function SYM.mid(i,    hi,out)
  hi = -1
  for k, n in pairs(i.has) do
    if n > hi then hi, out = n, k end end
  return out end

function NUM.mid(i) return i.mu end
```

<a name="entropy"></a><a name="sd"></a>

## diversity (entropy, standard deviation)

Shannon 1948: the spread of a symbol column, in bits — the mean
surprise of drawing from counts $p_k = n_k/n$:

$$e = -\sum_k p_k \log_2 p_k$$

All-same symbols: 0 bits. Uniform over $k$ symbols: $\log_2 k$
bits. **Variance (or sd) is the same question asked of numbers**
— "how far is this column from settled?" — which is why `div`
("diversity") is one protocol slot with two spellings:

```lua
function SYM.div(i)
  return sum(i.has, function(n,    p)
    p = n / i.n
    return -p * log(p) / log(2) end) end

function NUM.div(i)
  return i.n < 2 and 0 or sqrt(max(i.m2,0) / (i.n-1)) end
```

The two analogies are one design rule: every protocol slot names
a question; each type answers in its own dialect. Central
tendency: mean, mode. Diversity: sd, entropy. Trees built on
`div` therefore handle numeric and symbolic goals with the same
code.
