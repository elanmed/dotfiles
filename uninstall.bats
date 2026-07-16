#!/usr/bin/env bats
# Run with: bats uninstall.bats

setup() {
  export UNINSTALL_SCRIPT="${BATS_TEST_DIRNAME}/uninstall.sh"
}

@test "uninstall.sh: fails without -p argument" {
  run bash "$UNINSTALL_SCRIPT"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails when -p has no value" {
  run bash "$UNINSTALL_SCRIPT" -p
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails with invalid argument" {
  run bash "$UNINSTALL_SCRIPT" --invalid-arg
  [ "$status" -ne 0 ]
  [[ $output =~ "usage:" ]]
}

@test "uninstall.sh: fails with invalid package manager" {
  run bash "$UNINSTALL_SCRIPT" -p "invalid-pm"
  [ "$status" -ne 0 ]
  [[ $output =~ "invalid package manager" ]]
}

@test "uninstall.sh: fails when installed_packages log does not exist" {
  temp_dir="$(mktemp -d)"
  cp "$UNINSTALL_SCRIPT" "$temp_dir/"
  cp "${BATS_TEST_DIRNAME}/helpers.sh" "$temp_dir/"
  run bash -c "export DOTFILES_ROOT='$temp_dir' && source '$temp_dir/helpers.sh' && bash '$temp_dir/uninstall.sh' -p dnf"
  [ "$status" -ne 0 ]
  [[ $output =~ "installed_packages log does not exist" ]]
  rm -rf "$temp_dir"
}
