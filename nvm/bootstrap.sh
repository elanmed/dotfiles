#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

server_flag=false
package_manager=""

for arg in "$@"; do
  case "$arg" in
    --server)
      server_flag=true
      shift
      ;;
    --pm=*)
      package_manager="$arg"
      shift
      ;;
    *)
      h_format_error "--pm={brew,dnf,apt} --server"
      ;;
  esac
done

h_validate_package_manager "$package_manager"

h_echo --mode=doing "sourcing nvm"
source "$HOME/.nvm/nvm.sh"

if $server_flag; then
  h_echo --mode=noop "SKIPPING: installing the latest version of node"
else
  h_echo --mode=doing "installing the latest version of node"
  nvm install
fi
