#!/usr/bin/env bats
# Run with: bats helpers.bats

setup() {
  source "${BATS_TEST_DIRNAME}/helpers.sh"
}

@test "h_array_includes: returns 0 when needle is found in array" {
  run h_array_includes "apple" "banana" "apple" "cherry"
  [ "$status" -eq 0 ]
}

@test "h_array_includes: returns 1 when needle is not found in array" {
  run h_array_includes "grape" "banana" "apple" "cherry"
  [ "$status" -eq 1 ]
}

@test "h_array_includes: works with single item array when match" {
  run h_array_includes "single" "single"
  [ "$status" -eq 0 ]
}

@test "h_array_includes: works with single item array when no match" {
  run h_array_includes "needle" "haystack"
  [ "$status" -eq 1 ]
}

@test "h_array_includes: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_array_includes 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_array_includes" ]]
}

@test "h_array_includes: exits early with 1 argument" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_array_includes 'needle' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_array_includes" ]]
}

@test "h_string_includes: returns 0 when substring is found" {
  run h_string_includes "hello world" "world"
  [ "$status" -eq 0 ]
}

@test "h_string_includes: returns 1 when substring is not found" {
  run h_string_includes "hello world" "goodbye"
  [ "$status" -eq 1 ]
}

@test "h_string_includes: returns 0 when substring is at the beginning" {
  run h_string_includes "hello world" "hello"
  [ "$status" -eq 0 ]
}

@test "h_string_includes: returns 0 when substring is the entire string" {
  run h_string_includes "hello" "hello"
  [ "$status" -eq 0 ]
}

@test "h_string_includes: returns 0 when substring is empty" {
  run h_string_includes "hello world" ""
  [ "$status" -eq 0 ]
}

@test "h_string_includes: case sensitive check" {
  run h_string_includes "Hello World" "hello"
  [ "$status" -eq 1 ]
}

@test "h_string_includes: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_string_includes 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_string_includes" ]]
}

@test "h_string_includes: exits early with 1 argument" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_string_includes 'string' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_string_includes" ]]
}

@test "h_string_includes: exits early with 3 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_string_includes 'string' 'sub' 'extra' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_string_includes" ]]
}

@test "h_validate_package_manager: accepts brew" {
  run h_validate_package_manager "brew"
  [ "$status" -eq 0 ]
}

@test "h_validate_package_manager: accepts pacman" {
  run h_validate_package_manager "pacman"
  [ "$status" -eq 0 ]
}

@test "h_validate_package_manager: accepts dnf" {
  run h_validate_package_manager "dnf"
  [ "$status" -eq 0 ]
}

@test "h_validate_package_manager: accepts apt" {
  run h_validate_package_manager "apt"
  [ "$status" -eq 0 ]
}

@test "h_validate_package_manager: rejects invalid package manager" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_validate_package_manager 'invalid'"
  [ "$status" -ne 0 ]
}

@test "h_validate_package_manager: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_validate_package_manager 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_validate_package_manager" ]]
}

@test "h_validate_package_manager: exits early with 2 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_validate_package_manager 'dnf' 'extra' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_validate_package_manager" ]]
}

@test "h_install_package: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_install_package 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_install_package" ]]
}

@test "h_install_package: exits early with 1 argument" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_install_package 'dnf' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_install_package" ]]
}

@test "h_install_package: exits early with 3 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_install_package 'dnf' 'package' 'extra' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_install_package" ]]
}

@test "h_echo: error mode outputs to stderr with red color" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo error 'test message' 2>&1"
  [ "$status" -eq 0 ]
  [[ $output =~ "test message" ]]
  [[ $output =~ $'\033[0;31m' ]]
}

@test "h_echo: query mode outputs with green color" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo query 'test query'"
  [ "$status" -eq 0 ]
  [[ $output =~ "test query" ]]
  [[ $output =~ $'\033[0;32m' ]]
}

@test "h_echo: noop mode outputs with blue color" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo noop 'test noop'"
  [ "$status" -eq 0 ]
  [[ $output =~ "test noop" ]]
  [[ $output =~ $'\033[0;34m' ]]
}

@test "h_echo: doing mode outputs with purple color" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo doing 'test doing'"
  [ "$status" -eq 0 ]
  [[ $output =~ "test doing" ]]
  [[ $output =~ $'\033[0;35m' ]]
}

@test "h_echo: invalid mode triggers error" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo invalid 'test message' 2>&1"
  [ "$status" -ne 0 ]
}

@test "h_echo: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_echo" ]]
}

@test "h_echo: exits early with 1 argument" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo error 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_echo" ]]
}

@test "h_echo: exits early with 3 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_echo error 'message' 'extra' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_echo" ]]
}

@test "h_format_error: outputs error message and exits" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_format_error 'test error' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "test error" ]]
}

@test "h_format_error: exits early with 0 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_format_error 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_format_error" ]]
}

@test "h_format_error: exits early with 2 arguments" {
  run bash -c "source '${BATS_TEST_DIRNAME}/helpers.sh' && h_format_error 'error1' 'error2' 2>&1"
  [ "$status" -ne 0 ]
  [[ $output =~ "usage: h_format_error" ]]
}
