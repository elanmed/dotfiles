#!/bin/bash
# set -euo pipefail
source ~/.dotfiles/helpers.sh

usage="usage: ./bootstrap.sh -p {brew,dnf,apt} -d {mate,gnome,macos,headless}"
gui_desktop_envs=("gnome" "mate" "macos")
desktop_envs=("${gui_desktop_envs[@]}" "headless")
package_managers=("brew" "dnf" "apt")

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

if ! h_array_includes "$desktop_env" "${desktop_envs[@]}"; then
  h_echo error "$usage"
  exit 1
fi

if ! h_array_includes "$package_manager" "${package_managers[@]}"; then
  h_echo error "$usage"
  exit 1
fi

h_echo doing "writing $desktop_env to .desktop_env"
echo "$desktop_env" >"~/.dotfiles/.desktop_env"

h_echo doing "setting up installed_packages log"
if [[ -e "~/.dotfiles/installed_packages" ]]; then
  h_echo doing "backing up current log"
  cp "~/.dotfiles/installed_packages" "~/.dotfiles/installed_packages_prev"
fi
echo -n "" >"~/.dotfiles/installed_packages"

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

source "./_stow.sh" "$desktop_env"
source "./_install_packages.sh" "$package_manager" "$desktop_env"

if h_array_includes "$desktop_env" "${gui_desktop_envs[@]}"; then
  h_echo doing "bootstrapping fonts"
  if [[ "$(uname -s)" == "Linux" ]]; then
    h_echo noop "fonts already in the correct directory"
  else
    for font_dir in ~/.dotfiles/fonts/.local/share/fonts/*; do
      [[ -e $font_dir ]] || continue
      cp -r "$font_dir" ~/Library/Fonts/
    done
  fi

  h_echo doing "fetching terminfo"
  tempfile=$(mktemp) &&
    curl -so "$tempfile" "https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo" &&
    tic -x -o ~/.terminfo "$tempfile" &&
    rm "$tempfile"
fi

# h_install_package "$package_manager" wezterm

if h_is_macos; then
  h_echo doing "initializing the podman machine"
  if ! podman machine ls --format '{{.Name}}' 2>/dev/null | grep -qx 'podman-machine-default'; then
    podman machine init >/dev/null
  fi
  if ! podman machine inspect --format '{{.State}}' 2>/dev/null | grep -qx 'running'; then
    podman machine start >/dev/null
  fi
fi

h_echo doing "initializing nvm"
source ~/.nvm/nvm.sh
nvm install node >/dev/null

h_echo doing "installing pnpm"
npm install -g --silent pnpm@latest-11

h_echo doing "install bun"
# bun writes to your zshrc on every install
chmod a-w ~/.zshrc
curl -fsSL https://bun.com/install | bash >/dev/null
chmod u+w ~/.zshrc
export PATH="$HOME/.bun/bin:$PATH"

h_echo doing "installing agent-js deps"
pnpm --prefix ~/.dotfiles/containers/.local/lib/agent-js install --silent

h_echo doing "generating vim-js manifest"
npm --prefix ~/.dotfiles/neovim/.local/lib/vim-js run gen-manifest chrome >/dev/null

h_echo doing "bootstrapping neovim"
bash ~/.dotfiles/neovim/.config/nvim/bootstrap.sh -p "$package_manager" -d "$desktop_env"

if [[ -e "~/.dotfiles/installed_packages_prev" ]]; then
  h_echo doing "diffing prev log and current log"
  diff "~/.dotfiles/installed_packages_prev" "~/.dotfiles/installed_packages"
fi
