#!/usr/bin/env bash
# Installs Nerd Fonts required by the Powerlevel10k prompt.
# Edit FONT_NAME and FONT_FILES to install a different font.

set -euo pipefail

# shellcheck source=../lib/utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# ── Font to install ────────────────────────────────────────────────────────────
FONT_NAME="MesloLGS NF"

FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
declare -A FONT_FILES=(
  ["MesloLGS NF Regular.ttf"]="${FONT_BASE_URL}/MesloLGS%20NF%20Regular.ttf"
  ["MesloLGS NF Bold.ttf"]="${FONT_BASE_URL}/MesloLGS%20NF%20Bold.ttf"
  ["MesloLGS NF Italic.ttf"]="${FONT_BASE_URL}/MesloLGS%20NF%20Italic.ttf"
  ["MesloLGS NF Bold Italic.ttf"]="${FONT_BASE_URL}/MesloLGS%20NF%20Bold%20Italic.ttf"
)
# ──────────────────────────────────────────────────────────────────────────────

FONTS_DIR="${HOME}/.local/share/fonts/p10k"

info "Installing ${FONT_NAME} fonts"
mkdir -p "${FONTS_DIR}"

fonts_installed=0
for font_name in "${!FONT_FILES[@]}"; do
  font_path="${FONTS_DIR}/${font_name}"
  if [[ -f "${font_path}" ]]; then
    success "Font already present: ${font_name}"
  else
    info "Downloading: ${font_name}"
    curl -fsSL -o "${font_path}" "${FONT_FILES[${font_name}]}"
    (( fonts_installed++ )) || true
  fi
done

if (( fonts_installed > 0 )); then
  info "Refreshing font cache..."
  fc-cache -fv 2>&1 | tail -1
  success "${FONT_NAME} fonts installed (${fonts_installed} file(s) downloaded)."
else
  success "${FONT_NAME} fonts already up to date."
fi
