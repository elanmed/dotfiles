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
  echo "$2" >>./installed_packages

  h_echo doing "installing $2"

  case "$1" in
    brew)
      brew install "$2"
      ;;
    dnf)
      sudo dnf install "$2" -y
      ;;
    apt)
      sudo apt-get install "$2" -y
      ;;
  esac
}

# usage: h_uninstall_package <package_manager> <package>
h_uninstall_package() {
  [[ $# -ne 2 ]] && h_format_error "usage: h_uninstall_package <package_manager> <package>"
  h_validate_package_manager "$1"

  h_echo doing "uninstalling $2"

  case "$1" in
    brew)
      brew uninstall "$2"
      ;;
    dnf)
      sudo dnf remove "$2" -y
      ;;
    apt)
      sudo apt-get remove "$2" -y
      ;;
  esac
}

# usage: h_validate_package_manager <package_manager>
h_validate_package_manager() {
  [[ $# -ne 1 ]] && h_format_error "usage: h_validate_package_manager <package_manager>"

  if ! h_array_includes "$1" "brew" "dnf" "apt"; then
    h_format_error "usage: h_validate_package_manager <package_manager>"
  fi
}

# usage: h_validate_desktop_env <desktop_env>
# valid desktop_env: mate, gnome, macos, server
h_validate_desktop_env() {
  [[ $# -ne 1 ]] && h_format_error "usage: h_validate_desktop_env <mate|gnome|macos|server>"

  if ! h_array_includes "$1" "mate" "gnome" "macos" "server"; then
    h_format_error "usage: h_validate_desktop_env <mate|gnome|macos|server>"
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

h_is_toolbox() {
  if [[ "$(hostname)" == "toolbx" ]] || [[ "$(hostname)" == "toolbox" ]]; then
    return 0
  else
    return 1
  fi
}

h_is_podman() {
  if [[ -f /run/.containerenv ]]; then
    return 0
  else
    return 1
  fi
}

h_is_macos() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    return 0
  else
    return 1
  fi
}

# usage: h_require_root_env <command_name>
h_require_root_env() {
  [[ $# -ne 1 ]] && h_format_error "usage: h_require_root_env <command_name>"

  if h_is_toolbox || h_is_podman; then
    h_format_error "$1 should only be used in a root environment"
  fi
}

# usage: h_run_shell_in_container <shell-command>
# Runs a shell command string (e.g. "cd dir && cmd") inside toolbox on Linux,
# keeping the container alive after the command exits.
h_run_shell_in_container() {
  [[ $# -ne 1 ]] && h_format_error "usage: h_run_shell_in_container <shell-command>"

  if [[ $(uname -s) == "Linux" ]] && ! h_is_toolbox && ! h_is_podman; then
    h_echo doing "starting toolbox"
    toolbox run -c fedora-toolbox-43 zsh -ic "eval $1; exec zsh"
  else
    zsh -c "eval $1"
  fi
}

h_set_wezterm_user_var() {
  [[ $# -ne 2 ]] && h_format_error "usage: h_set_wezterm_user_var <key> <value>"

  printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(echo -n "$2" | base64)
  # printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" $(echo -n "true" | base64)
}
