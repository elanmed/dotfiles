#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

syntax_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [[ -d "${syntax_dir}" ]]
then
  h_echo --mode=noop "zsh-syntax-highlighting already installed"
else
  h_echo --mode=doing "cloning zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${syntax_dir}"
fi

suggest_dir=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
if [[ -d "${suggest_dir}" ]]
then
  h_echo --mode=noop "zsh-autosuggestions already installed"
else
  h_echo --mode=doing "cloning zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${suggest_dir}"
fi
