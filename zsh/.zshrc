export PATH=$HOME/.local/bin:$HOME/.deno/bin:/usr/local/sbin:$PATH

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="elan"
# https://stackoverflow.com/a/71271754
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
export plugins=(z zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

export EDITOR="nvim"
# https://superuser.com/a/71593
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=' -R '
# https://superuser.com/a/613754
export XDG_TEMPLATES_DIR="$HOME"
export XDG_PUBLICSHARE_DIR="$HOME"
export XDG_DOCUMENTS_DIR="$HOME"
export XDG_MUSIC_DIR="$HOME"
export XDG_PICTURES_DIR="$HOME"
export XDG_VIDEOS_DIR="$HOME"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion
export BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"
base16_tomorrow-night

# fzf aliases
if [[ "$(uname -s)" == "Linux" ]]
then
  alias open="xdg-open"
fi
# TODO: issues using fzf in a function that's registered with zle -N
bindkey -s '^O' 'file_to_open="$(fzf)"; if [[ "$file_to_open" != "" ]]; then; open "$file_to_open"; fi \n'
bindkey -s '^P' 'file_to_edit="$(fzf)"; if [[ "$file_to_edit" != "" ]]; then; nvim "$file_to_edit"; fi \n'
# https://unix.stackexchange.com/a/310553
setopt +o nomatch 

# autosuggest
export COMPLETION_WAITING_DOTS="true"
bindkey '^S' autosuggest-execute

# editing
alias ezsh="nvim ~/.dotfiles/zsh/.zshrc"
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

mkcd() { mkdir $1 && cd $1 }
cl() { cd $1 && ls }
zl() { z $1 && ls }
abspath() { 
  local abs_path=$(realpath $1)
  echo "$abs_path" | xclip -selection clipboard
  echo "$abs_path"
}
gd() {	nvim -c ":Git difftool -y"}
gif() { 
  ffmpeg -i $1.mov -pix_fmt rgb8 -r 10 $1.gif 
  gifsicle -O3 $1.gif -o $1.gif 
}
search() { grep "$1" ~/.zsh_history | tail -n 20 }
cb() {
  local branch=$(git symbolic-ref HEAD | cut -d'/' -f3)
  echo "$branch" | xclip -selection clipboard
}
killp() { kill -9 $(lsof -t -i:$1) }
