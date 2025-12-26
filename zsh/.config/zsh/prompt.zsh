prompt_prefix() {
  if h_is_linux && ! h_is_toolbx; then
    echo "%BHOST%b"
  else
    echo "󰮤"
  fi
}

prompt_dir_color() {
  if h_is_linux && ! h_is_toolbx; then
    echo "red"
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
