#!/usr/bin/env python3
"""
walk.py FILE.lua > FILE.html : two-pane classroom code walkthrough.

One input file, two parts:

  1. Lua code. Mark a line with a trailing comment  -- #:term
     (the marker is stripped from the display and becomes a
     clickable, numbered badge at the end of that line).
  2. Notes. The notes part starts at the first line beginning
     with ":term". Each ":term" line opens the note shown when
     that term's badge is clicked; its body runs to the next
     ":term". Blank lines break paragraphs; 4-space-indented
     lines become a code block; `x` becomes <code>x</code>.

Built for a projector: large fonts, code left, sticky notes
right. Keys 1..9 also open note n.
"""
import re, sys, html

src = open(sys.argv[1]).read().splitlines()

# ---- split code from notes -------------------------------------
split = next(i for i, l in enumerate(src) if re.match(r"^:\w", l))
code, notes = src[:split], src[split:]

# ---- parse notes: ":term title..." then body -------------------
sects, name = {}, None
for l in notes:
    m = re.match(r"^:(\w+)\s*(.*)", l)
    if m:
        name = m.group(1)
        sects[name] = {"title": m.group(2) or name, "body": []}
    elif name:
        sects[name]["body"].append(l)

def prose(lines):
    out, para, pre = [], [], []
    def flush_para():
        if para:
            t = html.escape(" ".join(para))
            t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
            out.append(f"<p>{t}</p>"); para.clear()
    def flush_pre():
        if pre:
            out.append("<pre>" + html.escape("\n".join(pre)) + "</pre>")
            pre.clear()
    for l in lines:
        if l.startswith("    "):
            flush_para(); pre.append(l[4:])
        elif l.strip() == "":
            flush_para(); flush_pre()
        else:
            flush_pre(); para.append(l.strip())
    flush_para(); flush_pre()
    return "\n".join(out)

# ---- highlight lua, extract #:term badges ----------------------
KW = (r"\b(function|return|if|then|elseif|else|for|in|do|while|"
      r"repeat|until|local|end|and|or|not|nil|true|false|break)\b")

def hilite(l):
    l = html.escape(l)
    parts = re.split(r"(--.*$)", l)
    out = ""
    for p in parts:
        if p.startswith("--"):
            out += f'<span class=c>{p}</span>'
        else:
            bits = re.split(r"(&quot;[^&]*?&quot;)", p)
            for b in bits:
                if b.startswith("&quot;"):
                    out += f'<span class=s>{b}</span>'
                else:
                    b = re.sub(KW, r'<span class=k>\1</span>', b)
                    b = re.sub(r'(?<=<span class=k>function</span> )'
                               r'([A-Za-z_][\w.]*)',
                               r'<span class=f>\1</span>', b)
                    out += b
    return out

order, lines = [], []
for l in code:
    m = re.search(r"\s*--\s*#:(\w+)\s*$", l)
    badge = ""
    if m:
        t = m.group(1)
        if t not in order: order.append(t)
        n = order.index(t) + 1
        l = l[:m.start()]
        badge = (f' <a class=fn href="#" data-n="{t}">'
                 f'{t}<sup>{n}</sup></a>')
    lines.append(hilite(l) + badge)

# ---- emit ------------------------------------------------------
notes_html = "".join(
    f'<div class=note id="n-{t}"><h3>{i+1}. '
    f'{html.escape(sects[t]["title"])}</h3>\n'
    f'{prose(sects[t]["body"])}</div>\n'
    for i, t in enumerate(order) if t in sects)

print(f"""<!doctype html><html lang=en><head><meta charset=utf-8>
<title>walkthru</title>
<meta name=viewport content="width=device-width">
<style>
body {{ margin:0; font:19px/1.5 Georgia, serif; color:#222; }}
.wrap {{ display:flex; align-items:flex-start; }}
.code {{ flex:1.3; min-width:0; }}
.notes {{ flex:1; min-width:0; position:sticky; top:0;
  max-height:100vh; overflow-y:auto; border-left:1px solid #ddd;
  padding:0 1em; }}
pre {{ margin:.6em; padding:.8em;
  font:21px/1.5 ui-monospace, Menlo, Consolas, monospace;
  background:#f7f7f7; border-radius:8px; overflow-x:auto; }}
.notes pre {{ font-size:17px; }}
.k {{ color:#8f4e8b; }} .s {{ color:#2a7f2a; }} .c {{ color:#999; }}
.f {{ color:#0b5394; font-weight:bold; }}
a.fn {{ color:#0b5394; background:#e8f0fe; border-radius:6px;
  padding:0 6px; text-decoration:none; }}
a.fn:hover {{ background:#c9ddfb; }}
.note {{ display:none; }} .note.on {{ display:block; }}
.note h3 {{ color:#0b5394; margin:.7em 0 .3em; }}
.hint {{ color:#777; font-style:italic; padding-top:1em; }}
</style></head><body><div class=wrap>
<div class=code><pre>{chr(10).join(lines)}</pre></div>
<div class=notes>
<p class=hint id=hint>&larr; click a term (or press 1-{len(order)}).</p>
{notes_html}</div></div>
<script>
const T={order!r};
function show(t){{
  document.getElementById("hint").style.display="none";
  document.querySelectorAll(".note").forEach(n=>n.classList.remove("on"));
  const e=document.getElementById("n-"+t); if(e)e.classList.add("on"); }}
document.querySelectorAll("a.fn").forEach(a=>a.addEventListener("click",
  e=>{{e.preventDefault(); show(a.dataset.n);}}));
document.addEventListener("keydown",e=>{{
  const i=+e.key-1; if(i>=0&&i<T.length) show(T[i]);}});
</script></body></html>""")
