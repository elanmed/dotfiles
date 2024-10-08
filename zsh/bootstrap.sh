#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

h_install_package "$1" "xclip"
h_install_package "$1" "fzf"
h_install_package "$1" "source-highlight"
h_install_package "$1" "highlight"

syntax_dir="$HOME/.zsh/zsh-syntax-highlighting"
if [[ -d "$syntax_dir" ]]
then
  h_echo --mode=noop "zsh-syntax-highlighting already installed"
else
  h_echo --mode=doing "cloning zsh-syntax-highlighting"
  git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$syntax_dir"
fi

suggest_dir="$HOME/.zsh/zsh-autosuggestions"
if [[ -d "$suggest_dir" ]]
then
  h_echo --mode=noop "zsh-autosuggestions already installed"
else
  h_echo --mode=doing "cloning zsh-autosuggestions"
  git clone "https://github.com/zsh-users/zsh-autosuggestions.git" "$suggest_dir"
fi

z_dir="$HOME/.zsh/zsh-z"
if [[ -d "$z_dir" ]]
then
  h_echo --mode=noop "z already installed"
else
  h_echo --mode=doing "cloning z"
  git clone "https://github.com/agkozak/zsh-z.git" "$z_dir"
fi

spaceship_dir="$HOME/.zsh/spaceship"
if [[ -d "$spaceship_dir" ]]
then
  h_echo --mode=noop "spaceship already installed"
else
  h_echo --mode=doing "cloning spaceship"
  git clone --depth=1 "https://github.com/spaceship-prompt/spaceship-prompt.git" "$spaceship_dir"
fi
