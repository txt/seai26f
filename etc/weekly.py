#!/usr/bin/env python3
"""
weekly.py SRC > OUT : expand @gloss markers into <details> blocks.

SRC is a lua (or python) walk file: real code, plus marker lines

    -- @gloss noir          (lua)
    #  @gloss pareto zoom   (python)

Each marker becomes a collapsible <details> note whose body is the
matching "### entry" from docs/lect/glossary.md, converted md->html
at build time — so walk pages can never drift from the glossary.
Fenced code blocks in an entry that would duplicate the walk's own
adjacent code are still included (the glossary is the SSOT; small
duplication beats drift).

Pipeline:  weekly.py w.lua > tmp.lua
           awk -f doc.awk tmp.lua > tmp2.lua ; pyccot tmp2.lua
   or:     weekly.py w.py  > tmp.py  ; pyccot tmp.py
"""
import re, sys, html, os

HERE = os.path.dirname(os.path.abspath(__file__))
GLOSS = os.path.join(HERE, "..", "docs", "lect", "glossary.md")

# ---- glossary -> {key: (title, body-lines)} --------------------
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
    sys.exit(f"weekly.py: no glossary entry matching '{key}'")

# ---- tiny markdown+latex -> html -------------------------------
MATH = [(r"\\quad", "   "), (r"\\left", ""), (r"\\right", ""),
        (r"\\approx", "≈"), (r"\\mu", "μ"), (r"\\sigma", "σ"),
        (r"\\pi", "π"), (r"\\sum_k", "Σₖ"), (r"\\sum_c", "Σc"),
        (r"\\sum", "Σ"), (r"\\log_2", "log₂"), (r"\\log", "log"),
        (r"\\sqrt\{([^{}]*)\}", r"√(\1)"),
        (r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)"),
        (r"\\,", " "), (r"\\;", " "), (r"m_2", "m2"),
        (r"p_k", "pₖ"), (r"n_k", "nₖ"), (r"g_c", "g_c"),
        (r"e\^\{([^{}]*)\}", r"e^(\1)"),
        (r"\^\{([^{}]*)\}", r"^(\1)"), (r"\s*\\\\\s*", " ")]

def math(s):
    for _ in range(3):                       # nested braces: fixpoint
        for a, b in MATH: s = re.sub(a, b, s)
    return s

def inline(s):
    s = html.escape(s, quote=False)
    s = re.sub(r"\$([^$]+)\$", lambda m: "<i>"+math(m.group(1))+"</i>", s)
    s = re.sub(r"`([^`]+)`", r"<code>\1</code>", s)
    s = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", s)
    s = re.sub(r"\[([^]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', s)
    return s

def md2html(lines):
    out, i = [], 0
    def para(buf):
        if buf: out.append("<p>" + inline(" ".join(buf)) + "</p>")
    buf = []
    while i < len(lines):
        l = lines[i]
        if l.startswith("```"):                       # fenced code
            para(buf); buf = []; i += 1; code = []
            while i < len(lines) and not lines[i].startswith("```"):
                code.append(lines[i]); i += 1
            out.append("<pre>" + html.escape("\n".join(code)) + "</pre>")
        elif l.startswith("$$"):                      # display math
            para(buf); buf = []; m = [l.strip("$ ")]
            while not l.rstrip().endswith("$$") or (len(m) == 1 and l.strip() == "$$"):
                i += 1; l = lines[i]; m.append(l.strip("$ "))
            out.append("<pre>" + html.escape(math(" ".join(x for x in m if x))) + "</pre>")
        elif l.startswith("|"):                       # table
            para(buf); buf = []; rows = []
            while i < len(lines) and lines[i].startswith("|"):
                cells = [c.strip() for c in lines[i].strip("| \t").split("|")]
                if not re.match(r"^[-: ]+$", cells[0]):
                    tag = "th" if not rows else "td"
                    rows.append("<tr>" + "".join(
                        f"<{tag}>{inline(c)}</{tag}>" for c in cells) + "</tr>")
                i += 1
            out.append("<table>" + "".join(rows) + "</table>"); i -= 1
        elif l.startswith("> "):                      # quote
            para(buf); buf = []; q = []
            while i < len(lines) and lines[i].startswith(">"):
                q.append(lines[i].lstrip("> ")); i += 1
            out.append("<p><i>" + inline(" ".join(q)) + "</i></p>"); i -= 1
        elif l.startswith("- "):                      # bullets
            para(buf); buf = []; items = []
            while i < len(lines) and (lines[i].startswith("- ") or
                                      lines[i].startswith("  ")):
                if lines[i].startswith("- "): items.append(lines[i][2:])
                else: items[-1] += " " + lines[i].strip()
                i += 1
            out.append("<ul>" + "".join(
                f"<li>{inline(x)}</li>" for x in items) + "</ul>"); i -= 1
        elif l.startswith("<img"):
            para(buf); buf = []; img = []
            while i < len(lines) and lines[i].strip():
                img.append(lines[i]); i += 1
            out.append(" ".join(img))
        elif re.match(r"^<a name", l):
            pass
        elif l.strip() == "":
            para(buf); buf = []
        else:
            buf.append(l.strip())
        i += 1
    para(buf)
    return out

# ---- expand markers --------------------------------------------
src = sys.argv[1]
cmt = "#" if src.endswith(".py") else "--"
for l in open(src):
    l = l.rstrip("\n")
    m = re.match(rf"\s*{re.escape(cmt)}\s*@gloss\s+(.+)$", l)
    if not m:
        print(l); continue
    t, body = entry(m.group(1).strip())
    print(f"{cmt} <details><summary><b>{inline(t)}</b></summary>")
    for h in md2html(body):
        for hl in h.splitlines():
            print(f"{cmt} {hl}")
    print(f"{cmt} </details>")

# printing: open every fold before print, restore after; and a
# print stylesheet (compact, page-break aware)
print(f"""{cmt} <script>
{cmt} window.addEventListener("beforeprint", () =>
{cmt}   document.querySelectorAll("details").forEach(d => {{
{cmt}     d.dataset.was = d.open; d.open = true; }}));
{cmt} window.addEventListener("afterprint", () =>
{cmt}   document.querySelectorAll("details").forEach(d => {{
{cmt}     d.open = d.dataset.was === "true"; }}));
{cmt} </script>
{cmt} <style media=print>
{cmt}   body {{ font-size: 8pt; }}
{cmt}   .docs pre, .code pre {{ font-size: 6pt !important;
{cmt}     line-height: 1.35 !important; }}
{cmt}   pre, table, details, .ex {{ break-inside: avoid; }}
{cmt}   details {{ background: #fff !important;
{cmt}     border: .5pt solid #999; }}
{cmt}   .ex {{ background: #fff !important;
{cmt}     border: 1pt solid #000; }}
{cmt} </style>""")
