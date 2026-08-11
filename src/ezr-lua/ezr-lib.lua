#!/usr/bin/env lua
local help = [[
ezr-lib.lua: the batteries under ezr.lua. No learners here,
just the little functions that make the learners short.
Settings live in `the`, built by The() from this help;
other files extend it with the:also"help". For LuaJIT,
or any Lua from 5.1 up.

core options:
  round=2          decimals printed by show
  seed=1234567891  every random stream starts here
  DATA=data/       bare table names live here (relative
                   DATA hangs off this script's own dir,
                   then ../ up: rock bins sit one level
                   under their rock's data)
  file=auto93.csv  default table]]

local max,min,floor = math.max, math.min, math.floor

-- All defs below land in this fresh table (which _G backs for
-- reads), so `function name` both defines and exports: the
-- last line returns _ENV as the module. The local works on
-- Lua 5.2+; the setfenv line is the same trick for 5.1 and
-- LuaJIT (where it is a plain local and setfenv is nil).
local _ENV = setmetatable({}, {__index = _G})
if setfenv then setfenv(1, _ENV) end

--## make and feed ---------------------------------------------
-- Four verbs the rest of the system leans on: `new` builds an
-- object, `iter` makes lists and generators loop alike,
-- `thing` coerces one cell of text, `csv` streams a table off
-- disk. The signature above each is a reading aid, not a
-- check: `list` is a table used as an array, `dict` one
-- used as a map. Note that names after the wide gap in an
-- argument list are LOCALS, not arguments, so they never
-- show up in a type.

-- *`new(kl:dict, t:dict) -> dict`*  
-- Class table is also its metatable.
function new(kl,t)
  kl.__index=kl;kl.__tostring=show; return setmetatable(t,kl) end

-- *`iter(src:list|fun) -> fun`*  
-- Iterate a list or a function.
function iter(src,    at)
  if type(src) == "function" then return src end
  at = 0; return function() at = at + 1; return src[at] end end

-- *`thing(s:str) -> num|bool|str`*  
-- String to number, bool, or string.
function thing(s)
  s = s:match"^%s*(.-)%s*$"
  return tonumber(s) or s=="True" or (s~="False" and s) end

-- *`pathname(s?:str) -> str`*  
-- Bare names live in `the.DATA`; a relative DATA hangs off
-- this script's own dir, then `../` up. `$VARS` expand.
function pathname(s,    d,t,f)
  s = s or the.file
  if not s:find"/" then
    d = the.DATA
    if d:find"^[/$]" then s = d .. s else
      t = (arg and arg[0] or ""):gsub("[^/]*$","")
      f = io.open(t .. d .. s)
      if f then f:close() end
      s = (f and t or t .. "../") .. d .. s end end
  return (s:gsub("%$(%w+)", function(k)
    return os.getenv(k) or k == "MOOT" and
           os.getenv"HOME" .. "/gits/moot" end)) end

-- *`csv(file?:str) -> fun -> row?`*  
-- Stream rows of coerced cells; nil ends the stream.
function csv(file,    f)
  f = io.lines(pathname(file))
  return function(    t,l)
    for line in f do
      l = line:gsub("\239\187\191","")   -- strip any BOM
              :gsub("%%.*",""):match"^%s*(.-)%s*$"
      if l ~= "" then
        t={}                        -- (.-), keeps empty cells
        for s in (l..","):gmatch"(.-)," do t[#t+1]=thing(s) end
        return t end end end end

--## settings --------------------------------------------------
-- One flat table of options, parsed out of the help string
-- that documents them, so the manual and the defaults cannot
-- drift apart. Every file adds its own paragraph with `also`.
THE = {}

-- *`The(s:str) -> THE`*  
-- Settings from the `k=v` words in a string; only the ones
-- after whitespace, so `--k=v` in the usage stays prose.
function The(s,    i)
  i = new(THE, {_help=s})
  for k,v in (" "..s):gmatch"%s(%a%w*)=(%S+)" do
    i[k] = thing(v) end
  return i end

-- *`THE:also(t:str|dict) -> THE`*  
-- Merge in new settings. Same-name fields crash.
function THE.also(i,t)
  if type(t) == "string" then
    -- newest file's full text leads; older helps keep only
    -- their options paragraphs
    i._help = t.."\n"..(i._help:match"[^\n]*[Oo]ptions:.*" or "")
    t = The(t) end
  for k,v in pairs(t) do
    if k ~= "_help" then
      assert(i[k] == nil, "duplicate setting: "..k)
      i[k] = v end end
  return i end

--## list making -----------------------------------------------
-- Small list verbs, all of them shorter than the loop they
-- replace. `fun` is why: it lets any of them take a function,
-- a method name, or a field index, so callers write
-- `map(cols, "mid")` instead of a closure.

-- *`push(t:list, v:any) -> any`*  
-- Add v to the end of t, returning v so pushes chain.
function push(t,v) t[1+#t] = v; return v end

-- *`fun(f:fun|str|int) -> fun`*  
-- A callable: f itself; or a method name; or a field index.
function fun(f)
  if type(f)=="string" then
    return function(v,...) return v[f](v,...) end end
  if type(f)=="number" then return function(v) return v[f]end end
  return f end

-- *`map(t:list, f:fun|str|int) -> list`*  
-- f (function, method name, or index) over a list.
function map(t,f,    u)
  f = fun(f)
  u = {}; for _,v in ipairs(t) do u[1+#u]=f(v) end; return u end

-- *`kap(t:dict, f:fun) -> list`*  
-- f(k,v) over all pairs, any order. A nil result vanishes,
-- so kap also filters.
function kap(t,f,    u)
  u = {}
  for k,v in pairs(t) do u[1+#u] = f(k,v) end; return u end

-- *`slice(t:list, lo?:int, hi?:int) -> list`*  
-- Copy t[lo..hi]; any size, any out-of-range bound.
function slice(t,lo,hi,    u)
  u, hi = {}, min(hi or #t, #t)
  for j = max(lo or 1, 1), hi do u[1+#u] = t[j] end
  return u end

-- *`copy(t:list) -> list`*  
-- Shallow copy of the list part.
function copy(t)
  return map(t, function(v) return v end) end

-- *`sum(t:list|dict, f:fun) -> num`*  
-- Add f(v) over the values.
function sum(t,f,    n)
  n = 0; for _, v in pairs(t) do n = n + f(v) end; return n end

--## ordering --------------------------------------------------
-- Sorting, done stably: ties keep their input order, so two
-- runs on one seed print the same lines and the frozen
-- transcripts diff clean across Lua versions.

-- *`sorted(t:list, f?:fun) -> list`*  
-- Sorted copy; the comparator is optional.
function sorted(t,f,    s)
  s = copy(t); table.sort(s, f); return s end

-- *`keysort(t:list, f:fun) -> list`*  
-- Sort by f(v). Stable, so ties keep their input order.
function keysort(t,f,    px,ix)
  px, ix = {}, {}
  for at, v in ipairs(t) do px[v], ix[v] = f(v), at end
  return sorted(t, function(u,v)
           if px[u] == px[v] then return ix[u] < ix[v] end
           return px[u] < px[v] end) end

-- *`keys(t:dict, skip?:str) -> list`*  
-- Sorted keys, dropping any that start with `skip`.
function keys(t,skip,    u)
  u = kap(t, function(k)
        if not (skip and tostring(k):sub(1,1) == skip) then
          return k end end)
  return keysort(u, tostring) end

-- *`least() -> fun`*  
-- Min-so-far reducer: call f{val,..} to offer a candidate,
-- f() to read the champion. The winner rides in the closure,
-- so no list of candidates is ever built.
function least(    lo)
  return function(x)
    if x and (lo == nil or x[1] < lo[1]) then lo = x end
    return lo end end

--## randomness ------------------------------------------------
-- Own Park-Miller PRNG: exact doubles, so the same seed
-- yields the same stream on any Lua, any machine. Lua's own
-- `math.random` is a different generator on 5.1, on 5.4, and
-- on LuaJIT, so a shared seed there would still fork the
-- stream and rot every frozen transcript.

-- *`Seed:int`* -- state of the one generator in this system.
Seed = 1234567891

-- *`srand(n?:int)`*  
-- Reseed with any integer; lands in 1..2^31-2.
function srand(n)
  Seed = floor(n or 1234567891) % 2147483647
  if Seed <= 0 then Seed = Seed + 2147483646 end end

-- *`rand(lo?:num, hi?:num) -> num`*  
-- No args: a float in [0,1). One arg n: an int in 1..n.
-- Two args: an int in lo..hi.
function rand(lo,hi,    x)
  Seed = (16807 * Seed) % 2147483647
  x = Seed / 2147483647
  if not lo then return x end
  if not hi then lo, hi = 1, lo end
  return lo + floor(x * (hi - lo + 1)) end

-- *`shuffle(lst:list) -> list`*  
-- Fisher-Yates; copies first, so the input survives.
function shuffle(lst,    t,j)
  t = copy(lst)
  for at = #t, 2, -1 do
    j = rand(at); t[at],t[j] = t[j],t[at] end
  return t end

-- *`some(lst:list, k:int) -> list`*  
-- k items at random -- or all of them, if k is too big.
function some(lst,k,    t)
  t = shuffle(lst)
  for at = #t, min(k, #t) + 1, -1 do t[at] = nil end
  return t end

--## rendering -------------------------------------------------
-- One number format and one table format for the whole
-- system. Both exist to keep printed output identical across
-- Lua versions, which is what makes a transcript a test.

-- *`round(v:num, n?:int) -> num`*  
-- Round to n (default `the.round`) places, then re-floor a
-- whole result: 5.3+ prints the float 15.0 as "15.0", while
-- 5.1 and LuaJIT print it as "15".
function round(v,n)
  if v % 1 == 0 then return floor(v) end
  n = 10 ^ (n or the.round)
  v = floor(v * n + 0.5) / n
  return v % 1 == 0 and floor(v) or v end

-- *`show(x:any) -> str`*  
-- Render anything. Tables recurse: lists print keyless,
-- dictionaries as ":k v" pairs, sorted.
function show(t,    u)
  if type(t) ~= "table" then
    return tostring(type(t) == "number" and round(t) or t) end
  u = #t > 0 and map(t, show) or
      sorted(kap(t, function(k,v)
        if tostring(k):sub(1,1) ~= "_" then
          return ":"..k.." "..show(v) end end))
  return "{"..table.concat(u, " ").."}" end

--## start-up --------------------------------------------------
-- Command line in, demos out. `go` is the only entry point a
-- file needs; it stays silent unless that file is the script
-- the user actually ran, so `require` never fires a demo.

-- *`cli(d:THE) -> THE`*  
-- `--key=val` flags update settings; `-h` prints the help.
-- A new value must keep the old value's type.
function cli(d,    v)
  for _, s in ipairs(arg) do
    if s == "-h" then print(d._help) end
    for k in pairs(d) do
      v = s:match("^%-%-" .. k .. "=(.*)")
      if v then
        v = thing(v)
        assert(type(v) == type(d[k]),
               "bad "..s.." : want "..type(d[k]))
        d[k] = v end end end
  return d end

-- *`run(funs:dict, w:str) -> bool?`*  
-- One seeded example. Returns nil if there is no such demo,
-- else whether it ran without crashing.
function run(funs,w,    ok,msg)
  srand(the.seed)
  if funs[w] then
    ok, msg = xpcall(funs[w], debug.traceback)
    if not ok then print(msg) end
    return ok end end

-- *`repl(env:dict)`*  
-- A tiny read-eval-print loop, run via the `--repl` demo. It
-- load()s each line inside `env` (a module _ENV), so bare
-- names like Tbl and csv resolve.
function repl(env,    s,f,ok,r)
  while true do
    io.write("ezr> ")
    s = io.read()
    if not s then io.write"\n"; return end
    f = load("return "..s, "=repl", "t", env) or
        load(s, "=repl", "t", env)
    if not f then print("! syntax") else
      ok, r = pcall(f)
      if not ok then print("! "..tostring(r))
      elseif r ~= nil then print(show(r)) end end end end

-- *`go(eg:dict)`*  
-- Parse the flags, run the demos named on the command line,
-- exit with the failure count. A no-op unless the caller is
-- the main script.
function go(eg,    n)
  if arg and arg[0] and
     debug.getinfo(2,"S").source == "@"..arg[0] then
    cli(the)
    n = 0
    for _,w in ipairs(arg) do
      if run(eg, w) == false then n = n + 1 end end
    os.exit(n) end end

the = The(help)

srand(the.seed) -- default stream; runners may reseed later

return _ENV
