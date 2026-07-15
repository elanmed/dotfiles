#!/usr/bin/env bats
# Run with: bats stow.bats

setup() {
  export STOW_SCRIPT="${BATS_TEST_DIRNAME}/stow.sh"
}

@test "stow.sh: fails without -d argument" {
  run bash "$STOW_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "stow.sh: fails with invalid argument" {
  run bash "$STOW_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "stow.sh: fails with invalid desktop env" {
  run bash "$STOW_SCRIPT" -d "kde"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_desktop_env" ]]
}

@test "stow.sh: fails when -d has no value" {
  run bash "$STOW_SCRIPT" -d
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "stow.sh: accepts -d headless" {
  run bash "$STOW_SCRIPT" -d headless
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts -d mate" {
  run bash "$STOW_SCRIPT" -d mate
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts -d gnome" {
  run bash "$STOW_SCRIPT" -d gnome
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts -d macos" {
  run bash "$STOW_SCRIPT" -d macos
  [ "$status" -eq 0 ]
}
