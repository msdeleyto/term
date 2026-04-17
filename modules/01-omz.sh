#!/usr/bin/env bash
# modules/01-omz.sh
# Installs Oh My Zsh, sets the theme, and applies plugins from config/plugins.txt.

step 4 "Installing Oh My Zsh"
if [[ -d "$OMZ_DIR" ]]; then
  success "Oh My Zsh already installed at $OMZ_DIR."
else
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
fi

step 5 "Setting ZSH_THEME"
if grep -q '^ZSH_THEME=' "$ZSHRC" 2>/dev/null; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
  success "ZSH_THEME updated to powerlevel10k."
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
  success "ZSH_THEME appended to $ZSHRC."
fi

step 6 "Applying OMZ plugins"
PLUGINS_FILE="$CONFIG_DIR/plugins.txt"
if [[ ! -f "$PLUGINS_FILE" ]]; then
  warn "No $PLUGINS_FILE found — skipping plugins update."
else
  plugins_list=$(grep -v '^\s*#' "$PLUGINS_FILE" | grep -v '^\s*$' | tr '\n' ' ' | sed 's/ $//')
  plugins_zsh_line="plugins=(${plugins_list})"
  if grep -q '^plugins=(' "$ZSHRC" 2>/dev/null; then
    sed -i "s|^plugins=(.*)|${plugins_zsh_line}|" "$ZSHRC"
    success "plugins= line updated: $plugins_zsh_line"
  else
    echo "$plugins_zsh_line" >> "$ZSHRC"
    success "plugins= appended: $plugins_zsh_line"
  fi
fi
