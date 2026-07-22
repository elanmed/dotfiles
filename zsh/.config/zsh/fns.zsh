#!/bin/zsh
# _helpers.sh already sourced by exports.zsh

# https://unix.stackexchange.com/a/310553
setopt +o nomatch
unalias ls 2>/dev/null
ls() {
  if [[ $_H_OS == "Linux" ]]; then
    command ls --color=auto -A "$@"
  else
    command ls -G -A "$@"
  fi
}

# lsa_cmd="command ls -a --color=tty"
# [[ "$(uname -s)" == "Linux" ]] && lsa_cmd+=" --group-directories-first"
# alias lsa="$lsa_cmd"

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

if h_is_macos; then
  alias copy="pbcopy"
else
  alias copy="xclip -selection clipboard"
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
    h_echo error "usage: cbuild {ubuntu,fedora}"
    exit 1
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
    h_echo error "usage: crun <directory> {ubuntu,fedora} [command...]"
    exit 1
  fi

  if [[ $2 != "ubuntu" ]] && [[ $2 != "fedora" ]]; then
    h_echo error "usage: crun <directory> {ubuntu,fedora} [command...]"
    exit 1
  fi

  h_require_root_env "crun"

  if h_is_macos; then
    podman machine start >/dev/null 2>&1
  fi

  if h_is_macos; then
    paste_cmd="pbpaste"
    copy_cmd="pbcopy"
  else
    paste_cmd="xclip -selection clipboard -o"
    copy_cmd="xclip -selection clipboard -in"
  fi

  paste_fifo=/tmp/paste-fifo
  rm -f "$paste_fifo"
  mkfifo "$paste_fifo"
  node "$HOME/.dotfiles/containers/.local/lib/agent-js/scripts/paste-server.ts" "$paste_cmd" >"$paste_fifo" &
  paste_server_pid="$!"
  read -r PASTE_PORT <"$paste_fifo"
  rm -f "$paste_fifo"

  copy_fifo=/tmp/copy-fifo
  rm -f "$copy_fifo"
  mkfifo "$copy_fifo"
  node "$HOME/.dotfiles/containers/.local/lib/agent-js/scripts/copy-server.ts" "$copy_cmd" >"$copy_fifo" &
  copy_server_pid="$!"
  read -r COPY_PORT <"$copy_fifo"
  rm -f "$copy_fifo"

  trap "kill $paste_server_pid $copy_server_pid 2>/dev/null" EXIT

  local workspace="/$(basename "$(realpath "$1")")"
  local dir="$1"
  local distro="$2"
  shift 2
  local cmd=("$@")
  [[ ${#cmd[@]} -eq 0 ]] && cmd=("zsh")

  local podman_args=(
    # keep stdin open to enable typing commands into the container
    --interactive
    # allocate a pseudo-terminal, enabling colors, line editing, and ctrl-c
    --tty
    # delete the container's file system on exit (non-mounted volumes)
    --rm
    # disable SELinux so the container can read/write mounted volumes
    --security-opt label=disable
    # cd "$workspace" on load
    --workdir "$workspace"
    # bind the host dir on the left of the : to the container dir on the right side of the :
    --volume "$HOME/.dotfiles/.env:/root/.dotfiles/.env:ro"
    --volume "$(realpath "$dir"):$workspace"

    --env AGENT_JS_EDIT='printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" "$(echo -n "false" | base64)"
nvim -u "$HOME/.dotfiles/neovim/.config/nvim/container.lua" -c "normal! G$" -c startinsert! __FILE__
printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" "$(echo -n "true" | base64)"'
    --env AGENT_JS_HISTORY='nvim -u "$HOME/.dotfiles/neovim/.config/nvim/container.lua" -c "normal! G$" __FILE__'
    --env AGENT_JS_CLIPBOARD_PASTE="nc --recv-only host.docker.internal $PASTE_PORT"
    --env COPY_PORT="$COPY_PORT"
    --env PASTE_PORT="$PASTE_PORT"
  )

  podman run "${podman_args[@]}" \
    "$distro-container" \
    zsh -ic 'exec "$@"' zsh "${cmd[@]}"
}

sub_remove() {
  local name="$1"
  [[ -z $name ]] && {
    h_echo error "usage: sub_remove <path>"
    exit 1
  }

  [[ -d ".git/modules/$name" ]] || {
    h_echo error "module data not found: .git/modules/$name"
    exit 1
  }

  git submodule deinit --force "$name" || return 1
  git rm --force "$name" || return 1
  rm -rf ".git/modules/$name"
  git config --remove-section "submodule.$name" 2>/dev/null
}

cagent() {
  h_require_root_env "cagent"
  h_set_wezterm_user_var "AGENT_JS_ACTIVE" "true"

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
  xinput list --name-only | grep '^Wacom HID .* \(Finger touch\|Pen stylus\)$' | while read dev; do
    xinput set-prop "$dev" "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
  done
}
ver() {
  xrandr --output eDP-1 --rotate left
  xinput list --name-only | grep '^Wacom HID .* \(Finger touch\|Pen stylus\)$' | while read dev; do
    xinput set-prop "$dev" "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
  done
}

v() {
  "$NVIM_CMD" "$@"
}

lg() {
  lazygit "$@"
}

ezsh() {
  cd "$HOME/.dotfiles/zsh/.config/zsh" && "$NVIM_CMD"
}

eterm() {
  cd "$HOME/.dotfiles" && "$NVIM_CMD" "$HOME/.dotfiles/wezterm/.config/wezterm/wezterm.lua"
}

etmux() {
  cd "$HOME/.dotfiles" && "$NVIM_CMD" "$HOME/.dotfiles/tmux/.config/tmux/tmux.conf"
}

edot() {
  cd "$HOME/.dotfiles" && "$NVIM_CMD"
}

evim() {
  cd "$HOME/.dotfiles/neovim/.config/nvim" && "$NVIM_CMD"
}

eagent() {
  cd "$HOME/.dotfiles/containers/.local/lib/agent-js" && "$NVIM_CMD"
}

firmware-upgrade() {
  sudo fwupdmgr update
}
