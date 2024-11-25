#!/bin/zsh

# editing
alias ezsh="builtin cd ~/.dotfiles/zsh/.config/zsh && n.sh ."
alias eterm="nvim ~/.dotfiles/alacritty/.config/alacritty/alacritty.toml"
alias etmux="nvim ~/.dotfiles/tmux/.config/tmux/tmux.conf"
alias edot="builtin cd ~/.dotfiles && n.sh ."
alias evim="builtin cd ~/.dotfiles/neovim/.config/nvim && n.sh ."
alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim ~/.config/coc"
# git
alias gs="git status"
alias gcb="git checkout -b"
alias gc="git checkout"
alias ga="git add -A"
alias gm="git commit -m"
alias gam="git add -A && git commit -m"
alias game="git add -A && git commit --allow-empty-message -m ''"
alias gpsh="git push origin HEAD"
alias gpl="git pull origin master"
# shorter commands
alias e="exit"
alias vi="nvim"
alias tm="tmux"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
lsa_cmd="command ls -a --color=tty"
[[ "$(uname -s)" == "Linux" ]] && lsa_cmd+=" --group-directories-first"
alias lsa="$lsa_cmd"
alias yt="yt-dlp --sub-langs all --write-subs $1"
# scripts
alias n="n.sh"
alias ps="ps.sh"
alias recipes="recipes-gui-run.sh"
alias reddit="redlib-run.sh"
[[ "$(uname -s)" == "Linux" ]] && alias open="xdg-open"
alias zf="source fzf-file-explorer.sh"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
alias cat="highlight -O ansi --force"
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
