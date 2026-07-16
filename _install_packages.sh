#!/bin/bash
source ~/.dotfiles/helpers.sh

[[ $# -ne 2 ]] && h_throw_error "usage: ./_install_packages.sh <package_manager> <desktop_env>"

base_packages=(
  "stow"
  "shfmt"
  "tmux"
  "bats"
  "fzf"
  "lazygit"
  "podman"
  "git-delta"
)

linux_packages=("xclip")

mate_packages=(
  "wmctrl"
  "rofi"
  "keyd"
  "xinput"
  "flatpak"
  "gnome-software"
  "gnome-software-plugin-flatpak"
  "xss-lock"
)

gnome_packages=()
macos_packages=()
headless_packages=()

install_packages() {
  for package in "$@"; do
    h_install_package "$1" package
  done
}

case "$2" in
  "gnome")
    install_packages "${base_packages[@]}" "${linux_packages[@]}" "${gnome_packages[@]}"
    ;;
  "mate")
    install_packages "${base_packages[@]}" "${linux_packages[@]}" "${mate_packages[@]}"
    link_keyd
    ;;
  "headless")
    install_packages "${base_packages[@]}" "${linux_packages[@]}"
    ;;
  "macos")
    install_packages "${base_packages[@]}" "${macos_packages[@]}"
    ;;
  *)
    h_throw_error "$usage"
    ;;
esac
