#!/usr/bin/env bats
# 02_fonts.bats — Verify that MesloLGS NF fonts are downloaded and the font
# directory is correctly set up by fonts-helper.sh.

load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

FONTS_DIR="${HOME}/.local/share/fonts/p10k"

setup_file() {
  bash /repo/install.sh
}

@test "font directory exists at ~/.local/share/fonts/p10k" {
  [ -d "${FONTS_DIR}" ]
}

@test "MesloLGS NF Regular.ttf is present" {
  [ -f "${FONTS_DIR}/MesloLGS NF Regular.ttf" ]
}

@test "MesloLGS NF Bold.ttf is present" {
  [ -f "${FONTS_DIR}/MesloLGS NF Bold.ttf" ]
}

@test "MesloLGS NF Italic.ttf is present" {
  [ -f "${FONTS_DIR}/MesloLGS NF Italic.ttf" ]
}

@test "MesloLGS NF Bold Italic.ttf is present" {
  [ -f "${FONTS_DIR}/MesloLGS NF Bold Italic.ttf" ]
}

@test "re-running fonts-helper skips downloads when fonts are already present" {
  run bash /repo/helpers/fonts-helper.sh
  assert_success
  assert_output --partial "already up to date"
}
