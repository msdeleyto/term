#!/usr/bin/env bash
# Applies shell environment configuration

zshrc_path="$1"
aliases_file_path="$2"

info "Applying shell configuration"

if [[ ! -f "${aliases_file_path}" ]]; then
  warn "No ${aliases_file_path} found — skipping."
else
  cp "${aliases_file_path}" "${HOME}/.aliases"
  source_line="[[ -f \"\$HOME/.aliases\" ]] && source \"\$HOME/.aliases\""
  append_if_absent "${source_line}" "${zshrc_path}"
  success "Aliases copied to ~/.aliases and source line present in ${zshrc_path}."
fi
