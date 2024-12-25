#!/bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

h_is_linux && h_install_package "$1" xclip
h_install_package "$1" fzf
h_install_package "$1" source-highlight
h_install_package "$1" highlight

zap_dir="$HOME/.local/share/zap"
if [[ -d "$zap_dir" ]]
then 
  h_echo --mode=noop "zap already installed"
else
  h_echo --mode=doing "installing zap"
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep
fi

spaceship_dir="$HOME/.zsh/spaceship"
if [[ -d "$spaceship_dir" ]]
then
  h_echo --mode=noop "spaceship already installed"
else
  h_echo --mode=doing "cloning spaceship"
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_dir" --depth=1
fi

h_echo --mode=doing "symlinking zshrc"
ln -s ~/.dotfiles/zsh/.config/zsh/.zshrc ~/.zshrc > /dev/null 2>&1

h_echo --mode=doing "symlinking spaceshiprc"
ln -s ~/.dotfiles/zsh/.config/zsh/.spaceshiprc.zsh ~/.spaceshiprc.zsh > /dev/null 2>&1
