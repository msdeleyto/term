#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# install.sh — Terminal bootstrap: zsh + Oh My Zsh + Powerlevel10k
#
# Usage:  bash install.sh
# Safe to re-run: every step is idempotent.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/utils.sh
source "${SCRIPT_DIR}/lib/utils.sh"

# ── Run modules in order ──────────────────────────────────────────────────────
for module in "${SCRIPT_DIR}"/modules/[0-9][0-9]-*.sh; do
  # shellcheck source=/dev/null
  source "$module"
done

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
