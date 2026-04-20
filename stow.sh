#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./stow.sh --desktop-env mate|gnome|macos|server"

desktop_env=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop-env)
      if [[ -z ${2:-} ]]; then
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

if [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi
h_validate_desktop_env "$desktop_env"

desktop_only_dirs=("fonts" "tmux" "wezterm")
for dir in "$HOME/.dotfiles/"*/; do
  dir_name=$(basename "$dir")
  if [[ $desktop_env == "server" ]] && h_array_includes "$dir_name" "${desktop_only_dirs[@]}"; then
    h_echo noop "SKIPPING: running 'stow $dir_name'"
  else
    h_echo doing "running 'stow $dir_name'"
    stow --dir "$HOME/.dotfiles" "$dir_name"
  fi
done

if [[ $desktop_env == "mate" ]] || [[ $desktop_env == "gnome" ]]; then
  h_echo doing "running 'stow $desktop_env'"
  stow --dir "$HOME/.dotfiles" "$desktop_env"
fi
