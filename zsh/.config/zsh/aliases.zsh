#!/bin/zsh

source ~/.dotfiles/helpers.sh

# editing
alias ezsh="builtin cd ~/.dotfiles/zsh/.config/zsh && n.sh ."
alias eterm="$NVIM_CMD ~/.dotfiles/wezterm/.config/wezterm/wezterm.lua"
alias etmux="$NVIM_CMD ~/.dotfiles/tmux/.config/tmux/tmux.conf"
alias edot="builtin cd ~/.dotfiles && n.sh ."
alias evim="builtin cd ~/.dotfiles/neovim/.config/nvim && n.sh ."
alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim"
# git
alias gs="nvim -c ':Gedit :'"
alias gcb="git checkout -b"
alias gc="git checkout"
alias ga="git add -A"
alias gm="git commit -m"
alias gam="git add -A && git commit -m"
alias game="git add -A && git commit --allow-empty-message -m ''"
alias gps="git push origin HEAD"
alias gpl="git pull origin master"
# shorter commands
alias e="exit"
alias c="clear"
alias v="$NVIM_CMD"
alias tm="tmux"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
lsa_cmd="command ls -a --color=tty"
h_is_linux && lsa_cmd+=" --group-directories-first"
alias lsa="$lsa_cmd"
# scripts
alias n="n.sh"
alias zf="source fzf-file-explorer.sh"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
h_is_linux && alias open="flatpak-xdg-open"
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
