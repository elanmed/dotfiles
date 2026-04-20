#!/usr/bin/env bats
# Run with: bats bootstrap.bats

setup() {
  export BOOTSTRAP_SCRIPT="${BATS_TEST_DIRNAME}/bootstrap.sh"
}

@test "bootstrap.sh: fails without --package-manager argument" {
  run bash "$BOOTSTRAP_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "missing required argument: --package-manager" ]]
}

@test "bootstrap.sh: fails with invalid package manager" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager "invalid-pm"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_package_manager" ]]
}

@test "bootstrap.sh: fails with invalid desktop env" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env "kde"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_desktop_env" ]]
}

@test "bootstrap.sh: fails with invalid argument" {
  run bash "$BOOTSTRAP_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: rejects --server and --desktop-env together" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --server --desktop-env gnome
  [ "$status" -ne 0 ]
  [[ $output =~ "mutually exclusive" ]]
  run bash "$BOOTSTRAP_SCRIPT" --desktop-env mate --package-manager apt --server
  [ "$status" -ne 0 ]
  [[ $output =~ "mutually exclusive" ]]
}
