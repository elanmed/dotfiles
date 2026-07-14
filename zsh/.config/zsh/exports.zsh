#!/bin/zsh
source ~/.dotfiles/helpers.sh

export BUN_INSTALL="$HOME/.bun"

export PATH="/usr/bin:$PATH"
export PATH="/usr/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.dotfiles/zsh/.zsh/bats-core/bin:$PATH"
export PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/node_modules/.bin:$PATH"
export PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release/bin:$PATH"

# https://tech.serhatteker.com/post/2019-12/remove-duplicates-in-path-zsh/
typeset -U path

if [[ -f "$HOME/.dotfiles/.desktop_env" ]] && [[ "$(cat "$HOME/.dotfiles/.desktop_env")" == "headless" ]]; then
  export NVIM_CMD="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi

export TERM="wezterm"
export EDITOR="$NVIM_CMD"
export VISUAL="$NVIM_CMD"
export MANPAGER="$NVIM_CMD +Man!"
export BAT_THEME="ansi"

if [[ "$(uname -s)" == "Linux" ]]; then
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
nvm use node >/dev/null 2>&1

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#969896"
