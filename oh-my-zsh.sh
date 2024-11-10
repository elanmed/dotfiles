#!/bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

# zsh is already installed for macos
if [[ "$1" == "--pm=dnf" ]]
then 
  h_install_package "$1" zsh
fi
