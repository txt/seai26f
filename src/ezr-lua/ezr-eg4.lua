#!/usr/bin/env lua
-- ezr-eg4.lua: week 4 of ten. Cuts, trees, XAI.
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
--     lua ezr-eg4.lua --egs     # list this week's demos
--     lua ezr-eg4.lua --all     # run them all; "failures: 0"
--     lua ezr-eg4.lua --show    # run just one
--     luajit ezr-eg4.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Last week, geometry split the rows. This week we ask a
-- business question of the split: WHICH single test -- which
-- column, cut where -- best separates good from bad? Score a
-- candidate cut by the expected diversity of its two sides
-- (val); score every cut of a sorted column in one linear
-- pass (grow the left summary, and the right is just
-- tot - here, by week 1's subtraction algebra); pass every
-- candidate to one champion-keeping closure (least). Recurse
-- on the winner and a decision tree falls out -- small enough
-- to read aloud, which is this course's idea of explainable
-- AI. Then go further: --tree visits every PRUNING of the
-- grown tree, hunting one that is smaller but scores the
-- same; --why walks one row to its leaf and prints the
-- journey as a sentence.
--
-- ## Glossary
-- [cut](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#cut),
-- [expected value](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#expected-value),
-- [val](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#val),
-- [least](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#least),
-- [one-pass cuts](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#one-pass-cuts),
-- [tree](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#tree),
-- [XAI](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#xai),
-- [diversity](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#diversity)
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

-- *`lua ezr-eg4.lua --cuts`*
-- The champion cut, named.
doc["--cuts"] = "the champion cut, named"
eg["--cuts"] = function(    t,b,c)
  t = Tbl(csv(the.file))
  b = t:bestcut(t.rows, t:Y(), Num, least())
  c = t.cols.all[b[2]]
  print(("best cut: %s <= %s (val %.3f)")
        :format(c.name, b[3], b[1]))
  assert(b[1] >= 0 and c) end

-- *`lua ezr-eg4.lua --show`*
-- The tree, one row per node, one column per goal mean.
-- Best leaf marked; best branch always printed first.
doc["--show"] = "print the tree; goal means per node"
eg["--show"] = function(    t,tr)
  t  = Tbl(csv(the.file))
  tr = Tree(t, t.rows)
  tr:show(t)
  assert(tr.leafs > 1) end

-- *`lua ezr-eg4.lua --tree`*
-- Visit every pruning of a grown tree, keep the best:
-- smallest tree whose val is no worse.
doc["--tree"] = "visit every pruning; keep the best"
eg["--tree"] = function(    t,tr,n,best)
  t  = Tbl(csv(the.file))
  tr = Tree(t, t.rows)
  n  = 0
  tr:walk(function(w)
    n = n + 1
    if not best or w.val < best.val or
       (w.val == best.val and w.leafs < best.leafs) then
      best = w end end)
  print(("tree: %s leafs. prunings: %s. best: %s leafs,"
         .." val %s"):format(tr.leafs, n, best.leafs,
                               show(best.val)))
  assert(best.val <= tr.val and best.leafs <= tr.leafs) end

-- *`lua ezr-eg4.lua --why`*
-- XAI, one row at a time: walk a row to its leaf, printing
-- each test taken. An explanation is a path you can argue
-- with.
doc["--why"] = "one row's path to its leaf, in words"
eg["--why"] = function(    t,tr,rows,why,n1,n2)
  t    = Tbl(csv(the.file))
  tr   = Tree(t, t.rows)
  rows = keysort(t.rows, t:Y())
  why  = function(row,    w,c,ok,n)
    w, n = tr, 0
    while w.at do
      c  = t.cols.all[w.at]
      ok = c:holds(row[w.at], w.v)
      io.write(c.name, c.has and (ok and " == " or " ~= ")
                            or  (ok and " <= " or " >  "),
               show(w.v), "; ")
      w, n = ok and w.yes or w.no, n + 1 end
    print("=> guess " .. show(w.mu))
    return n, w.mu end
  io.write("best  row: "); n1 = why(rows[1])
  io.write("worst row: "); n2 = why(rows[#rows])
  assert(n1 <= the.maxd and n2 <= the.maxd) end

--## homework 4 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg4.lua. For its demos (--cuts, --tree, --show,
--    --why), trace only the functions they actually call,
--    following the require chain into [ezr.lua](ezr.html) and
--    [ezr-lib.lua](ezr-lib.html). Print that Lua source in two
--    parts, split by a divider line: above it, code I must
--    hand-port to Python; below it, code a Python builtin
--    already handles, each function commented with the module
--    and function that replaces it. Near enough is good
--    enough."
-- 2. Port the above-the-line code to Python, on top of last
--    week's poles, halve and Node, wiring each demo to a test_
--    function. Near enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers. Stuck on the ideas? Each function
--    here gets its own tiny lecture in [gloss4](gloss4.html).
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for val, the cuts functions and Tree. At the
--    end of that code, add comments answering the "check your
--    port" questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. NUM.cuts sorts its (x,y) pairs before walking them. What
--    exactly breaks if you skip the sort? (Hint: what does
--    "tot - here" mean when "here" is not a prefix?)
-- 7. Rerun --show with --leaf=1. What happens to the leaf
--    sizes, and why is a leaf of one row memorization rather
--    than learning?
-- 8. --tree reports the pruning count. Why can a pruned tree
--    with FEWER leafs score the same val as the full tree,
--    and why should you prefer it when it does?
-- 9. In --show's output, siblings print better-branch-first
--    and the best leaf is marked. What can a reader with ten
--    seconds learn from just the top three lines?

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
