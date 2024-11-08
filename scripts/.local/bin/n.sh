#!/bin/bash
source ~/.dotfiles/helpers.sh

split_window() {
  tmux split-window -h
  tmux send-keys "builtin cd $1 && clear" "C-m"
  tmux select-pane -L
  tmux resize-pane -Z
}

if [[ "$TERM_PROGRAM" == tmux ]]
then
  tmux send-keys "nvim " "$1" "C-m"
  num_panes=$(tmux display-message -p '#{window_panes}')
  [[ "$num_panes" == 1 ]] && split_window "$@"
  exit
fi


uuid=$(uuidgen)
uuid=${uuid:0:3}
tmux new-session -d -s "n-${uuid}"
window=0
tmux rename-window -t "n-${uuid}":0 "code"
tmux send-keys "nvim " "$1" C-m
split_window "$@"
window=1
tmux new-window -t "n-${uuid}":1
tmux rename-window -t "n-${uuid}":1 "tests"
tmux select-window -t "n-${uuid}":0
tmux attach-session -t "n-${uuid}"
