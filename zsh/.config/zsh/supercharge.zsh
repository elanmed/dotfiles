# modified from:
# https://github.com/zap-zsh/supercharge/blob/e76f4e82d443706c2d9c8ab8e9633facbcdec768/supercharge.plugin.zsh

# completions
autoload -Uz compinit
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zmodload zsh/complist
_comp_options+=(globdots) # Include hidden files.
for dump in "$HOME/.zcompdump"(N.mh+24); do
  compinit
done
compinit -C

unsetopt BEEP
setopt AUTO_CD
setopt GLOB_DOTS
setopt MENU_COMPLETE
setopt EXTENDED_GLOB
setopt APPEND_HISTORY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000

# Colors
autoload -Uz colors && colors

# bindings
bindkey '^H' backward-kill-word # Ctrl + Backspace to delete a whole word.
