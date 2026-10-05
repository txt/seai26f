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

# Undergraduate Project: the Shrinking-Code Demos

**Team:** your group (three-ish). One submission per group. The two
cohorts differ only in scope: 491 builds one domain, 591 builds
three (see "The corpora").
**Due:** last class (Mon Nov 30). One deliverable, no intermediaries.
**Hand in:** one PDF to Moodle: the report (ACM transactions
format; 491: 3 pages, 591: 6 to 9 pages), repo URL on page one.

## The hypothesis, and its rival

Everything below tests one claim. State it, and its rival, on the
first page of your report:

> **The Timm hypothesis.** Neuro-symbolic systems improve when
> their symbolic half is factored into small reusable structures.
> The ten skills are [synonyms](../lect/glossary.md#synonyms): one
> machine (cluster, tree, leaf) wearing ten hats. Hence an LLM, or
> a human, extends a well-factored library with less new code, and
> fewer errors, than a monolithic one.

> **The rival.** The ten skills are ten separate problems. Factoring
> buys nothing: skill i+1 costs about the same whoever writes it,
> and whatever library sits underneath.

The falsifiable prediction is the shape of your new-code histogram:
if the bars fall, reuse is real; if they stay flat, the rival wins.
Either way you score — honest negative results are findings.

## The big picture

This project is requirements engineering, then an architecture
payoff. Four moves:

1. **Pick a domain** that [MOOT](https://github.com/timm/moot) data
   supports: buying cars (`misc/auto93.csv`), tuning a database or
   video encoder (`config/SS-*.csv`, `config/X264_AllMeasurements.csv`),
   estimating software projects (`process/nasa93dem.csv`,
   `process/coc1000.csv`), designing a development process
   (`process/pom3*.csv`, `process/xomo*.csv`), predicting open-source
   project health (`hpo/Health-*.csv`)... Browse the whole shop at
   [moot/optimize](https://github.com/timm/moot/tree/master/optimize).
   Fair warning: some data sets will just laugh at you — nothing
   learns, nothing shrinks. That is a negative result, not a
   disaster: report it honestly and it scores.
2. **Write a requirements doc**: twenty skills a customer might ask
   of an AI in that domain. One line each, in domain words, not
   algorithm words ("find me a great car cheap", not "run NSGA-II").
   Tag each skill with the corpus cell (below) it will demo. Put
   this doc at `docs/requirements.md` in your repo.
3. **Build the skills in steps** (step1, step2, ...), each step
   git-tagged. If your architecture is right, each step reuses the
   machinery of the steps before it, so step[i+1] needs less new
   code than step[i].
4. **Hand in** a report (sections below) whose histograms and
   `same` tables deliver a verdict on the hypothesis.

## The corpora

Three corpora. The first two are vocabularies to mine; the third is
the assignment:

- **Corpus A — analytics.** Figure 6 of
  [Buse & Zimmermann, ICSE 2012](../lect/buse-icse-2012.pdf): nine
  analyses in a 3×3 grid — Trends, Alerts, Forecasting; Summarization,
  Overlays, Goals; Modeling, Benchmarking, Simulation.
- **Corpus B — explanation.** Figure 1 and Tables 1–2 of
  [Hoffman et al., Metrics for XAI](../lect/xai.pdf): the explanation
  triggers — *how does it work? what did it just do? why not z? what if
  x were different?* — plus the goodness and satisfaction measures that
  score the answers.
- **Corpus C — a domain you invent.** Pick a client and write their
  wish list: 10 to 20 things they want to know. A car yard ("which
  cars sell? which listing is a scam? what happens to price if I
  restock?"), a swimming coach ("who is about to quit the team?"), a
  hospital roster, a game studio. The list must be written down before
  you code, and it must be honest work for the client, not ten
  restatements of one query. Get the list okayed by the lecturer.

How many Corpus C's?

- **CSC 491 (undergraduate): one.** One client, one wish list, one
  MOOT data set — every skill tagged with the Corpus A or B cell it
  demos.
- **CSC 591 (graduate): three.** Three different clients on three
  different MOOT data sets, one shared codebase. The synonyms claim
  says your machinery transfers: by the third domain you should be
  writing almost nothing except the wish list.

Build an **impressive sequence of small demos** that covers your
corpus, running on your chosen MOOT data.

**The rule of the game:** work in steps — step1, step2, step3... If your
architecture is right, each step reuses the machinery of the steps
before it, so **step[i+1] needs less new code than step[i]**. A
summarizer feeds the trend-spotter; the trend-spotter feeds the alerter;
the alerter's stats feed the forecaster. By the last step you should be
writing almost nothing and demoing something amazing.

Tag each step in git (`step1`, `step2`, ...). That history is marked.

## Worked example: ten asks from a car yard

[The course intro](https://txt.github.io/seai26f/hello.html) plays
this exact game with MOOT's `misc/auto93.csv` (398 cars; goals:
light, quick, economical). Ten customer asks, each mapped to a
skill, with the cost of each skill measured as new lines of code:

| task                                            | skill                     | %LOC | new LOC |
|-------------------------------------------------|---------------------------|-----:|--------:|
| From 400 cars, find unusually great buys.       | remember (representation) |  45% |     150 |
| Guess the fuel use before we see the sticker    | guess (prediction)        |  17% |      57 |
| Say when "better" is real, and when it is noise | certify (certification)   |  12% |      40 |
| Decide on the spot as cars arrive one at a time | flow (streaming)          |   8% |      27 |
| Say why the bad cars are slow, or thirsty       | blame (diagnosis)         |   6% |      20 |
| Justify any verdict to a skeptical buyer        | justify (explanation)     |   4% |      13 |
| Find the best car, test-driving very few        | choose (optimization)     |   3% |      10 |
| Find the cheapest change that fixes this car    | fix (repair)              |   3% |      10 |
| Spot a strange car: a typo, or a scam           | spot (anomaly detection)  |   2% |       6 |
| Race our skills against the field's best        | race (baselining)         |   0% |       0 |
| **Totals**                                      |                           | **100%** | **333** |

The first skill costs 45% of the code: it pays for the data
structures everything shares. After that, each new skill mostly
rewires old parts. That falling right-hand column IS your
histogram, done right.

## Same game, other data

Swap the data set and the nouns change — but the skills do not.
That is the whole trick. **Tuning a database server**
(`config/SS-M.csv`: 864 configs of encryption, caching, logging
options; goals: less energy, less time, less cpu):

| task                                                   | skill    |
|--------------------------------------------------------|----------|
| From 800+ configs, find the unusually green ones       | remember |
| Guess the energy bill before running the benchmark     | guess    |
| Say when "faster" is real, and when it is noise        | certify  |
| Judge configs as benchmark results stream in           | flow     |
| Say why the slow configs burn so much cpu              | blame    |
| Justify a recommended config to a skeptical admin      | justify  |
| Find the best config, benchmarking very few            | choose   |
| Find the smallest settings change that fixes a slow box| fix      |
| Spot a benchmark run that looks like a glitch          | spot     |
| Race our tuner against the field's best                | race     |

**Estimating software projects** (`process/nasa93dem.csv`: 93 NASA
projects described by COCOMO attributes; goals: more code, less
effort, fewer defects):

| task                                                    | skill    |
|---------------------------------------------------------|----------|
| From 93 past projects, find the unusually productive    | remember |
| Guess effort and defects before the project starts      | guess    |
| Say when one practice really beats another              | certify  |
| Assess new project proposals as they arrive             | flow     |
| Say why the troubled projects blew their budgets        | blame    |
| Justify an estimate to a skeptical manager              | justify  |
| Find project settings giving most code for least pain   | choose   |
| Find the cheapest process change rescuing a risky project| fix     |
| Spot a project record that is a typo, or a lie          | spot     |
| Race our estimator against the field's best             | race     |

Your requirements doc does this for your domain, then grows the
list to twenty. Getting from ten to twenty is where your corpus
earns its keep: each of Buse's nine analyses, and each of Hoffman's
triggers and measures, is a customer ask waiting to be phrased in
your domain's words.

**What is being tested** is the hypothesis at the top of this page.
The rival gets its day in court via the no-reuse treatments in the
experiment below: ask an LLM for each skill cold, one fresh prompt
per skill, and plot its new-code-per-step beside yours.

## Example ladders (yours may differ)

**Corpus A:** load+summarize a MOOT csv → trends (regression over
releases) → alerts (anomaly = far from trend) → forecast (extrapolate
the trend) → overlays (correlate two indicators) → goals (which
indicator moved us toward/away from target) → modeling (learn
normal-vs-odd) → benchmarking (significance test between two projects)
→ simulation (what-if: perturb a config, rerun the pipeline).

**Corpus B:** train a tiny model on a MOOT csv → global explanation
("how it works": rules or feature ranks) → local explanation ("what did
it just do" for one row) → contrastive ("why not z") → counterfactual
("what if x were different") → error modes ("when will it get it
wrong") → goodness checklist auto-scored on your own explanations →
satisfaction scale run on three humans.

## The experiment: seven ways up the ladder

Climbing the ladder once proves nothing. So climb it seven ways —
six with an LLM, one by hand:

| # | who writes skill i+1 | background code given | told to reuse skills 1..i? |
|--:|----------------------|----------------------|:--:|
| 1 | LLM | plain Python           | no  |
| 2 | LLM | plain Python           | yes |
| 3 | LLM | scikit-learn           | no  |
| 4 | LLM | scikit-learn           | yes |
| 5 | LLM | ezr                    | no  |
| 6 | LLM | ezr                    | yes |
| 7 | you | your own prior skills  | reuse as much as you can |

In every treatment the game is the same: to get skill i+1, supply
the background library, the code for skills 1..i, and the one-line
requirement — then measure how much new code appears, and how well
the result runs. Treatment 7 is your control: a human trying their
hardest to reuse.

## Repeats, and the reset rule

Run the whole thing N times. Each trial must face an LLM that
remembers nothing of the trials before it — otherwise trial 2 is
just trial 1 with a warm start. To reset: use one-shot headless
calls (`claude -p`, or the API with an empty history); keep memory
features off; no CLAUDE.md; one fresh directory per trial. A new
chat window is NOT enough if memory or project context is on.

How big is N? Twenty is the dream. Ten earns congratulations.
Three is the floor below which there are no statistics, only
anecdotes.

## Only report real differences

Two treatments will never print identical numbers; that is noise,
not news. Compare treatments with `same`
([ezr.lua](../../src/ezr-lua/ezr.lua): the Cohen + Kolmogorov-Smirnov
+ Cliffs-delta test, demoed in eg6 `--same`; see also
[these notes](https://claude.ai/artifact/4FHa7wnqRgLff1jAx58cj9#54488ac0-a3ee.m2a52yavgxa.78)).
Report a difference only when `same` says there really is one.

## When ezr loses (it will, at first)

Expect the first-pass ezr treatments to disappoint. Out of the box,
ezr is untuned for your data. Fixing that is part of the project:

- **(a) Wire up the oracle.** `TBL:label` in ezr.lua is the hook:
  handed a row whose goals are "?", it asks `i.model` for the
  answers. Tweak that function so an unseen row actually runs
  something — your pipeline, your simulator, your benchmark — with
  parameters you control.
- **(b) Tune ezr with ezr.** Build a MOOT-style csv where each row
  is a random pick of ezr's low-level controls (`few`, `p`, `keepf`,
  `leaf`, `maxd`, `more`, `stop` — NOT the meta controls `budget`
  and `check`) and the goal columns score how well that pick
  performs. Then point ezr at its own tuning data.

If tuned ezr still loses, say so. Honest negative results score;
hidden failures cost more.

## The report

One PDF, ACM transactions format (LaTeX `acmart`; Overleaf has the
template). **491: 3 pages. 591: 6 to 9 pages** (three domains need
the room). Repo URL on page one; the repo is public, steps tagged,
tests exist, requirements doc at `docs/requirements.md`, README
runs every demo in one command each. These five section headers,
in this order:

1. **Hypotheses.** The Timm hypothesis and its rival, verbatim from
   the top of this page, then one paragraph: your domain(s), your
   data, and what result would make each side win.
2. **Requirements.** The twenty customer asks (591: per domain),
   each tagged with its skill and its Corpus A/B cell.
3. **Methods.** The seven treatments, the reset protocol you
   actually used, your N, and any ezr tuning (the oracle rewire,
   the self-tuning csv).
4. **Results.** The histograms — x-axis: step; y-axis: % new code,
   from your git tags (`git diff --stat step2..step3`, or cloc per
   tag), one line per treatment — and the `same` tables.
5. **Discussion.** The verdict: which hypothesis won, where, and
   why — using only differences your `same` tables certify. Honest
   failures belong here, not in a drawer.

## Rubric (25 marks)

One row per report section, plus the repo and the disclosure:

| Marks | Section | For | 3-point check |
|------:|---------|-----|---------------|
| 2 | **Hypotheses** | both claims stated, win conditions named | verbatim + win conditions = 2; paraphrased or one-sided = 1 |
| 5 | **Requirements** | 20 asks in customer words, all tagged (591: ×3 domains) | all = 5; two-thirds = 3; algorithm words = 1 |
| 4 | **Methods** | seven treatments, documented resets, N declared | all three = 4; shared contexts = 1 |
| 6 | **Results** | histograms derivable from tags, `same` on every comparison | N≥10 = 6; N=3 = 3; claims without `same` = 0 |
| 3 | **Discussion** | verdict follows from the tables; honest negatives score full | conclusions the tables do not support = 0 |
| 2 | **The repo** | tags, tests, one-command demos | a demo that only "ran once" = 0 |
| 3 | **AI disclosure** | what the LLM wrote, which of its errors you caught | zero caught errors reads as zero checking |

Ways to lose marks: a histogram not derivable from the repo's tags;
steps that share nothing (nine little programs is not a ladder); code
dumped in one final commit; a requirements doc written in algorithm
words instead of customer words; trials that shared an LLM context
(that is one trial, counted once); a "difference" between treatments
that `same` calls noise; a report over the page limit.
