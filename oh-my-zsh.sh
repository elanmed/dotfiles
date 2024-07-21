#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager $1

# zsh is already installed and the default shell in macos
if [[ $1 == "--pm=dnf" ]]
then 
  h_install_package $1 zsh
  sudo lchsh $USER
fi

if [[ -d ~/.oh-my-zsh ]]
then
  h_cecho --noop "oh-my-zsh already installed"
else
  h_cecho --doing "installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
