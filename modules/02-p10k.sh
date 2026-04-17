#!/usr/bin/env bash
# modules/02-p10k.sh
# Clones the Powerlevel10k theme, installs MesloLGS Nerd Fonts,
# and applies the configuration from config/p10k.zsh.

step 7 "Installing Powerlevel10k theme"
if [[ -d "$P10K_THEME_DIR" ]]; then
  success "Powerlevel10k already present at $P10K_THEME_DIR."
else
  info "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
  success "Powerlevel10k installed."
fi

step 8 "Installing MesloLGS Nerd Fonts"
FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
declare -A FONTS=(
  ["MesloLGS NF Regular.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Regular.ttf"
  ["MesloLGS NF Bold.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Bold.ttf"
  ["MesloLGS NF Italic.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Italic.ttf"
  ["MesloLGS NF Bold Italic.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Bold%20Italic.ttf"
)
mkdir -p "$FONTS_DIR"
fonts_installed=0
for font_name in "${!FONTS[@]}"; do
  font_path="$FONTS_DIR/$font_name"
  if [[ -f "$font_path" ]]; then
    success "Font already present: $font_name"
  else
    info "Downloading: $font_name"
    curl -fsSL --create-dirs -o "$font_path" "${FONTS[$font_name]}"
    (( fonts_installed++ )) || true
  fi
done
if (( fonts_installed > 0 )); then
  info "Refreshing font cache..."
  fc-cache -fv "$FONTS_DIR" &>/dev/null
  success "Font cache updated."
fi

step 9 "Applying Powerlevel10k config"
P10K_SRC="$CONFIG_DIR/p10k.zsh"
if [[ ! -f "$P10K_SRC" ]]; then
  warn "No $P10K_SRC found — skipping p10k config."
else
  cp "$P10K_SRC" "$HOME/.p10k.zsh"
  success "Copied p10k config to ~/.p10k.zsh"
  append_if_absent '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' "$ZSHRC"
  success "p10k source line present in $ZSHRC."
fi
