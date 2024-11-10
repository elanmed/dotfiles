#!/bin/zsh

export PATH="$HOME/.local/bin:$HOME/.deno/bin:/usr/local/sbin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'
export TERMINAL="alacritty"

# https://superuser.com/a/71593
source_highlight_path="/usr"
[[ "$(uname -s)" != "Linux" ]] && source_highlight_path+="/local"
source_highlight_path+="/bin/src-hilite-lesspipe.sh"
export LESSOPEN="| $source_highlight_path %s"
export LESS=" -R "

if [[ "$(uname -s)" == "Linux" ]]
then
  # https://superuser.com/a/613754
  export XDG_TEMPLATES_DIR="$HOME"
  export XDG_PUBLICSHARE_DIR="$HOME"
  export XDG_DOCUMENTS_DIR="$HOME"
  export XDG_MUSIC_DIR="$HOME"
  export XDG_PICTURES_DIR="$HOME"
  export XDG_VIDEOS_DIR="$HOME"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"
base16_tomorrow-night
