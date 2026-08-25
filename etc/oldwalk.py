#!/usr/bin/env python3
"""
oldwalk.py SRC > OUT.html : old-school single-column walk page.

SRC is a walk file (lua or python): real code plus "@gloss term"
marker comments. Each marker prints the matching glossary entry
INLINE, right where it sits — no folds, no details/summary.

Look: Courier, black on white, 10px left padding. Headings are
text, old-school:

    ------------------------------------------------
                        H 1
    ------------------------------------------------

    h2
    ==

    h3
    --

Glossary notes get circled-number badges ① ② ③ to break up the
text. Code sits in a lightly indented, syntax-highlighted block.
"""
import re, sys, html, os

HERE  = os.path.dirname(os.path.abspath(__file__))
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
    sys.exit(f"oldwalk.py: no glossary entry matching '{key}'")

# ---- syntax highlight ------------------------------------------
LUA_KW = (r"\b(function|return|if|then|elseif|else|for|in|do|while|"
          r"repeat|until|local|end|and|or|not|nil|true|false|break)\b")
PY_KW  = (r"\b(def|return|if|elif|else|for|while|in|try|except|import|"
          r"from|as|with|lambda|and|or|not|None|True|False|class|"
          r"global|yield|pass|raise|break|continue|is)\b")

def hilite(l, lang):
    l = html.escape(l)
    cmt = r"(--.*$)" if lang == "lua" else r"(#.*$)"
    kw  = LUA_KW if lang == "lua" else PY_KW
    out = ""
    for p in re.split(cmt, l):
        if (lang == "lua" and p.startswith("--")) or \
           (lang == "py"  and p.startswith("#")):
            out += f'<span class=c>{p}</span>'
        else:
            for b in re.split(r"(&quot;[^&]*?&quot;|&#x27;[^&]*?&#x27;)", p):
                if b.startswith("&quot;") or b.startswith("&#x27;"):
                    out += f'<span class=s>{b}</span>'
                else:
                    out += re.sub(kw, r'<span class=k>\1</span>', b)
    return out

def codeblock(lines, lang):
    while lines and not lines[0].strip():  lines = lines[1:]
    while lines and not lines[-1].strip(): lines = lines[:-1]
    if not lines: return ""
    return ("<pre class=code>" +
            "\n".join(hilite(l, lang) for l in lines) + "</pre>")

# ---- tiny markdown+latex -> old-school html --------------------
MATH = [(r"\\quad", "   "), (r"\\left", ""), (r"\\right", ""),
        (r"\\approx", "≈"), (r"\\mu", "μ"), (r"\\sigma", "σ"),
        (r"\\pi", "π"), (r"\\sum_k", "Σₖ"), (r"\\sum_c", "Σc"),
        (r"\\sum", "Σ"), (r"\\log_2", "log₂"), (r"\\log", "log"),
        (r"\\sqrt\{([^{}]*)\}", r"√(\1)"),
        (r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)"),
        (r"\\,", " "), (r"\\;", " "), (r"m_2", "m2"),
        (r"p_k", "pₖ"), (r"n_k", "nₖ"),
        (r"e\^\{([^{}]*)\}", r"e^(\1)"),
        (r"\^\{([^{}]*)\}", r"^(\1)"), (r"\s*\\\\\s*", " ")]

def math(s):
    for _ in range(3):
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
    out, i, buf = [], 0, []
    def para():
        if buf: out.append("<p>" + inline(" ".join(buf)) + "</p>")
        buf.clear()
    while i < len(lines):
        l = lines[i]
        if l.startswith("```"):
            para(); lang = "py" if "python" in l else "lua"
            i += 1; code = []
            while i < len(lines) and not lines[i].startswith("```"):
                code.append(lines[i]); i += 1
            out.append(codeblock(code, lang))
        elif l.startswith("$$"):
            para(); m = [l.strip("$ ")]
            while not l.rstrip().endswith("$$") or (len(m) == 1 and l.strip() == "$$"):
                i += 1; l = lines[i]; m.append(l.strip("$ "))
            out.append("<pre class=code>" +
                       html.escape(math(" ".join(x for x in m if x))) + "</pre>")
        elif l.startswith("|"):
            para(); rows = []
            while i < len(lines) and lines[i].startswith("|"):
                cells = [c.strip() for c in lines[i].strip("| \t").split("|")]
                if not re.match(r"^[-: ]+$", cells[0]):
                    tag = "th" if not rows else "td"
                    rows.append("<tr>" + "".join(
                        f"<{tag}>{inline(c)}</{tag}>" for c in cells) + "</tr>")
                i += 1
            out.append("<table>" + "".join(rows) + "</table>"); i -= 1
        elif l.startswith("> "):
            para(); q = []
            while i < len(lines) and lines[i].startswith(">"):
                q.append(lines[i].lstrip("> ")); i += 1
            out.append("<p><i>" + inline(" ".join(q)) + "</i></p>"); i -= 1
        elif l.startswith("- "):
            para(); items = []
            while i < len(lines) and (lines[i].startswith("- ") or
                                      lines[i].startswith("  ")):
                if lines[i].startswith("- "): items.append(lines[i][2:])
                else: items[-1] += " " + lines[i].strip()
                i += 1
            out.append("<ul>" + "".join(
                f"<li>{inline(x)}</li>" for x in items) + "</ul>"); i -= 1
        elif l.startswith("<img"):
            para(); img = []
            while i < len(lines) and lines[i].strip():
                img.append(lines[i]); i += 1
            out.append(" ".join(img).replace('src="', 'src="lect/../'))
        elif re.match(r"^<a name", l):
            pass
        elif l.strip() == "":
            para()
        else:
            buf.append(l.strip())
        i += 1
    para()
    return "\n".join(out)

# ---- old-school headings ---------------------------------------
RULE = "-" * 64

def h1(s):
    return (f"<pre class=h1>{RULE}\n\n"
            f"{s.upper().center(64)}\n\n{RULE}</pre>")

def h2(s): return f"<div class=hd>{inline(s)}<br>{'=' * len(s)}</div>"
def h3(s): return f"<div class=hd>{inline(s)}<br>{'-' * len(s)}</div>"

def badge(n):  # ① ② ③ ...
    return chr(0x2460 + n - 1) if n <= 20 else f"({n})"

# ---- walk the source -------------------------------------------
src  = sys.argv[1]
lang = "py" if src.endswith(".py") else "lua"
CMT  = "#" if lang == "py" else "--"
out, prose, code, nnote, title_done = [], [], [], 0, False

def flush_prose():
    global prose
    txt = []
    for l in prose:
        if l.strip() == "" and txt:
            out.append("<p>" + inline(" ".join(txt)) + "</p>"); txt = []
        elif re.match(r"^\d+\.\s", l):          # exercise items: own lines
            if txt: out.append("<p>" + inline(" ".join(txt)) + "</p>")
            txt = [l]
        elif l.strip():
            txt.append(l.strip())
    if txt: out.append("<p>" + inline(" ".join(txt)) + "</p>")
    prose = []

def flush_code():
    global code
    live = [l for l in code if not re.match(r'\s*local _ = "week', l)]
    b = codeblock(live, lang)
    if b: out.append(b)
    code = []

for raw in open(src):
    l = raw.rstrip("\n")
    m = re.match(rf"\s*{re.escape(CMT)}\s?(.*)$", l)
    if m and not l.strip().startswith('"'):
        c = m.group(1)
        flush_code()
        if not title_done and c.strip():
            out.append(h1(c.strip().rstrip("."))); title_done = True
        elif re.match(r"^#?#\s", c):                       # "## story"
            flush_prose(); out.append(h2(re.sub(r"^#?#\s+|\s*-+\s*$", "", c)))
        elif g := re.match(r"^@gloss\s+(.+)$", c):
            flush_prose(); nnote += 1
            t, b = entry(g.group(1).strip())
            out.append(f"<div class=note>{h3(badge(nnote) + ' ' + t)}"
                       f"{md2html(b)}</div>")
        elif c.strip() == "---":
            flush_prose(); out.append(f"<pre class=h1>{RULE}</pre>")
        elif c.strip() in ("<div class=ex>", "</div>"):
            flush_prose()
        else:
            prose.append(c)
    else:
        flush_prose()
        code.append(l)
flush_prose(); flush_code()

name = os.path.basename(src)
print(f"""<!doctype html>
<html lang=en><head><meta charset=utf-8>
<title>{html.escape(name)}</title>
<meta name=viewport content="width=device-width">
<style>
 body {{ font-family:"Courier New",Courier,monospace; font-size:14px;
        line-height:1.5; color:#111; background:#fff;
        margin:0; padding:20px 16px 80px 10px; max-width:76ch; }}
 a {{ color:#00e; }}
 p  {{ margin:14px 0; }}
 b  {{ font-weight:bold; }}
 code {{ background:#f2f2f2; padding:0 3px; }}
 .h1 {{ margin:28px 0; font-weight:bold; }}
 .hd {{ margin:26px 0 12px 0; font-weight:bold; }}
 .note {{ margin:18px 0; }}
 pre.code {{ margin:14px 0 14px 2ch; padding:8px 10px;
        background:#f7f7f7; border-left:3px solid #bbb;
        overflow-x:auto; }}
 .k {{ color:#00c; font-weight:bold; }}
 .s {{ color:#a11; }}
 .c {{ color:#777; font-style:italic; }}
 table {{ border-collapse:collapse; margin:14px 0; }}
 th,td {{ border:1px solid #999; padding:3px 8px; text-align:left; }}
 th {{ background:#eee; }}
 img {{ max-width:100%; }}
 ul {{ margin:14px 0; padding-left:3ch; }}
</style></head><body>
{chr(10).join(out)}
</body></html>""")
