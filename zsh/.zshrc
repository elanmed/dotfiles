source ~/.dotfiles/helpers.sh

export ZSH="$HOME/.oh-my-zsh"
export PATH=$HOME/.local/bin:$HOME/.deno/bin:/usr/local/sbin:$PATH
export EDITOR="nvim"

# https://stackoverflow.com/a/71271754
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# https://superuser.com/a/613754
XDG_TEMPLATES_DIR="$HOME"
XDG_PUBLICSHARE_DIR="$HOME"
XDG_DOCUMENTS_DIR="$HOME"
XDG_MUSIC_DIR="$HOME"
XDG_PICTURES_DIR="$HOME"
XDG_VIDEOS_DIR="$HOME"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[[ -r $NVM_DIR/bash_completion ]] && \. $NVM_DIR/bash_completion

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"
base16_tomorrow-night

export ZSH_THEME="elan"
export plugins=(z zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
export COMPLETION_WAITING_DOTS="true"
bindkey '^S' autosuggest-execute

if [[ "$(uname -s)" == "Linux" ]]
then
  alias open="xdg-open"
fi
# issues using fzf in a function that's registered with zle -N
bindkey -s '^O' 'FILE="$(fzf)"; if [[ "$FILE" != "" ]]; then; open "$FILE"; fi \n'
bindkey -s '^P' 'FILE="$(fzf)"; if [[ "$FILE" != "" ]]; then; nvim "$FILE"; fi \n'
setopt +o nomatch # https://unix.stackexchange.com/a/310553

alias ezsh="nvim ~/.dotfiles/zsh/.zshrc"
alias evim="cd ~/.dotfiles/neovim/.config/nvim && n.sh ."
alias eterm="nvim ~/.dotfiles/alacritty/.config/alacritty/alacritty.toml"
alias etmux="nvim ~/.dotfiles/tmux/.config/tmux/tmux.conf"

alias gs="git status"
alias gcb="git checkout -b"
alias gc="git checkout"
alias ga="git add -A"
alias gm="git commit -m"
alias gam="git add -A && git commit -m"
alias game="git add -A && git commit --allow-empty-message -m ''"
alias gpsh="git push origin HEAD"
alias gpl="git pull origin master"

alias src="exec zsh"
alias tsrc="tmux source ~/.config/tmux/tmux.conf"

alias e="exit"
alias c="clear"

alias resetnvim="rm -rf ~/.cache/nvim ~/.local/share/nvim ~/.config/coc"
alias vim="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
alias vi="nvim"
alias tm="tmux"

alias man='nvim -c "Man find" -c "wincmd o"'
alias cat="highlight -O ansi --force"

alias n="n.sh"
alias ps="ps.sh"

unalias ls
ls() {
  if [[ "$(find . -maxdepth 1 ! -name '.*' | wc -l)" == 0 ]]
  then 
    command ls -a --color=tty --group-directories-first
  else
    command ls --color=tty --group-directories-first
  fi
}

if [[ "$(uname -s)" == "Linux" ]]
then
  alias pbcopy="xclip"
fi

abspath() { 
  ABS_PATH=$(realpath $1)
  echo "$ABS_PATH" | pbcopy 
  echo "$ABS_PATH"
}
gd () {	nvim -c ":Git difftool -y"}
gif() { 
  ffmpeg -i $1.mov -pix_fmt rgb8 -r 10 $1.gif 
  gifsicle -O3 $1.gif -o $1.gif 
}
search() { grep "$1" ~/.zsh_history | tail -n 20 }
cdl() { h_cecho --error "use 'cl' instead!" }
mkcd () { mkdir $1 && cd $1 }
cl() { cd $1 && ls }
zl() { z $1 && ls }
cb() {
  REF=$(git symbolic-ref HEAD | cut -d'/' -f3)
  echo "$REF" | pbcopy
  echo "$REF"
}
killp() { kill -9 $(lsof -t -i:$1) }
