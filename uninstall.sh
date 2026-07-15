#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./uninstall.sh -p brew|dnf|apt"
package_manager=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      if [[ -z ${2:-} ]]; then
        h_echo error "$usage"
        exit 1
      fi
      package_manager="$2"
      shift 2
      ;;
    *)
      h_echo error "$usage"
      exit 1
      ;;
  esac
done

if [[ -z $package_manager ]]; then
  h_echo error "$usage"
  exit 1
fi

if ! h_array_includes "$1" "brew" "dnf" "apt"; then
  h_echo error "$usage"
  exit 1
fi

if [[ ! -f ./installed_packages ]]; then
  echo "installed_packages log does not exist"
  exit 1
fi

while IFS= read -r package; do
  h_uninstall_package "$package_manager" "$package"
done <./installed_packages
