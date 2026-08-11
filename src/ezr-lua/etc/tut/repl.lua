-- ezr REPL replay harness. usage: lua repl.lua FILE [start]
-- Runs from the ezr-lua dir so package.path finds the modules.
local dir = os.getenv("EZR") or "."
package.path = dir.."/?.lua;"..package.path
local E = require"ezr-apps"        -- chains: apps->ezr->lib->_G
local ok,D = pcall(require,"ezr-dtlz"); if ok then
  setmetatable(D, {__index=E}); E = D end
E.the.DATA = (dir:gsub("/$","")).."/data/"   -- add dtlz names
local n = (tonumber(arg[2]) or 1) - 1
for s in io.lines(arg[1]) do
  if s:match"^####" or s == "" then print(s)
  else
    n = n + 1
    io.write(("[%d]> %s\n"):format(n, s))
    local f = s:match";$" and load(s,"=l","t",E)
              or load("return "..s,"=l","t",E) or load(s,"=l","t",E)
    local r = {pcall(f)}
    if r[1] then
      if #r > 1 then
        local o={} for i=2,#r do o[#o+1]=tostring(r[i]) end
        print(table.concat(o,"\t")) end
    else print("ERROR: "..tostring(r[2])) end end end
print(("-- next event: [%d]"):format(n+1))
