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

# How to find a research question (retired gproj track)

*Parked here when the grad project became the shrinking-code
experiment (see [gproj.md](../submit/gproj.md)). Kept because the
method is good: use it whenever you need to turn a course report
into a real paper.*

## Step 1 — find a question

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

**2. Find the [knee](../lect/glossary.md#knee).** Why a knee is enough:
in any field of *N* researchers, about *√N* of them write the artifacts
half the field uses; the rest is bottle-washing (re-measuring,
re-tuning, re-reporting). Reading above the knee is how you find the
√N. Sort your top ~100 hits by citation count and plot
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
