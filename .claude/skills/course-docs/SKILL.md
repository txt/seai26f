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
  are 30 min; tool talks Aug 31–Nov 9, one letter per night (2 talks:
  ugrad + grad); grad task talks Nov 16 + Nov 23, four per night.
  Nov 30 = 1-hr 491 final + project hand-ins, no talks; no Dec slot.
  Project deadlines live in the grad submit column. Night shape:
  ~1 hr lecture + up to 90 min student talks. Every lecture night
  carries a 1-mark quiz (none on exam nights) — 12 for ugrads.
- Grading and NCSU-required sections: `docs/lect/policies.md`. TWO
  cohorts, each totals 100. NO marks table — the assessment section is
  prose + one bullet list per cohort (bold **CSC 491 (undergraduate).**
  / **CSC 591 (graduate).** lead-ins): CSC 491 = quizzes 12 (1 mark
  each, none on exam nights) + tool talk 15 + group ugrad project 25 +
  mid-term 24 + final 24 (in class, Nov 30, 1 hr); CSC 591 = quizzes 7 (grads stop quizzing
  after the mid-term) + tool talk 15 + task talk 15 + mid-term 24 +
  project 39 (initial 5 + final 34), NO final exam — project carries
  that weight. NO homeworks. ALL exams weigh the same (24). Ugrad
  project = group-of-3 shrinking-code demos (docs/submit/uproj.md,
  one submission per group, video capped 5 min): Buse Fig 6
  analytics or Hoffman XAI triggers on MOOT data, git-tagged steps,
  5-min video, %-new-code histogram that must fall, due last class
  (Mon Nov 30), no intermediary. Grad project = research paper
  (docs/submit/gproj.md): citation-knee lit review, reproduction-package
  baseline, pre-registered eval, sigconf paper 3-5pp; initial 5 marks
  (Nov 9: knee evidence 2, running package 2, claim 1), final 34 marks
  (rubric in file). Split structure: ugrads = quizzes + tool talk +
  exams; grads = quizzes (pre-mid-term) + two talks + mid-term + a
  six-week project (Oct 26–Nov 30, runnable-slice initial deliverable
  Nov 9). Shared blocks after the cohort lists: attendance (quizzes
  in-class only, REG 02.20.03 excuses), late work (−1 mark/day,
  weekend = 1 day), ten-point grading scale. Keep both cohorts
  summing to 100 when anything moves.
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

## Pycco doc pipeline (docs/*.html)

- Regen loop per lua file (run from src/ezr-lua; $S = scratchpad):
  `awk -v ext=lua -f ~/gits/timm/src/etc/doc.awk F.lua > $S/F.lua`
  → `python3 ~/gits/timm/src/etc/pyccot.py -d ../../docs $S/F.lua`
  → `python3 ../../etc/nav.py ../../docs/F.html`
- EVERY pyccot run rewrites docs/pycco.css: re-append the
  "timm extras" CSS block after (guard: `grep -q 'timm extras'`).
- etc/nav.py reads docs/.order (base TAB src TAB code|tests);
  injects README badge row (SSOT = README's first
  `<p align="center">` block), centered file-list bar, centered
  prev|next, h1 → github source link. Idempotent via
  `<!-- seai26f-nav -->` marker. All rows centered; no per-page
  left/right prose alignment.
- Lua comment conventions for pycco: `--## name ----` banner =
  section heading; markdown links work in `-- ` prose; run-lines
  ``-- *`lua F.lua --flag`*`` need TWO trailing spaces (hard
  break); `-- ---` after a blank `--` line = hr.
- GitHub Pages: enabled, main:/docs, .nojekyll present. Pages
  live at https://txt.github.io/seai26f/<base>.html. Markdown
  docs are linked via github blob URLs instead.

## Weekly demo files (src/ezr-lua/ezr-eg0..eg9.lua)

- Ten chunks (table lives in front.md "The demos, week by
  week"): eg0 boot, eg1 columns, eg2 dist, eg3 cluster,
  eg4 cuts+trees, eg5 acquire+holdout, eg6 stats, eg7 apps,
  eg8 optimizers, eg9 dtlz. Old monolith parked at
  src/ezr-lua/etc/ezr-eg.lua.
- Each file: install header (no rlwrap), `--egs` lister with a
  `doc` table, `--repl`, `--all` (must skip --all/--egs/--repl),
  glossary links (github blob URLs to docs/lect/glossary.md#term),
  homework at end. A week's file must not mention later weeks'
  machinery (no Tbl before week 2).
- Homework tone: weekly port is "near enough is good enough";
  exact diff-match demanded only for the Park-Miller pair
  (src/ezr-lua/rand.lua vs src/rand.py — verified identical).
- The saved step-2 prompt (in eg1's homework): trace only the
  demos' call chain through require, print the Lua split by a
  divider — above = hand-port to Python, below = covered by a
  Python builtin, each commented with module.function.
- Python port basis: src/101.py (settings `the` from docstring,
  test_* dispatch, `say()` printer: floats integral→"%d" else
  %.{the.round}f, dicts insertion-order, "_" keys hidden).

## Review files & glossary

- docs/review/wN.md: easy recall questions, answers at bottom;
  linked from the README schedule's Review column (w0 = Aug 17,
  eg1 page = Aug 24).
- docs/lect/glossary.md: entry per term in discovery order,
  verbatim ezr.lua code, math in $$..$$. Fused headings —
  "mid (mode, mean)", "diversity (entropy, standard deviation)",
  "columnProtocol" (add sub mid div norm dist holds reset) —
  each with explicit `<a name>` anchors so old #mode/#entropy
  links survive.
