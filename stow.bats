#!/usr/bin/env bats
# Run with: bats stow.bats

setup() {
  export STOW_SCRIPT="${BATS_TEST_DIRNAME}/stow.sh"
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

@test "stow.sh: rejects --server and --desktop-env together" {
  run bash "$STOW_SCRIPT" --server --desktop-env gnome
  [ "$status" -ne 0 ]
  [[ $output =~ "mutually exclusive" ]]
}

@test "stow.sh: rejects --desktop-env and --server in reverse order" {
  run bash "$STOW_SCRIPT" --desktop-env mate --server
  [ "$status" -ne 0 ]
  [[ $output =~ "mutually exclusive" ]]
}