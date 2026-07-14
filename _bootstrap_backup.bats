#!/usr/bin/env bats
# Run with: bats bootstrap.bats

setup() {
  export BOOTSTRAP_SCRIPT="${BATS_TEST_DIRNAME}/bootstrap.sh"
}

@test "bootstrap.sh: fails without -p argument" {
  run bash "$BOOTSTRAP_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails without -d argument" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid package manager" {
  run bash "$BOOTSTRAP_SCRIPT" -p "invalid-pm" -d server
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_package_manager" ]]
}

@test "bootstrap.sh: fails when -p has no value" {
  run bash "$BOOTSTRAP_SCRIPT" -p -d server
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid desktop env" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d "kde"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_desktop_env" ]]
}

@test "bootstrap.sh: fails when -d has no value" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: fails with invalid argument" {
  run bash "$BOOTSTRAP_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "bootstrap.sh: accepts -d server" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d server
  [[ $output =~ "writing server to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts -d mate" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d mate
  [[ $output =~ "writing mate to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts -d gnome" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d gnome
  [[ $output =~ "writing gnome to .desktop_env" ]] || [ "$status" -eq 0 ]
}

@test "bootstrap.sh: accepts -d macos" {
  run bash "$BOOTSTRAP_SCRIPT" -p dnf -d macos
  [[ $output =~ "writing macos to .desktop_env" ]] || [ "$status" -eq 0 ]
}
