#!/usr/bin/env python3 -B
"""
101.py: just enough to reset settings from the command line
(c) 2026, Tim Menzies <timm@ieee.org>, MIT license

USAGE: python3 101.py [--key=val ...] [test ...]

OPTIONS: (defaults below are parsed into `the`):
  --file   data file  = $MOOT/optimize/misc/auto93.csv
  --seed   random seed           = 1
  --round  decimals shown        = 3
  -h       print this help
"""
import os, re, sys, random
from math import floor
from types import SimpleNamespace as o

MOOT = (os.environ.get("MOOT") or
        os.path.expanduser("~/gits/moot"))

def say(x):
  if isinstance(x, float):
    return (f"{x:.0f}" if x==floor(x) else f"{x:.{the.round}f}")
  if isinstance(x, dict): return "{" + " ".join(
    f":{k} {say(v)}" for k,v in x.items()if str(k)[0]!="_")+"}"
  return str(x)

def thing(s):
  if (s[1:] if s[:1]=="-" else s).isdigit(): return int(s)
  try: return float(s)
  except ValueError: return s=="True" or (s!="False" and s)

def settings(doc):
  pat = r"--(\w+)\s+[^=\n]*=\s*(\S+)"
  return o(**{k: thing(v) for k,v in re.findall(pat, doc)})

def test_config(): print(say(vars(the)))

def main(funs):
  if "-h" in sys.argv: return print(__doc__)
  for a in sys.argv[1:]:
    if a[:2]=="--" and "=" in a:
      k,v = a[2:].split("=",1)
      if k in vars(the): setattr(the, k, thing(v))
  for a in sys.argv[1:]:
    if (n := "test_"+a) in funs:
      random.seed(the.seed); funs[n]()

the = settings(__doc__)

if __name__=="__main__": main(globals())
