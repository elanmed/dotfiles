#! /bin/bash
source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

[[ "$(uname -s)" == "Linux" ]] && h_install_package "$1" xclip
h_install_package "$1" fzf
h_install_package "$1" source-highlight
h_install_package "$1" highlight

syntax_dir="$ZSH/custom/plugins/zsh-syntax-highlighting"
if [[ -d "$syntax_dir" ]]
then
  h_echo --mode=noop "zsh-syntax-highlighting already installed"
else
  h_echo --mode=doing "cloning zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$syntax_dir"
fi

suggest_dir="$ZSH/custom/plugins/zsh-autosuggestions"
if [[ -d "$suggest_dir" ]]
then
  h_echo --mode=noop "zsh-autosuggestions already installed"
else
  h_echo --mode=doing "cloning zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$suggest_dir"
fi

spaceship_dir="$ZSH/custom/themes/spaceship-prompt"
if [[ -d "$spaceship_dir" ]]
then
  h_echo --mode=noop "spaceship already installed"
else
  h_echo --mode=doing "cloning spaceship"
  git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_dir" --depth=1
  ln -s "$ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$spaceship_dir"
fi

h_echo --mode=doing "symlinking zshrc"
ln -s ~/.dotfiles/zsh/.config/zsh/.zshrc ~/.zshrc > /dev/null 2>&1

h_echo --mode=doing "symlinking spaceshiprc"
ln -s ~/.dotfiles/zsh/.config/zsh/.spaceshiprc.zsh ~/.spaceshiprc.zsh > /dev/null 2>&1
