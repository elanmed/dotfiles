#!/bin/zsh

source "$HOME/.dotfiles/helpers.sh"

# https://spaceship-prompt.sh/config/intro/
SPACESHIP_PROMPT_ORDER=(
  dir 
  git 
  exit_code 
  exec_time 
  char
)
dir_color="yellow"
if h_is_linux && ! h_is_toolbx; then
  dir_color="red"
fi
SPACESHIP_DIR_COLOR="$dir_color"
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_DIR_TRUNC=10

SPACESHIP_GIT_STATUS_STASHED=""

SPACESHIP_EXIT_CODE_SYMBOL=""
SPACESHIP_EXIT_CODE_PREFIX="status code: "
SPACESHIP_EXIT_CODE_SHOW=true

prefix="🚀"
if h_is_linux && ! h_is_toolbx; then
  prefix="HOST"
fi

SPACESHIP_CHAR_SYMBOL=" "
SPACESHIP_CHAR_SUFFIX="\n$prefix :: "

SPACESHIP_PROMPT_ADD_NEWLINE=false
