#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./stow.sh [--server] [--desktop-env gnome|mate]"

server=false
desktop_env=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)
      server=true
      shift
      ;;
    --desktop-env)
      if [[ -z "${2:-}" ]]; then
        h_echo error "$usage"
        exit 1
      fi
      desktop_env="$2"
      shift 2
      ;;
    *)
      h_echo error "$usage"
      exit 1
      ;;
  esac
done

h_validate_desktop_env "$desktop_env"

if [[ $server == true ]] && [[ -n $desktop_env ]]; then
  h_echo error "--server and --desktop-env are mutually exclusive"
  exit 1
fi

desktop_only_dirs=("fonts" "tmux" "wezterm")
for dir in "$HOME/.dotfiles/"*/; do
  dir_name=$(basename "$dir")
  if [[ $server == true ]] && h_array_includes "$dir_name" "${desktop_only_dirs[@]}"; then
    h_echo noop "SKIPPING: running 'stow $dir_name'"
  else
    h_echo doing "running 'stow $dir_name'"
    stow --dir "$HOME/.dotfiles" "$dir_name"
  fi
done

if [[ -n $desktop_env ]]; then
  h_echo doing "running 'stow $desktop_env'"
  stow --dir "$HOME/.dotfiles" "$desktop_env"
fi