#!/bin/zsh

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743

[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zap-zsh/supercharge"
# plug "zap-zsh/completions"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "agkozak/zsh-z"

# https://github.com/Aloxaf/fzf-tab/issues/24#issuecomment-574986122
zstyle -d ':completion:*' format
zstyle ':completion:*:descriptions' format '[%d]'

# https://github.com/junegunn/fzf?tab=readme-ov-file#setting-up-shell-integration
source <(fzf --zsh)

source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.zsh/spaceship/spaceship.zsh"

if [[ "$TERM_PROGRAM" != tmux ]]
then
  tmux
fi
