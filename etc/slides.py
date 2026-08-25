#!/usr/bin/env python3
"""
slides.py SRC > OUT.md : anchor file -> pandoc beamer markdown.

Same input as weekly.py (code + "-- @gloss term" markers + an
exercises div). Output: two-column slides, notes left (verbatim
glossary markdown -- pandoc renders its math and tables natively),
code right. Build:

  pandoc -t beamer --pdf-engine=tectonic --slide-level=2 \\
     -V fontsize=8pt -V aspectratio=169 -V theme=default \\
     -V colortheme=dove out.md -o out.pdf
"""
import re, sys, os

HERE  = os.path.dirname(os.path.abspath(__file__))
GLOSS = os.path.join(HERE, "..", "docs", "lect", "glossary.md")

sects, title, body = {}, None, []
for l in open(GLOSS):
    m = re.match(r"^### (.+)", l)
    if m:
        if title: sects[title.lower()] = (title, body)
        title, body = m.group(1).strip(), []
    elif re.match(r"^## ", l):
        if title: sects[title.lower()] = (title, body)
        title, body = None, []
    elif title is not None:
        body.append(l.rstrip("\n"))
if title: sects[title.lower()] = (title, body)

def entry(key):
    k = key.lower()
    for t in sects:
        if t.startswith(k): return sects[t]
    sys.exit(f"slides.py: no glossary entry matching '{key}'")

def clean(body, droplang=None):
    out, i = [], 0
    while i < len(body):
        l = body[i]
        if re.match(r"^<a name", l): i += 1; continue
        if droplang and l.startswith("```" + droplang):
            while i + 1 < len(body) and body[i+1].strip() != "```":
                i += 1
            i += 2; continue
        m = re.match(r'^<img src="([^"]+)"', l)
        if m:                                  # html img -> md img
            while i < len(body) and body[i].strip(): i += 1
            p = m.group(1).replace("../", "docs/")
            out.append(f"![]({p}){{width=55%}}")
        else:
            out.append(l)
        i += 1
    return out

src   = open(sys.argv[1]).read().splitlines()
cmt   = "#" if sys.argv[1].endswith(".py") else "--"
lang  = "python" if cmt == "#" else "lua"
MARK  = re.compile(rf"^\s*{re.escape(cmt)}\s*@gloss\s+(.+)$")
CMT   = re.compile(rf"^\s*{re.escape(cmt)}($| )")

# ---- segment: [prose] then (markers, code)* then [exercises] ----
head, segs, ex = [], [], []
mode, markers, code = "head", [], []
for l in src:
    m = MARK.match(l)
    if re.match(rf"^\s*{re.escape(cmt)}#?#? ?## exercises", l) or \
       re.match(rf"^{re.escape(cmt)}## exercises", l) or \
       "## exercises" in l and CMT.match(l):
        if markers or code: segs.append((markers, code))
        mode, markers, code = "ex", [], []
    elif m:
        if mode != "mark" and (markers or code):
            segs.append((markers, code)); markers, code = [], []
        markers.append(m.group(1).strip()); mode = "mark"
    elif mode == "head":
        if CMT.match(l): head.append(CMT.sub("", l, 1))
        else: mode = "code"; code.append(l)
    elif mode == "ex":
        if CMT.match(l): ex.append(CMT.sub("", l, 1))
    else:
        mode = "code"; code.append(l)
if markers or code: segs.append((markers, code))

def strip_code(c):
    while c and not c[0].strip(): c.pop(0)
    while c and not c[-1].strip(): c.pop()
    return c

# ---- emit ------------------------------------------------------
t = head[0].rstrip(".") if head else "walkthru"
print("---")
print(f"title: '{t}'")
print("---\n")

head = [re.sub(r"\s*\(click a &#9654; to open one\)", "", h) for h in head]
story = [l for l in head[1:] if not l.startswith("## ")]
story = [l for l in story if l.strip() not in ("---",)]
if story:
    print("## the story\n")
    print("\n".join(story).strip(), "\n")

for markers, code in segs:
    code = strip_code(code)
    if not code: continue
    if not markers:
        print(f"## (continued) {{.allowframebreaks}}\n")
        print(f"```{lang}")
        print("\n".join(code))
        print("```\n")
        continue
    titles = [entry(k)[0] for k in markers]
    print(f"## {', '.join(titles)} {{.allowframebreaks}}\n")
    print("::::: {.columns}")
    print('::: {.column width=47%}')
    print("\\scriptsize\n")
    for k in markers:
        _, b = entry(k)
        print("\n".join(clean(b, lang)).strip(), "\n")
    print(":::")
    print('::: {.column width=53%}')
    print("\\scriptsize")
    print(f"```{lang}")
    print("\n".join(code))
    print("```")
    print(":::")
    print(":::::\n")

if ex:
    x = [l for l in ex if "<div" not in l and "</div" not in l]
    print("## exercises {.allowframebreaks}\n")
    print("\\small\n")
    print("\n".join(x).strip())
