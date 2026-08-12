#!/usr/bin/env python3 -B
"""rand.py: Park-Miller (1988) random numbers; a port of
rand.lua. Run this file to print 20 of them; import it to
get srand, rand."""
from math import floor

Seed = 1234567891

def srand(n=1234567891):
  "Reseed with any integer; lands in 1..2^31-2."
  global Seed
  Seed = floor(n) % 2147483647
  if Seed <= 0: Seed += 2147483646

def rand(lo=None, hi=None):
  """No args: a float in [0,1). One arg n: an int in 1..n.
  Two args: an int in lo..hi."""
  global Seed
  Seed = (16807 * Seed) % 2147483647
  x = Seed / 2147483647
  if lo is None: return x
  if hi is None: lo, hi = 1, lo
  return lo + floor(x * (hi - lo + 1))

if __name__ == "__main__":
  srand()
  for _ in range(20): print(f"{rand():.6f}")
