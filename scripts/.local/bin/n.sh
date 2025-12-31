#!/bin/bash
# shellcheck source=/dev/null

split_window() {
  tmux split-window -h
  tmux send-keys "builtin cd $1 && clear" "C-m"
  tmux select-pane -L
  tmux resize-pane -Z
}

main() {
  if ! command -v "tmux" >/dev/null 2>&1; then
    "$NVIM_CMD" "$1"
    exit 0
  fi

  if [[ $TERM_PROGRAM == "tmux" ]]; then
    tmux send-keys "nvim $1" "C-m"
    num_panes="$(tmux display-message -p '#{window_panes}')"
    [[ $num_panes -eq 1 ]] && split_window "$1"
    exit 0
  fi

  uuid="$(uuidgen)"
  uuid="${uuid:0:3}"
  session_name="n-$uuid"
  tmux new-session -d -s "$session_name"
  tmux rename-window -t "$session_name":0 "code"
  tmux send-keys "nvim " "$1" C-m
  split_window "$1"
  tmux new-window -t "$session_name":1
  tmux rename-window -t "$session_name":1 "tests"
  tmux select-window -t "$session_name":0
  tmux attach-session -t "$session_name"
}

main "$@"
