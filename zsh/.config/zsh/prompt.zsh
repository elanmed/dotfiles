#!/bin/zsh

# perform command substitution and parameter expansion
# in prompt strings each time the prompt is displayed
setopt PROMPT_SUBST

if h_is_podman; then
  _prompt_prefix="%B󰍇%b"
  _prompt_dir_color="green"
else
  _prompt_prefix="􀀀 "
  _prompt_dir_color="yellow"
fi

prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d '/' -f 3)
  if [[ -n $branch ]]; then
    echo "on %F{magenta} $branch%f"
  fi
}

PROMPT='%B%F{'$_prompt_dir_color'}%~%f%b $(prompt_git_branch)
'$_prompt_prefix' :: '
