-- find shifts where cohen/ks/cliffs split their vote,
-- under the new Park-Miller stream + book seed
package.path = "/Users/timm/gits/timm/src/sas/src/?.lua;"
               .. package.path
local z = require"ezr3"
local sqrt,log,cos,pi = math.sqrt, math.log, math.cos, math.pi
z.srand(z.the.seed)
local g = function()
  local u = {}
  for j = 1, 100 do
    u[j] = sqrt(-2*log(1 - z.rand()))
           * cos(2*pi*z.rand()) end
  return z.sorted(u) end
local x = g()
for j = 0, 100 do
  local mu = j / 100
  local y  = z.map(x, function(v) return v + mu end)
  local c  = z.cohen(x, y)  <= 0.35
  local k  = z.ks(x, y)     <= 1.36
  local cl = z.cliffs(x, y) <= 0.195
  if (c ~= k) or (k ~= cl) then
    print(("%.2f c=%s k=%s cl=%s"):format(
      mu, tostring(c), tostring(k), tostring(cl))) end end
