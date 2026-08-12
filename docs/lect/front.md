<p align="center">
  <a href="https://github.com/txt/seai26f/blob/main/README.md"><img 
     src="https://img.shields.io/badge/Home-%23ff5733?style=flat-square&logo=home&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/docs/lect/policies.md"><img 
      src="https://img.shields.io/badge/Policies-%230055ff?style=flat-square&logo=openai&logoColor=white" /></a>
  <a href="#"><img
      src="https://img.shields.io/badge/Teams-%23ffd700?style=flat-square&logo=users&logoColor=white" /></a>
  <a href="https://moodle-courses2527.wolfware.ncsu.edu/course/view.php?id=11951"><img 
      src="https://img.shields.io/badge/Moodle-%23dc143c?style=flat-square&logo=moodle&logoColor=white" /></a>
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

<a name="contents"></a>

# Why Look at AI a Different Way?

The AI world, as we know it, will change soon. NVIDIA, Open AI, Meta, Google are in trouble

- They've paid too much for technology which, if want to wait 3 months, you can get from free from China.
- As token costs for these new models sky-rocket, it come timely to talk cost-effective mix-and-match of cheaper and more expensive technologies [^compact].
- The cloud-based subscription model will collapse and we discover ways to scale down LLMs to local machines.
- The $1.2 trillion dollar data center debt will destroy them, especially since they those data centers age so quickly.
- Dreams of replacing humans with automation will become nightmare maintenance and monitoring scones (see "AI Slop:" [^baltes]
  and "Ironies of Automation" [^bainbridge].

[^baltes]: Baltes, Sebastian et al. “"An Endless Stream of AI Slop": How Developers Discuss the Burden of AI-Assisted Software Development.” (2026).

[^bainbridge]: Bainbridge, Lisanne. “Ironies of automation.” Autom. 19 (1982): 775-779.

[^compact]: Tim Menzies. 2025. The Case for Compact AI. Commun. ACM 68, 9 (September 2025), 6–7. https://doi.org/10.1145/3746057

So there is an opportunity to reshape what we mean by AI. What could we do with that?

# Writing Reusable Skills

This subject makes you a domain-engineering wizard. Imagine a
world where you talk to an LLM and it builds you a skill. You name
the task. The dialog layer — neural, chatty, forgiving — turns your
words into a spec.

Under the hood, something else runs. Solvers, trees, samplers,
statistics. A wide variety of tools, most of them not neural at
all. That under-the-hood layer is what this book writes.

Make it concrete. You want to buy a car. A good car accelerates
fast, drinks little fuel, and weighs little — a lighter car is
cheaper to build, so cheaper to buy. Someone offers you this one:

    Clndrs, Volume, HpX, Model, origin, Lbs-, Acc+, Mpg+
         4,    140,  92,    76,      1, 2572, 14.9,   30

What should an AI know about it? Whether the car is unusual. Whether
it is worth buying. Whether a better one exists. And if you must
buy this one, which single change helps most.

Here are ten ways an AI could help. Ask an LLM to code that second
column and you get 10K lines of glue around 1000K lines of
sci-kit-learn and pandas — a system you could not possibly understand.

| task                                            | skill                     |     %LOC | new LOC |
| ----------------------------------------------- | ------------------------- | -------: | ------: |
| Put 400 cars in one table; measure any gap      | remember (representation) |      45% |     150 |
| Guess the fuel use before we see the sticker    | guess (prediction)        |      17% |      57 |
| Say when "better" is real, and when it is noise | certify (certification)   |      12% |      40 |
| Decide on the spot as cars arrive one at a time | flow (streaming)          |       8% |      27 |
| Say why the bad cars are slow, or thirsty       | blame (diagnosis)         |       6% |      20 |
| Justify any verdict to a skeptical buyer        | justify (explanation)     |       4% |      13 |
| Find the best car, test-driving very few        | choose (optimization)     |       3% |      10 |
| Find the cheapest change that fixes this car    | fix (repair)              |       3% |      10 |
| Spot a strange car: a typo, or a scam           | spot (anomaly detection)  |       2% |       6 |
| Race our skills against the field's best        | race (baselining)         |       0% |       0 |
| **Totals**                                      |                           | **100%** | **333** |

So is there a simpler way?
Using the methods of this subject, those tasks cost the lines shown
on the right. That shape is what good domain engineering buys.
Skill i+1 reuses machinery already built for skills 1 through i.
The first skill pays for the data structure everything shares.
Certification comes early, before the experiments that need a
referee. By the end, a new skill rewires old parts; it does not add
new ones.

Do the domain engineering right and everything gets simple,
understandable, verifiable.

## Why look under the hood?

That plan runs against the current orthodoxy. Ryan Dahl (creator of
Node.js) says the era of human-written code is ending. Jensen Huang
(Nvidia CEO) advises the young against learning to code. Nobody
reads programs anymore — fly over the details, let the machine
drive.

This course disagrees, by demonstration. We read EZR: five short
Lua files, a few hundred lines each. They define a state-of-the-art
optimization and explanation tool that runs in milliseconds. EZR
summarizes data, draws explainable trees, spots anomalies, sorts
options by many goals at once, and optimizes under label budgets
that would bankrupt fancier methods.

Why read code, when a large model can write it? Large models are
extraordinary at generation. Nothing here disputes that. But big AI
is a rented telescope: powerful, and pointed by someone else. You
cannot inspect it. It changes without notice, so last year's result
may not run this year. It is wrong in confident ways, so every
output needs a human check. And each generation needs more power,
money, and cooling than the last.

The bill is already arriving. Baltes, Cheong and Treude read 1,154
developer posts about "AI slop" — Merriam-Webster's 2025 Word of the
Year — and found a tragedy of the commons: one person's productivity
gain becomes everyone else's review burden. The curl project shut
down its bug bounty because AI-written vulnerability reports ate
maintainer time and produced nothing valid.
([arXiv:2603.27249](https://arxiv.org/abs/2603.27249), local copy in
`src/ezr-lua/etc/refs/`.)

There is an older warning. In 1983, Bainbridge cautioned [^bain83]
that if we automate the parts that are easy to automate, we leave
humans the residue: the hard cases, plus a monitoring role that
humans are cognitively terrible at, plus skill atrophy from not
doing the easy cases anymore. In 2024, CrowdStrike shipped a
malformed configuration file that crashed 8.5 million machines. The
file was live for 78 minutes; the bill came to $5.4 billion in
direct losses at Fortune 500 companies alone. It was skilled
programmers, reading crash dumps and boot loaders, who handled that
emergency.

So ask yourself: who do you want to be? The person we rely on in a
crisis, or the programmer sacked in the next reorganization? Tools
expertise gets you hired; judgment gets you promoted — and judgment
is only ever built by reading the details someone else was willing
to skip. That is the difference between the engineer who is called
at 3am and the one who is merely notified. Fly over the details and
you are qualified for exactly the job the machine already has. So
we go the other way: down, into a few hundred lines, until you can
say what the program does and why it is right. We train the
reviewers, not the reviewed.

[^bain83]: Bainbridge, Lisanne. "Ironies of Automation." _Automatica_, vol. 19, no. 6, 1983, pp. 775-79, https://doi.org/10.1016/0005-1098(83)90046-8.

## The work, and its wall

Look at what you will actually be paid to do. Fifty years of
software engineering research — test generation, release planning,
effort estimation, refactoring, configuration tuning, program
repair, scheduling — is almost never generation. It is **rank,
select, configure, schedule, estimate, prioritize**, over a table.

Every one of those jobs hits the same wall: **labels cost money.**
Unlabeled data is cheap. Accurate labels ("this is good", "this is
bad") are so slow and expensive that we often face a label famine:

- Human experts are slow at labeling, and get worse when rushed.
  Hours for a handful of cases.
- Historical logs are big but unreliable. In one study, 90% of
  labeled technical-debt "false positives" were themselves wrong.
- Automated labeling is crude (regex) or merely assistive (LLMs).
- Even a real oracle can be ruinous. Exhaustively exploring the
  **11** parameters of the x264 video encoder (compile each one,
  then run a large test suite) took **1,000+ hours**.

So we ask: what can you do with a few dozen evaluations, not a few
million? That is the question this course answers: **how much can
you learn from a few dozen labels?** The answer turns out to be
_most of it_. Lecture 0 shows where that number comes from, then
checks it against 17,737 real records.

## The whole course in one screen

Read a table. Name each column. Add `+` or `-` to the goals you
want to maximize or minimize. Here is a sample of such data. In
practice the goals are mostly "?", since labels are the thing we
cannot afford:

       x = controllables, observables               y = goals
    --------------------------------------      -----------------------
    d2h    Rank   OVR   PHY   Acceleration      Penalties+   Strength+
    0.02   322    82    82    71                88           94
    0.02   4      91    88    80                90           93
    ...
    0.99   5902   69    68    37                10           30
    0.99   7937   67    65    49                10           30

Pass EZR 17,737 such rows. It finds 15 rows worth labeling and
builds a model you can read:

         n   d2h Penalties+ Strength+
        15  0.34        59    75.07
         8  0.11     77.25    79.75  Rank <= 222
     ▲   5  0.07      81.6       83  |  Crossing >  79
         3  0.18        70    74.33  |  Crossing <= 79
         7  0.60     38.14    69.71  Rank >  222
         4  0.54     37.25    79.25  |  DEF >  60
     ▼   3  0.68     39.33       57  |  DEF <= 60

(Fyi: d2h is a measure of success. lower values are better.)

Three attributes matter, out of 57. And it is _fast_, which is what
happens when a model has almost nothing in it:

| step                            | time        |
| ------------------------------- | ----------- |
| read 17,737 rows                | 346 ms      |
| choose 15 rows worth labeling  | 98 ms       |
| **build the model**             | **11.9 ms** |
| score 1,024 unseen rows with it | 0.3 ms      |

How many labels is enough? For this and 127 other such problems
(from the MOOT repository [^moot]) we swept budgets from 1 to 150
and "checks" from 1 to 10, 100,000 times. One team builds a model
using some budget; another team uses that model to check related
data. Runs are scored by how much they improve things (100 = max
improvement). Above a budget of ~50 and a check of ~5, the contours
flatten at 95:

[^moot]: Menzies, T., Chen, T., Ye, Y., Ganguly, K. K., Rayegan, A., Srinivasan, S., & Lustosa, A. (2026, April). MOOT: a repository of many multi-objective optimization tasks. In Proceedings of the 23rd International Conference on Mining Software Repositories (pp. 584-589).

<img src="../../src/ezr-lua/etc/img/fig2-w2.png" alt="wins by budget and check">

Fifty labels to build a model. Five or six to reuse someone else's.
Lecture 0 derives both numbers from one line of algebra, then tests
them.

The course thesis: every learner is a falsifiable bet about the
shape of your problem, and a few hundred readable lines are enough
to run the experiment yourself.

## Setup

Three steps: Lua, the code, the data.

**1. Lua** (get the latest, 5.4):

    sudo apt install lua5.4 luajit          # Debian, Ubuntu
    brew install lua luajit                 # macOS

Debian and Ubuntu name the binary `lua5.4`. Add a link, or the
commands below cannot find it:

    sudo ln -sf /usr/bin/lua5.4 /usr/local/bin/lua

Windows: use WSL. In PowerShell, as administrator:

    wsl --install

Reboot, set a username and password when Ubuntu first starts, then
run the Debian lines above inside it. From here on, everything in
this course happens inside that Ubuntu shell. Lua does run natively
on Windows (`scoop install lua`, or binaries from
luabinaries.sourceforge.net), but that build has no line editing at
the prompt.

**2. The code** (it lives in this repo, under `src/ezr-lua`):

    git clone https://github.com/txt/seai26f
    cd seai26f/src/ezr-lua
    make demo      # sanity check; three runs, each "failures: 0"

`src/ezr-lua` holds the five `.lua` files, `tut.md`, the
sample table, and the replay harness that checks every trace below.
The `curl … INSTALL.md | sh` line in the README is a different
thing: it fetches the `.lua` files alone, for embedding in your own
code, and leaves out the data this course needs.

**3. The data:**

    make players   # the 3.6MB table Lecture 0 uses
    git clone https://github.com/timm/moot ~/gits/moot
    export MOOT=$HOME/gits/moot

`make` on its own lists the rest. `make data` pulls the whole
126-table corpus, and `make all CORES=8` scores every table in it.

**If you want raw speed:** `luajit` runs this code ten to fifty
times faster than `lua`, and is worth having installed. But LuaJIT
implements Lua 5.1, so speed costs you the newer syntax. Write to
5.1 and your code runs under both:

| Avoid             | 5.4 only          | Write instead            |
| ----------------- | ----------------- | ------------------------ |
| `a // b`          | integer divide    | `math.floor(a/b)`        |
| `& \| ~ << >>`    | bitwise operators | `bit.band` etc, or avoid |
| `<const> <close>` | attributes        | plain `local`            |
| `math.type`       | integer subtype   | 5.1 has no integers      |
| `table.move`      | 5.3               | a `for` loop             |
| `string.pack`     | 5.3               | —                        |
| `utf8.*`          | 5.3               | —                        |

Two names moved, so shim them once at the top of the file:

    local unpack     = table.unpack or unpack
    local loadstring = loadstring or load

One gotcha will bite you before any of the above. In 5.4,
`print(6/2)` shows `3.0`; in LuaJIT it shows `3`. Every test that
compares printed output will differ between the two. So never print a
raw number — round it first:

    local function o(x)
      if type(x)=="number" then
        return x==math.floor(x) and string.format("%.0f",x)
                                or  string.format("%.3g",x) end
      ...

Then check both, every time:

    for lua in luajit lua5.4; do $lua l5.lua -e all; done

## Lua, and the port

Learning needs a little challenge — not a simple slide-and-forget
into your brain, but something that gives you pause to reflect. So
in this subject, you will port EZR from one language (Lua) to
another (Python), around 50 lines of code per week. Lua is a small,
Python-like language — a standard library of 9 modules, not 200.
Some people prefer Python because, unlike Lua, it comes with vast
and intricate toolkits. Other people prefer Lua for exactly that
reason.

Here is a taste: the whole random number generator, from
`ezr-lib.lua` (Park-Miller 1988). Every "random" number in this
course comes from these few lines:

```lua
Seed = 1234567891

-- Reseed with any integer; lands in 1..2^31-2.
function srand(n)
  Seed = floor(n or 1234567891) % 2147483647
  if Seed <= 0 then Seed = Seed + 2147483646 end end

-- No args: a float in [0,1). One arg n: an int in 1..n.
-- Two args: an int in lo..hi.
function rand(lo,hi,    x)
  Seed = (16807 * Seed) % 2147483647
  x = Seed / 2147483647
  if not lo then return x end
  if not hi then lo, hi = 1, lo end
  return lo + floor(x * (hi - lo + 1)) end
```

(Note the Lua idiom: names after the wide gap in an argument
list are locals, not arguments.)

Why teach in Lua? It is a language few of you know, and it is the
simplest to learn.

**It is small enough to read.** The whole toolkit is five files and
under 500 lines of code (without comments). You can hold it in your
head. That is the point of the course: you are not learning a
library, you are reading a system.

**It is fast, and it is tiny in memory** — useful when a Python
stack will not fit (an edge device, a phone, a build agent).
Measured over 128 data models, four runtimes, 512 runs, on an Apple
M4 (`src/ezr-lua/REPORTcpu.md`):

| models           | runtime | total time | mean mem   | vs LuaJIT  |
| ---------------- | ------- | ---------- | ---------- | ---------- |
| small (<1k rows) | CPython | 37.5 s     | 25.7 MB    | 81x slower |
|                  | LuaJIT  | **0.46 s** | **3.3 MB** | 1x         |
| mid (1k–10k)     | CPython | 58.1 s     | 26.2 MB    | 19x slower |
|                  | LuaJIT  | **3.0 s**  | **6.3 MB** | 1x         |

**It runs everywhere.** Any Lua from 5.1 up, and LuaJIT, print
identical output — no runtime, no wheels, no virtual environment, no
GPU.

For the mid-term and final, you will debug tiny bugs in tiny Lua
scripts (and each week you will get zero-mark practice exercises in
that task). You will not be asked to WRITE Lua, but you will be
required to read it. (Aside: sure, you could use an LLM to automate
the port. But then would you learn anything? And how would you
perform in the exams?)

**Homework, standing assignment.** Implement this system in a
language of your choice (Python recommended), paced by the lectures:
by the end of week _k_, your program reproduces every REPL event
through that lecture's range. The RNG is a portable 10-line
Park-Miller generator (`rand` in `ezr-lib.lua`), so a correct port
prints the SAME numbers shown here — grading is diff. Match table
contents exactly; match floats to the printed precision.

## The demos, week by week

The demos of `ezr-eg.lua`, `ezr-apps.lua` and `ezr-dtlz.lua`
are split into ten weekly files, `src/ezr-lua/ezr-eg0.lua` to
`ezr-eg9.lua`, sorted simplest to hardest. Each file is a
tutorial and a test suite at once: `--egs` lists that week's
demos, `--all` runs them (want "failures: 0"), and each file
ends with exercises. The later weeks look bigger, but each of
their demos is short application code reusing machinery from
the earlier weeks, so the reading load stays flat.

| file                                                      | theme                          | egs                                                                      |
| --------------------------------------------------------- | ------------------------------ | ------------------------------------------------------------------------ |
| ezr-eg0.lua                                               | boot: run, settings, read data | `--the` `--csv` `--repl`                                                 |
| [ezr-eg1.lua](https://txt.github.io/seai26f/ezr-eg1.html) | columns, streaming, forgetting | `--col` `--without` `--sub`                                              |
| ezr-eg2.lua                                               | distance & gap-to-heaven       | `--distx` `--disty` `--laws`                                             |
| ezr-eg3.lua                                               | clustering by poles            | `--half` `--node`                                                        |
| ezr-eg4.lua                                               | cuts, trees, XAI               | `--cuts` `--tree` `--show`                                               |
| ezr-eg5.lua                                               | active learning + holdout rig  | `--acquire` `--holdout` `--holdouts`                                     |
| ezr-eg6.lua                                               | statistics                     | `--same` `--ranks`                                                       |
| ezr-eg7.lua                                               | apps: predict, guard, group    | `--knn` `--detect` `--nb` `--kmeans` `--kpp`                             |
| ezr-eg8.lua                                               | classic optimizers             | `--dominate` `--ga` `--de` `--sa` `--ls` `--race`                        |
| ezr-eg9.lua                                               | DTLZ: labels cost money        | `--fronts` `--label` `--models` `--pure` `--why` `--generalize` `--wins` |

---
