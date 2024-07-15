directory() {
   echo "%F{green}%~%{$reset_color%}"
}

ZSH_THEME_GIT_PROMPT_PREFIX=" ["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red} dirty%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{cyan} clean%{$reset_color%}"

NEWLINE=$'\n'
LINE_ABOVE=""
for i in {0..5}; LINE_ABOVE="-$LINE_ABOVE"

PROMPT='${LINE_ABOVE}${NEWLINE}$(directory)$(git_prompt_info)${NEWLINE}🍕:: '

