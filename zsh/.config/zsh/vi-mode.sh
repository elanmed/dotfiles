
bindkey -v
export KEYTIMEOUT=1

if [[ "$(uname -s)" == "Linux" ]]
then
  alias open="xdg-open"
fi

fzf_cmd_prefix='file="$(fzf)"; if [[ "$file" != "" ]]; then;'
fzf_cmd_suffix=' "$file"; fi \n'

# TODO: issues using fzf with a widget registered with zle -N
bindkey -sM vicmd '^P' "i $fzf_cmd_prefix nvim $fzf_cmd_suffix"
bindkey -sM viins '^P' "$fzf_cmd_prefix nvim $fzf_cmd_suffix"
bindkey -sM vicmd '^F' "i $fzf_cmd_prefix open $fzf_cmd_suffix"
bindkey -sM viins '^F' "$fzf_cmd_prefix open $fzf_cmd_suffix"

time_machine_backwards() {
  source ~/Desktop/cd_time_machine/main.sh --backwards
  zle accept-line
}
time_machine_forwards() {
  source ~/Desktop/cd_time_machine/main.sh --forwards
  zle accept-line
}
zle -N time_machine_backwards
zle -N time_machine_forwards

w_exit() {
  exit
}
zle -N w_exit

bindkey -M viins '^E' autosuggest-execute
bindkey -M vicmd '^?' vi-backward-word
bindkey -M vicmd '^?' vi-backward-word
bindkey -M vicmd '^O' time_machine_backwards
bindkey -M viins '^O' time_machine_backwards
bindkey -M vicmd '^I' time_machine_forwards
bindkey -M viins '^I' time_machine_forwards
bindkey -M vicmd '^Y' w_exit
bindkey -M viins '^Y' w_exit
bindkey -M vicmd '^G' clear-screen
bindkey -M viins '^G' clear-screen
bindkey -M viins '^S' expand-or-complete

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

bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
