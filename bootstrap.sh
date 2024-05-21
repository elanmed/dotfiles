#!/bin/bash
function cecho(){
    tput setaf $2;
    echo $1;
    tput sgr0;
}

function hasHomebrewPackage() {
  if [ "$(brew ls --versions "$1")" == "" ]; then echo 0; else echo 1; fi
}

function maybeInstallPackage() {
  if [ "$(hasHomebrewPackage "$1")" == 1 ]; then
    cecho "$1 already installed" 4
  else
    cecho "installing $1" 2
    if [ "$1" == "neovim" ]; then brew install --HEAD "$1"; else brew install "$1"; fi
  fi
}

if [ "$(command -v brew)" == "" ]; then
    cecho "installing hombrew" 2
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  cecho "homebrew already installed" 4
fi

maybeInstallPackage stow
for dir in */; do
    cecho "running: stow $dir" 2
    stow "$dir"
done
