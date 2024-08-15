#!/bin/bash
source ~/.dotfiles/helpers.sh

if [[ "$TERM_PROGRAM" = tmux ]]
then
  tmux send-keys "$(which nvim) " $1 C-m
  tmux split-window -h
  tmux send-keys "cd $1 && clear" C-m
  tmux select-pane -L
  tmux resize-pane -Z
  exit
fi

uuid=$(uuidgen)
uuid=${uuid:0:3}
tmux new-session -d -s "n-${uuid}"
window=0
tmux rename-window -t "n-${uuid}":0 "$(which nvim)"
tmux send-keys "$(which nvim) " $1 C-m
tmux split-window -h
tmux send-keys "cd $1 && clear" C-m
tmux select-pane -L
tmux resize-pane -Z
window=1
tmux new-window -t "n-${uuid}":1
tmux select-window -t "n-${uuid}":0
tmux attach-session -t "n-${uuid}"
