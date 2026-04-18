#!/usr/bin/env bash
# Installs Oh My Zsh, sets the theme, and applies plugins from config/plugins.txt.

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

zshrc_path="$1"
omz_dir="$2"
plugins_file_path="$3"

info "Installing Oh My Zsh"

if [[ -d "${omz_dir}" ]]; then
  success "Oh My Zsh already installed at ${omz_dir}."
else
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
fi

# Build plugins list
plugins_zsh_line="plugins=(git)"
if [[ -f "${plugins_file_path}" ]]; then
  plugins_list=$(grep -v '^\s*#' "${plugins_file_path}" | grep -v '^\s*$' | tr '\n' ' ' | sed 's/ $//')
  plugins_zsh_line="plugins=(${plugins_list})"
fi

omz_block="export ZSH=\"\$HOME/.oh-my-zsh\"
ZSH_THEME=\"powerlevel10k/powerlevel10k\"
${plugins_zsh_line}
source \"\$ZSH/oh-my-zsh.sh\""

write_block "Oh My Zsh" "${omz_block}" "${zshrc_path}"
success "Oh My Zsh block written to ${zshrc_path}."
