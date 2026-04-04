#!/bin/bash
source ~/.dotfiles/helpers.sh

if [[ $1 == --server ]]; then
  server=true
elif [[ -n $1 ]]; then
  h_echo error "usage: ./stow.sh [--server]"
  exit 1
else
  server=false
fi

desktop_only_dirs=("fonts" "tmux" "wezterm")
for dir in "$HOME/.dotfiles/"/*/; do
  dir_name=$(basename "$dir")
  if [[ $server == true ]] && h_array_includes "$dir_name" "${desktop_only_dirs[@]}"; then
    h_echo noop "SKIPPING: running 'stow $dir_name'"
  else
    h_echo doing "running 'stow $dir_name'"
    stow --dir "$HOME/.dotfiles" "$dir_name"
  fi
done
