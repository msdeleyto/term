#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# install.sh — Terminal bootstrap: zsh + Oh My Zsh + Powerlevel10k
#
# Usage:  bash install.sh
# Safe to re-run: every step is idempotent.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
OMZ_DIR="$HOME/.oh-my-zsh"
P10K_THEME_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}/themes/powerlevel10k"
FONTS_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="$SCRIPT_DIR/config"

# ── Helpers ───────────────────────────────────────────────────────────────────

# Append a line to a file only if it is not already present.
append_if_absent() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ── Step 1: Prerequisites ──────────────────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 1: Checking prerequisites ━━━${RESET}"
missing=()
for cmd in curl git; do
  command -v "$cmd" &>/dev/null || missing+=("$cmd")
done
if (( ${#missing[@]} )); then
  error "Missing required tools: ${missing[*]}"
  error "Install them and re-run this script."
  exit 1
fi
success "curl and git are available."

# ── Step 2: Install zsh ────────────────────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 2: Install zsh ━━━${RESET}"
if command -v zsh &>/dev/null; then
  success "zsh is already installed ($(zsh --version))."
else
  info "Installing zsh via apt..."
  sudo apt-get update -qq && sudo apt-get install -y zsh
  success "zsh installed."
fi

# ── Step 3: Install Oh My Zsh ─────────────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 3: Install Oh My Zsh ━━━${RESET}"
if [[ -d "$OMZ_DIR" ]]; then
  success "Oh My Zsh already installed at $OMZ_DIR."
else
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed."
fi

# ── Step 4: Install Powerlevel10k theme ───────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 4: Install Powerlevel10k ━━━${RESET}"
if [[ -d "$P10K_THEME_DIR" ]]; then
  success "Powerlevel10k already present at $P10K_THEME_DIR."
else
  info "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
  success "Powerlevel10k installed."
fi

# ── Step 5: Install MesloLGS Nerd Fonts ───────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 5: Install MesloLGS Nerd Fonts ━━━${RESET}"
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

# ── Step 6: Set ZSH_THEME in .zshrc ───────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 6: Set ZSH_THEME ━━━${RESET}"
if grep -q '^ZSH_THEME=' "$ZSHRC" 2>/dev/null; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$ZSHRC"
  success "ZSH_THEME updated to powerlevel10k."
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
  success "ZSH_THEME appended to $ZSHRC."
fi

# ── Step 7: Apply plugins from config/plugins.txt ─────────────────────────────
echo -e "\n${BOLD}━━━ Step 7: Apply OMZ plugins ━━━${RESET}"
PLUGINS_FILE="$CONFIG_DIR/plugins.txt"
if [[ ! -f "$PLUGINS_FILE" ]]; then
  warn "No $PLUGINS_FILE found — skipping plugins update."
else
  # Build space-separated list from non-empty, non-comment lines.
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

# ── Step 8: Apply p10k config ─────────────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 8: Apply Powerlevel10k config ━━━${RESET}"
P10K_SRC="$CONFIG_DIR/p10k.zsh"
if [[ ! -f "$P10K_SRC" ]]; then
  warn "No $P10K_SRC found — skipping p10k config."
else
  cp "$P10K_SRC" "$HOME/.p10k.zsh"
  success "Copied p10k config to ~/.p10k.zsh"
  append_if_absent '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' "$ZSHRC"
  success "p10k source line present in $ZSHRC."
fi

# ── Step 9: Source aliases ─────────────────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 9: Source aliases ━━━${RESET}"
ALIASES_FILE="$CONFIG_DIR/aliases.zsh"
if [[ ! -f "$ALIASES_FILE" ]]; then
  warn "No $ALIASES_FILE found — skipping."
else
  SOURCE_LINE="[[ -f \"$ALIASES_FILE\" ]] && source \"$ALIASES_FILE\""
  # Export the repo path so the ealias helper in aliases.zsh works.
  ENV_LINE="export TERM_BOOTSTRAP_DIR=\"$SCRIPT_DIR\""
  append_if_absent "$ENV_LINE" "$ZSHRC"
  append_if_absent "$SOURCE_LINE" "$ZSHRC"
  success "Aliases source line present in $ZSHRC."
fi

# ── Step 10: Set zsh as default shell ─────────────────────────────────────────
echo -e "\n${BOLD}━━━ Step 10: Set default shell to zsh ━━━${RESET}"
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  success "zsh is already the default shell."
else
  info "Changing default shell to $ZSH_PATH (you may be prompted for your password)..."
  chsh -s "$ZSH_PATH"
  success "Default shell changed to $ZSH_PATH."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  Bootstrap complete!${RESET}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Set your terminal font to ${CYAN}MesloLGS NF${RESET} in terminal preferences."
echo -e "  2. Close and reopen your terminal (or run ${CYAN}exec zsh${RESET})."
echo ""
