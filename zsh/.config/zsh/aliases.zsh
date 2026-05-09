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

alias wifi="nmcli radio wifi"
alias wifion="nmcli radio wifi on"
alias wifioff="nmcli radio wifi off"
alias wifils="nmcli dev wifi list"
function wificon() {
  [[ -z $1 ]] && {
    h_format_error "usage: wificon <name>"
  }
  nmcli dev wifi connect "$1" --ask
}
