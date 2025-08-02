#!/bin/zsh

source ~/.dotfiles/helpers.sh

# editing
alias ezsh="builtin cd ~/.dotfiles/zsh/.config/zsh && v ."
alias eterm="$NVIM_CMD ~/.dotfiles/wezterm/.config/wezterm/wezterm.lua"
alias etmux="$NVIM_CMD ~/.dotfiles/tmux/.config/tmux/tmux.conf"
alias edot="builtin cd ~/.dotfiles && v ."
alias evim="builtin cd ~/.dotfiles/neovim/.config/nvim && v ."
alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim"
# git
alias gs="git status"
alias ghb="git checkout -b"
alias gh="git checkout"
alias ga="git add -A"
alias gm="git commit -m"
alias gam="git add -A && git commit -m"
alias game="git add -A && git commit --allow-empty-message -m ''"
alias gps="git push origin HEAD"
alias gpl="git pull origin master"
alias lg="lazygit"
# shorter commands
alias e="exit"
alias c="clear"
alias v="$NVIM_CMD"
alias f="toolbox enter fedora"
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
