#!/usr/bin/env bats
# Run with: bats bootstrap.bats

setup() {
  export BOOTSTRAP_SCRIPT="/.dotfiles/bootstrap.sh"
}

@test "bootstrap.sh: fails without --package-manager argument" {
  run bash "$BOOTSTRAP_SCRIPT"
  [ "$status" -eq 1 ]
  [[ $output =~ "missing required argument: --package-manager" ]]
}

@test "bootstrap.sh: fails with invalid package manager" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager "invalid-pm"
  [ "$status" -ne 0 ]
}

@test "bootstrap.sh: fails when both --server and --container are passed" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --server --container
  [ "$status" -eq 1 ]
  [[ $output =~ "only one of --server or --container can be passed" ]]
}

@test "bootstrap.sh: fails with invalid argument" {
  run bash "$BOOTSTRAP_SCRIPT" --invalid-arg
  [ "$status" -eq 1 ]
  [[ $output =~ "usage:" ]]
}
