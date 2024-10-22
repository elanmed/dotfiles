#!/bin/bash
source ~/.dotfiles/helpers.sh

if [[ "$TERM_PROGRAM" = "tmux" ]]
then
  h_echo --error "only run ps.sh outside a tmux session!" 
  exit
fi

uuid=$(uuidgen)
uuid=${uuid:0:8}
tmux new-session -d -s "n-${uuid}"
window=0
tmux rename-window -t "n-${uuid}":0 "code"
tmux send-keys "nvim" C-m
window=1
tmux new-window -t "n-${uuid}":1
tmux select-window -t "n-${uuid}":1
tmux send-keys "cd $1 && clear" C-m
tmux send-keys "open http://localhost:3001 && npm run dev" C-m
tmux split-window -h
tmux send-keys "cd $1 && clear" C-m
tmux send-keys "npx prisma studio" C-m
tmux select-window -t "n-${uuid}":0
tmux attach-session -t "n-${uuid}"
