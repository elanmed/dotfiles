#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

# zsh is already installed for macos
if [[ $1 == "--pm=dnf" ]]
then 
  h_install_package "$1" "zsh"
fi

if [[ -d ~/.oh-my-zsh ]]
then
  h_echo --mode=noop "oh-my-zsh already installed"
else
  h_echo --mode=doing "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
