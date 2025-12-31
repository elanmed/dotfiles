#!/bin/zsh

# https://github.com/junegunn/fzf#setting-up-shell-integration
source <(fzf --zsh)

# plugins
source "$HOME/.dotfiles/zsh/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.dotfiles/zsh/.zsh/zsh-z/zsh-z.plugin.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/supercharge.zsh"

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743
source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/prompt.zsh"

# https://github.com/zsh-users/zsh-syntax-highlighting#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
source "$HOME/.dotfiles/zsh/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
