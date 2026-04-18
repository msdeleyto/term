#!/usr/bin/env bash
# Installs Oh My Zsh, sets the theme, and applies plugins from config/plugins.txt.

OMZ_DIR="${HOME}/.oh-my-zsh"

zshrc_path="$1"
plugins_file_path="$2"

info "Installing Oh My Zsh"

if [[ -d "${OMZ_DIR}" ]]; then
  success "Oh My Zsh already installed at ${OMZ_DIR}."
else
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
fi

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
