#!/usr/bin/env lua
-- ezr-eg3.lua: week 3 of ten. Clustering by poles.
-- Tutorial and tests in one file: prose lives in these
-- comments, each demo is one eg[] function that reseeds,
-- prints, then asserts; no crash means pass.
--
-- ## Install
--     sudo apt install lua5.4 luajit         # Debian, Ubuntu
--     brew install lua luajit                # macOS
--     sudo ln -sf /usr/bin/lua5.4 /usr/local/bin/lua # Debian
--
-- ## Run
--     lua ezr-eg3.lua --egs     # list this week's demos
--     lua ezr-eg3.lua --all     # run them all; "failures: 0"
--     lua ezr-eg3.lua --half    # run just one
--     luajit ezr-eg3.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Last week, distance. This week, what distance buys:
-- structure, found without labels. Pick a row at random; its
-- farthest neighbor is one pole; that pole's farthest neighbor
-- is the other. Two distance sweeps, and we hold (roughly) the
-- longest line through the data (fastmap). The cosine rule
-- then projects every row onto that line, keysort orders them
-- (slow keys, cached once -- see w3's DSU notes), and a median
-- split gives two halves. Recurse and that is Node: a binary
-- chop through data space, log-many splits deep, no centroids,
-- no k, no labels -- except two. Each split labels only its
-- poles, so the better pole goes first and the left half leans
-- toward heaven. Remember that thrift; it becomes active
-- learning.
--
-- ## Glossary
-- [cluster](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#cluster),
-- [fastmap](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#fastmap),
-- [projection](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#projection),
-- [halve](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#halve),
-- [node](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#node),
-- [distx](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#distx),
-- [disty](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#disty)
--
-- ---

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- all defs below land here; reads fall through to ezr
-- (and, through it, to lib and _G)
local _ENV = setmetatable({}, {__index = require"ezr"})
if setfenv then setfenv(1, _ENV) end

--## demos -----------------------------------------------------
eg, doc = {}, {}

doc["--egs"] = "list this week's demos"
eg["--egs"] = function()
  for _,k in ipairs(keys(eg)) do
    print(("%-10s %s"):format(k, doc[k] or "")) end end

doc["--repl"] = "an interactive prompt; bare names resolve"
eg["--repl"] = function() repl(_ENV) end

doc["--all"] = "all the demos; fail if any of them do"
eg["--all"] = function(    bad)
  bad = 0
  for _,k in ipairs(keys(eg)) do
    if k ~= "--all" and k ~= "--egs" and k ~= "--repl" and
       run(eg, k) == false then bad = bad + 1 end end
  print("failures: " .. bad)
  assert(bad == 0) end

-- *`lua ezr-eg3.lua --half`*
-- The far-pole split, and which half is the good one.
doc["--half"] = "split on far poles; better pole first"
eg["--half"] = function(    t,a,b,lo,hi)
  t = Tbl(csv(the.file))
  a, b, lo, hi = t:halve(t.rows)
  print(show{lo=#lo, hi=#hi,
             a=t:disty(a), b=t:disty(b)})
  assert(#lo + #hi == #t.rows)             -- rows conserved
  assert(t:disty(a) <= t:disty(b)) end     -- best pole first

-- *`lua ezr-eg3.lua --node`*
-- Recursive halving; rows are conserved in the leafs.
doc["--node"] = "tree of halves; rows conserved in leafs"
eg["--node"] = function(    t,nd,n,leafs,walk)
  t  = Tbl(csv(the.file))
  nd = Node(t)
  n, leafs = 0, 0
  walk = function(x)
    if x.lo then walk(x.lo); walk(x.hi)
    else n = n + #x.here.rows; leafs = leafs + 1 end end
  walk(nd)
  print(show{leafs=leafs, rows=n,
             leaf1=t:disty(nd:leaf(t.rows[1]).here.rows[1])})
  assert(n == #t.rows and leafs > 1) end

--## homework 3 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg3.lua. For its demos (--half, --node), trace
--    only the functions they actually call, following the
--    require chain into [ezr.lua](ezr.html) and
--    [ezr-lib.lua](ezr-lib.html). Print that Lua source in two
--    parts, split by a divider line: above it, code I must
--    hand-port to Python; below it, code a Python builtin
--    already handles, each function commented with the module
--    and function that replaces it. Near enough is good
--    enough."
-- 2. Port the above-the-line code to Python, on top of last
--    week's Tbl, distx and disty, wiring each demo to a test_
--    function. Near enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers.
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for poles, halve and Node. At the end of that
--    code, add comments answering the "check your port"
--    questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. poles picks its two poles from some(rows, the.few), a
--    random sample of 128 rows, not from all of them. Rerun
--    --half with --few=8, then --few=512. How much do the
--    halves change? Why so little?
-- 7. After finding the two poles, one line sorts them by
--    disty. How many labels does a single halve spend, and
--    what does that buy the left-hand half?
-- 8. Node stops splitting when a node holds fewer than
--    2 * the.stop rows. auto93 has 398 rows and stop=32:
--    predict the leaf count BEFORE running --node.
-- 9. The projection is (d(lo,r)^2 + c^2 - d(hi,r)^2) / (2c),
--    where c = d(lo,hi). Draw the triangle and derive this
--    from the cosine rule. What does a projection less than
--    zero tell you about a row?

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
