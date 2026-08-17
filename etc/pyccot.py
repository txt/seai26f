#!/usr/bin/env python3
"""
pycco.py: run pycco with markdown's `tables` extension added
(pycco hardcodes smarty/fenced_code/footnotes only, so the
tutorial's | call | returns | what | tables render as text).
Same CLI as pycco: python3 etc/pyccot.py -d docs FILE.scm
"""
import sys
from markdown import markdown as md
import pycco.main as P

P.markdown = lambda text, extensions=(): md(
    text, extensions=list(extensions) + ["tables"])
sys.argv = ["pycco"] + sys.argv[1:]
P.main()
