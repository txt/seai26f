-- play.lua: a scratchpad for the tutorial. Start it with
--     lua -i play.lua
-- and every name from ezr, ezr-lib, ezr-apps and ezr-dtlz is
-- in scope at the prompt. Lua's own -i gives you arrow keys,
-- history and multi-line input, so no rlwrap is needed.
--
-- Why a separate file: the modules keep their definitions in
-- a `local _ENV`, which `lua -i` cannot see, and each -eg
-- file calls go() and exits. This file does neither. It just
-- copies the names up into _G and hands you the prompt.

package.path = (arg and arg[0] or ""):gsub("[^/]*$","")
               .. "?.lua;" .. package.path

local E = require"ezr-apps"          -- chains: apps -> ezr -> lib
local ok, D = pcall(require, "ezr-dtlz")
if ok then setmetatable(D, {__index=E}); E = D end

-- Walk the __index chain and lift every public name into _G,
-- nearest module first so the newest definition wins.
local t = E
while type(t) == "table" do
  for k, v in pairs(t) do
    if type(k) == "string" and k:sub(1,1) ~= "_" and _G[k] == nil then
      _G[k] = v end end
  local mt = getmetatable(t)
  t = mt and mt.__index end

_PROMPT  = "ezr> "                   -- lua -i honours these
_PROMPT2 = "  .. "

_G.srand(_G.the.seed)                -- same stream every start

print(("ezr ready. Default table: %s"):format(_G.the.file))
print("in scope: the, Tbl, csv, Num, Sym, Tree, acquirer ...")
print("try:     t = Tbl(csv())   then   #t.rows")
print("Ctrl-D exits.")
