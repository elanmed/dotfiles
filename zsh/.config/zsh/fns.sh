 
if [[ "$(uname -s)" == "Linux" ]]
then
  alias lsa="command ls -a --color=tty --group-directories-first"
else
  alias lsa="command ls -a --color=tty"
fi

# https://unix.stackexchange.com/a/310553
setopt +o nomatch 
unalias ls
ls() {
  if [[ "$(find . -maxdepth 1 ! -name '.*' | wc -l)" == 0 ]]
  then 
    lsa "$@"
  else
    ls_cmd="command ls --color=tty"
    [[ "$(uname -s)" == "Linux" ]] && ls_cmd+=" --group-directories-first"
    ls_cmd+=" "$@""
    eval "$ls_cmd"
  fi
}
copy() {
  if [[ "$(uname -s)" == "Linux" ]] then 
    xclip -selection keyboard "$1"
  else
    pbcopy "$1"
  fi
}
mkcd() { mkdir "$1" && cd "$1" }
cl() { cd "$1" && ls }
zl() { z "$1" && ls }
abspath() { 
  local abs_path=$(realpath "$1")
  echo "$abs_path" | copy
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
  echo "$branch" | copy
}
killp() { kill -9 $(lsof -t -i:$1) }
c() {
  source ~/Desktop/cd_time_machine/main.sh --change_dir="$1"
  ls
}
