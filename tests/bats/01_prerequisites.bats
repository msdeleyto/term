#!/usr/bin/env bats
# 01_prerequisites.bats — Verify that prerequisites-helper.sh correctly
# detects present and missing tools.

load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

HELPER="/repo/helpers/prerequisites-helper.sh"

@test "prerequisites pass when curl, git, and zsh are all present" {
  run bash "${HELPER}"
  assert_success
  assert_output --partial "zsh, curl and git are available"
}

@test "prerequisites fail and report error when zsh is missing" {
  # Build a PATH that contains curl and git but not zsh
  local tmpbin
  tmpbin="$(mktemp -d)"

  # Symlink only the tools we want to keep
  ln -s "$(command -v curl)" "${tmpbin}/curl"
  ln -s "$(command -v git)"  "${tmpbin}/git"

  # Use env + absolute bash path so only the subprocess gets the restricted PATH.
  # PATH="..." run bash ... does not work: 'run' is a shell function, so the
  # assignment modifies the current shell's PATH, making bash itself unfindable (exit 127).
  run env PATH="${tmpbin}" /bin/bash "${HELPER}"
  assert_failure
  assert_output --partial "zsh"

  rm -rf "${tmpbin}"
}

@test "prerequisites fail and report error when curl is missing" {
  local tmpbin
  tmpbin="$(mktemp -d)"

  ln -s "$(command -v git)" "${tmpbin}/git"
  ln -s "$(command -v zsh)" "${tmpbin}/zsh"

  run env PATH="${tmpbin}" /bin/bash "${HELPER}"
  assert_failure
  assert_output --partial "curl"

  rm -rf "${tmpbin}"
}

@test "prerequisites fail and report error when git is missing" {
  local tmpbin
  tmpbin="$(mktemp -d)"

  ln -s "$(command -v curl)" "${tmpbin}/curl"
  ln -s "$(command -v zsh)"  "${tmpbin}/zsh"

  run env PATH="${tmpbin}" /bin/bash "${HELPER}"
  assert_failure
  assert_output --partial "git"

  rm -rf "${tmpbin}"
}
