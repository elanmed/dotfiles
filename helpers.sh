#!/bin/bash

export red='\033[0;31m'
export blue='\033[0;34m'
export green='\033[0;32m'
export purple='\033[0;35m'
export no_color='\033[0m'

# usage: h_echo <mode> <message>
h_echo() {
  [[ $# -ne 2 ]] && h_format_error "usage: h_echo <mode> <message>"

  case "$1" in
    "error")
      echo -e "${red}$2${no_color}" >&2
      ;;
    "query")
      echo -e "${green}$2${no_color}"
      ;;
    "noop")
      echo -e "${blue}$2${no_color}"
      ;;
    "doing")
      echo -e "${purple}$2${no_color}"
      ;;
    *)
      h_format_error "usage: h_echo <mode> <message>"
      ;;
  esac
}

# usage: h_install_package <package_manager> <package>
h_install_package() {
  [[ $# -ne 2 ]] && h_format_error "usage: h_install_package <package_manager> <package>"
  h_validate_package_manager "$1"

  h_echo doing "installing $2"

  case "$1" in
    brew)
      brew install "$2"
      ;;
    dnf)
      sudo dnf install "$2" -y
      ;;
    pacman)
      sudo pacman --sync --quiet --noconfirm "$2"
      ;;
    apt)
      sudo apt-get install "$2" -y
      ;;
  esac
}

# usage: h_validate_package_manager <package_manager>
h_validate_package_manager() {
  [[ $# -ne 1 ]] && h_format_error "usage: h_validate_package_manager <package_manager>"

  if ! h_array_includes "$1" "brew" "pacman" "dnf" "apt"; then
    h_format_error "usage: h_validate_package_manager <package_manager>"
  fi
}

# usage: h_format_error <error_message>
h_format_error() {
  [[ $# -ne 1 ]] && {
    echo -e "${red}usage: h_format_error <error_message>${no_color}" >&2
    kill -INT $$
  }

  h_echo error "$1"
  kill -INT $$
}

# usage: h_array_includes <needle> <items...>
h_array_includes() {
  [[ $# -lt 2 ]] && h_format_error "usage: h_array_includes <needle> <items...>"

  local needle="$1"
  shift # remove the first argument
  local array=("$@")

  for item in "${array[@]}"; do
    if [[ $item == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# usage: h_string_includes <string> <substring>
h_string_includes() {
  [[ $# -ne 2 ]] && h_format_error "usage: h_string_includes <string> <substring>"

  if [[ $1 == *"$2"* ]]; then
    return 0
  else
    return 1
  fi
}
