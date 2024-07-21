#! /bin/bash

red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
purple='\033[0;35m'
no_color='\033[0m' # No Color

h_cecho () {
  case $1 in 
    --error)
      echo -e "${red}$2${no_color}"
      ;;
    --query)
      echo -e "${green}$2${no_color}"
      ;;
    --noop)
      echo -e "${blue}$2${no_color}"
      ;;
    --doing)
      echo -e "${purple}$2${no_color}"
      ;;
    *)
      h_option_error "--error|query|noop|doing"
      exit 1
      ;;
  esac
}

# $1: --pm=brew|dnf
# $2: package_name
h_install_package () {
  h_validate_num_args --num=2 "$@"
  h_validate_package_manager $1

  local package=("${@:2}")

  if h_has_package $1 $package
  then
    h_cecho --noop "$package already installed"
  else 
    h_cecho --doing "installing $package"
    if [[ $1 == '--pm=brew' ]]
    then
      brew install $package
    else 
      sudo dnf install $package
    fi
  fi
}

# $1: --pm=brew|dnf
# $2: package_name
h_has_package () {
  h_validate_num_args --num=2 "$@"
  h_validate_package_manager $1

  if [[ $1 == "--pm=brew" ]]
  then
    brew ls --versions $2 > /dev/null 2>&1
  else
    dnf list installed $2 > /dev/null 2>&1
  fi
  return $?
}

# $1: --num
# $2: args
h_validate_num_args () {
  local args=("${@:2}")
  local num_actual="${#args[@]}"
  local num_expected=$(echo $1 | cut -d= -f2)

  case $1 in 
    --num=$num_actual)
      ;;
    --num=*)
      h_cecho --error "wrong number of arguments, received $num_actual, expected $num_expected"
      exit 1
      ;;
    *)
      h_option_error "--num="
      exit 1
      ;;
  esac
}

# $1: --pm=brew|dnf
h_validate_package_manager () {
  case $1 in 
    --pm=*)
      if [[ $1 != "--pm=brew" ]] && [[ $1 != "--pm=dnf" ]]
      then
        h_option_error "--pm=brew|dnf"
        exit 1
      fi
      ;;
    *)
      h_option_error "--pm=brew|dnf"
      exit 1
      ;;
  esac
}

# $1: a string of the missing option
h_option_error () {
  if [[ "$#" != 1 ]]
  then 
    h_cecho --error "expects 1 argument"
    exit 1
  fi

  local error_message="bad option, only '$1' is supported"
  h_cecho --error "$error_message"
}
