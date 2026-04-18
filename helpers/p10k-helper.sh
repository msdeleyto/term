#!/usr/bin/env bash
# Clones the Powerlevel10k theme, installs MesloLGS Nerd Fonts,
# and applies the configuration from config/p10k.zsh.

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

FONTS_DIR="${HOME}/.local/share/fonts"
FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
declare -A FONTS=(
  ["MesloLGS NF Regular.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Regular.ttf"
  ["MesloLGS NF Bold.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Bold.ttf"
  ["MesloLGS NF Italic.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Italic.ttf"
  ["MesloLGS NF Bold Italic.ttf"]="$FONT_BASE_URL/MesloLGS%20NF%20Bold%20Italic.ttf"
)

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

# info "Installing MesloLGS Nerd Fonts"
# mkdir -p "${FONTS_DIR}"
# fonts_installed=0
# for font_name in "${!FONTS[@]}"; do
#   font_path="$FONTS_DIR/$font_name"
#   if [[ -f "$font_path" ]]; then
#     success "Font already present: $font_name"
#   else
#     info "Downloading: $font_name"
#     curl -fsSL --create-dirs -o "$font_path" "${FONTS[$font_name]}"
#     (( fonts_installed++ )) || true
#   fi
# done
# if (( fonts_installed > 0 )); then
#   success "MesloLGS Nerd Fonts installed."
# fi

info "Configuring Powerlevel10k"
if [[ ! -f "${p10k_src_path}" ]]; then
  warn "No ${p10k_src_path} found — skipping p10k config."
else
  cp "${p10k_src_path}" "${HOME}/.p10k.zsh"
  success "Copied p10k config to ~/.p10k.zsh"

  # Strip legacy bare line
  sed -i '/^\[\[ -f ~\/\.p10k\.zsh \]\] && source ~\/\.p10k\.zsh$/d' "${zshrc_path}"

  write_block "Powerlevel10k" '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' "${zshrc_path}"
  success "Powerlevel10k block written to ${zshrc_path}."
fi
