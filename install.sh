#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# install.sh — Terminal bootstrap: zsh + Oh My Zsh + Powerlevel10k
#
# Usage:  bash install.sh
# Safe to re-run: every step is idempotent.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC_PATH="${HOME}/.zshrc"
P10K_THEME_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}/themes/powerlevel10k"
CONFIG_DIR="${SCRIPT_DIR}/config"

# shellcheck source=lib/utils.sh
source "${SCRIPT_DIR}/lib/utils.sh"

# ── Run helpers ──────────────────────────────────────────────────────
${SCRIPT_DIR}/helpers/prerequisites-helper.sh
${SCRIPT_DIR}/helpers/omz-helper.sh "${ZSHRC_PATH}" "${CONFIG_DIR}/plugins.txt"
${SCRIPT_DIR}/helpers/p10k-helper.sh "${ZSHRC_PATH}" "${P10K_THEME_DIR}" "${CONFIG_DIR}/p10k.zsh"
${SCRIPT_DIR}/helpers/shell-config-helper.sh "${ZSHRC_PATH}" "${CONFIG_DIR}/aliases.zsh"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  Bootstrap complete!${RESET}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
