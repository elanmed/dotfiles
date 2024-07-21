#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager $1

if [[ ! -d ~/.oh-my-zsh ]]
then
  h_cecho --error "oh-my-zsh is not yet installed, run 'oh-my-zsh.sh' before 'bootstrap.sh'"
  exit 1
fi

h_cecho --query "this script delete your .zshrc. confirm 'y' for yes, anything else to abort: "
read answer

if [[ "$answer" != 'y' ]]
then 
  h_cecho --error "aborting"
fi

h_cecho --doing "removing ~/.zshrc"
rm -rf ~/.zshrc

h_install_package $1 stow
for dir in */
do
  stripped_dir="${dir%?}"
  h_cecho --doing "running 'stow $stripped_dir'"
  stow "$stripped_dir"
done


package_manager=$(echo $1 | cut -d= -f2)
h_cecho --noop "to finish bootstrapping, run:"
h_cecho --noop "./neovim/.config/nvim/bootstrap.sh --pm=$package_manager"
h_cecho --noop "./tmux/.config/tmux/bootstrap.sh --pm=$package_manager"
h_cecho --noop "./zsh/bootstrap.sh"
