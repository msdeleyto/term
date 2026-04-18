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

# Write a named, marked block to a file, idempotently.
# If the block (BEGIN/END markers) already exists, its content is replaced.
# If not, the block is appended.
# Usage: write_block <name> <content> <file>
write_block() {
  local name="$1" content="$2" file="$3"
  local begin="# --- BEGIN: ${name} ---"
  local end="# --- END: ${name} ---"
  local tmp="${file}.tmp"

  if grep -qF "${begin}" "${file}" 2>/dev/null; then
    awk -v begin="${begin}" -v end="${end}" -v content="${content}" '
      $0 == begin { print begin; print content; in_block=1; next }
      in_block && $0 == end { print end; in_block=0; next }
      in_block { next }
      { print }
    ' "${file}" > "${tmp}" && mv "${tmp}" "${file}"
  else
    printf '\n%s\n%s\n%s\n' "${begin}" "${content}" "${end}" >> "${file}"
  fi
}
