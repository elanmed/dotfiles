#!/bin/zsh

# perform command substitution and parameter expansion
# in prompt strings each time the prompt is displayed
setopt PROMPT_SUBST

randicon() {
  pokemon_count=151
  first_codepoint=0x100000

  random_offset=$((RANDOM % pokemon_count))
  codepoint=$((first_codepoint + random_offset))
  codepoint_hex=$(printf '%08x' "$codepoint")

  printf "\U${codepoint_hex}"
}

if h_is_podman; then
  _prompt_prefix="%B󰍇%b"
  _prompt_dir_color="green"
else
  _prompt_prefix='$(randicon)'
  _prompt_dir_color="yellow"
fi

prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d '/' -f 3)
  if [[ -n $branch ]]; then
    echo "on %F{magenta} $branch%f"
  fi
}

PROMPT='%B%F{'$_prompt_dir_color'}%~%f%b $(prompt_git_branch)
'$_prompt_prefix'   \$ '
