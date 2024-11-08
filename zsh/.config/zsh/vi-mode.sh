bindkey -v
export KEYTIMEOUT=1

bindkey -M viins '^E' autosuggest-execute
bindkey -M vicmd '^?' vi-backward-word
bindkey -M vicmd '^?' vi-backward-word
bindkey -M vicmd '^O' push_backwards
bindkey -M viins '^O' push_backwards
bindkey -M vicmd '^I' pop_forwards
bindkey -M viins '^I' pop_forwards
bindkey -M vicmd '^G' clear-screen
bindkey -M viins '^G' clear-screen
bindkey -M viins '^S' expand-or-complete
bindkey -M vicmd 'yy' expand-or-complete
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

[[ "$(uname -s)" == "Linux" ]] && alias open="xdg-open"
fzf_cmd_prefix='file="$(fzf)"; if [[ "$file" != "" ]]; then;'
fzf_cmd_suffix=' "$file"; fi \n'
# TODO: issues using fzf with a widget registered with zle -N
bindkey -sM vicmd '^P' "i $fzf_cmd_prefix nvim $fzf_cmd_suffix"
bindkey -sM viins '^P' "$fzf_cmd_prefix nvim $fzf_cmd_suffix"
bindkey -sM vicmd '^F' "i $fzf_cmd_prefix open $fzf_cmd_suffix"
bindkey -sM viins '^F' "$fzf_cmd_prefix open $fzf_cmd_suffix"

setopt noautopushd
push_backwards() {
  pushd .. > /dev/null 2>&1
}
pop_forwards() {
  popd > /dev/null 2>&1
  if [[ $? -eq 1 ]] 
  then 
    echo
    ls
    echo -en "${red}Can't move forwards${no_color}"
    zle accept-line
  fi
}
zle -N push_backwards
zle -N pop_forwards

exit_widget() {
  exit
}
zle -N exit_widget
bindkey -M vicmd '^Y' exit_widget
bindkey -M viins '^Y' exit_widget

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

vi-yank-clipboard() {
  zle vi-yank
  echo "$CUTBUFFER" | copy 
}
zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-clipboard
bindkey -M visual 'y' vi-yank-clipboard

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
