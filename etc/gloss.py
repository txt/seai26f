#!/usr/bin/env python3
"""Rebuild docs/gloss5.md .. gloss9.md from the glossary SSOT.

  python3 etc/gloss.py          # all of them
  python3 etc/gloss.py 5 7      # just those weeks

docs/lect/glossary.md holds every entry, once. This script lifts
one '## Week N' section out of it and re-types it in the md2html
dialect used by the gloss pages (no fences: <pre> blocks with
<br>, hand-coloured by span classes; internal links flattened to
italics; math spelled with entities). gloss1-gloss4 and gloss10
predate this script and are hand-maintained.
"""
import os, re, sys

KW = set("""function return if then else elseif end local while for do and or
not nil true false in break repeat until""".split())

# math this script has met; anything else is stripped of its $ signs
MATH = {
 r"$\sqrt{(n_x+n_y)/(n_x n_y)}$":
   "&radic;((n<sub>x</sub>+n<sub>y</sub>)/(n<sub>x</sub>n<sub>y</sub>))",
 r"$a + F\,(b - c)$": "a + F(b - c)",
 r"$e^{-\Delta/T}$": "e<sup>-&Delta;/T</sup>",
 r"$[0,1]^{N_x}$": "[0,1]<sup>Nx</sup>",
 r"$\sum f = 0.5$": "&sum;f = 0.5",
 r"$\sum f^2 = 1$": "&sum;f<sup>2</sup> = 1",
 r"$N_x-M+1$": "Nx-M+1",
 r"$M-1$": "M-1",
 r"$\sqrt{n}$": "&radic;n",
}

PAGE = {  # week: (icon, page heading, section heading, date)
 5: ("🎯", "Week 5: active learning", "Labels cost money", "2026-09-28"),
 6: ("📊", "Week 6: statistics and ranking", "Is that gap real?", "2026-10-05"),
 7: ("🧰", "Week 7: applications", "One substrate, four chapters", "2026-10-26"),
 8: ("🏁", "Week 8: optimizers", "The drag race", "2026-11-02"),
 9: ("🛰️", "Week 9: models and the seam", "When the goals cost money",
     "2026-11-09"),
}

SUMM = {
5: """**Summary:** *Weeks 1-4 got the goals for free. Now suppose a
single y value costs a test drive, a trial, a week of CPU
&mdash; and you get fifty, ever. This week is how to spend
them: label only the poles, cull gently, restart when the pool
dries, and count every purchase. Then the honesty check: a
holdout that picks from rows the search never studied. Demos in
[ezr-eg5.lua](ezr-eg5.html); machinery verbatim from
[ezr.lua](ezr.html). Each entry is a tiny lecture &mdash; hook,
idea, math if any, then the code.*""",
6: """**Summary:** *Last week ended with twenty holdouts and a
spread. This week asks the only question that matters about a
spread: is that gap real, or is it noise? Three cheap tests
(means, ranks, shapes), all three of which must agree; a rank
table where ties share a rank; and the row-versus-row
comparison (domination) that refuses to speak when the goals
disagree. Demos in [ezr-eg6.lua](ezr-eg6.html); machinery
verbatim from [ezr.lua](ezr.html) and
[ezr-apps.lua](ezr-apps.html).*""",
7: """**Summary:** *Textbooks give a chapter each to prediction,
anomaly detection, Bayes classifiers and clustering. This week
is the claim that those chapters are synonyms: given distance
and column summaries, each one is a dozen lines. Count the new
lines per chapter; that falling count is the whole argument of
this course, and of the undergraduate project. Demos in
[ezr-eg7.lua](ezr-eg7.html); machinery verbatim from
[ezr-apps.lua](ezr-apps.html).*""",
8: """**Summary:** *Fifty years of search, in four short functions:
genetic algorithms, differential evolution, simulated annealing
and greedy local search &mdash; plus the random baseline that
exists to embarrass anyone whose clever method cannot beat a
lucky dip. They all work. They also spend evaluations like
water, which is fine when the model is cheap and ruinous when
it is not. Demos in [ezr-eg8.lua](ezr-eg8.html); machinery
verbatim from [ezr-apps.lua](ezr-apps.html).*""",
9: """**Summary:** *The last piece: replace the csv with a MODEL.
Rows are born with "?" goals and disty buys them, one row at a
time, so the label count IS the experiment. DTLZ1-7 give us
problems whose true answers are known, so a search can be
graded exactly. Then the week's punchline: the classics spend
the whole pool; acquire spends 45 and lands in the same place.
Demos in [ezr-eg8.lua](ezr-eg8.html); machinery verbatim from
[ezr-dtlz.lua](ezr-dtlz.html).*""",
}

REFS = {
5: ["@ [Menzies, Srinivasan & Ganguly: Can AI be easy? Lessons learned from the EZR.py toolkit](https://arxiv.org/abs/2606.03640). Tim Menzies, S. Srinivasan, Kishan Kumar Ganguly. Software: Practice and Experience, 2026. arXiv:2606.03640. (Source of the budget/check sweep above.)",
    "@ [Settles: Active learning literature survey](https://minds.wisconsin.edu/handle/1793/60660). Burr Settles. Univ. Wisconsin-Madison, Computer Sciences TR 1648, 2009.",
    "@ [Chen, Nair, Krishna & Menzies: Sampling as a baseline optimizer for search-based software engineering](https://doi.org/10.1109/TSE.2018.2790925). IEEE TSE 45(6), 2019, 597-614."],
6: ["@ [Cohen: Statistical power analysis for the behavioral sciences](https://doi.org/10.4324/9780203771587). Jacob Cohen. 2nd edition, Lawrence Erlbaum, 1988.",
    "@ [Cliff: Dominance statistics: Ordinal analyses to answer ordinal questions](https://doi.org/10.1037/0033-2909.114.3.494). Norman Cliff. Psychological Bulletin 114(3), 1993, 494-509.",
    "@ [Massey: The Kolmogorov-Smirnov test for goodness of fit](https://doi.org/10.1080/01621459.1951.10500769). Frank J. Massey Jr. JASA 46(253), 1951, 68-78.",
    "@ [Arcuri & Briand: A practical guide for using statistical tests to assess randomized algorithms in software engineering](https://doi.org/10.1145/1985793.1985795). Andrea Arcuri, Lionel Briand. ICSE 2011."],
7: ["@ [Aha, Kibler & Albert: Instance-based learning algorithms](https://doi.org/10.1007/BF00153759). David W. Aha, Dennis Kibler, Marc K. Albert. Machine Learning 6, 1991, 37-66.",
    "@ [Domingos & Pazzani: On the optimality of the simple Bayesian classifier under zero-one loss](https://doi.org/10.1023/A:1007413511361). Pedro Domingos, Michael Pazzani. Machine Learning 29, 1997, 103-130.",
    "@ [Arthur & Vassilvitskii: k-means++: The advantages of careful seeding](https://dl.acm.org/doi/10.5555/1283383.1283494). David Arthur, Sergei Vassilvitskii. SODA 2007, 1027-1035."],
8: ["@ [Holland: Adaptation in natural and artificial systems](https://doi.org/10.7551/mitpress/1090.001.0001). John H. Holland. University of Michigan Press, 1975.",
    "@ [Storn & Price: Differential evolution -- a simple and efficient heuristic for global optimization over continuous spaces](https://doi.org/10.1023/A:1008202821328). Rainer Storn, Kenneth Price. Journal of Global Optimization 11, 1997, 341-359.",
    "@ [Kirkpatrick, Gelatt & Vecchi: Optimization by simulated annealing](https://doi.org/10.1126/science.220.4598.671). S. Kirkpatrick, C.D. Gelatt, M.P. Vecchi. Science 220(4598), 1983, 671-680."],
9: ["@ [Deb, Thiele, Laumanns & Zitzler: Scalable multi-objective optimization test problems](https://doi.org/10.1109/CEC.2002.1007032). Kalyanmoy Deb, Lothar Thiele, Marco Laumanns, Eckart Zitzler. CEC 2002, 825-830.",
    "@ [Chen, Nair, Krishna & Menzies: Sampling as a baseline optimizer for search-based software engineering](https://doi.org/10.1109/TSE.2018.2790925). IEEE TSE 45(6), 2019, 597-614."],
}

def code(src):
  "One fenced lua block -> one <pre> line, keywords coloured."
  out = []
  for line in src.split("\n"):
    s = line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    cut, tail = s.find("--"), ""
    if cut >= 0 and s[:cut].count('"') % 2 == 0:
      tail, s = s[cut:], s[:cut]
    s = re.sub(r"[A-Za-z_][A-Za-z_0-9]*",
               lambda m: (f"<span class=k>{m.group(0)}</span>"
                          if m.group(0) in KW else m.group(0)), s)
    s = re.sub(r"(<span class=k>function</span> )([A-Za-z_][\w.]*)",
               r"\1<span class=f>\2</span>", s)
    s = re.sub(r'"[^"]*"', lambda m: f"<span class=s>{m.group(0)}</span>", s)
    if tail: s += f"<span class=c>{tail}</span>"
    out.append(s)
  return "<pre>" + "<br>".join(out) + "</pre>"

def prose(t):
  t = re.sub(r"<a name=[^>]*></a>\s*", "", t)
  t = t.replace('src="../', 'src="')          # docs/lect/x.png -> docs/x.png
  for k, v in MATH.items(): t = t.replace(k, v)
  t = re.sub(r"\$\$?([^$]*)\$\$?", r"\1", t)
  t = re.sub(r"\[([^\]]+)\]\(#[^)]*\)", r"*\1*", t)   # internal links
  t = t.replace("—", "&mdash;").replace("≤", "&le;")
  t = t.replace("≥", "&ge;").replace("±", "&plusmn;")
  t = t.replace("√", "&radic;").replace("×", "&times;")
  return t.replace("`", "*")

def entries(week, path="docs/lect/glossary.md"):
  "The '## Week N' section, as gloss-page entries."
  body = next(s for s in re.split(r"\n## ", open(path).read())
              if s.startswith(f"Week {week}:"))
  body = "\n".join(body.split("\n")[1:])
  out, term = [], None
  for j, b in enumerate(re.split(r"```lua\n(.*?)```\n", body, flags=re.S)):
    if j % 2:
      out.append(code(b.rstrip("\n"))); continue
    for para in b.split("\n\n"):
      para = para.strip()
      if not para: continue
      if para.startswith("### "):
        out.append("-"); term = para[4:].strip()
      elif term:
        out.append(f"**{term}**: " + prose(para)); term = None
      else:
        out.append(prose(para))
  return "\n\n".join(out)

def page(n):
  icon, wk, head, date = PAGE[n]
  style = open("docs/gloss3.md").read().split("\n")[4]  # SSOT for the css
  nl = chr(10)
  return f"""title: Glossary {n}: SE for AI
icon: {icon}
footer: This page is [designed to last](http://jeffhuang.com/designed_to_last/).

{style}

# A glossary of tiny lectures, part {n}

## {wk}

#### By [Tim Menzies](https://timm.fyi), published {date}, updated {date}

{SUMM[n]}

--- #week{n}

### {head}

---

{entries(n)}

{nl.join(x + nl for x in REFS[n])}
.
"""

if __name__ == "__main__":
  assert os.path.isfile("docs/lect/glossary.md"), "run me from the repo root"
  for n in [int(x) for x in sys.argv[1:]] or sorted(PAGE):
    open(f"docs/gloss{n}.md", "w").write(page(n))
    print(f"docs/gloss{n}.md")
