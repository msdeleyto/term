#!/usr/bin/env bash
# Applies shell environment configuration

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

zshrc_path="$1"
aliases_file_path="$2"

info "Applying shell configuration"

if [[ ! -f "${aliases_file_path}" ]]; then
  warn "No ${aliases_file_path} found — skipping."
else
  cp "${aliases_file_path}" "${HOME}/.zsh_aliases"
  write_block "Aliases" 'source ~/.zsh_aliases' "${zshrc_path}"
  success "Aliases copied to ~/.zsh_aliases and block written to ${zshrc_path}."
fi
