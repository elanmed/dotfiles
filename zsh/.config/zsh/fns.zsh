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
  GIF_FILE="$1.gif"
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

  h_require_root_env "cbuild"
  if h_is_macos; then
    podman machine start 2>/dev/null
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

  h_require_root_env "crun"

  if h_is_macos; then
    podman machine start >/dev/null 2>&1
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
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    --env DISPLAY \
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

cagent() {
  h_require_root_env "cagent"
  h_set_wezterm_user_var "AGENT_JS_ACTIVE" "true"

  if h_is_macos; then
    node ~/.dotfiles/containers/.local/lib/agent-js/scripts/pbpaste.ts &
    CLIP_PID=$!
    trap "kill $CLIP_PID 2>/dev/null" EXIT
  else
    xhost +local: >/dev/null 2>&1
  fi

  crun . fedora \
    node /root/.dotfiles/containers/.local/lib/agent-js/src/index.ts
  h_set_wezterm_user_var "AGENT_JS_ACTIVE" ""
}

chat() {
  h_require_root_env "chat"
  cd "$(mktemp -d)" && cagent
  exit
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

f() {
  h_require_root_env "f"
  toolbox enter fedora-toolbox-43
}

tbuild() {
  h_require_root_env "toolbox"
  if h_is_macos; then
    h_format_error "toolbox is only supported on linux"
  fi

  toolbox create --distro fedora --release 43
}

v() {
  h_run_shell_in_container "\$NVIM_CMD $@"
}

lg() {
  h_run_shell_in_container "lazygit $@"
}

ezsh() {
  h_run_shell_in_container 'cd ~/.dotfiles/zsh/.config/zsh && $NVIM_CMD'
}

eterm() {
  h_run_shell_in_container 'cd ~/.dotfiles && $NVIM_CMD ~/.dotfiles/wezterm/.config/wezterm/wezterm.lua'
}

etmux() {
  h_run_shell_in_container 'cd ~/.dotfiles && $NVIM_CMD ~/.dotfiles/tmux/.config/tmux/tmux.conf'
}

edot() {
  h_run_shell_in_container 'cd ~/.dotfiles && $NVIM_CMD'
}

evim() {
  h_run_shell_in_container 'cd ~/.dotfiles/neovim/.config/nvim && $NVIM_CMD'
}

firmware-upgrade() {
  sudo fwupdmgr update
}
