#!/usr/bin/env lua
-- ezr-eg7.lua: week 7 of ten. Applications.
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
--     lua ezr-eg7.lua --egs     # list this week's demos
--     lua ezr-eg7.lua --all     # run them all; "failures: 0"
--     lua ezr-eg7.lua --knn     # run just one
--     luajit ezr-eg7.lua --all  # 10-50x faster, same output
--
-- ## This week's story
-- Data mining textbooks give a chapter each to prediction,
-- anomaly detection, Bayes classifiers and clustering. This
-- week is the claim that those chapters are SYNONYMS: with a
-- distance function and a few column summaries already built,
-- each chapter is a dozen lines.
--
-- * The Fortune Teller (`knn`): to guess a row's goals, ask
--   the `the.k` rows nearest it. No model is fitted; the
--   neighbours ARE the model.
-- * The Bouncer (`anomaly`): score a row by how far it sits
--   from everything seen so far. This is the certification
--   envelope -- the red light that says "you are asking me
--   about something I was never built from". Learners without
--   one answer anyway, confidently, which is how NASA's Crater
--   model came to rule on debris 400 times larger than
--   anything it had been calibrated on.
-- * The ER Nurse (`classify`): naive Bayes, test-then-train.
--   Each class keeps its own column summaries, a row goes to
--   whichever class likes it best, and only then is the true
--   label folded in. No batch, no epochs.
-- * The Curator (`kmeans`, `kpp`): k centroids, assign and
--   recentre -- and kpp, which seeds those centroids far
--   apart, because week 3's poles taught the same lesson.
--
-- Four "different" algorithms; one substrate. Count the new
-- lines each one needed: that number is the whole argument of
-- this course, and of the undergraduate project.
--
-- ## Glossary
-- [knn](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#knn),
-- [anomaly detection](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#anomaly-detection),
-- [certification envelope](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#certification-envelope),
-- [naive bayes](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#naive-bayes),
-- [kmeans](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#kmeans),
-- [kpp](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#kpp),
-- [synonyms](https://github.com/txt/seai26f/blob/main/docs/lect/glossary.md#synonyms)
--
-- ---

-- find [ezr.lua](ezr.html) beside this file, whatever the cwd
package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path
-- reads fall through to [ezr-apps](ezr-apps.html), where this
-- week's four residents live, and through it to ezr, lib, _G
local _ENV = setmetatable({}, {__index = require"ezr-apps"})
if setfenv then setfenv(1, _ENV) end

local abs, floor, min = math.abs, math.floor, math.min

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

-- *`lua ezr-eg7.lua --knn`*
-- Neighbours beat the global mean as a guess. Nothing was
-- fitted; the data is the model.
doc["--knn"] = "guess from k neighbours; beats the mean guess"
eg["--knn"] = function(    t,y,mu,e1,e2,r)
  t  = Tbl(csv(the.file))
  y  = t:Y()
  mu = adds(map(t.rows, y)).mu
  e1, e2 = 0, 0
  for _ = 1, 32 do
    r  = t.rows[rand(#t.rows)]
    e1 = e1 + abs(t:knn(r) - y(r))
    e2 = e2 + abs(mu       - y(r)) end
  print(("knn err %.3f vs mean-guess err %.3f"):format(
          e1/32, e2/32))
  assert(e1 < e2) end

-- *`lua ezr-eg7.lua --detect`*
-- Anomaly scores, 0..1: someone in here is lonely. That score
-- is the red light on any prediction made about that row.
doc["--detect"] = "anomaly scores; the red light on a guess"
eg["--detect"] = function(    t,det,ss)
  t   = Tbl(csv(the.file))
  det = t:anomaly()
  ss  = sorted(map(t.rows, det))
  print("anomaly scores " .. show{lo=ss[1],
        mid=ss[floor(#ss/2)+1], hi=ss[#ss]})
  assert(0 <= ss[1] and ss[#ss] <= 1)
  assert(ss[#ss] > 0.5)                 -- somebody is odd
  assert(ss[floor(#ss/2)+1] < ss[#ss]) end -- most are not

-- *`lua ezr-eg7.lua --nb`*
-- Naive Bayes, test-then-train: guess first, learn second, so
-- every score is earned on unseen rows.
doc["--nb"] = "test-then-train naive bayes, on diabetes"
eg["--nb"] = function(    t,seen,a)
  t    = Tbl(csv"$MOOT/classify/diabetes.csv")
  seen = t:classify()
  a    = acc(seen)
  print(("diabetes: acc %.2f over %s guesses"):format(
          a, #seen))
  assert(a > 0.65) end

-- *`lua ezr-eg7.lua --kmeans`*
-- The textbook clusterer: assign, recentre, repeat. Rows are
-- conserved -- a cheap, sharp test of any clusterer.
doc["--kmeans"] = "assign and recentre; rows are conserved"
eg["--kmeans"] = function(    t,cs,n)
  t  = Tbl(csv(the.file))
  cs = t:kmeans()
  n  = 0
  for _,c in ipairs(cs) do n = n + #c.rows end
  print("cluster sizes " ..
    show(sorted(map(cs, function(c) return #c.rows end))))
  assert(n == #t.rows and #cs <= the.kluster) end

-- *`lua ezr-eg7.lua --kpp`*
-- Seeds, spread out: each new centre is picked with a chance
-- proportional to its distance from the centres so far. Week
-- 3's poles, wearing a different hat.
doc["--kpp"] = "seeds picked far apart, kmeans++ style"
eg["--kpp"] = function(    t,cents,d)
  t     = Tbl(csv(the.file))
  cents = t:kpp()
  d = 1e32
  for j = 1, #cents do
    for k = j+1, #cents do
      d = min(d, t:distx(cents[j], cents[k])) end end
  print(("%s kpp seeds, min gap %.3f"):format(#cents, d))
  assert(#cents == the.kluster and d > 0) end

--## homework 7 ------------------------------------------------
-- 1. Give Claude this prompt:
--    "Read ezr-eg7.lua. For its demos (--knn, --detect, --nb,
--    --kmeans, --kpp), trace only the functions they actually
--    call, following the require chain into
--    [ezr-apps.lua](ezr-apps.html), [ezr.lua](ezr.html) and
--    [ezr-lib.lua](ezr-lib.html). Print that Lua source in two
--    parts, split by a divider line: above it, code I must
--    hand-port to Python; below it, code a Python builtin
--    already handles, each function commented with the module
--    and function that replaces it. Near enough is good
--    enough."
-- 2. Port the above-the-line code to Python, on top of the
--    weeks before, wiring each demo to a test_ function. Near
--    enough is good enough.
-- 3. Think, pair, share: list all the bits you do not
--    understand. Share that list with your pair. See if,
--    together, you can figure them out.
-- 4. Make that Python perform like the Lua: same demos,
--    similar printed numbers. Stuck on the ideas? Each function
--    here gets its own tiny lecture in [gloss7](gloss7.html).
-- 5. Hand in: one side of one piece of paper, showing your
--    Python code for knn, anomaly and the naive Bayes scorer.
--    At the end of that code, add comments answering the
--    "check your port" questions below.
--
-- Check your port (we will discuss these in class):
--
-- 6. Count the NEW lines each resident needed on top of the
--    distance and column machinery you already had. Plot those
--    counts, chapter by chapter. Is the plot falling? (That is
--    the undergraduate project, in miniature.)
-- 7. --detect scores rows already IN the table. Sketch the
--    three extra lines that would turn it into a certification
--    envelope around --knn: a guess, plus a warning when the
--    row is too strange to trust. What threshold would you
--    use, and how would you pick it?
-- 8. Naive Bayes assumes the columns are independent, which is
--    plainly false for (say) weight and horsepower. Rerun --nb
--    with two strongly correlated columns duplicated. What
--    happens to accuracy, and why is "naive" still a winning
--    bet in practice?
-- 9. kmeans needs k, a full pass per iteration and a distance
--    to every centroid. Week 3's Node needs none of those.
--    Name one thing kmeans gives you that Node does not -- and
--    one thing Node gives you that kmeans cannot.

--## start-up --------------------------------------------------
-- Fires only when this file is the script the user ran.
go(eg)

return _ENV
