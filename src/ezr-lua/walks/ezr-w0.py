# ezr, week 0: the port, warm-up.
# All of [101.py](https://github.com/txt/seai26f/blob/main/src/101.py),
# verbatim, with glossary notes folded in, and this week's exercises at the bottom.
#
# ## This week's story
# Nothing clever yet: one small Python shell — settings from a help
# string, tests run from the command line, seeds reset before every
# run. Every later week's port grows inside this file.
#
# ---
#
# @gloss python docstrings
# @gloss SSOT
# @gloss mechanism-policy
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
import os, re, random, sys; sys.dont_write_bytecode = True
from math import floor
from types import SimpleNamespace as o

# @gloss python environ
MOOT = (os.environ.get("MOOT") or
        os.path.expanduser("~/gits/moot"))

# @gloss python f-strings
def say(x):
  if isinstance(x, float):
    return (f"{x:.0f}" if x==floor(x) else f"{x:.{the.round}f}")
  if isinstance(x, dict): return "{" + " ".join(
    f":{k} {say(v)}" for k,v in x.items()if str(k)[0]!="_")+"}"
  return str(x)

# @gloss python slices
def thing(s):
  if (s[1:] if s[:1]=="-" else s).isdigit(): return int(s)
  try: return float(s)
  except ValueError: return s=="True" or (s!="False" and s)

# @gloss regx
def settings(doc):
  pat = r"--(\w+)\s+[^=\n]*=\s*(\S+)"
  return o(**{k: thing(v) for k,v in re.findall(pat, doc)})

def test_config(): print(say(vars(the)))

# @gloss python argv
# @gloss RNG
# @gloss TDD
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

# ## exercises
# <div class=ex>
#
# **Exercises, week 0**
#
# 1. Run `python3 101.py config`, then again with
#    `--round=1 --seed=42 config`. Explain every difference.
# 2. Add `test_rand`: print ten random numbers. Run it twice with
#    the same seed, then twice with different seeds. What is
#    guaranteed, and by which line of `main`?
# 3. Port `rand.lua` (Park-Miller) to Python. Same seed, SAME 20
#    numbers as the Lua, or the port is wrong:
#    `diff <(lua rand.lua) <(python3 rand.py)` prints nothing.
# 4. Add one new option to the docstring only (say
#    `--bins  cuts  = 5`). Prove `the.bins` now exists without
#    touching any code. Which principle is that?
# 5. Break `thing`: what does it return for `"-3"`, `"3.1.4"`,
#    `"None"`? Which answers surprise you?
#
# </div>
