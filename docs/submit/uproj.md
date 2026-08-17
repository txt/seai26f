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
  <a href="https://discord.gg/uQgTnGsfR"><img 
      src="https://img.shields.io/badge/Chat-%23008080?style=flat-square&logo=discord&logoColor=white" /></a>
  <a href="https://github.com/txt/seai26f/blob/main/LICENSE.md"><img 
      src="https://img.shields.io/badge/©%20timm%202026-%234b4b4b?style=flat-square&logoColor=white" /></a></p>
<h1 align="center">:cyclone: CSC491/591: SE for AI <br>NC State, Fall '26</h1>
<img src="https://raw.githubusercontent.com/txt/seai26f/refs/heads/main/etc/img/seai26f.png">

# Undergraduate Project: the Shrinking-Code Demos

**Team:** your ugrad group (three-ish). One submission per group.
**Due:** last class (Mon Nov 30). One deliverable, no intermediaries.
**Hand in:** repo URL + a video (5 minutes MAX — watching stops at
5:00) + one histogram (details below), as one PDF/links page to
Moodle.

## The idea

Pick ONE corpus:

- **Corpus A — analytics.** Figure 6 of
  [Buse & Zimmermann, ICSE 2012](../lect/buse-icse-2012.pdf): nine
  analyses in a 3×3 grid — Trends, Alerts, Forecasting; Summarization,
  Overlays, Goals; Modeling, Benchmarking, Simulation.
- **Corpus B — explanation.** Figure 1 and Tables 1–2 of
  [Hoffman et al., Metrics for XAI](../lect/xai.pdf): the explanation
  triggers — *how does it work? what did it just do? why not z? what if
  x were different?* — plus the goodness and satisfaction measures that
  score the answers.

Build an **impressive sequence of small demos** that covers your corpus,
running on example data from [MOOT](https://github.com/timm/moot)
(config tuning, effort estimation, project health...).

**The rule of the game:** work in steps — step1, step2, step3... If your
architecture is right, each step reuses the machinery of the steps
before it, so **step[i+1] needs less new code than step[i]**. A
summarizer feeds the trend-spotter; the trend-spotter feeds the alerter;
the alerter's stats feed the forecaster. By the last step you should be
writing almost nothing and demoing something amazing.

Tag each step in git (`step1`, `step2`, ...). That history is marked.

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

## What to hand in

1. **The repo.** Public. Steps tagged. Tests exist. A README that says
   how to run every demo in one command each.
2. **The video (5 minutes, hard cap).** Every step demoed, live, in
   order. Narrate what each step adds and what it reuses.
3. **The histogram.** X-axis: step number. Y-axis: % of that step's code
   that is NEW (not reused from earlier steps). Compute it from your git
   tags (e.g. `git diff --stat step2..step3`, or cloc per tag). If your
   design is right, the bars fall.

## Rubric (25 marks)

| Marks | For | 3-point check |
|------:|-----|---------------|
| 6 | **Coverage**: how much of the corpus is demoed | all cells = 6; two-thirds = 4; half = 3 |
| 6 | **The shrink**: falling histogram, honest git tags | bars fall steadily = 6; flat = 3; rising or untagged = 0 |
| 6 | **The video**: 5 min, every demo runs, story is clear | a stranger sees why step N was cheap = 6 |
| 3 | **Code quality**: tests, small, readable | |
| 4 | **AI disclosure**: what the LLM wrote, which of its errors you caught | zero caught errors reads as zero checking |

Ways to lose marks: a demo that only runs in the video; a histogram not
derivable from the repo's tags; steps that share nothing (nine little
programs is not a ladder); code dumped in one final commit.
