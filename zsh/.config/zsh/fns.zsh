#!/bin/zsh
source ~/.dotfiles/helpers.sh

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
  local branch="$(git symbolic-ref HEAD | cut -d '/' -f 3)"
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
    h_format_error "usage: cbuild {ubuntu,fedora}"
  fi

  if h_is_toolbox || h_is_podman; then
    h_format_error "cbuild should only be used in a root environment"
  fi
  podman build --tag "$1-container" --no-cache "$HOME/.dotfiles/containers/.containerfiles/$1"
  podman image prune --force
}

crun() {
  if [[ -z $1 ]]; then
    h_format_error "usage: crun <directory> {ubuntu,fedora} [command...]"
  fi

  if [[ $2 != "ubuntu" ]] && [[ $2 != "fedora" ]]; then
    h_format_error "usage: crun <directory> {ubuntu,fedora} [command...]"
  fi

  local workspace="/$(basename "$(realpath "$1")")"
  local dir="$1"
  local distro="$2"
  shift 2
  local cmd=("$@")
  [[ ${#cmd[@]} -eq 0 ]] && cmd=("zsh")

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
    --volume "$HOME/.dotfiles/.env:/root/.dotfiles/.env:ro" \
    --volume "$(realpath "$dir"):$workspace" \
    "$distro-container" \
    zsh -ic 'exec "$@"' zsh "${cmd[@]}"
}

cat_args() {
  for arg in "$@"; do
    echo "FILE NAME: $arg"
    cat "$arg"
  done
}

sub_remove() {
  local name="$1"
  [[ -z $name ]] && {
    h_format_error "usage: sub_remove <path>"
  }

  [[ -d ".git/modules/$name" ]] || {
    h_format_error "module data not found: .git/modules/$name"
  }

  git submodule deinit --force "$name" || return 1
  git rm --force "$name" || return 1
  rm -rf ".git/modules/$name"
  git config --remove-section "submodule.$name" 2>/dev/null
}

agent() {
  if h_is_toolbox || h_is_podman; then
    h_format_error "agent should only be used in a root env"
  else
    crun . fedora \
      /root/.nvm/versions/node/v24.15.0/bin/node \
      "/root/.dotfiles/containers/.local/lib/agent-js/src/index.ts"
  fi
}

hor() {
  xrandr --output eDP-1 --rotate normal
  xinput list --name-only | grep '^IPTSD Virtual' | while read dev; do
    xinput set-prop "$dev" "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
  done
}

ver() {
  xrandr --output eDP-1 --rotate left
  xinput list --name-only | grep '^IPTSD Virtual' | while read dev; do
    xinput set-prop "$dev" "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
  done
}
