#!/bin/zsh

source ~/.dotfiles/helpers.sh

PATH="/usr/bin:$PATH"
PATH="/usr/sbin:$PATH"
PATH="/usr/local/sbin:$PATH"
PATH="$HOME/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.deno/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/node_modules/.bin:$PATH"
export PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release/bin:$PATH"

# https://tech.serhatteker.com/post/2019-12/remove-duplicates-in-path-zsh/
typeset -U path

if h_is_server; then
  export NVIM_CMD="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi

export EDITOR="$NVIM_CMD"
export VISUAL="$NVIM_CMD"
export MANPAGER="$NVIM_CMD +Man!"
export BAT_THEME="ansi"
export SNACKS_WEZTERM=true
export TERM_PROGRAM="WezTerm"

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

# https://github.com/nvm-sh/nvm#git-install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# https://github.com/chriskempson/base16-shell#bashzsh
export BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"

if h_is_command_valid "base16_tomorrow-night" 
then 
  base16_tomorrow-night
fi

