# perform command substitution and parameter expansion
# in prompt strings each time the prompt is displayed
setopt PROMPT_SUBST

is_toolbox() {
  if [[ "$(hostname)" == "toolbx" ]] || [[ "$(hostname)" == "toolbox" ]]; then
    return 0
  else
    return 1
  fi
}

is_podman() {
  if [[ -f /run/.containerenv ]]; then
    return 0
  else
    return 1
  fi
}

prompt_prefix() {
  if [[ "$(uname -s)" == "Linux" ]]; then
    if is_toolbox; then
      echo "%B%b"
    elif is_podman; then
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
    if is_toolbox; then
      echo "yellow"
    elif is_podman; then
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
  branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
  if [[ -n $branch ]]; then
    echo "on %F{magenta} $branch%f"
  fi
}

PROMPT='%B%F{$(prompt_dir_color)}%~%f%b $(prompt_git_branch)
$(prompt_prefix) :: '
