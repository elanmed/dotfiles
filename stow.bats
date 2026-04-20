#!/usr/bin/env bats
# Run with: bats stow.bats

setup() {
  export STOW_SCRIPT="${BATS_TEST_DIRNAME}/stow.sh"
}

@test "stow.sh: fails without --desktop-env argument" {
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
  run bash "$STOW_SCRIPT" --desktop-env "kde"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_desktop_env" ]]
}

@test "stow.sh: fails when --desktop-env has no value" {
  run bash "$STOW_SCRIPT" --desktop-env
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "stow.sh: accepts --desktop-env server" {
  run bash "$STOW_SCRIPT" --desktop-env server
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts --desktop-env mate" {
  run bash "$STOW_SCRIPT" --desktop-env mate
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts --desktop-env gnome" {
  run bash "$STOW_SCRIPT" --desktop-env gnome
  [ "$status" -eq 0 ]
}

@test "stow.sh: accepts --desktop-env macos" {
  run bash "$STOW_SCRIPT" --desktop-env macos
  [ "$status" -eq 0 ]
}