title: Glossary 10: SE for AI
icon: 🧩
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

<style>:root { --back-color: rgb(24, 31, 43); } pre { background: rgba(212,212,212,0.07); border: 1px solid rgba(212,212,212,0.25); padding: 10px 14px; margin: 20px 0; font-size: 0.85em; line-height: 1.4; overflow-x: auto; } pre .k { color: #79b8ff; } pre .s { color: #e0b06a; } pre .c { color: #8ac28a; font-style: italic; } pre .f { color: #d2a8ff; }</style>

# A glossary of tiny lectures, part 10

## Revision: one machine, many names

#### By [Tim Menzies](https://timm.fyi), published 2026-11-09, updated 2026-11-09

**Summary:** *No new terms here. This page is the map: what
each week bought, how the pieces stack into one machine, and
the claim the whole course exists to test &mdash; that most of
the "different" tools in a data mining textbook are the same
tool, wearing hats. Read this before the final, and before you
write up either project.*

--- #stack

### The stack, in one page

---

Every week added one layer, and every layer used only the ones
below it.

| week | what it added | what that bought |
|------|---------------|------------------|
| 1 | columns that summarize as they read (*Num*, *Sym*, *add*, *mid*, *div*) | O(1) memory, and summaries that subtract |
| 2 | tables, distance, *disty* (gap to heaven) | one number for "how good is this row" |
| 3 | fastmap poles, projection, recursive halving | structure with no labels, and an index |
| 4 | cuts scored by expected diversity; trees; XAI | a model small enough to argue with |
| 5 | budgets, acquire, restart, holdout | good rows for about 45 labels, honestly scored |
| 6 | cohen, cliffs, ks, ranks, domination, wins | the right to say "this one is better" |
| 7 | knn, anomaly, naive Bayes, kmeans, kpp | the textbook chapters, a dozen lines each |
| 8 | ga, de, sa, local search, race | fifty years of search, and its price tag |
| 9 | the model seam, DTLZ | goals that cost money, and known right answers |

-

**The one machine.** Read down this picture and every week is
in it:

<pre>rows (x cheap, y expensive)<br>  |<br>  +-- distx -----&gt; poles -----&gt; projection -----&gt; halve<br>  |                                                  |<br>  |                                            recurse = tree<br>  |                                                  |<br>  +-- disty (buys labels) --&gt; better half only --&gt; acquire<br>                                                     |<br>                              leaf -&gt; mean = regression<br>                              leaf -&gt; mode = classification<br>                              far from leaf = anomaly / alert<br>                              read the tree  = summarization / XAI<br>                              mutate + re-drop = forecast / what-if</pre>

--- #synonyms

### The synonyms claim

---

Buse & Zimmermann's analytics grid has nine boxes; the
explanation literature has its own list of triggers. The claim
is that those lists collapse:

| they call it | we call it |
|--------------|------------|
| classification | the leaf's mode |
| regression, forecasting | the leaf's mean |
| optimization, tuning | keep the better half, recurse |
| alerts, anomaly detection | far outside the leaf's own spread |
| benchmarking | anomaly detection, with a reference population |
| simulation, what-if, goals | mutate x, re-drop, read the new leaf |
| summarization, overlays | read the tree |
| privacy | publish the corner (prototypes of the columns that matter) |
| explanation | the tree is the explanation |

-

**How you can prove this wrong.** The claim is falsifiable, and
the undergraduate project is the experiment: build the skills in
order, tag each step, and plot the percentage of NEW code per
step. If reuse is real the bars fall. If they stay flat, this
course's architecture lost &mdash; and an honest flat histogram
scores full marks, because failures are findings.

The rival is easy to run: ask an LLM for each skill cold, one
fresh prompt per skill, with no instruction to reuse anything.
The prediction to beat is a thousand lines of new glue per
skill, ten separate programs, each hooked into a large library.

--- #ideas

### Ideas worth carrying out of here

---

- **x is cheap, y is expensive.** Almost everything in this
  course follows from that one asymmetry.
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
