#!/bin/zsh

# https://unix.stackexchange.com/a/310553
setopt +o nomatch
unalias ls 2>/dev/null
ls() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    command ls --color=auto "$@"
  else
    command ls -G "$@"
  fi
}

unalias z
# need `function`
# https://github.com/ohmyzsh/ohmyzsh/issues/6723#issue-313463147
function z {
  zshz "$@"
  ls
}

cd() {
  builtin cd "$@"
  ls
}

if [[ "$(uname -s)" == "Linux" ]]; then
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
# https://gist.github.com/SheldonWangRJT/8d3f44a35c8d1386a396b9b49b43c385#solution
gif() {
  GIF_FILE="gif-$(date +%T).gif"
  ffmpeg -i "$1" -pix_fmt rgb8 -r 10 "$GIF_FILE"
  gifsicle --optimize=3 "$GIF_FILE" --output "$GIF_FILE"
}

killp() {
  kill -9 "$(lsof -t -i:$1)"
}

cbuild() {
  podman build -t container-env --no-cache ~/.dotfiles/containers
  podman image prune -f
}

crun() {
  if [[ -z $1 ]]; then
    echo "usage: crun <directory>"
    return 1
  fi
  podman run -it --rm -v "$(realpath "$1"):/$(basename "$(realpath "$1")"):Z" container-env zsh
}
