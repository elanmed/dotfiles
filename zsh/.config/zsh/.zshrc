#!/usr/bin/env zsh

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zap-zsh/supercharge"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "hlissner/zsh-autopair"
plug "agkozak/zsh-z"

autoload -Uz compinit
compinit

source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.zsh/spaceship/spaceship.zsh"

if [[ "$TERM_PROGRAM" != tmux ]]
then
  tmux
fi
