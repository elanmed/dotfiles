#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./bootstrap.sh -p {brew,dnf,apt} -d {mate,gnome,macos,headless}"

package_manager=""
desktop_env=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      if [[ -z ${2:-} ]]; then
        h_echo error "$usage"
        exit 1
      fi
      package_manager="$2"
      shift 2
      ;;
    -d)
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

if [[ -z $package_manager ]] || [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi

gui_desktop_envs=("gnome" "mate" "macos")

h_validate_package_manager "$package_manager"
h_validate_desktop_env "$desktop_env"

h_echo doing "writing $desktop_env to .desktop_env"
echo "$desktop_env" >./.desktop_env

h_echo doing "setting up installed_packages log"
if [[ -e ./installed_packages ]]; then
  h_echo doing "backing up current log"
  cp ./installed_packages ./installed_packages_prev
fi
echo -n "" >./installed_packages

# install packages
# diff from previous expected packages
# notify if diff (new or removed expected package)

h_echo doing "initializing submodules"
git submodule init
git submodule update
git submodule foreach --quiet 'source ~/.dotfiles/helpers.sh && h_update_submodule'

h_install_package "$package_manager" zsh

if ! h_string_includes "$SHELL" "zsh"; then
  h_echo doing "setting the default shell to zsh"
  chsh -s "$(command -v zsh)"
  h_echo noop "exiting early, log out and re-run the script"
  exit 0
fi

if h_array_includes "$desktop_env" "${gui_desktop_envs[@]}"; then
  h_echo doing "installing $desktop_env-specific packages"
fi

# h_install_package "$package_manager" wezterm

case "$desktop_env" in
  gnome)
    echo ""
    ;;
  mate)
    h_install_package "$package_manager" wmctrl
    h_install_package "$package_manager" rofi
    h_install_package "$package_manager" keyd
    h_install_package "$package_manager" xinput
    h_install_package "$package_manager" flatpak
    h_install_package "$package_manager" gnome-software
    h_install_package "$package_manager" gnome-software-plugin-flatpak
    h_install_package "$package_manager" xss-lock
    ;;
  macos)
    echo ""
    ;;
esac

case "$package_manager" in
  brew) ;;
  dnf) ;;
  apt) ;;
esac

h_echo doing "installing system packages"
h_install_package "$package_manager" stow
h_install_package "$package_manager" shfmt
h_install_package "$package_manager" tmux
h_install_package "$package_manager" bats
h_install_package "$package_manager" xclip
h_install_package "$package_manager" fzf
h_install_package "$package_manager" source-highlight
h_install_package "$package_manager" highlight
h_install_package "$package_manager" lazygit
h_install_package "$package_manager" podman
h_install_package "$package_manager" git-delta

if h_is_macos; then
  h_echo doing "initializing the podman vim"
  podman machine init >/dev/null
  podman machine start >/dev/null
fi

if h_array_includes "$desktop_env" "${gui_desktop_envs[@]}"; then
  h_echo doing "installing $desktop_env-specific packages"
fi
