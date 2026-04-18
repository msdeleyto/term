#!/usr/bin/env bats
# 03_p10k.bats — Verify that Powerlevel10k is cloned and configured.

load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

setup_file() {
  bash /repo/install.sh
}

@test "powerlevel10k theme directory exists" {
  local p10k_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
  [ -d "${p10k_dir}" ]
}

@test "p10k config file exists at ~/.p10k.zsh" {
  [ -f "${HOME}/.p10k.zsh" ]
}

@test "zshrc contains the Powerlevel10k named block" {
  grep -qF "# --- BEGIN: Powerlevel10k ---" "${HOME}/.zshrc"
}

@test "zshrc Powerlevel10k block sources ~/.p10k.zsh" {
  grep -qF "source ~/.p10k.zsh" "${HOME}/.zshrc"
}

@test "p10k config content matches repo config/p10k.zsh" {
  diff -q /repo/config/p10k.zsh "${HOME}/.p10k.zsh" > /dev/null
}
