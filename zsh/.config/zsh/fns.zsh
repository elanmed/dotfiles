#!/bin/zsh
#
source ~/.dotfiles/helpers.sh

# https://unix.stackexchange.com/a/310553
setopt +o nomatch 
unalias ls
ls() {
  if [[ "$(find . -maxdepth 1 ! -name '.*' | wc -l)" -eq 0 ]]
  then 
    command ls -a "$@"
  else
    if h_is_linux 
    then
      command ls --color=auto "$@"
    else
      command ls -G "$@"
    fi
  fi
}

export ZSHZ_CMD="zsh_z"
# need `function` 
# https://github.com/ohmyzsh/ohmyzsh/issues/6723#issue-313463147
function z { 
  zsh_z "$@" 
  ls 
}

setopt auto_cd
cd() {
  builtin cd "$@"
  ls
}

if h_is_linux
then 
  alias copy="xclip -selection clipboard"
else
  alias copy="pbcopy"
fi
abspath() { 
  local abs_path="$(realpath "$1")"
  echo "$abs_path" | copy
  echo "$abs_path"
}
cb() {
  local branch="$(git symbolic-ref HEAD | cut -d'/' -f3)"
  echo "$branch" | copy
}

# misc
gif() { 
  ffmpeg -i "$1.mov" -pix_fmt rgb8 -r 10 "$1.gif"
  gifsicle -O3 "$1.gif" -o "$1.gif"
}
killp() { kill -9 $(lsof -t -i:$1) }
