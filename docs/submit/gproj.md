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

# Graduate Project: the Shrinking-Code Experiment, at Scale

**Team:** your grad group (three-ish).
**Runs:** the last six weeks, Oct 26 to Nov 30.
**Deliverables:** initial (Mon Nov 9, 5 marks) and final (Mon Nov 30,
34 marks). Your task talk (15 marks, Nov 16 or Nov 23) presents this
work.

## The project

Read [uproj.md](uproj.md) first — all of it. The grad project is
that experiment at triple scope:

- **Three invented domains.** Three different clients, three
  different MOOT data sets, one shared codebase. The synonyms claim
  says your machinery transfers across domains; prove or refute it.
- **Seven treatments, N repeats, `same` tables** — exactly as
  uproj.md specifies, run across all three domains.
- **One report**, 6 to 9 pages, ACM transactions format, the five
  section headers from uproj.md.

The research question is given: the Timm hypothesis versus its
rival, stated at the top of uproj.md. Your creativity goes into the
domains, the clients' wish lists, and the honesty of the
evaluation. The eval is pre-registered: both hypotheses and their
win conditions are written down before you code — that is your
claim (metric: new-code-per-step and `same`-certified wins;
baseline: the no-reuse treatments) — and the final report delivers
a verdict against it. Failures are findings: a domain that laughs
at you, honestly diagnosed, scores; a hidden failure does not.

(The old research-paper track — knee-finding literature reviews,
reproduction packages — is parked in
[the attic](../attic/gproj-litreview.md): use it whenever you want
to grow this report into a real paper.)

## The task talk (15 marks)

Twenty minutes: aim for 15, leaving 5 for questions. The talk
reviews your project so far: the claim (the two hypotheses and
their win conditions), what has run, what the evidence says, and
your verdict (persevere, re-plan, descope). Write it in Google
Slides, public to everyone, editable by timm@ieee.org; discuss it
with the lecturer the week before.

| Marks | For | Check |
|------:|-----|-------|
| 3 | **The claim**: both hypotheses, win conditions, stated first | a stranger could rerun the bet |
| 3 | **The evidence**: what ran, on what data | treatments and domains named; `same` on every comparison shown |
| 3 | **The verdict**: results against the claim, honestly | a failed claim with a recorded decision loses nothing; a hidden one loses everything |
| 2 | **Discussed with lecturer the week before** | no discussion = 0 |
| 2 | **Timing**: done in 15, left 5 minutes for questions | running past 20 = 0 |
| 2 | **Slides + delivery**: Google Slides public and editable by timm@ieee.org; in person, whole group on stage | |

Ways to lose marks: claim stated nowhere (or invented after the
results); evidence that cannot be traced to the repo; no time
for questions; slides the lecturer cannot open.

## Initial deliverable (Mon Nov 9, 5 marks)

*Something must work.* Hand in one page + repo:

| Marks | For |
|------:|-----|
| 2 | Three requirements docs: twenty customer asks per domain, skill-tagged, okayed by the lecturer |
| 2 | One domain's ladder running: tagged steps, tests, one-command demos |
| 1 | The pre-registered claim: both hypotheses and their win conditions, verbatim, plus one paragraph on your domains and data |

## Final deliverable (Mon Nov 30, 34 marks)

The report: LaTeX `acmart` (ACM transactions format), 6 to 9 pages,
PDF to Moodle, repo URL on page one. Same five section headers as
the undergrads; marked against the 591 column of the
[shared rubric](uproj.md#rubric) (which scales each row for the
triple scope: 34 marks in all).

Ways to lose marks: everything on uproj.md's list, plus: three
domains that are one domain wearing three hats; a third domain with
no transfer numbers (how much old machinery did it reuse?); a
verdict that quietly drops one of the three domains.
