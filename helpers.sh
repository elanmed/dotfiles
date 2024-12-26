#!/bin/bash

export red='\033[0;31m'
export blue='\033[0;34m'
export green='\033[0;32m'
export purple='\033[0;35m'
export no_color='\033[0m'

# eg: h_echo --mode=error "something went wrong!"
# $1: --mode={error,query,noop,doing}: the type of message
# $2: the message itself
h_echo() {
  h_validate_num_args --num=2 "$@"

  local mode
  case "$1" in
    --mode=*)
      mode=$(h_option_value "$1")
      ;;
    *)
      h_format_error "--mode={error,query,noop,doing}"
      ;;
  esac

  case "$mode" in
    "error")
      echo -e "${red}$2${no_color}"
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
      h_format_error "--mode={error,query,noop,doing}"
      ;;
  esac
}

# eg: h_install_package --pm=dnf neovim
# $1: --pm={brew,dnf,apt}: the package manager
# $2: the package name
h_install_package() {
  h_validate_num_args --num=2 "$@"
  h_validate_package_manager "$1"

  local package_manager
  package_manager=$(h_option_value "$1")
  local package="$2"

  if h_has_package "$1" "$package"; then
    h_echo --mode=noop "$package already installed"
    return
  fi

  h_echo --mode=doing "installing $package"
  case "$package_manager" in
    brew)
      brew install "$package"
      ;;
    dnf)
      sudo dnf install "$package" -y
      ;;
    apt)
      sudo apt-get install "$package" -y
      ;;
  esac

}

# eg: h_has_package --pm=dnf neovim
# $1: --pm={brew,dnf,apt}: the package manager
# $2: the package name
h_has_package() {
  h_validate_num_args --num=2 "$@"
  h_validate_package_manager "$1"

  local package_manager
  package_manager=$(h_option_value "$1")

  case "$package_manager" in
    brew)
      brew ls --versions "$2" >/dev/null 2>&1
      ;;
    dnf)
      dnf list installed "$2" >/dev/null 2>&1
      ;;
    apt)
      dpkg-query --show "$2" >/dev/null 2>&1
      ;;
  esac

  return "$?"
}

# eg: h_validate_num_args --num=2 "$@"
# $1: --pm={0}: the number of arguments expected
# $2: the args
h_validate_num_args() {
  local num_actual=$(($# - 1))
  local num_expected
  num_expected=$(h_option_value "$1")

  case "$1" in
    --num="$num_actual") ;;
    --num=*)
      h_echo --mode=error "wrong number of arguments: received $num_actual, expected $num_expected"
      exit 1
      ;;
    *)
      h_format_error "--num={0..}"
      ;;
  esac
}

# eg: h_validate_package_manager --pm=dnf
# $1: --pm={brew,dnf,apt}
h_validate_package_manager() {
  case "$1" in
    --pm=*)
      local package_manager
      package_manager=$(h_option_value "$1")
      if ! h_array_includes --needle="$package_manager" "brew" "dnf" "apt"; then
        h_format_error "--pm={brew,dnf,apt}"
      fi
      ;;
    *)
      h_format_error "--pm={brew,dnf,apt}"
      ;;
  esac
}

# eg: h_format_error --pm={brew,dnf,apt}
# $1: the missing option
h_format_error() {
  h_validate_num_args --num=1 "$@"

  h_echo --mode=error "bad option, only '$1' is supported"
  exit 1
}

# eg: h_option_value --pm=dnf
# $1: the entire option, with =
h_option_value() {
  echo "$1" | cut -d'=' -f2
}

# eg: h_option_value --needle="1" "1" "2" "3"
# $1: --needle=
# $: the items of the array, spread as arguments
h_array_includes() {
  case "$1" in
    --needle=*) ;;
    *)
      h_format_error "--needle="
      ;;
  esac

  local needle=
  needle=$(h_option_value "$1")
  shift # remove the first argument
  local array=("$@")

  for item in "${array[@]}"; do
    if [[ $item == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# eg: h_string_includes "string" "str"
# $1: the string to search
# $2: the substring to check
h_string_includes() {
  if [[ $1 == *"$2"* ]]; then
    return 0
  else
    return 1
  fi
}

# eg: h_is_linux
h_is_linux() {
  h_validate_num_args --num=0 "$@"

  if [[ "$(uname -s)" == "Linux" ]]; then
    return 0
  else
    return 1
  fi
}

# eg: h_is_command_valid "tmux"
# $1: the command to check
h_is_command_valid() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}
