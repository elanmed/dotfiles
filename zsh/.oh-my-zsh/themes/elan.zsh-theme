ORANGE="$FG[016]"
RED="$FG[001]"
MAGENTA="$FG[005]"
CYAN="$FG[006]"

directory() {
   echo "${CYAN}%~%{$reset_color%}"
}

ZSH_THEME_GIT_PROMPT_PREFIX=" ["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_DIRTY="${RED} dirty%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="${MAGENTA} clean%{$reset_color%}"

NEWLINE=$'\n'
LINE_ABOVE=""
for i in {0..5}; LINE_ABOVE="-$LINE_ABOVE"

PROMPT='$(directory)$(git_prompt_info)${NEWLINE}🍕:: '
