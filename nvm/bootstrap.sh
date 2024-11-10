#!/bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR"  ]]
then
  h_echo --mode=noop "nvm already installed"
else
  h_echo --mode=doing "installing nvm"
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
fi

h_echo --mode=doing "sourcing nvm"
source "$NVM_DIR/nvm.sh" 

h_echo --mode=doing "installing the latest version of node"
nvm install 'lts/*'
