#!/bin/zsh
source "$HOME/.dotfiles/_helpers.sh"

export BUN_INSTALL="$HOME/.bun"

export PATH="/usr/bin:$PATH"
export PATH="/usr/sbin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/node_modules/.bin:$PATH"
export PATH="$HOME/.dotfiles/neovim/.config/nvim/language_servers/lua-language-server-release/bin:$PATH"

# https://tech.serhatteker.com/post/2019-12/remove-duplicates-in-path-zsh/
typeset -U path

if [[ -f "$HOME/.dotfiles/.desktop_env" ]] && [[ "$(cat "$HOME/.dotfiles/.desktop_env")" == "headless" ]]; then
  export NVIM_CMD="nvim -u $HOME/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi

if infocmp wezterm &>/dev/null; then
  export TERM="wezterm"
fi
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

# Add Node to PATH without loading nvm.
# Respect nvm's default alias if it points to an installed version;
# otherwise fall back to the latest installed version.
# nvm itself is lazy-loaded on first use of the `nvm` command.
local nvm_active
if [[ -f "$NVM_DIR/alias/default" ]]; then
  local default_version
  default_version=$(command cat "$NVM_DIR/alias/default" 2>/dev/null)
  for v in "$default_version" "v$default_version"; do
    [[ -d "$NVM_DIR/versions/node/$v/bin" ]] && nvm_active="$NVM_DIR/versions/node/$v/bin"
  done
fi

if [[ -z $nvm_active || ! -d $nvm_active ]]; then
  nvm_active=$(command ls -d "$NVM_DIR/versions/node"/*/bin 2>/dev/null | command sort -V | command tail -n1)
fi

if [[ -n $nvm_active && -d $nvm_active ]]; then
  export PATH="$nvm_active:$PATH"
fi

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#969896"
