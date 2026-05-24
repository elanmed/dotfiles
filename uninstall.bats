#!/usr/bin/env bats
# Run with: bats uninstall.bats

setup() {
  export UNINSTALL_SCRIPT="${BATS_TEST_DIRNAME}/uninstall.sh"
}

@test "uninstall.sh: fails without --package-manager argument" {
  run bash "$UNINSTALL_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails when --package-manager has no value" {
  run bash "$UNINSTALL_SCRIPT" --package-manager
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails with invalid argument" {
  run bash "$UNINSTALL_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails with invalid package manager" {
  run bash "$UNINSTALL_SCRIPT" --package-manager "invalid-pm"
  [ "$status" -ne 0 ]
  [[ $output =~ "h_validate_package_manager" ]]
}

@test "uninstall.sh: fails when installed_packages log does not exist" {
  (
    cd "$(mktemp -d)"
    cp "$UNINSTALL_SCRIPT" .
    cp "${BATS_TEST_DIRNAME}/helpers.sh" .
    run bash ./uninstall.sh --package-manager dnf
    [ "$status" -ne 0 ]
    [[ $output =~ "installed_packages log does not exist" ]]
  )
}
