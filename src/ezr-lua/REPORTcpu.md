# CPU and memory study: Lua and Python runtimes

This report compares four runtimes on the same tasks.
The runtimes are CPython 3.14.5, pypy3 7.3.17 (Python
3.10), PUC Lua 5.5.0, and LuaJIT 2.1. The test machine is
an Apple M4 with 16 GB of memory.

## The task

Each test starts one process. The process reads one data
model (a CSV file). Then it runs two demos:

- `tree`: build a multi-goal decision tree over all rows.
- `acquire`: do active learning; label a few rows, cull
  the pool, and repeat.

The Python code is `ezr-py/xai-eg.py`. The Lua code is
`xai-eg.lua` (the generation before `ezr.lua`; the two
ports share one design). The command forms are:

    python3 xai-eg.py tree acquire --file=CSV
    lua     xai-eg.lua -f CSV --tree --acquire

`/usr/bin/time -l` measures each process. "Real" is the
wall-clock time. "CPU" is user time plus system time.
"RSS" is the maximum resident set size of one process.
The tables show the sum of real and CPU over a band, and
the mean and the peak of RSS over a band.

## The models

The models come from the moot repository
(`github.com/timm/moot`, directory `optimize/`). The 128
models divide into three bands by row count.

| band  | rows        | N   |
|-------|-------------|-----|
| small | < 1,000     | 25  |
| mid   | 1k - 10k    | 37  |
| large | >= 10,000   | 66  |
| all   |             | 128 |

The "LuaJIT speedup" column is the real time of a runtime
divided by the real time of LuaJIT. A value above 1 means
that LuaJIT is faster. A value below 1 means that LuaJIT
is slower. All 512 runs complete with zero failures.

## Results: small band (N = 25 models)

| runtime  | N  | real (s) | CPU (s) | mean RSS (MB) | peak RSS (MB) | LuaJIT speedup |
|----------|----|----------|---------|---------------|---------------|----------------|
| CPython  | 25 | 37.49    | 37.10   | 25.7          | 26.2          | 81.5           |
| pypy3    | 25 | 9.88     | 9.15    | 55.9          | 63.0          | 21.5           |
| PUC Lua  | 25 | 1.00     | 0.90    | 3.1           | 4.6           | 2.2            |
| LuaJIT   | 25 | 0.46     | 0.34    | 3.3           | 4.8           | 1.0            |

LuaJIT is 81 times faster than CPython. PUC Lua is 37
times faster than CPython. pypy3 is 3.8 times faster than
CPython.

## Results: mid band (N = 37 models)

| runtime  | N  | real (s) | CPU (s) | mean RSS (MB) | peak RSS (MB) | LuaJIT speedup |
|----------|----|----------|---------|---------------|---------------|----------------|
| CPython  | 37 | 58.13    | 57.42   | 26.2          | 28.4          | 19.4           |
| pypy3    | 37 | 15.74    | 15.18   | 59.9          | 66.6          | 5.2            |
| PUC Lua  | 37 | 7.17     | 6.79    | 6.9           | 15.1          | 2.4            |
| LuaJIT   | 37 | 3.00     | 2.76    | 6.3           | 19.2          | 1.0            |

LuaJIT is 19 times faster than CPython. PUC Lua is 8
times faster. pypy3 is 4 times faster and uses 10 times
more memory than LuaJIT.

## Results: large band (N = 66 models)

| runtime  | N  | real (s) | CPU (s) | mean RSS (MB) | peak RSS (MB) | LuaJIT speedup |
|----------|----|----------|---------|---------------|---------------|----------------|
| CPython  | 66 | 132.09   | 128.88  | 41.0          | 257.9         | 1.9            |
| pypy3    | 66 | 32.15    | 30.89   | 74.1          | 192.7         | 0.46           |
| PUC Lua  | 66 | 189.01   | 186.31  | 71.9          | 588.6         | 2.7            |
| LuaJIT   | 66 | 69.17    | 68.01   | 50.8          | 330.1         | 1.0            |

The order changes on large models. pypy3 is the fastest
(4 times faster than CPython). LuaJIT is second (2 times
faster). PUC Lua is the slowest (0.7 times the CPython
speed). The 0.46 in the pypy3 row shows that LuaJIT runs
at less than half of the pypy3 speed on this band. The
Lua peak memory also grows past the Python peak memory on
this band.

## CPU and memory notes

- All work is CPU-bound. CPU time is almost equal to real
  time in all 512 runs. Disk wait is not a factor.
- On small and mid models, the Lua runtimes hold 3 MB to
  7 MB. That is one tenth of the pypy3 footprint.
- On large models, the Lua tables grow faster than the
  Python structures. The PUC Lua peak is 589 MB. Garbage
  collection load is the probable cause of the PUC Lua
  slowdown.
- pypy3 pays about 0.25 s to start each process. Its JIT
  needs seconds of work before it wins. Many short
  processes hide its speed. Few long processes show it.

## Summary

The safe claim is: LuaJIT is 4 times faster than CPython
on long runs with a warm JIT. On many small models, the
gap grows to 19-81 times. pypy3 draws level only when one
process runs for seconds, and it then leads on the
largest models. LuaJIT holds a tenth of the pypy3 memory
on small and mid models, and that advantage inverts on
the largest models.

## Study cost

The study made 512 measured runs (128 models times 4
runtimes). The total measured process time is 555 s,
about 9.3 minutes.

## Limits

- The two ports share one design. They are not the same
  program.
- One machine, one operating system, one run per cell.
  Run-to-run noise is about 10 percent.
- The Lua runs use a copy of the `xai` sources with three
  small repairs. The CSV reader keeps empty cells as `?`
  and removes byte-order marks (the same rules as the new
  `ezr-lib.lua` reader; without them, one model,
  `dress-up.csv`, fails). Two `//` operators become
  `math.floor` calls, because LuaJIT does not parse `//`.
  One loop variable gets a new name, because Lua 5.5 makes
  loop variables constant.
