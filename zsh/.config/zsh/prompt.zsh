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

if h_is_macos; then
  _battery_percent=""
else
  percent="$(cat /sys/class/power_supply/BAT*/capacity)"
  icon=""
  if [[ -z $percent ]]; then
    icon=""
  elif [[ $percent -gt 75 ]]; then
    icon="󱊣"
  elif [[ $percent -gt 50 ]]; then
    icon="󱊢"
  elif [[ $percent -gt 25 ]]; then
    icon="󱊡"
  else
    icon="󰂎"
  fi

  _battery_percent="at %F{green}$icon $(cat /sys/class/power_supply/BAT*/capacity)%%%f"
fi

prompt_git_branch() {
  local branch
  branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d '/' -f 3)
  if [[ -n $branch ]]; then
    echo "on %F{magenta} $branch%f"
  fi
}

PROMPT='%B%F{'$_prompt_dir_color'}%~%f%b $(prompt_git_branch) '$_battery_percent'
'$_prompt_prefix'  :: '
