#!/bin/zsh
#
source ~/.dotfiles/helpers.sh

export PATH="/usr/bin:/usr/sbin:/usr/local/sbin:$HOME/.local/bin:$HOME/.deno/bin:$PATH"
# https://tech.serhatteker.com/post/2019-12/remove-duplicates-in-path-zsh/
typeset -U path

if h_is_server; then
  export NVIM_CMD="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi
git config --global core.editor "$NVIM_CMD"

export EDITOR="$NVIM_CMD"
export VISUAL="$NVIM_CMD"
export MANPAGER="$NVIM_CMD +Man!"
export TERMINAL="alacritty"

# https://superuser.com/a/71593
source_highlight_path="/usr"
! h_is_linux && source_highlight_path+="/local"
source_highlight_path+="/bin/src-hilite-lesspipe.sh"
export LESSOPEN="| $source_highlight_path %s"
export LESS=" -R "

if h_is_linux
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

if h_is_command_valid "base16_tomorrow-night" 
then 
  base16_tomorrow-night
fi

