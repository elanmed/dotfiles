#!/bin/bash
uuid=$(uuidgen)
uuid=${uuid:0:3}
tmux new-session -d -s "n-${uuid}"
window=0
tmux rename-window -t "n-${uuid}":0 'nvim'
tmux send-keys 'nvim ' $1 C-m
tmux split-window -h
tmux send-keys "cd $1 && clear" C-m
tmux select-pane -L
tmux resize-pane -Z
window=1
tmux new-window -t "n-${uuid}":1
tmux select-window -t "n-${uuid}":0
tmux attach-session -t "n-${uuid}"

