#!/bin/zsh

bindkey -v
export KEYTIMEOUT=1

# by default, control+s will pause input to the terminal until 
# control+q is used to resume input. ssty -ixon disables 
# pausing/resuming
stty -ixon

# bindkey -M viins '^E' autosuggest-execute
bindkey -M viins '^E' end-of-line
bindkey -M vicmd '^E' end-of-line
bindkey -M viins '^A' beginning-of-line 
bindkey -M vicmd '^A' beginning-of-line 
bindkey -M viins '^S' expand-or-complete
bindkey -M menuselect '^[' undo # cancel menuselect in vim mode
bindkey -M vicmd '^?' vi-backward-word
bindkey -M vicmd '^G' clear-screen
bindkey -M viins '^G' clear-screen
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

# remap fzf default keymapping
bindkey -rM vicmd '^T'
bindkey -rM viins '^T'

fzf-file-execute-widget() {
  fzf_res="$(__fzf_select)"
  LBUFFER="${LBUFFER}$fzf_res"
  if [[ -z "$fzf_res" ]] 
  then 
    zle reset-prompt
    return 1
  fi
  local ret=$?
  zle reset-prompt
  zle accept-line
  return $ret
}
zle -N fzf-file-execute-widget
bindkey M vicmd '^P' fzf-file-execute-widget
bindkey M viins '^P' fzf-file-execute-widget

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
bindkey -M vicmd '^O' push-backwards
bindkey -M viins '^O' push-backwards
bindkey -M vicmd '^I' pop-forwards
bindkey -M viins '^I' pop-forwards

exit-widget() {
  exit
}
zle -N exit-widget
bindkey -M vicmd '^Y' exit-widget
bindkey -M viins '^Y' exit-widget

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

vi-yank-clipboard() {
  zle vi-yank
  echo "$CUTBUFFER" | copy 
}
zle -N vi-yank-clipboard
bindkey -M vicmd y vi-yank-clipboard

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
