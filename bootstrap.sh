#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./bootstrap.sh -p {brew,dnf,apt} -d {mate,gnome,macos,headless}"

package_manager=""
desktop_env=""

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
    -d)
      if [[ -z ${2:-} ]]; then
        h_echo error "$usage"
        exit 1
      fi
      desktop_env="$2"
      shift 2
      ;;
    *)
      h_echo error "$usage"
      exit 1
      ;;
  esac
done

if [[ -z $package_manager ]] || [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi

h_validate_package_manager "$package_manager"
h_validate_desktop_env "$desktop_env"

h_echo doing "setting up installed_packages log"
if [[ -e ./installed_packages ]]; then
  h_echo doing "backing up current log"
  cp ./installed_packages ./installed_packages_prev
fi
echo -n "" >./installed_packages

# install packages
# diff from previous expected packages
# notify if diff (new or removed expected package)
