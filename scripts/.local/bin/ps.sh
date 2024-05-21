#!/bin/bash
uuid=$(uuidgen)
uuid=${uuid:0:8}
dir=~/Desktop/personal-site
tmux new-session -d -s "n-${uuid}"
window=0
tmux rename-window -t "n-${uuid}":0 'nvim'
tmux send-keys "nvim ${dir}" C-m
window=1
tmux new-window -t "n-${uuid}":1
tmux select-window -t "n-${uuid}":1
tmux send-keys "cd ${dir} && clear" C-m
tmux send-keys 'open http://localhost:3001 && npm run dev' C-m
tmux split-window -h
tmux send-keys "cd ${dir} && clear" C-m
tmux send-keys 'npx prisma studio' C-m
tmux select-window -t "n-${uuid}":0
tmux attach-session -t "n-${uuid}"

