#!/usr/bin/env bash
# Verifies required tools are present, installs zsh, and sets it as default shell.

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

info "Checking prerequisites"

missing=()

for cmd in curl git zsh; do
  command -v "${cmd}" &>/dev/null || missing+=("${cmd}")
done

if (( ${#missing[@]} )); then
  error "Missing required tools: ${missing[*]}"
  error "Install them and re-run this script."
  exit 1
fi

success "zsh, curl and git are available."
