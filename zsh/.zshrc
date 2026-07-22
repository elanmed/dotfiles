#!/bin/zsh

# https://github.com/junegunn/fzf#setting-up-shell-integration
# cache fzf shell integration to avoid process substitution on every startup
_fzf_zsh_cache="$HOME/.cache/fzf-zsh.zsh"
if [[ ! -f $_fzf_zsh_cache ]] || [[ fzf -nt $_fzf_zsh_cache ]]; then
  fzf --zsh >"$_fzf_zsh_cache" 2>/dev/null
fi
[[ -f $_fzf_zsh_cache ]] && source "$_fzf_zsh_cache"
unset _fzf_zsh_cache

# plugins
source "$HOME/.dotfiles/zsh/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.dotfiles/zsh/.zsh/base16-shell/base16-shell.plugin.zsh"
source "$HOME/.dotfiles/zsh/.zsh/zsh-z/zsh-z.plugin.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/supercharge.zsh"

base16_tomorrow-night

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743
source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/prompt.zsh"

# auto-export every variable
set -a
source "$HOME/.dotfiles/.env"
set +a

# https://github.com/zsh-users/zsh-syntax-highlighting#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
source "$HOME/.dotfiles/zsh/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
