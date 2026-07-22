#!/bin/zsh

# perform command substitution and parameter expansion
# in prompt strings each time the prompt is displayed
setopt PROMPT_SUBST

prompt_prefix() {
  if h_is_podman; then
    echo "%B%b"
  elif h_is_macos; then
    echo "􀂍 "
  else
    echo "􀀀 "
  fi
}

prompt_dir_color() {
  if h_is_podman; then
    echo "green"
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

_prompt_prefix="$(prompt_prefix)"
_prompt_dir_color="$(prompt_dir_color)"

PROMPT='%B%F{'$_prompt_dir_color'}%~%f%b $(prompt_git_branch)
'$_prompt_prefix' :: '
