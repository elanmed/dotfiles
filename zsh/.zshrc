# plugins
source "$ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH/zsh-z/zsh-z.plugin.zsh"
source "$ZSH/spaceship/spaceship.zsh"

# https://dev.to/hbenvenutti/using-zsh-without-omz-4gch
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
# https://unix.stackexchange.com/a/310553
setopt +o nomatch 

# fzf aliases
if [[ "$(uname -s)" == "Linux" ]]
then
  alias open="xdg-open"
fi
# TODO: issues using fzf in a function that's registered with zle -N
bindkey -s '^O' 'file_to_open="$(fzf)"; if [[ "$file_to_open" != "" ]]; then; open "$file_to_open"; fi \n'
bindkey -s '^P' 'file_to_edit="$(fzf)"; if [[ "$file_to_edit" != "" ]]; then; nvim "$file_to_edit"; fi \n'

# autosuggest
bindkey '^s' autosuggest-execute
# https://stackoverflow.com/a/6951487
stty -ixon -ixoff

# editing
alias ezsh="cd ~/.dotfiles/zsh && n.sh ."
alias eterm="nvim ~/.dotfiles/alacritty/.config/alacritty/alacritty.toml"
alias etmux="nvim ~/.dotfiles/tmux/.config/tmux/tmux.conf"
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
alias c="clear"
alias vi="nvim"
alias tm="tmux"
alias lsa="command ls -a --color=tty --group-directories-first"
# scripts
alias n="n.sh"
alias ps="ps.sh"
# overrides
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
alias man='nvim -c "Man find" -c "wincmd o"'
alias cat="highlight -O ansi --force"
unalias ls
ls() {
  if [[ "$(find . -maxdepth 1 ! -name '.*' | wc -l)" == 0 ]]
  then 
    lsa "$@"
  else
    command ls --color=tty --group-directories-first "$@"
  fi
}

mkcd() { mkdir "$1" && cd "$1" }
cl() { cd "$1" && ls }
zl() { z "$1" && ls }
abspath() { 
  local abs_path=$(realpath "$1")
  echo "$abs_path" | xclip -selection clipboard
  echo "$abs_path"
}
gd() { nvim -c ":Git difftool -y"}
gif() { 
  ffmpeg -i "$1.mov" -pix_fmt rgb8 -r 10 "$1.gif"
  gifsicle -O3 "$1.gif" -o "$1.gif"
}
search() { grep "$1" "$ZSH/.zsh_history" | tail -n 20 }
cb() {
  local branch=$(git symbolic-ref HEAD | cut -d'/' -f3)
  echo "$branch" | xclip -selection clipboard
}
killp() { kill -9 $(lsof -t -i:$1) }
