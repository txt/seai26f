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

# Graduate Project: a Research Paper, with Receipts

**Team:** your grad group (three-ish).
**Runs:** the last six weeks, Oct 26 to Nov 30.
**Deliverables:** initial (Mon Nov 9, 5 marks) and final (Mon Nov 30,
34 marks). Your task talk presents this work.

This project must be **far more creative** than the undergrad project.
Undergrads execute a defined corpus. You invent a question, pre-register
its eval, run the experiment, and defend the result in a research paper.

## Step 1 — find a question (before Oct 26; get "ok to go" from the lecturer)

- Start at Table II of
  [arXiv:2607.11705](https://arxiv.org/pdf/2607.11705) (the optimizer
  tournament) or the course [tools list](../lect/tools.md); or start at
  [arXiv:2511.16882](https://arxiv.org/pdf/2511.16882), Table 2.
- Poke around Google Scholar. Focus on the
  [top SE venues](https://scholar.google.com/citations?view_op=top_venues&hl=en&vq=eng_softwaresystems),
  mostly papers since 2015 — but grab anything seminal or uber-cool.
- Save your search strings. Write down the citation counts of the top
  100 hits. Sort them. Find the **knee** (the bend furthest from the
  line joining first to last point).
- Read, in detail, everything above the knee (expect 10 to 30 papers).
  Divide them on four or five big properties. Draw the Venn diagram of
  the groups and their overlaps — an empty middle is a finding: that is
  the unexplored region.
- Your question lives in that empty region.

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
| 5 | Background | motivation (is the problem real?), related work organized by your knee groups, origin of data |
| 5 | Methods | variables and metrics defined; selection of data sets and magic parameters justified; steps replicable |
| 6 | Results | experimental rig; what was seen, judged against the pre-registered claim |
| 4 | Discussion | implications; an explicit validity-threats section; future work |
| 3 | Honest failure handling | negative or messy results diagnosed, not hidden; goalpost moves logged |
| 4 | Replication artifacts | a public repo with all scripts and data; a stranger can rerun the headline table (e.g. [KKGanguly/NEO](https://github.com/KKGanguly/NEO)) |
| 3 | Writing and format | sigconf, 3–5 pages, readable by a non-expert in your niche |

Ways to lose marks: a question with no knee evidence behind it; a
baseline you wrote yourself when a reproduction package existed; results
that dodge the pre-registered claim; a repo the marker cannot run.
