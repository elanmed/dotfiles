#!/bin/zsh

bindkey -v
export KEYTIMEOUT=1

# by default, control+s will pause input to the terminal until 
# control+q is used to resume input. ssty -ixon disables 
# pausing/resuming
stty -ixon

bindkey -M viins '^e' autosuggest-execute
bindkey -M vicmd '^e' end-of-line
bindkey -M viins '^a' beginning-of-line 
bindkey -M vicmd '^a' beginning-of-line 
bindkey -M menuselect '^[' undo # cancel menuselect in vim mode
bindkey -M vicmd '^?' vi-backward-word # backspace
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

export FZF_CTRL_R_OPTS="--layout=reverse"

fzf-tab-complete-execute() {
  LBUFFER_BEFORE="${LBUFFER}"
  fzf-tab-complete
  [[ "${LBUFFER}" == "${LBUFFER_BEFORE}" ]] && return
  zle accept-line
}
zle -N fzf-tab-complete-execute
bindkey -M viins '^x' fzf-tab-complete-execute

fzf-file-explorer-widget() {
  LBUFFER_BEFORE="${LBUFFER}"
  local dir="$(pwd)"
  source ~/.dotfiles/scripts/.local/bin/fzf-file-explorer.sh
  LBUFFER="$(fzf-file-explorer $dir)"
  [[ "${LBUFFER}" == "${LBUFFER_BEFORE}" ]] && return
  zle accept-line
}
zle -N fzf-file-explorer-widget
bindkey -M vicmd '^f' fzf-file-explorer-widget
bindkey -M viins '^f' fzf-file-explorer-widget

setopt noautopushd
push-backwards() {
  pushd .. > /dev/null 2>&1
}
pop-forwards() {
  popd > /dev/null 2>&1
  if [[ $? -eq 1 ]] 
  then 
    echo
    ls
    echo -en "${red}Can't move forwards${no_color}"
    zle accept-line
  fi
}
zle -N push-backwards
zle -N pop-forwards
bindkey -M vicmd '^o' push-backwards
bindkey -M viins '^o' push-backwards
bindkey -M vicmd '^i' pop-forwards
bindkey -M viins '^i' pop-forwards

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^t' edit-command-line
bindkey -M viins '^t' edit-command-line

vi-yank-clipboard() {
  zle vi-yank
  echo "$CUTBUFFER" | copy 
}
zle -N vi-yank-clipboard
bindkey -M vicmd y vi-yank-clipboard

# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
fg-widget () {
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
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
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
