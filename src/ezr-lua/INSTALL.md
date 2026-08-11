FILES="ezr.lua
       ezr-lib.lua
       ezr-eg.lua
       ezr-apps.lua
       ezr-dtlz.lua"
: <<'DOCS'

# ezr-lua

Install:

    curl -fL https://raw.githubusercontent.com/timm/src/refs/heads/main/ezr-lua/INSTALL.md | sh

Or, via luarocks (also installs the `ezr`, `ezr-apps`,
`ezr-dtlz` commands):

    luarocks install ezr

List the files (reading order; also the doc page order):

    sh INSTALL.md list

DOCS
BASE="https://raw.githubusercontent.com/timm/src/refs/heads/main/ezr-lua/"
if [ -n "$1" ]; then echo $FILES; else
  for f in $FILES; do
    echo "# $f"
    curl -fL "$BASE/$f" -o "$f"
    done; fi
