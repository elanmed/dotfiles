#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

h_install_package "$1" tmux

h_echo --mode=doing "installing tpm plugins"
~/.tmux/plugins/tpm/bin/install_plugins
