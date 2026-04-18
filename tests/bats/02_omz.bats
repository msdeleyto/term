#!/usr/bin/env bats
# 02_omz.bats — Verify that Oh My Zsh is installed and .zshrc is correctly configured.

load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

setup_file() {
  bash /repo/install.sh
}

@test "oh-my-zsh directory exists at ~/.oh-my-zsh" {
  [ -d "${HOME}/.oh-my-zsh" ]
}

@test "zshrc contains the Oh My Zsh named block" {
  grep -qF "# --- BEGIN: Oh My Zsh ---" "${HOME}/.zshrc"
}

@test "zshrc sets ZSH_THEME to powerlevel10k" {
  grep -qF 'ZSH_THEME="powerlevel10k/powerlevel10k"' "${HOME}/.zshrc"
}

@test "zshrc plugins line matches config/plugins.txt" {
  # Build expected plugins string from config/plugins.txt
  local expected_plugins
  expected_plugins=$(grep -v '^\s*#' /repo/config/plugins.txt | grep -v '^\s*$' | tr '\n' ' ' | sed 's/ $//')
  grep -qF "plugins=(${expected_plugins})" "${HOME}/.zshrc"
}

@test "zshrc sources oh-my-zsh.sh" {
  grep -qF 'source "$ZSH/oh-my-zsh.sh"' "${HOME}/.zshrc"
}
