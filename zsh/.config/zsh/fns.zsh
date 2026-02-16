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
  if [[ $1 != "ubuntu" ]] && [[ $1 != "fedora" ]]; then
    echo "usage: cbuild {ubuntu,fedora}"
    return 1
  fi
  podman build -t "$1-container" --no-cache "$HOME/.dotfiles/containers/.containerfiles/$1"
  podman image prune -f
}

crun() {
  if [[ -z $1 ]]; then
    echo "usage: crun <directory> {ubuntu,fedora}"
    return 1
  fi

  if [[ $2 != "ubuntu" ]] && [[ $2 != "fedora" ]]; then
    echo "usage: crun <directory> {ubuntu,fedora}"
    return 1
  fi
  local workspace="/$(basename "$(realpath "$1")")"

  # --interactive: keep stdin open to enable typing commands into the container
  # --tty: allocate a pseudo-terminal, enabling colors, line editing, and ctrl-c
  # --rm: delete the container's file system on exit (non-mounted volumes)
  # --security-opt label=disable: disable SELinux so the container can read/write mounted volumes
  # --workdir: cd "$workspace" on load
  # --volume: bind the host dir on the left of the : to the container dir on the right side of the :
  podman run \
    --interactive \
    --tty \
    --rm \
    --security-opt label=disable \
    --workdir "$workspace" \
    --volume "$(realpath "$1"):$workspace" \
    "$2-container" \
    zsh
}

cat_args() {
  for arg in "$@"; do
    echo "FILE NAME: $arg"
    cat "$arg"
  done
}
