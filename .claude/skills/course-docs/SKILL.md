---
name: course-docs
description: Use when editing any markdown in this course repo (README, docs/lect) — header propagation rules, make mds, schedule conventions, grading bookkeeping, eval doctrine.
---

# Editing seai26f course docs

## Header propagation (make mds)

- `make mds` copies the README header (lines 1 → first blank line: badge
  block + h1 + banner) onto LICENSE.md and every `docs/**/*.md`,
  **deleting each target's first block** (lines 1 → first blank line).
- Therefore every docs md MUST start with the header block ending in a
  blank line, or its first paragraph gets eaten on the next `make mds`.
  New file? Paste the README header + blank line at the top first.
- Change a badge/banner only in README.md, then run `make mds`.
  Never hand-edit headers in docs files.
- Run `make mds` before every commit that touches markdown; it is
  idempotent.

## Single sources of truth

- Dates, talk slots, deliverable dates: README schedule table.
  Mondays; holidays 🟩 green, exams 🟥 light red. Five columns: Date,
  Lecture, grad submit, ugrad talks, grad talks. No homework rows and
  no quiz markers in the table (both live in policies prose). Letters
  are group IDs within a cohort (toolA, taskA — no u/g prefix). Talks
  are 30 min; tool talks Sep 14–Nov 9 (2–3/night); grad task talks
  backloaded into the last three nights (3+3+2). Project deadlines live
  in the grad submit column. Night shape: ~1 hr lecture + up to 90 min
  student talks. Every lecture night carries a 1-mark quiz (marked in
  the Lecture column; none on mid-term night) — 13 total.
- Grading and NCSU-required sections: `docs/lect/policies.md`. TWO
  cohorts, each totals 100, one 4-column table (Component | 491 | 591 |
  Notes, plain numbers — no ditto marks): CSC 491 (quizzes 13, tool
  talk 7, mid-term 32, final 48) and CSC 591 (quizzes 7 — grads stop
  quizzing after the mid-term, talks 7+7, project 15+50, mid-term 14,
  NO final). NO homeworks for anyone. Ugrad final = 1.5 × mid-term;
  mids differ across cohorts. Homeworks are
  Split structure: ugrads = quizzes + tool talk + exams; grads =
  quizzes (pre-mid-term) + two talks + mid-term + a six-week project
  (Oct 26–Nov 30, runnable-slice initial deliverable Nov 9). Keep both
  columns summing to 100 when anything moves.
- Tool-talk menu: `docs/lect/tools.md` (26 optimizers with refs);
  signup lives in the linked Google Sheet.

## Course doctrine (keep consistent when editing)

- Groups of ~3 within each cohort: 8 ugrad groups (one tool talk each),
  8 grad groups (tool talk + task talk + semester project).
- Grad project = pre-registered eval: initial deliverable (week 10)
  carries the claim (metric, threshold, baseline) plus a runnable
  instrument on sample/synthetic data; final deliverable (last class)
  reports against that claim. Real data = top of range, never a gate.
- "Failures are findings": honest negative results score; hidden
  failures cost more than honest low scores.
- Talks make measurable claims — show the tool running against a
  baseline where feasible.
- Course thesis: generate and assess ALTERNATE technologies for AI —
  cheaper/faster/explainable rivals to default-LLM solutions, measured
  against baselines. Outcomes, talks, and project all serve this.
- Policies lists exactly six learning outcomes (generate alternatives,
  benchmark vs baselines, learn-from-docs, critical AI use, 591
  pre-registered eval, 591 communication); add one ONLY if a graded
  deliverable provably assesses it. Long outcome lists are hubris.

## Style

Plain words, short sentences, no buzzwords. Rubrics say how marks are
lost, concretely.
