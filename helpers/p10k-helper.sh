#!/usr/bin/env bash
# Clones the Powerlevel10k theme and applies the configuration from config/p10k.zsh.

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

zshrc_path="$1"
p10k_theme_dir="$2"
p10k_src_path="$3"

info "Installing Powerlevel10k"
if [[ -d "${p10k_theme_dir}" ]]; then
  success "Powerlevel10k already present at ${p10k_theme_dir}."
else
  info "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${p10k_theme_dir}"
  success "Powerlevel10k installed."
fi

info "Configuring Powerlevel10k"
if [[ ! -f "${p10k_src_path}" ]]; then
  warn "No ${p10k_src_path} found — skipping p10k config."
else
  cp "${p10k_src_path}" "${HOME}/.p10k.zsh"
  write_block "Powerlevel10k" 'source ~/.p10k.zsh' "${zshrc_path}"
  success "Powerlevel10k block written to ${zshrc_path}."
fi
