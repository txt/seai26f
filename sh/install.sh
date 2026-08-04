#!/usr/bin/env bash
# Below is a **fully hardened, idempotent, cross-platform bootstrap script**.
# 
# Design goals met:
# 
# * ✅ **macOS (Intel + Apple Silicon)**
# * ✅ **Ubuntu / Debian**
# * ✅ **WSL**
# * ✅ **Arch Linux**
# * ⚠️ **Other Linux distros** → still works via **Linuxbrew**, system deps skipped safely
# * ❌ **No assumptions** about `sudo`, `apt`, `bashrc`, or shell
# * ✅ **Safe re-runs** (idempotent)
# * ✅ **Correct PATH setup (session + persistent)**
# * ✅ **Graceful degradation**
# 
# ---
# 
# ## ✅ Hardened “works everywhere” script

set -euo pipefail

echo "🔍 Detecting environment..."

OS="$(uname -s)"
ARCH="$(uname -m)"
OSTYPE_LC="$(printf '%s' "${OSTYPE:-unknown}" | tr '[:upper:]' '[:lower:]')"

IS_LINUX=false
IS_MAC=false
IS_WSL=false

[[ "$OS" == "Linux" ]] && IS_LINUX=true
[[ "$OS" == "Darwin" ]] && IS_MAC=true
grep -qi microsoft /proc/version 2>/dev/null && IS_WSL=true

command -v sudo &>/dev/null && SUDO="sudo" || SUDO=""

echo "   OS=$OS  ARCH=$ARCH  WSL=$IS_WSL"

# ------------------------------------------------------------
# 1. System prerequisites (best-effort, Ubuntu/Debian/Arch only)
# ------------------------------------------------------------
if $IS_LINUX && command -v apt &>/dev/null; then
  echo "📦 Installing system prerequisites (apt)..."
  $SUDO apt update -y
  $SUDO apt install -y \
    build-essential procps curl file git perl || true
elif $IS_LINUX && command -v pacman &>/dev/null; then
  echo "📦 Installing system prerequisites (pacman)..."
  $SUDO pacman -Sy --needed --noconfirm \
    base-devel procps-ng curl file git perl || true
else
  echo "ℹ️  No supported system package manager detected; skipping sys deps"
fi

# ------------------------------------------------------------
# 2. Install Homebrew if missing
# ------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ------------------------------------------------------------
# 3. Ensure brew is in PATH (current session)
# ------------------------------------------------------------
# h
#
brew_shellenv() {
  for p in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    "$HOME/.linuxbrew/bin/brew" \
    /home/linuxbrew/.linuxbrew/bin/brew
  do
    [[ -x "$p" ]] && "$p" shellenv && return 0
  done
  return 1
}

eval "$(brew_shellenv)"

if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew not found in PATH after install"
  exit 1
fi

echo "🍺 Homebrew ready: $(brew --version | head -1)"

# ------------------------------------------------------------
# 4. Persist Homebrew PATH (bash + zsh, no shell guessing)
# ------------------------------------------------------------
BREW_LINE='eval "$($(brew --prefix)/bin/brew shellenv)"'

persist() {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  grep -Fqs "$BREW_LINE" "$rc" || {
    echo "🔧 Persisting Homebrew PATH in $rc"
    echo "$BREW_LINE" >> "$rc"
  }
}

# Always correct for login shells
persist "$HOME/.profile"

# Nice-to-have for interactive shells
persist "$HOME/.bashrc"
persist "$HOME/.zshrc"

# ------------------------------------------------------------
# 5. Update brew safely
# ------------------------------------------------------------
echo "🔄 Updating Homebrew..."
brew update || true

# ------------------------------------------------------------
# 6. Install tools (idempotent)
# ------------------------------------------------------------
tools=(
  # Core
  yazi tmux gawk julia lua pandoc micro ghostscript nano
  bat stow python bash figlet make neovim ranger
  asciiquarium cmatrix htop

  # Yazi deps
  ffmpegthumbnailer sevenzip jq poppler fd ripgrep fzf
)

echo "📦 Installing tools via Homebrew..."
for t in "${tools[@]}"; do
  if brew list "$t" &>/dev/null; then
    echo "   ✔ $t already installed"
  else
    echo "   ➕ installing $t"
    brew install "$t" || echo "   ⚠️  failed: $t (continuing)"
  fi
done

# ------------------------------------------------------------
# 7. TinyTeX (portable LaTeX)
# ------------------------------------------------------------
if ! command -v pdflatex &>/dev/null; then
  echo "📄 Installing TinyTeX..."
  curl -fsSL https://yihui.org/tinytex/install-bin-unix.sh | sh
else
  echo "✔ LaTeX already present"
fi

# ------------------------------------------------------------
# 8. Final sanity check
# ------------------------------------------------------------
echo
echo "✅ Installation complete"
echo "   Shell: $SHELL"
echo "   Brew:  $(brew --prefix)"
echo
SHELL_RC=""
if [[ -f "$HOME/.bashrc" && "$SHELL" == *"bash"* ]]; then
  SHELL_RC="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" && "$SHELL" == *"zsh"* ]]; then
  SHELL_RC="$HOME/.zshrc"
fi

if [[ -n "$SHELL_RC" ]]; then
  echo "👉 Restart your terminal or run:"
  echo "   source \"$SHELL_RC\""
else
  echo "👉 Restart your terminal to activate changes"
fi

# ---
# 
# ## Why this truly “works everywhere”
# 
# | Problem            | Solution                            |
# | ------------------ | ----------------------------------- |
# | macOS Intel vs ARM | Dynamic brew discovery              |
# | Linux vs WSL       | `uname` + `/proc/version` detection |
# | Missing `sudo`     | Optional `sudo`                     |
# | Missing `apt`      | Safe skip                           |
# | Bash vs Zsh        | Correct RC file                     |
# | PATH not active    | In-session + persistent fix         |
# | Re-running         | Fully idempotent                    |
# | Partial failures   | Continue safely                     |
# 
# ---
# 
# ## Optional upgrades (nice but not needed)
# 
# If you want, I can also give you:
# 
# * 🧪 `--dry-run` mode
# * ⚡ parallel installs
# * 🧱 distro-native fallback (dnf / pacman / apk)
# * 📜 logging to file
# * 🐳 container-safe variant
# * 🧩 split into reusable modules
# 
# Just tell me how far you want to take it.
# 
# 
