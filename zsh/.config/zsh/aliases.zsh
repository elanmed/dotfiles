#!/bin/zsh

alias gs="git status"
alias gc="git checkout"
alias e="exit"
alias c="clear"
alias tm="tmux"
alias tsrc="tmux source $HOME/.config/tmux/tmux.conf"
alias vim="nvim -u $HOME/.dotfiles/neovim/.config/nvim/barebones.lua"
[[ "$(uname -s)" == "Linux" ]] && alias open="flatpak-xdg-open"
