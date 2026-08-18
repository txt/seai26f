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

# Graduate Project: a Research Paper, with Receipts

**Team:** your grad group (three-ish).
**Runs:** the last six weeks, Oct 26 to Nov 30.
**Deliverables:** initial (Mon Nov 9, 5 marks) and final (Mon Nov 30,
34 marks). Your task talk (15 marks, Nov 16 or Nov 23) presents this
work.

## The task talk (15 marks)

Twenty minutes: aim for 15, leaving 5 for questions. The talk
reviews your project so far: the question, the pre-registered
claim (metric, threshold, baseline), what has run, what the
evidence says, and your verdict (persevere, re-plan, descope).
Write it in Google Slides, public to everyone, editable by
timm@ieee.org; discuss it with the lecturer the week before.

| Marks | For | Check |
|------:|-----|-------|
| 3 | **The question + claim**: stated first, with metric, threshold, baseline | a stranger could rerun the bet |
| 3 | **The evidence**: what ran, on what data | real data tops the range; synthetic clearly labelled |
| 3 | **The verdict**: results against the claim, honestly | a failed claim with a recorded decision loses nothing; a hidden one loses everything |
| 2 | **Discussed with lecturer the week before** | no discussion = 0 |
| 2 | **Timing**: done in 15, left 5 minutes for questions | running past 20 = 0 |
| 2 | **Slides + delivery**: Google Slides public and editable by timm@ieee.org; in person, whole group on stage | |

Ways to lose marks: claim stated nowhere (or invented after the
results); evidence that cannot be traced to the repo; no time
for questions; slides the lecturer cannot open.

This project must be **far more creative** than the undergrad project.
Undergrads execute a defined corpus. You invent a question, pre-register
its eval, run the experiment, and defend the result in a research paper.

## Step 1 — find a question (before Oct 26; get "ok to go" from the lecturer)

How to read a literature, in five moves. (This is the short form; the
long form, with a worked end-to-end example, is
[how2write.pdf](../lect/how2write.pdf).)

**1. Search inside your field's venues.** Start at Table II of
[arXiv:2607.11705](https://arxiv.org/pdf/2607.11705) (the optimizer
tournament) or the course [tools list](../lect/tools.md); or at
[arXiv:2511.16882](https://arxiv.org/pdf/2511.16882), Table 2. Then run
queries restricted to the
[top SE venues](https://scholar.google.com/citations?view_op=top_venues&hl=en&vq=eng_softwaresystems),
mostly papers since 2015. The venue filter is not optional: unfiltered,
your top hits will be blockbusters from nowhere near SE (in one run of
this method, only nine of the top 1,000 unfiltered hits were SE papers).
Save your search strings — they go in the paper.

**2. Find the knee.** Sort your top ~100 hits by citation count and plot
the curve. Draw the chord from the most-cited to the least-cited paper;
the **knee** is the point on the curve furthest from that chord.
Worked example: one 249-paper search gave a knee of 23 papers, all with
31+ citations. Everything above the knee is your reading set — expect
10 to 30 papers. Add a few **seeds** below the knee if you must (an
anchor paper per theme, admitted regardless of citations — say which,
and why).

**3. Snowball, unfiltered.** From the reading set, chase references
backward (the classics) and citations forward (the newest work) —
deliberately ignoring the venue filter this time, since good ancestors
and good critics live anywhere. A low full-text download rate is normal
(one run retrieved 41%); report the rate, never silently drop the
missing papers.

**4. Code the set; draw the Venn.** Read the above-knee papers in
detail. Tag each with three or four topic flags (your field's big
properties). Draw the Venn diagram of the flags: count the papers in
each region. **The empty (or near-empty) region is the finding** — a
combination the field talks about but nobody studies. That corner is
the unexplored territory, and each empty cell is an address for a next
paper.

**5. Point your question at the empty region.** One sentence: "the
literature does X and Y but never X-and-Y under Z; we ask..."

When you write this up (the Background section), use the
respect-then-disrespect shape: first say clearly what prior work did
and what was good about it; then say, just as clearly, why it is not
good enough for *this* task — naming the mismatch (wrong assumptions,
wrong data, wrong question). End with the pivot: "based on the above,
the open issues are...; this paper addresses the first two." Everything
later in the paper must trace back to that pivot.

## Step 2 — stand on the shoulders of giants

- In your above-the-knee papers, hunt for **reproduction packages**.
  Get them running. Warnings from bitter experience: only a third will
  run, and of those only half run fast enough for a six-week project.
- Show baseline results from a running package. That running baseline
  is your launchpad — extend it, do not rebuild it.

## Step 3 — pre-register the eval

Before the experiment, write the claim: **metric, threshold, baseline**,
and the instrument (a runnable script) that will measure it. Failures
are findings: a pre-registered claim that fails, with an honest
diagnosis, scores; a hidden failure does not.

## Initial deliverable (Mon Nov 9, 5 marks)

*Something must work.* Hand in one page + repo:

| Marks | For |
|------:|-----|
| 2 | The question, with knee evidence: search strings, sorted citation counts, the above-the-knee reading list, the Venn |
| 2 | A reproduction package running, with baseline numbers |
| 1 | The pre-registered claim: metric, threshold, baseline, instrument |

## Final deliverable (Mon Nov 30, 34 marks)

A research paper: LaTeX, `\documentclass[sigconf,nonacm]{acmart}`,
3–5 pages of text plus up to 2 pages of references. PDF to Moodle,
plus the replication repo.

| Marks | Section | The marker asks |
|------:|---------|-----------------|
| 4 | Introduction | clear goal, stated research questions, list of contributions |
| 5 | Background | motivation (is the problem real?); related work in the respect-then-disrespect shape, organized by your Venn groups, ending in the pivot your paper answers; origin of data |
| 5 | Methods | variables and metrics defined; selection of data sets and magic parameters justified; steps replicable |
| 6 | Results | experimental rig; what was seen, judged against the pre-registered claim |
| 4 | Discussion | implications; an explicit validity-threats section; future work |
| 3 | Honest failure handling | negative or messy results diagnosed, not hidden; goalpost moves logged |
| 4 | Replication artifacts | a public repo with all scripts and data; a stranger can rerun the headline table (e.g. [KKGanguly/NEO](https://github.com/KKGanguly/NEO)) |
| 3 | Writing and format | sigconf, 3–5 pages, readable by a non-expert in your niche |

Ways to lose marks: a question with no knee evidence behind it; a
baseline you wrote yourself when a reproduction package existed; results
that dodge the pre-registered claim; a repo the marker cannot run.
