#!/bin/zsh

source "$HOME/.dotfiles/helpers.sh"

plug "zap-zsh/supercharge"
plug "Aloxaf/fzf-tab"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "agkozak/zsh-z"

# https://github.com/Aloxaf/fzf-tab/tree/master#configure
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # filename coloring
zstyle ':completion:*:descriptions' format '[%d]' # labeled, colored descriptions

# https://github.com/junegunn/fzf#setting-up-shell-integration
if h_is_linux && ! h_is_toolbx; then 
  source <(fzf --zsh 2>/dev/null)
else
  source <(fzf --zsh)
fi

# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743
source "$HOME/.dotfiles/zsh/.config/zsh/exports.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/aliases.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/fns.zsh"
source "$HOME/.dotfiles/zsh/.config/zsh/vi-mode.zsh"
source "$HOME/.zsh/spaceship/spaceship.zsh"

if h_is_command_valid "tmux" 
then 
  if [[ "$TERM_PROGRAM" != tmux ]]; then; tmux; fi
fi

