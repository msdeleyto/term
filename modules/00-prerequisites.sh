#!/usr/bin/env bash
# modules/00-prerequisites.sh
# Verifies required tools are present, installs zsh, and sets it as default shell.

step 1 "Checking prerequisites"
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

step 2 "Installing zsh"
if command -v zsh &>/dev/null; then
  success "zsh is already installed ($(zsh --version))."
else
  info "Installing zsh via apt..."
  sudo apt-get update -qq && sudo apt-get install -y zsh
  success "zsh installed."
fi

step 3 "Setting zsh as default shell"
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  success "zsh is already the default shell."
else
  info "Changing default shell to $ZSH_PATH (you may be prompted for your password)..."
  chsh -s "$ZSH_PATH"
  success "Default shell changed to $ZSH_PATH."
fi
