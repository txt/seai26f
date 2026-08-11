package = "ezr"
version = "3.0-1"
source = {
  url = "git+https://github.com/timm/src.git"
}
description = {
  summary  = "Multi-goal trees, XAI, active learning,"
             .. " optimization. Tiny.",
  homepage = "https://github.com/timm/src",
  license  = "MIT"
}
dependencies = { "lua >= 5.1" }
build = {
  type = "builtin",
  modules = {
    ezr          = "ezr.lua",
    ["ezr-lib"]  = "ezr-lib.lua",
    ["ezr-eg"]   = "ezr-eg.lua",
    ["ezr-apps"] = "ezr-apps.lua",
    ["ezr-dtlz"] = "ezr-dtlz.lua"
  },
  copy_directories = { "data" },
  install = { bin = {
    ezr          = "ezr-eg.lua",
    ["ezr-apps"] = "ezr-apps.lua",
    ["ezr-dtlz"] = "ezr-dtlz.lua"
  } }
}
