#!/bin/zsh
source ~/.dotfiles/helpers.sh

# perform command substitution and parameter expansion
# in prompt strings each time the prompt is displayed
setopt PROMPT_SUBST

prompt_prefix() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    if h_is_toolbox; then
      echo "%B%b"
    elif h_is_podman; then
      echo "%B%b"
    else
      echo "%B%b"
    fi
  else
    echo ""
  fi
}

prompt_dir_color() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    if h_is_toolbox; then
      echo "yellow"
    elif h_is_podman; then
      echo "green"
    else
      echo "red"
    fi
  else
    echo "yellow"
  fi
}

prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d '/' -f 3)
  if [[ -n $branch ]]; then
    echo "on %F{magenta} $branch%f"
  fi
}

PROMPT='%B%F{$(prompt_dir_color)}%~%f%b $(prompt_git_branch)
$(prompt_prefix) :: '
