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
OMZ_DIR="${HOME}/.oh-my-zsh"
P10K_THEME_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}/themes/powerlevel10k"
CONFIG_DIR="${SCRIPT_DIR}/config"

# ── Run helpers ──────────────────────────────────────────────────────
${SCRIPT_DIR}/helpers/prerequisites-helper.sh
${SCRIPT_DIR}/helpers/omz-helper.sh "${ZSHRC_PATH}" "${OMZ_DIR}" "${CONFIG_DIR}/plugins.txt"
${SCRIPT_DIR}/helpers/p10k-helper.sh "${ZSHRC_PATH}" "${P10K_THEME_DIR}" "${CONFIG_DIR}/p10k.zsh"
${SCRIPT_DIR}/helpers/shell-config-helper.sh "${ZSHRC_PATH}" "${CONFIG_DIR}/aliases.zsh"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "               Bootstrap complete!"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
