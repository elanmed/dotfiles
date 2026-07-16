#!/bin/zsh

alias gs="git status"
alias gc="git checkout"
alias e="exit"
alias c="clear"
alias tm="tmux"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
[[ "$(uname -s)" == "Linux" ]] && alias open="flatpak-xdg-open"
