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

# Ensure the OMZ export is present
append_if_absent "export ZSH=\"\$HOME/.oh-my-zsh\"" "${zshrc_path}"

if grep -q '^ZSH_THEME=' "${zshrc_path}" 2>/dev/null; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "${zshrc_path}"
  success "ZSH_THEME updated to powerlevel10k."
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "${zshrc_path}"
  success "ZSH_THEME appended to ${zshrc_path}."
fi

if [[ ! -f "${plugins_file_path}" ]]; then
  warn "No ${plugins_file_path} found — skipping plugins update."
else
  plugins_list=$(grep -v '^\s*#' "${plugins_file_path}" | grep -v '^\s*$' | tr '\n' ' ' | sed 's/ $//')
  plugins_zsh_line="plugins=(${plugins_list})"

  if grep -q '^plugins=(' "${zshrc_path}" 2>/dev/null; then
    sed -i "s|^plugins=(.*)|${plugins_zsh_line}|" "${zshrc_path}"
    success "plugins= line updated: ${plugins_zsh_line}"
  else
    echo "${plugins_zsh_line}" >> "${zshrc_path}"
    success "plugins= appended: ${plugins_zsh_line}"
  fi
fi

# source oh-my-zsh.sh must come AFTER ZSH_THEME and plugins are set
append_if_absent "source \"\$ZSH/oh-my-zsh.sh\"" "${zshrc_path}"
