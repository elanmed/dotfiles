#!/bin/bash
source ~/.dotfiles/helpers.sh

usage="usage: ./bootstrap.sh -p brew|dnf|apt -d mate|gnome|macos|server"

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

if [[ $(uname -s) == "Linux" ]] && ! h_is_toolbox && ! h_is_podman; then
  h_echo error "bootstrap.sh must be run in a container or macos"
  exit 1
fi
if [[ -z $package_manager ]]; then
  h_echo error "$usage"
  exit 1
fi
if [[ -z $desktop_env ]]; then
  h_echo error "$usage"
  exit 1
fi

h_validate_package_manager "$package_manager"
h_validate_desktop_env "$desktop_env"

h_echo doing "resetting installed_packages log"
echo -n "" >./installed_packages

h_echo doing "initializing submodules"
git submodule init
git submodule update
git submodule foreach --quiet 'source ~/.dotfiles/helpers.sh && h_update_submodule'

if command -v zsh >/dev/null 2>&1; then
  h_echo noop "zsh already installed"
else
  h_install_package "$package_manager" zsh
  h_echo noop "exiting early, re-run the script"
  exit 0
fi

if ! h_string_includes "$SHELL" "zsh"; then
  h_echo doing "setting the default shell to zsh"
  chsh -s "$(command -v zsh)"
  h_echo noop "exiting early, log out and re-run the script"
  exit 0
fi

h_install_package "$package_manager" stow
h_install_package "$package_manager" shfmt
h_install_package "$package_manager" tmux
h_install_package "$package_manager" xclip
h_install_package "$package_manager" fzf
h_install_package "$package_manager" source-highlight
h_install_package "$package_manager" highlight
h_install_package "$package_manager" lazygit
h_install_package "$package_manager" unzip
h_install_package "$package_manager" podman
h_install_package "$package_manager" git-delta

if h_is_macos; then
  h_echo doing "initializing the podman vim"
  podman machine init
  podman machine start
fi

h_echo doing "writing $desktop_env to .desktop_env"
echo "$desktop_env" >./.desktop_env

source "$HOME/.dotfiles/stow.sh" -d "$desktop_env"

if [[ $desktop_env == "server" ]]; then
  h_echo noop "SKIPPING: bootstrapping fonts"
else
  h_echo doing "bootstrapping fonts"
  if [[ "$(uname -s)" == "Linux" ]]; then
    h_echo noop "fonts already in the correct directory"
  else
    for font_dir in ~/.dotfiles/fonts/.local/share/fonts/*; do
      cp -r "$font_dir" ~/Library/Fonts/
    done
  fi
fi

h_echo doing "initializing nvm"
source ~/.nvm/nvm.sh
nvm install --lts

h_echo doing "installing pnpm"
npm install -g pnpm@latest-11

h_echo doing "install bun"
# bun writes to your zshrc on every install
chmod a-w ~/.zshrc
curl -fsSL https://bun.com/install | bash
chmod u+w ~/.zshrc
export PATH="$HOME/.bun/bin:$PATH"

h_echo doing "installing agent-js deps"
pnpm --prefix ~/.dotfiles/containers/.local/lib/agent-js install

h_echo doing "generating vim-js manifest"
npm --prefix ~/.dotfiles/neovim/.local/lib/vim-js run gen-manifest chrome

h_echo doing "bootstrapping neovim"
bash ~/.dotfiles/neovim/.config/nvim/bootstrap.sh -p "$package_manager" -d "$desktop_env"

h_echo doing "fetching terminfo"
tempfile=$(mktemp) &&
  curl -so $tempfile https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo &&
  tic -x -o ~/.terminfo $tempfile &&
  rm $tempfile
