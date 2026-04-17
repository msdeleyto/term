#!/usr/bin/env bash
# lib/utils.sh — Shared utilities and path variables.
# Sourced by install.sh before any module runs.

# ── Colours & logging ─────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

step() {
  local number="$1"; shift
  echo -e "\n${BOLD}━━━ Step ${number}: $* ━━━${RESET}"
}

# ── Helpers ───────────────────────────────────────────────────────────────────

# Append a line to a file only if it is not already present.
append_if_absent() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ── Shared paths ──────────────────────────────────────────────────────────────
# SCRIPT_DIR must be set by the caller (install.sh) before sourcing this file.
ZSHRC="$HOME/.zshrc"
OMZ_DIR="$HOME/.oh-my-zsh"
P10K_THEME_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}/themes/powerlevel10k"
FONTS_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="${SCRIPT_DIR}/config"
