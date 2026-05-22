#!/bin/zsh

# git
alias gs="git status"
alias gc="git checkout"
# shorter commands
alias e="exit"
alias c="clear"
alias tm="tmux"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
lsa_cmd="command ls -a --color=tty"
[[ "$(uname -s)" == "Linux" ]] && lsa_cmd+=" --group-directories-first"
alias lsa="$lsa_cmd"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
[[ "$(uname -s)" == "Linux" ]] && alias open="flatpak-xdg-open"
