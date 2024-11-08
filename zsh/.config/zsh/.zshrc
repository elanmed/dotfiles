# Don't use a .zshenv!
# https://github.com/christoomey/vim-tmux-navigator/issues/72#issuecomment-103566743

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="spaceship"
plugins=(z zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

source ~/.dotfiles/zsh/.config/zsh/variables.sh
source ~/.dotfiles/zsh/.config/zsh/aliases.sh
source ~/.dotfiles/zsh/.config/zsh/fns.sh
source ~/.dotfiles/zsh/.config/zsh/vi-mode.sh

[[ "$TERM_PROGRAM" != tmux ]] && tmux
