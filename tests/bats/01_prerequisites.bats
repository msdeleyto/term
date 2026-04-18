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
  # Override the 'command' builtin for the subprocess only — no PATH manipulation,
  # so utils.sh and all other commands continue to work normally.
  run bash -c '
    command() { [[ "$1" == "-v" && "$2" == "zsh" ]] && return 1; builtin command "$@"; }
    export -f command
    bash /repo/helpers/prerequisites-helper.sh
  '
  assert_failure
  assert_output --partial "zsh"
}

@test "prerequisites fail and report error when curl is missing" {
  run bash -c '
    command() { [[ "$1" == "-v" && "$2" == "curl" ]] && return 1; builtin command "$@"; }
    export -f command
    bash /repo/helpers/prerequisites-helper.sh
  '
  assert_failure
  assert_output --partial "curl"
}

@test "prerequisites fail and report error when git is missing" {
  run bash -c '
    command() { [[ "$1" == "-v" && "$2" == "git" ]] && return 1; builtin command "$@"; }
    export -f command
    bash /repo/helpers/prerequisites-helper.sh
  '
  assert_failure
  assert_output --partial "git"
}
