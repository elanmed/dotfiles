#!/bin/bash

export red='\033[0;31m'
export blue='\033[0;34m'
export green='\033[0;32m'
export purple='\033[0;35m'
export no_color='\033[0m'

# usage: h_echo <mode> <message>
h_echo() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_echo <mode> <message>"

  case "$1" in
    "error")
      printf "%b\n" "${red}$2${no_color}" >&2
      ;;
    "query")
      printf "%b\n" "${green}$2${no_color}"
      ;;
    "noop")
      printf "%b\n" "${blue}$2${no_color}"
      ;;
    "doing")
      printf "%b\n" "${purple}$2${no_color}"
      ;;
    *)
      h_throw_error "usage: h_echo <mode> <message>"
      ;;
  esac
}

# usage: h_resolve_package <package_manager> <canonical_name>
h_resolve_package() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_resolve_package <package_manager> <canonical_name>"

  case "$1:$2" in
    dnf:fd | apt:fd)
      echo "fd-find"
      ;;
    apt:nc)
      echo "netcat-openbsd"
      ;;
    brew:nc)
      echo "netcat"
      ;;
    brew:bats)
      echo "bats-core"
      ;;
    *)
      echo "$2"
      ;;
  esac
}

# usage: h_has_package <package_manager> <package>
h_has_package() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_has_package <package_manager> <package>"
  h_validate_package_manager "$1"

  local pkg
  pkg=$(h_resolve_package "$1" "$2")

  case "$1" in
    brew)
      brew list "$pkg" >/dev/null 2>&1
      ;;
    dnf)
      rpm -q "$pkg" >/dev/null 2>&1
      ;;
    apt)
      dpkg -s "$pkg" >/dev/null 2>&1
      ;;
  esac
}

# usage: h_install_package <package_manager> <package>
h_install_package() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_install_package <package_manager> <package>"
  h_validate_package_manager "$1"

  local pkg
  pkg=$(h_resolve_package "$1" "$2")
  echo "$pkg" >>./installed_packages

  if h_has_package "$1" "$2"; then
    h_echo noop "already has $pkg"
    return 0
  fi

  if [[ $1 == "dnf" && $2 == "lazygit" ]]; then
    h_echo doing "enabling COPR repo dejan/lazygit"
    sudo dnf copr enable "dejan/lazygit" -y
  fi

  h_echo doing "installing $pkg"

  case "$1" in
    brew)
      brew install "$pkg"
      ;;
    dnf)
      sudo dnf install "$pkg" -y
      ;;
    apt)
      sudo apt-get install "$pkg" -y
      ;;
  esac
}

# usage: h_uninstall_package <package_manager> <package>
h_uninstall_package() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_uninstall_package <package_manager> <package>"
  h_validate_package_manager "$1"

  local pkg
  pkg=$(h_resolve_package "$1" "$2")

  h_echo doing "uninstalling $pkg"

  case "$1" in
    brew)
      brew uninstall "$pkg"
      ;;
    dnf)
      sudo dnf remove "$pkg" -y
      ;;
    apt)
      sudo apt-get remove "$pkg" -y
      ;;
  esac
}

# TODO: cleanup
# usage: h_validate_package_manager <package_manager>
h_validate_package_manager() {
  [[ $# -ne 1 ]] && h_throw_error "usage: h_validate_package_manager <package_manager>"

  if ! h_array_includes "$1" "brew" "dnf" "apt"; then
    h_throw_error "usage: h_validate_package_manager <package_manager>"
  fi
}

# usage: h_validate_desktop_env <desktop_env>
# valid desktop_env: mate, gnome, macos, headless
h_validate_desktop_env() {
  [[ $# -ne 1 ]] && h_throw_error "usage: h_validate_desktop_env <desktop_env>"

  # TODO: cleanup
  if ! h_array_includes "$1" "mate" "gnome" "macos" "headless"; then
    h_throw_error "usage: h_validate_desktop_env <desktop_env>"
  fi
}

# TODO: rename
# usage: h_throw_error <error_message>
h_throw_error() {
  [[ $# -ne 1 ]] && {
    printf "%b\n" "${red}usage: h_throw_error <error_message>${no_color}" >&2
    kill -INT $$
  }

  h_echo error "$1"
  kill -INT $$
}

# usage: h_array_includes <needle> <items...>
h_array_includes() {
  [[ $# -lt 2 ]] && h_throw_error "usage: h_array_includes <needle> <items...>"

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
  [[ $# -ne 2 ]] && h_throw_error "usage: h_string_includes <string> <substring>"

  if [[ $1 == *"$2"* ]]; then
    return 0
  else
    return 1
  fi
}

# usage: h_update_submodule
h_update_submodule() {
  git checkout -b master origin/master >/dev/null 2>&1 || git checkout master >/dev/null 2>&1
  git fetch origin master -q
  if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/master)" ]]; then
    git pull origin master
  else
    h_echo noop "submodule $sm_path is up to date"
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
  [[ $# -ne 1 ]] && h_throw_error "usage: h_require_root_env <command_name>"

  if h_is_toolbox || h_is_podman; then
    h_throw_error "$1 should only be used in a root environment"
  fi
}

# usage: h_run_shell_in_container <shell-command>
# Runs a shell command string (e.g. "cd dir && cmd") inside toolbox on Linux,
# keeping the container alive after the command exits.
h_run_shell_in_container() {
  [[ $# -ne 1 ]] && h_throw_error "usage: h_run_shell_in_container <shell-command>"

  if [[ $(uname -s) == "Linux" ]] && ! h_is_toolbox && ! h_is_podman; then
    h_echo doing "starting toolbox"
    toolbox run -c fedora-toolbox-43 zsh -ic "$1; exec zsh"
  else
    zsh -c "$1"
  fi
}

h_set_wezterm_user_var() {
  [[ $# -ne 2 ]] && h_throw_error "usage: h_set_wezterm_user_var <key> <value>"

  printf "\033]1337;SetUserVar=%s=%s\007" "$1" $(printf '%s' "$2" | base64)
  # printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" $(echo -n "true" | base64)
}
