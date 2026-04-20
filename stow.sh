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

desktop_dirs=("fonts" "tmux" "wezterm")
base_dirs=("containers" "git" "neovim" "nvm" "scripts" "zsh")

server_dirs=("${base_dirs[@]}")
mate_dirs=("${base_dirs[@]}" "${desktop_dirs[@]}" "mate")
gnome_dirs=("${base_dirs[@]}" "${desktop_dirs[@]}" "gnome")
macos_dirs=("${base_dirs[@]}" "${desktop_dirs[@]}")

run_stow() {
  for dir in "$@"; do
    h_echo doing "running 'stow $dir'"
    stow --dir "$HOME/.dotfiles" "$dir"
  done
}

case "$desktop_env" in
  "gnome")
    run_stow "${gnome_dirs[@]}"
    ;;
  "mate")
    run_stow "${mate_dirs[@]}"
    ;;
  "server")
    run_stow "${server_dirs[@]}"
    ;;
  "macos")
    run_stow "${macos_dirs[@]}"
    ;;
  *)
    h_format_error "$usage"
    ;;
esac
