#!/usr/bin/env bats
# 04_aliases.bats — Verify that aliases are copied and usable in a zsh session.

load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

setup_file() {
  bash /repo/install.sh
}

@test "aliases file exists at ~/.zsh_aliases" {
  [ -f "${HOME}/.zsh_aliases" ]
}

@test "zshrc contains the Aliases named block" {
  grep -qF "# --- BEGIN: Aliases ---" "${HOME}/.zshrc"
}

@test "zshrc Aliases block sources ~/.zsh_aliases" {
  grep -qF "source ~/.zsh_aliases" "${HOME}/.zshrc"
}

@test "alias ll is defined after sourcing ~/.zsh_aliases" {
  run zsh -c 'source ~/.zsh_aliases && alias ll'
  assert_success
  assert_output --partial "ll="
}

@test "alias .. (navigate up) is defined after sourcing ~/.zsh_aliases" {
  run zsh -c "source ~/.zsh_aliases && alias .."
  assert_success
  assert_output --partial "..="
}

@test "alias gs (git status) is defined after sourcing ~/.zsh_aliases" {
  run zsh -c 'source ~/.zsh_aliases && alias gs'
  assert_success
  assert_output --partial "gs="
}

@test "aliases file content matches repo config/zsh_aliases" {
  diff -q /repo/config/zsh_aliases "${HOME}/.zsh_aliases" > /dev/null
}
