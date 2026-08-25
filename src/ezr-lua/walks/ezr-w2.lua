-- ezr, week 2: tables, distance, gap to heaven.
-- One weekly-sized chunk of [ezr.lua](ezr.html), verbatim, with
-- glossary notes folded in, and this
-- week's exercises at the bottom.
--
-- ## This week's story
-- Rows gather into tables; row 1 alone decides every column's
-- kind and role. Then two numbers see the whole table: distx,
-- the gap between two rows over the x columns; and disty, the
-- gap from a row's goals to heaven. Sorting by disty is
-- optimization with no model, no weights, no training.
--
-- ---
--
-- @gloss Tbl
function Tbl(src)
  src = iter(src)
  return adds(src, new(TBL, {rows={}, mid=nil,
                             cols=Cols(src())})) end

function Cols(names,    all,x,y,klass)
  all, x, y = {}, {}, {}
  for at, s in ipairs(names) do
    all[at] = Col(s, at)
    if s:find"!$" then klass = all[at]
    elseif s:find"[+-]$" then y[#y+1] = all[at]
    elseif s:sub(-1) ~= "X" then x[#x+1] = all[at] end end
  return new(COLS, {names=names,all=all,x=x,y=y,klass=klass}) end

-- @gloss minkowski
function minkowski(cols,f,    d,n)
  d, n = 0, TINY
  for _, c in ipairs(cols) do n, d = n+1, d + f(c) ^ the.p end
  return (d / n) ^ (1 / the.p) end

-- @gloss distx
function SYM.dist(i,a,b)
  if a == "?" and b == "?" then return 1 end
  return a ~= b and 1 or 0 end

function NUM.dist(i,a,b)
  if a == "?" and b == "?" then return 1 end
  a, b = i:norm(a), i:norm(b)
  if a == "?" then a = b > 0.5 and 0 or 1 end
  if b == "?" then b = a > 0.5 and 0 or 1 end
  return abs(a - b) end

function TBL.distx(i,row1,row2)
  return minkowski(i.cols.x, function(c)
           return c:dist(row1[c.at], row2[c.at]) end) end

-- @gloss heaven
-- @gloss disty
-- @gloss Pareto frontier
-- @gloss Pareto zoom
function TBL.disty(i,row)
  if i.model and row[i.cols.y[1].at] == "?" then
    i:label(row) end
  return minkowski(i.cols.y, function(y)
           return abs(y:norm(row[y.at]) - y.heaven) end) end

--## exercises -------------------------------------------------
-- <div class=ex>
--
-- **Exercises, week 2**
--
-- 1. Port this page's code to Python, wiring each demo of
--    ezr-eg2 (`--distx --disty --laws`) to a test_ function.
-- 2. On auto93, sort all rows by disty and print the top and
--    bottom three. Do the best rows *look* best? (If not, see
--    exercise 5 of week 1.)
-- 3. `--laws` probes distance laws at random. State the four
--    laws. Which one fails for the "?"-handling here, and why
--    is that a price worth paying?
-- 4. Set `the.p=1`, then 4, then 8. How does the disty ranking
--    change? What is minkowski converging to as p grows?
-- 5. distx never reads a goal; disty reads nothing else. Why
--    does that split matter when labels cost money?
--
-- </div>
local _ = "week 2 ends here"
