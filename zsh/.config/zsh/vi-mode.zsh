#!/bin/zsh

bindkey -v
export KEYTIMEOUT=1

bindkey -M viins '^y' autosuggest-execute
bindkey -M menuselect '^[' undo # cancel menuselect in vim mode
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

bindkey -M viins '^h' backward-char
bindkey -M viins '^l' forward-char
bindkey -M viins '^w' forward-word
bindkey -M viins '^b' backward-word
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^e' end-of-line

# default
FZF_CTRL_R_OPTS="--layout=reverse"
bindkey -M vicmd '^r' fzf-history-widget
bindkey -M viins '^r' fzf-history-widget
bindkey -M vicmd '^t' fzf-file-widget
bindkey -M viins '^t' fzf-file-widget
# custom
bindkey -M vicmd '^x' fzf-completion
bindkey -M viins '^x' fzf-completion
bindkey -M viins '^n' menu-complete
bindkey -M viins '^p' reverse-menu-complete

bindkey -M vicmd '^f' fzf-cd-widget
bindkey -M viins '^f' fzf-cd-widget

setopt noautopushd
push-backwards() {
  pushd .. >/dev/null 2>&1
  zle reset-prompt
}
pop-forwards() {
  popd >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    echo
    ls
    echo -en "${red}Can't move forwards${no_color}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N push-backwards
zle -N pop-forwards
bindkey -M vicmd '^o' push-backwards
bindkey -M viins '^o' push-backwards
bindkey -M vicmd '^i' pop-forwards
bindkey -M viins '^i' pop-forwards

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^g' edit-command-line
bindkey -M viins '^g' edit-command-line

vi-yank-clipboard() {
  zle vi-yank
  echo "$CUTBUFFER" | copy
}
zle -N vi-yank-clipboard
bindkey -M vicmd y vi-yank-clipboard

# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
fg-widget() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fg-widget
bindkey '^z' fg-widget

# https://thevaluable.dev/zsh-install-configure-mouseless/
cursor_mode() {
  cursor_block='\e[2 q'
  cursor_beam='\e[6 q'
  function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
      [[ $1 == 'block' ]]; then
      echo -ne $cursor_block
    elif [[ ${KEYMAP} == main ]] ||
      [[ ${KEYMAP} == viins ]] ||
      [[ ${KEYMAP} == '' ]] ||
      [[ $1 == 'beam' ]]; then
      echo -ne $cursor_beam
    fi
  }
  zle-line-init() {
    echo -ne $cursor_beam
  }
  zle -N zle-keymap-select
  zle -N zle-line-init
}
cursor_mode
