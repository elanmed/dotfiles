#!/bin/zsh

# TODO
# Replace spaceship with custom prompt 
## Update prompt without accepting a line
# Replace fzf tab with fzf completion
# Look into replicating supercharge
# Replace zap with submodules
# Issue with functions not applying when sourced in toolbox

source "$HOME/.dotfiles/helpers.sh"
source "$HOME/.dotfiles/zsh/.local/share/zap/zap.zsh"

plug "zap-zsh/supercharge"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "agkozak/zsh-z"

# https://github.com/Aloxaf/fzf-tab/tree/master#configure
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # filename coloring
zstyle ':completion:*:descriptions' format '[%d]' # labeled, colored descriptions

# https://github.com/junegunn/fzf#setting-up-shell-integration
source <(fzf --zsh)

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743
source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/prompt.zsh"
