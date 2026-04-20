#!/usr/bin/env bats
# Run with: bats bootstrap.bats

setup() {
  export BOOTSTRAP_SCRIPT="${BATS_TEST_DIRNAME}/bootstrap.sh"
}

@test "bootstrap.sh: fails without --package-manager argument" {
  run bash "$BOOTSTRAP_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails without --desktop-env argument" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid package manager" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager "invalid-pm" --desktop-env server
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_package_manager" ]]
}

@test "bootstrap.sh: fails when --package-manager has no value" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager --desktop-env server
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid desktop env" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env "kde"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_desktop_env" ]]
}

@test "bootstrap.sh: fails when --desktop-env has no value" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid argument" {
  run bash "$BOOTSTRAP_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: accepts --desktop-env server" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env server
  [[ $output =~ "writing server to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts --desktop-env mate" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env mate
  [[ $output =~ "writing mate to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts --desktop-env gnome" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env gnome
  [[ $output =~ "writing gnome to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts --desktop-env macos" {
  run bash "$BOOTSTRAP_SCRIPT" --package-manager dnf --desktop-env macos
  [[ $output =~ "writing macos to .desktop_env" ]] || [ "$status" -eq 0 ]
}
