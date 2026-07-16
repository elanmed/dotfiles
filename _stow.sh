#!/bin/bash
source ~/.dotfiles/helpers.sh

[[ $# -ne 1 ]] && h_throw_error "usage: ./_stow.sh <desktop_env>"

gui_desktop_dirs=("fonts" "tmux" "wezterm")
base_dirs=("containers" "git" "neovim" "nvm" "scripts" "zsh")

run_stow() {
  for dir in "$@"; do
    h_echo doing "running 'stow $dir'"
    stow --dir "$HOME/.dotfiles" "$dir"
  done
}

case "$desktop_env" in
  "gnome")
    run_stow "${base_dirs[@]}" "${gui_desktop_dirs[@]}" "gnome"
    ;;
  "mate")
    run_stow "${base_dirs[@]}" "${gui_desktop_dirs[@]}" "mate"

    h_echo doing "symlinking keyd conf"
    sudo mkdir -p /etc/keyd
    sudo ln -sf ~/.dotfiles/keyd/etc/keyd/default.conf /etc/keyd/default.conf
    ;;
  "headless")
    run_stow "${base_dirs[@]}"
    ;;
  "macos")
    run_stow "${base_dirs[@]}" "${gui_desktop_dirs[@]}" "macos"
    ;;
  *)
    h_throw_error "$usage"
    ;;
esac
