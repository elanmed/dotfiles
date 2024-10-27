#! /bin/bash
source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager "$1"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"

if [[ -d "$NVM_DIR"  ]]
then
  h_echo --mode=noop "nvm already installed"
else
  h_echo --mode=doing "installing nvm"
  PROFILE=/dev/null curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 

h_echo --mode=doing "installing the latest version of node"
nvm install 'lts/*'
