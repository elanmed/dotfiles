# editing
alias ezsh="cd ~/.dotfiles/zsh/.config/zsh && n.sh ."
alias eterm="nvim ~/.dotfiles/alacritty/.config/alacritty/alacritty.toml"
alias etmux="nvim ~/.dotfiles/tmux/.config/tmux/tmux.conf"
alias edot="nvim ~/.dotfiles && n.sh"
alias evim="cd ~/.dotfiles/neovim/.config/nvim && n.sh ."
alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim ~/.config/coc"
# sourcing
alias src="exec zsh"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"
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
lsa_cmd="command ls -a --color=tty"
[[ "$(uname -s)" == "Linux" ]] && lsa_cmd+=" --group-directories-first"
alias lsa="$lsa_cmd"
alias yt="yt-dlp --sub-langs all --write-subs $1"
# scripts
alias n="n.sh"
alias ps="ps.sh"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
alias cat="highlight -O ansi --force"
# TODO: merge the two
man_fn(){ nvim -c "Man $1" -c "wincmd o" }
alias man="man_fn"
