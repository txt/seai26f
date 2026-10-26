title: Glossary 10: SE for AI
icon: 🧩
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 10

## Revision: desugaring data mining

#### By [Tim Menzies](https://timm.fyi), published 2026-11-09, updated 2026-10-26

**Summary:** *No new terms here. This page is the map. Compilers
run a big surface language for humans over a tiny core for the
machine, and the bridge between them is called desugaring. The
claim this whole course exists to test: data mining is all
surface. Four primitives, one learner, one coordinate, three
aimings &mdash; and every chapter heading in the textbook
desugars to them. Read this before the final, and before you
write up either project.*

--- #desugar

### Surface and core

---

Languages run a big surface for humans over a tiny core for the
machine. Haskell calls the bridge *desugaring*; Rust calls it
*lowering*; Lean calls it *elaboration*; Lisp calls it *macro
expansion*. Same move every time: *do*, *for*, *async*, *guard*,
*cond* stop existing, and a handful of forms survive. Surface is
where the vocabulary lives. Core is where the work happens, and
it is always smaller than anyone expects.

-

Data mining is all surface. Classification, regression, anomaly
detection, retrieval, repair, planning, monitoring, forecasting
&mdash; those are chapter headings, not algorithms. Here is the
core, and you have already built every piece of it.

--- #core

### The core

---

Four primitives. Each branches exactly once, on column type
&mdash; and the header row already said which:

| primitive | on a *Sym* | on a *Num* | job |
|-----------|------------|------------|-----|
| *mid* | mode | mean | summarize |
| *dist* | 0 or 1 | scaled difference | compare |
| *sample* | roulette | gauss | generate |
| *delta* | frequency shift | mu difference | extrapolate |

One learner and one coordinate, built only from the primitives:

| form | job |
|------|-----|
| *project*(a, b) &rarr; t | place a row on the line between two far poles |
| *cluster*(rows) &rarr; groups | group the similar: *project*, halve, recurse |

Three aimings and one clock &mdash; ways of pointing the
primitives at clusters:

| aiming | spelled in primitives |
|--------|-----------------------|
| *relevant*(row, clusters) | *dist*, row to each cluster's *mid*s; smallest wins |
| *DISTINGUISH*(here, there) | *dist* between two clusters' *mid*s; largest wins |
| *impute*(row, cluster) | *sample* the cluster, write it back into the row |
| *TRAJECTORY*(eras) | *delta*, era i to era i+1, chained forward |

You met all of these, one per week. *mid* is week 1: mode for
*Sym*s, mean for *Num*s. *dist* is week 2's *distx*: zero-or-one
for symbols, scaled difference for numbers. *project* and
*cluster* are week 3: fastmap poles, projection, recursive
halving. *delta* is week 6: a shift in frequencies, a difference
in means &mdash; cohen and friends are *delta* with a threshold.
*sample* is how week 8's optimizers made new rows: roulette on a
*Sym*'s counts, a gaussian step from a *Num*'s mu and sd.

-

Goals need no operator of their own. The header row already says
*Lbs-*, *Acc+*, *class!*, and *disty* (week 2) folds any set of
those into one number, 0 = best.

--- #rules

### The rules

---

Every task in the textbook is one of the aimings, pointed
somewhere. Read the right column: it only uses the words of the
core &mdash; that is the whole claim.

| core call | task | desugars to |
|-----------|------|-------------|
| *cluster*(rows) | summarization | read each cluster's *mid*s |
| *relevant*(row, clusters) | classification | *mid* of the nearest cluster's *Sym* target |
| | regression | *mid* of the nearest cluster's *Num* target |
| | anomaly | the *dist* itself: how far to the nearest *mid*s? |
| | retrieval | the nearest cluster's rows |
| | spread | *sample* the nearest cluster's y cells |
| *impute*(row, cluster) | repair | *sample* own cluster; write the empty cells |
| | planning | *sample* a better cluster; write the actionable cells |
| | synthesis | *sample* any cluster; write all the cells |
| *DISTINGUISH*(here, there) | explanation | largest *dist* between left's and right's *mid*s |
| | planning | here = worse cluster, there = better |
| | monitoring | here = better cluster, there = worse |
| | trends | here = era i, there = era i+1 |
| *TRAJECTORY*(eras) | trends | the *delta*s, read at t &le; 1 |
| | forecasting | the same *delta*s, read at t &gt; 1 |
| | alerts | a step whose *dist* from the last *mid*s is anomalous |
| compositions | optimization | planning + monitoring, looped |
| | simulation | synthesis (*impute*), then *relevant* to predict |
| | benchmarking | *same()*: three *delta*s (cohen, cliffs, ks), hedged |

Nothing in that table branches on the task. The only branch
anywhere in the system is *Num* or *Sym*, inside the four
primitives.

-

Read a few rows aloud and the week 7 demos fall out.
Classification is *relevant*: walk a row to its nearest cluster,
report the mid of a symbolic target &mdash; that is knn, that is
the leaf's mode. Make the target numeric and the same walk is
regression. Keep the walk but report the distance instead of the
mid and you have anomaly detection: loneliness is the whole
test. Point *DISTINGUISH* at a worse and a better cluster and
the biggest difference between their mids is a plan ("change
these cells"); swap the direction and the same answer is a
monitor ("watch these cells"). Loop plan-then-monitor under a
label budget and you have week 5's optimizer. None of those took
a new algorithm. Each took an argument.

--- #nine

### The nine

---

Buse & Zimmermann (ICSE 2012) surveyed what practitioners ask of
software analytics and got nine techniques: three activities,
three tenses. That grid is the surface language of this field.
Here is what each cell desugars to:

| | Past | Present | Future |
|---|---|---|---|
| **Explore** | Trends: *trajectory, read at t &le; 1* | Alerts: *steps + anomaly* | Forecasting: *trajectory, read at t &gt; 1* |
| **Analyze** | Summarization: *read the mids* | Overlays: *unclaimed* | Goals: *disty* |
| **Experiment** | Modeling: *cluster* | Benchmarking: *same()* | Simulation: *synthesis, then predict* |

Eight of nine. Goals is not even a technique here &mdash; it is
punctuation in the header row (*Lbs-*, *Acc+*). Only Overlays
has no core form.

-

Classic machine learning covers a different slice of the same
surface &mdash; classify, regress, cluster, detect, retrieve,
repair, synthesize, explain, plan &mdash; and desugars to the
same core. Two literatures, one machine.

--- #stack

### The stack: where each week fits

---

Every week added one layer, every layer used only the ones below
it, and every layer is a core form:

| week | what it added | core form |
|------|---------------|-----------|
| 1 | columns that summarize as they read (*Num*, *Sym*, *add*, *mid*, *div*) | *mid* |
| 2 | tables, distance, *disty* (gap to heaven) | *dist*, goals |
| 3 | fastmap poles, projection, recursive halving | *project*, *cluster* |
| 4 | cuts scored by expected diversity; trees; XAI | *DISTINGUISH* |
| 5 | budgets, acquire, restart, holdout | plan + monitor, looped |
| 6 | cohen, cliffs, ks, ranks, domination, wins | *delta*, *same()* |
| 7 | knn, anomaly, naive Bayes, kmeans, kpp | *relevant*, and the rules above |
| 8 | ga, de, sa, local search, race | *sample*, and the loop again |
| 9 | the model seam, DTLZ | simulation, with known right answers |

-

**The one machine.** Read down this picture and every week is
in it:

<pre>rows (x cheap, y expensive)<br>  |<br>  +-- distx -----&gt; poles -----&gt; projection -----&gt; halve<br>  |                                                  |<br>  |                                            recurse = tree<br>  |                                                  |<br>  +-- disty (buys labels) --&gt; better half only --&gt; acquire<br>                                                     |<br>                              leaf -&gt; mean = regression<br>                              leaf -&gt; mode = classification<br>                              far from leaf = anomaly / alert<br>                              read the tree  = summarization / XAI<br>                              mutate + re-drop = forecast / what-if</pre>

--- #falsify

### How you can prove this wrong

---

The claim is falsifiable, and the undergraduate project is the
experiment: build the skills in order, tag each step, and plot
the percentage of NEW code per step. If the core is real the
bars fall &mdash; each new task is a few lines pointing an old
aiming somewhere new. If the bars stay flat, this course's
architecture lost &mdash; and an honest flat histogram scores
full marks, because failures are findings.

-

The rival is easy to run: ask an LLM for each skill cold, one
fresh prompt per skill, with no instruction to reuse anything.
The prediction to beat is a thousand lines of new glue per
skill, ten separate programs, each hooked into a large library.

--- #skills

### The ten skills, desugared and assessed

---

The project scores ten skills. Here is each one four ways: its
harness name re-labeled in core vocabulary; what a used car yard
manager would actually ask for; what the scorer does to it; and
the number Q it earns. The middle columns are surface. Column
one is the core. The last column is the part most students skip
&mdash; and it is the most reusable thing on this page.

| skill | the yard asks | the scorer does | Q (higher is better) |
|-------|---------------|-----------------|----------------------|
| 1 remember = *retrieval* | "Pull a short list of cars like our best sellers ever." | Skill returns up to 5% of the rows it judges best. | 1 &minus; (median score of the returned rows &divide; median score of random sets of the same size). Baseline 0. |
| 2 guess = *regression* | "No sticker on this trade-in &mdash; estimate its mpg from cars like it." | 30 train/test splits; predicts the target on held-out rows. | Average of 1 &minus; (error &divide; error of predicting the training average). Baseline 0. |
| 3 certify = *same()* | "This month's trade-ins feel different from last month's. Really, or just noise?" | 200 pairs of samples: half the same, half shifted by 0.5, 1 or 2 sd; three shapes; sizes 10, 30, 100. | Balanced accuracy of saying "same" or "different". Chance = 0.5. |
| 4 flow = *disty*, streamed | "At auction the cars roll past once. Bid the moment you see a good one &mdash; no going back." | 100 random arrival orders; must commit to a row the moment it is read (no look-ahead). | Average of 1 &minus; (chosen row's score &divide; average score of the stream). Baseline 0. |
| 5 blame = *explanation* | "The yard lost money this quarter. Which features of the cars we stocked did it?" | Names predictor columns and rules that explain a poor score. | Rewrite the blamed cells to values no row blames; re-score. Q = (old score &minus; new score) &divide; old score, minus the same delta from rewriting as many random columns. Baseline 0. |
| 6 justify = *disty* percentile + *explanation* | "How good is this car, really &mdash; and why should I believe you?" | 20 rows from the best quarter; skill returns a score percentile and a text reason. | Improvement over always answering 0.5: (error of 0.5 &minus; error of the answer) &divide; error of 0.5. Baseline 0. |
| 7 choose = *optimization* | "You can afford 50 mechanic inspections. Find me the best car on the lot." | 30 runs; may look at no more than 50 labels; returns the best row it found. | Win rate against the best of 50 random rows: win 1, tie 0.5, loss 0. Chance = 0.5. |
| 8 fix = *planning* | "These 20 clunkers will not sell. What can we actually change &mdash; price, tires, detailing?" | 20 worst-quartile rows; skill returns a change to allowed lever columns only. | Share of the 20 with a valid change (levers only, values in range). It does not measure improvement. |
| 9 spot = *anomaly* | "Odometer readings get typed in by hand. Find the entries that look wrong." | 30 copies of 1,000 rows with 10 injected errors; skill returns suspect rows. | Precision at 20: hits among the first 20 returned &divide; 20. Chance &asymp; 0.01. |
| 10 race = *benchmarking* | "Three consultants swear by three buying strategies. Same budget each; who wins?" | 30 runs; must race at least 3 strategies, one random, within 50 labels. | Win rate of the returned winner against random-50 (win 1, tie 0.5, loss 0). Invalid race counts as failed. |

"Score" throughout is the domain's combined objective &mdash;
*disty*, lower is better. A call that fails earns the baseline
value in the primary analysis: crashing is not a way to sit out
a round.

-

**How to read the Q column.** Every Q is the same three moves,
and together they are how you assess any system designed this
way. First, pick a dumb rival that costs nothing: random rows of
the same size, the training average, chance, always answering
0.5. Second, scale against that rival so 0 means "no better than
dumb" and higher is better &mdash; now every number carries its
own baseline. Third, score failures at the baseline, so a crash
and a useless answer cost the same. That is week 6 pointed at
your own code: no score without a rival, no number without a
zero, no silent failures. Blame gets the strictest test of all:
an explanation is assessed by acting on it &mdash; rewrite what
was blamed, re-score, and beat the rival of rewriting as many
random columns. An explanation that changes nothing when acted
on explained nothing. One wrinkle remains &mdash; each skill
has its own scale and baseline &mdash; so before comparing
conditions, the analysis re-expresses Q as Z within each domain
and skill.

--- #ideas

### Ideas worth carrying out of here

---

- **x is cheap, y is expensive.** Almost everything in this
  course follows from that one asymmetry.
- **Surface is vocabulary, core is work.** Before learning a
  "new" technique, ask what it desugars to.
- **Weak indicators, hedged.** A cheap heuristic is evidence,
  not truth: ask it more times, or act on it more gently.
- **Before optimizing a computation, ask how little data it
  needs.** Poles from 128 rows; cuts from a sample; prototypes
  instead of rows.
- **Support, not just purity.** A split that isolates one row
  explains nothing.
- **Say what it cost.** A score without its label count, or
  without saying pure-vs-generalize, is not a result.
- **Ties are the normal case.** Rank 0 is usually a set. So is
  a Pareto front.
- **Know when you do not know.** The certification envelope is
  three lines and it is the difference between a useful model
  and Crater.
- **Explanations must be actionable.** Not "tires are
  important" &mdash; *bald* tires.

-

**Where to look things up.** Principles and weeks 0-2:
[gloss1](gloss1.html). The Lua machinery under the demos:
[gloss2](gloss2.html). Clustering: [gloss3](gloss3.html). Cuts
and trees: [gloss4](gloss4.html). Active learning:
[gloss5](gloss5.html). Statistics: [gloss6](gloss6.html).
Applications: [gloss7](gloss7.html). Optimizers:
[gloss8](gloss8.html). Models and the seam:
[gloss9](gloss9.html). The full text of every entry lives in
one file: [glossary.md](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md).

@ [Buse & Zimmermann: Information needs for software development analytics](https://doi.org/10.1109/ICSE.2012.6227122). Raymond P.L. Buse, Thomas Zimmermann. ICSE 2012.

@ [Hoffman, Mueller, Klein & Litman: Metrics for explainable AI: challenges and prospects](https://arxiv.org/abs/1812.04608). Robert R. Hoffman, Shane T. Mueller, Gary Klein, Jordan Litman. arXiv:1812.04608, 2018.

.
