#!/bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

if h_has_package "$1" "zsh"
then
  h_echo --mode=noop "zsh already installed"
else
  h_echo --mode=doing "installing zsh, then exiting. re-run the script in a zsh script"
  h_install_package "$1" zsh
  exit 1
fi

echo -n $(h_echo --mode=query "this script delete your ~/.zshrc. confirm 'y' for yes, anything else to abort: ")
read answer

if [[ "$answer" != 'y' ]]
then 
  h_echo --mode=error "aborting"
  exit 1
fi

h_echo --mode=doing "removing ~/.zshrc"
rm ~/.zshrc

h_install_package "$1" stow
for dir in */
do
  stripped_dir="${dir%?}"
  h_echo --mode=doing "running 'stow $stripped_dir'"
  stow "$stripped_dir"
done

h_echo --mode=doing "bootstrapping zsh"
source ~/.dotfiles/zsh/.config/zsh/bootstrap.sh "$1"

h_echo --mode=doing "bootstrapping tmux"
source ~/.dotfiles/tmux/.config/tmux/bootstrap.sh "$1"

h_echo --mode=doing "bootstrapping nvm"
source ~/.dotfiles/nvm/bootstrap.sh "$1"

h_echo --mode=doing "bootstrapping fonts"
source ~/.dotfiles/fonts/bootstrap.sh "$1"

h_echo --mode=doing "bootstrapping nvim"
source ~/.dotfiles/neovim/.config/nvim/bootstrap.sh "$1"
