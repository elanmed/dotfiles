#!/bin/zsh

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

if grep -q '^0$' "$HOME/.dotfiles/.is_server" >/dev/null 2>&1; then
  export NVIM_CMD="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi

export EDITOR="$NVIM_CMD"
export VISUAL="$NVIM_CMD"
export MANPAGER="$NVIM_CMD +Man!"
export BAT_THEME="ansi"

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

# https://github.com/nvm-sh/nvm#git-install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#969896"
