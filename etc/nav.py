#!/usr/bin/env python3
"""
nav.py docs/NAME.html: inject the course badge header, a
file list, and <prev | next> links into a pycco page,
before its first <h1>. All injected rows are centered.

One page per source file; order comes from the .order
manifest beside the page (tab-separated: base, src, group).
The badge row is lifted verbatim from the README's leading
<p align="center"> block, so README stays the single source
of truth. The file list names every page in this directory;
the current page shows bold, unlinked. The <h1> links to
the source file on github. Idempotent: a page already
carrying the nav marker is left alone.
"""
import os, re, sys

REPO   = "https://github.com/txt/seai26f"
SRCDIR = "src/ezr-lua"
MARK   = "<!-- seai26f-nav -->"

page = sys.argv[1]
here = os.path.dirname(page)
name = os.path.basename(page)[:-len(".html")]
root = os.path.join(here, "..")

s = open(page).read()
if MARK in s: sys.exit(0)

rows  = [l.split("\t") for l in
         open(os.path.join(here, ".order"))
         .read().splitlines() if l]
order = [r[0] for r in rows]
src   = dict((r[0], r[1]) for r in rows).get(name, name)

m = re.search(r'<p align="center">.*?</p>',
              open(os.path.join(root, "README.md")).read(),
              re.S)
badges = m.group(0) if m else ""

files = '<p align="center">' + " | ".join(
  f"<b>{b}</b>" if b == name else
  f'<a href="{b}.html">{b}</a>' for b in order) + "</p>"

i    = order.index(name)
prev = (f'<a href="{order[i-1]}.html">&lt; prev</a>'
        if i > 0 else "&lt; prev")
nxt  = (f'<a href="{order[i+1]}.html">next &gt;</a>'
        if i + 1 < len(order) else "next &gt;")
nav  = f'<p align="center">{prev} | {nxt}</p>'

h1 = (f'<h1><a href="{REPO}/blob/main/{SRCDIR}/{src}">'
      f'{src}</a></h1>')

s = s.replace(f"<h1>{src}</h1>", h1)
s = s.replace("<h1", MARK + badges + files + nav + "<h1", 1)
open(page, "w").write(s)
