#!/bin/zsh

# editing
alias ezsh="builtin cd ~/.dotfiles/zsh/.config/zsh && $NVIM_CMD"
alias eterm="builtin cd ~/.dotfiles && $NVIM_CMD ~/.dotfiles/wezterm/.config/wezterm/wezterm.lua"
alias etmux="builtin cd ~/.dotfiles && $NVIM_CMD ~/.dotfiles/tmux/.config/tmux/tmux.conf"
alias edot="builtin cd ~/.dotfiles && $NVIM_CMD"
alias evim="builtin cd ~/.dotfiles/neovim/.config/nvim && $NVIM_CMD"
alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim"
# git
alias gs="git status"
alias lg="lazygit"
# shorter commands
alias e="exit"
alias c="clear"
alias v="$NVIM_CMD"
alias f="toolbox enter fedora-toolbox-43"
alias tm="tmux"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
lsa_cmd="command ls -a --color=tty"
[[ "$(uname -s)" == "Linux" ]] && lsa_cmd+=" --group-directories-first"
alias lsa="$lsa_cmd"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
[[ "$(uname -s)" == "Linux" ]] && alias open="flatpak-xdg-open"
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
