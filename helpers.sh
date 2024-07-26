#! /bin/bash
source ~/.dotfiles/spinner.sh

red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
purple='\033[0;35m'
no_color='\033[0m' # No Color

# eg: h_spinner --text="hi" sleep 3
# $1: --text
# $2: command to run
h_spinner() {
  local args="${@:2}"
  local text=$(echo $1 | cut -d= -f2)
  case $1 in 
    --text=*)
      formatted_text="${purple}$text${no_color}"
      start_spinner "$formatted_text"
      $args
      stop_spinner "$formatted_text"
      ;;
    *)
      h_format_error "--text="
      ;;
  esac
}

# eg: h_cecho --error "something went wrong!"
# $1: --{error,query,noop,doing}=
# $2: message to echo
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
      h_format_error "--error|query|noop|doing"
      ;;
  esac
}

# eg: h_install_package --pm=dnf neovim
# $1: --pm={brew,dnf}
# $2: package name
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

# eg: h_has_package --pm=dnf neovim
# $1: --pm={brew,dnf}
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

# eg: h_validate_num_args --num=2 "$@"
# $1: --num=
# $2: the args
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
      h_format_error "--num="
      ;;
  esac
}

# eg: h_validate_package_manager --pm=dnf
# $1: --pm={brew,dnf}
h_validate_package_manager () {
  case $1 in 
    --pm=*)
      if [[ $1 != "--pm=brew" ]] && [[ $1 != "--pm=dnf" ]]
      then
        h_format_error "--pm=brew|dnf"
      fi
      ;;
    *)
      h_format_error "--pm=brew|dnf"
      ;;
  esac
}

# eg: h_format_error "--pm={brew,dnf}"
# $1: the missing option
h_format_error () {
  h_validate_num_args --num=1 "$@"

  h_cecho --error "bad option, only '$1' is supported"
  exit 1
}

