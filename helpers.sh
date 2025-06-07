#!/bin/bash

# eg: h_is_linux
h_is_linux() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    return 0
  else
    return 1
  fi
}

# eg: h_is_toolbx
h_is_toolbx() {
  if [[ "$(hostname)" == "toolbx" ]]; then
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

# eg: h_is_server
h_is_server() {
  grep -q '^0$' ~/.dotfiles/.is_server >/dev/null 2>&1
}
