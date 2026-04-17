#!/usr/bin/env bash
# modules/03-shell-config.sh
# Applies shell environment configuration: aliases and env variables.

step 10 "Applying shell configuration"
ALIASES_FILE="$CONFIG_DIR/aliases.zsh"
if [[ ! -f "$ALIASES_FILE" ]]; then
  warn "No $ALIASES_FILE found — skipping."
else
  ENV_LINE="export TERM_BOOTSTRAP_DIR=\"${SCRIPT_DIR}\""
  SOURCE_LINE="[[ -f \"${ALIASES_FILE}\" ]] && source \"${ALIASES_FILE}\""
  append_if_absent "$ENV_LINE" "$ZSHRC"
  append_if_absent "$SOURCE_LINE" "$ZSHRC"
  success "Aliases source line present in $ZSHRC."
fi
