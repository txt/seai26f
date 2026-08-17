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
  Mondays; holidays 🟩 green, exams 🟥 light red. Six columns: Date,
  Lecture, submit (due start of class — holds the weekly egs AND
  project deadlines), ugrad talks, grad talks, Review. No separate
  homework column; no quiz markers in the table (quizzes live in
  policies prose). No "Also:" row — intro links live in the Aug 17
  Lecture cell (hello + tools + Lua-101); the course intro is
  docs/hello.md → https://txt.github.io/seai26f/hello.html
  (front.md and l0.md retired to docs/attic/). Tool
  cells name their topic as tool:acronym (tool:ds .. tool:llm) and
  deep-link to <a name> anchors on rows of docs/lect/tools.md,
  assigned chronologically (ugrad cell = earlier tech each night);
  task cells (taskA–D, taskE–H) link gproj.md's task-talk section.
  Tool talks are 30 min (25 + 5 questions), Aug 31–Nov 9, 2 per
  night (one ugrad group, one grad group, 1 hr in all); grad task
  talks are 20 min (15 + 5), Nov 16 + Nov 23, four per night in a
  90-min window.
  Nov 30 = 1-hr 491 final + project hand-ins, no talks; no Dec slot.
  Project deadlines live in the grad submit column. Night shape:
  ~1 hr lecture + 1 hr tool talks (90 min task talks on Nov 16/23).
  Every lecture night carries a 1-mark quiz (none on exam nights) —
  12 for ugrads.
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
- Tool talks SSOT: `docs/lect/tools.md` — ONE page holding the talk
  spec (30 min), the 15-mark rubric, and the 16-topic SBSE table
  (rows tagged tool:ds .. tool:llm with <a name> anchors the README
  schedule cells deep-link). Signup lives in the linked Google
  Sheet. Retired to docs/attic/: topics.md (the unpruned 39-row
  list) and tools-26menu.md (the old 26-optimizer tournament menu
  with numbered refs).

## Course doctrine (keep consistent when editing)

- Groups of ~3 within each cohort: 8 ugrad groups (491 = 25 students:
  seven 3s + one 4; one tool talk each), 8 grad groups (591 = 23
  students: seven 3s + one 2; tool talk + task talk + semester
  project).
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

## Self-hosting (standing rule)

- NO references to github.com/timm/src or timm.github.io/src
  anywhere in this repo — badges, curl installers, doc links,
  rockspec, comments, and INSIDE src/ezr-lua/ezr-lua.zip. After
  edits, verify: `grep -rn "timm/src\|timm.github.io/src" .`
  (outside .git) must be empty. The pycco tools are vendored at
  etc/doc.awk + etc/pyccot.py; INSTALL.md's BASE fetches from
  raw.githubusercontent.com/txt/seai26f/refs/heads/main/src/ezr-lua.
- When any file shipped in ezr-lua.zip changes (core .lua, eg
  files, play, Makefile, README/INSTALL/tut.md, etc/tut, etc/img,
  etc/ezr-eg.lua, data/auto93.csv, root LICENSE), rebuild the zip:
  stage under scratchpad as ezr-lua/, `zip -qr`, copy back, then
  `unzip -p ezr-lua.zip | strings | grep timm/src` must be empty.

## Style

Plain words, short sentences, no buzzwords. Rubrics say how marks are
lost, concretely.

## Pycco doc pipeline (docs/*.html)

- Regen loop per lua file (run from src/ezr-lua; $S = scratchpad):
  `awk -v ext=lua -f ../../etc/doc.awk F.lua > $S/F.lua`
  → `python3 ../../etc/pyccot.py -d ../../docs $S/F.lua`
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
- nav.py REFRESHES: on re-run it strips the old marker block
  and re-injects, so after any README badge edit run make mds
  AND nav.py over every docs/*.html except hello.html.

## Single-file html pages (md2html)

- docs/hello.md (the course intro, "dinosaurs vs rats") is NOT
  a pycco or header-propagated page. It starts with
  title:/icon:/footer: frontmatter and renders to
  docs/hello.html via `make html` (sh/md2html.awk +
  sh/style.css inlined). sh/headers skips any docs md whose
  first line starts "title:" — NEVER paste the badge header
  into these files.
- md2html has no code blocks and no backticks: use tables for
  tabular/code-ish content, `-` alone = numbered item, `- x` =
  bullet, `@ [T](url)...` = reference div, `.` ends a list.
- hello.md images live in docs/ (rats.png, pso.gif, gauss.png,
  fig2-w2.png, snap2-*.png) — keep them local (designed to
  last), no hotlinks.

## Weekly demo files (src/ezr-lua/ezr-eg0..eg8.lua)

- NINE files, demos spread across eg1..eg8 (table lives at the
  bottom of README, with an Applications section after it):
  eg0 the-port-warm-up (no demos);
  eg1 boot+columns (--the --csv --col --without --sub);
  eg2 dist (--distx --disty --laws);
  eg3 cluster (--half --node);
  eg4 cuts+trees+XAI (--cuts --tree --show --why);
  eg5 active learning (--acquire --holdout --holdouts --label);
  eg6 stats+ranking (--same --ranks --dominate --fronts --wins);
  eg7 apps (--knn --detect --nb --kmeans --kpp);
  eg8 optimizers vs DTLZ (--ga --de --sa --ls --race --models
  --pure --generalize). eg9 DELETED; its dtlz demos absorbed
  into eg4/eg5/eg6/eg8 as above. Old monolith parked at
  src/ezr-lua/etc/ezr-eg.lua.
- egs are deadlines in the README submit column, due ONE WEEK
  after their lecture (eg0 due Aug 24 .. eg8 due Nov 9),
  skipping exam/break nights.
- eg0 is special: no demos, no go(eg), no install header, never
  mentions 101.py. Just the require chain plus "the port,
  warm-up": Part 1 = the builtin-covered ezr-lib functions as
  real code (pycco RHS) with NO Python answers on the prose
  side (that is the exercise); one kept rule = exact
  Park-Miller RNG parity via diff. Part 2 = build port.py
  (settings `the`, --key=val flags, test_rand, seed
  reset-and-replay). Part 3 = Claude typesets the paper
  hand-in (print.html: 2 CSS columns, 6pt mono, ~70 chars).
- eg1-style files: install header (no rlwrap), `--egs` lister
  with a `doc` table, `--repl`, `--all` (must skip
  --all/--egs/--repl), glossary links (github blob URLs to
  docs/lect/glossary.md#term), homework at end. A week's file
  must not mention later weeks' machinery (no Tbl before
  week 2).
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
  linked from the README schedule's Review column (w1 = Aug 17,
  eg1 page = Aug 24).
- docs/lect/glossary.md: entry per term in discovery order,
  verbatim ezr.lua code, math in $$..$$. Fused headings —
  "mid (mode, mean)", "diversity (entropy, standard deviation)",
  "columnProtocol" (add sub mid div norm dist holds reset) —
  each with explicit `<a name>` anchors so old #mode/#entropy
  links survive.
