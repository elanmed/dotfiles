#!/bin/zsh

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

if [[ -f "$HOME/.dotfiles/.desktop_env" ]] && [[ "$(cat "$HOME/.dotfiles/.desktop_env")" == "server" ]]; then
  export NVIM_CMD="nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua"
else
  export NVIM_CMD="nvim"
fi

export TERM="wezterm"
export EDITOR="$NVIM_CMD"
export VISUAL="$NVIM_CMD"
export MANPAGER="$NVIM_CMD +Man!"
export BAT_THEME="ansi"

export AGENT_JS_EDIT='printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" "$(echo -n "false" | base64)"
nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua -c "normal! G$" -c startinsert! __FILE__
printf "\033]1337;SetUserVar=%s=%s\007" "AGENT_JS_ACTIVE" "$(echo -n "true" | base64)"'

export AGENT_JS_HISTORY='nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua -c "normal! G$" __FILE__'

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

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#969896"
