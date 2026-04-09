#!/bin/bash
source ~/.dotfiles/helpers.sh

package_manager=""
server=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --server)
      server=true
      shift
      ;;
    --package-manager)
      package_manager="$2"
      shift 2
      ;;
    *)
      h_echo error "usage: ./scratch.sh --package-manager <pm> [--server]"
      exit 1
      ;;
  esac
done

if [[ -z $package_manager ]]; then
  h_echo error "missing required argument: --package-manager"
  exit 1
fi
h_validate_package_manager "$package_manager"

git submodule init
git submodule update

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

if [[ $server == true ]]; then
  is_server_value=0
else
  is_server_value=1
fi

h_echo doing "writing $is_server_value to .is_server"
echo "$is_server_value" >./.is_server

if [[ $server == true ]]; then
  source "$HOME/.dotfiles/stow.sh" --server
else
  source "$HOME/.dotfiles/stow.sh"
fi

if [[ $server == true ]]; then
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

h_echo doing "install bun"
# bun writes to your zshrc on every install
chmod a-w ~/.zshrc
curl -fsSL https://bun.com/install | bash
chmod u+w ~/.zshrc

h_echo doing "bootstrapping neovim"
bash ~/.dotfiles/neovim/.config/nvim/bootstrap.sh --package-manager "$package_manager"
