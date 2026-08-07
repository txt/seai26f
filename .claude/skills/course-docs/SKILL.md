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

- Dates, talk slots (utoolA–H, gtoolA–H, gtaskA–H), deliverable dates:
  README schedule table. Mondays; holidays 🟩 green, exams 🟥 light red.
- Grading and NCSU-required sections: `docs/lect/policies.md`. TWO
  cohorts, each totals 100: CSC 491 (ugrad: tests 13, tool talk 7,
  mid-term 32, final 48) and CSC 591 (grad: tests 13, talks 7+7,
  project 5+18, mid-term 20, final 30). Final = 1.5 × mid-term. Keep
  both tables summing to 100 when anything moves.
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
