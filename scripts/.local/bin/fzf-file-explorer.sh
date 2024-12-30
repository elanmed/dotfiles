#!/bin/bash

fzf-file-explorer() {
  local find_cmd="find $dir -name node_modules -prune -o -name .git -prune -o"
  local show_preview_cmd
  show_preview_cmd="[[ $(tput columns) -ge 100 ]] && echo '50%,border-sharp'  || echo 'hidden'"

  local dir="$1"
  if [[ $dir == "" ]]; then
    dir="."
  fi

  temp_file=$(mktemp)
  echo edit >"$temp_file"

  base_header="
CTRL-D to display directories | CTRL-F to display files
CTRL-A to toggle all
CTRL-O to open | CTRL-E to edit"

  # based on https://thevaluable.dev/practical-guide-fzf-example/
  selection=$(
    eval "$find_cmd -type f -print" | fzf --multi --height=100% --border=sharp --layout=reverse-list \
      --preview-window="$(eval "$show_preview_cmd")" \
      --preview="highlight -O ansi --force {}" \
      --prompt='Files > ' \
      --bind="ctrl-o:execute-silent(eval 'echo open > $temp_file')" \
      --bind="ctrl-o:+change-header(
$base_header
<CR> to OPEN)" \
      --bind="ctrl-e:execute-silent(eval 'echo edit > $temp_file')" \
      --bind="ctrl-e:+change-header(
$base_header
<CR> to EDIT)" \
      --bind="ctrl-d:change-prompt(Dirs > )" \
      --bind="ctrl-d:+reload(eval \"$find_cmd -type d -print\")" \
      --bind="ctrl-d:+change-preview(tree -C {})" \
      --bind="ctrl-d:+refresh-preview" \
      --bind="ctrl-f:change-prompt(Files > )" \
      --bind="ctrl-f:+reload(eval \"$find_cmd -type f -print\")" \
      --bind="ctrl-f:+change-preview(highlight -O ansi --force {})" \
      --bind="ctrl-f:+refresh-preview" \
      --bind="ctrl-a:toggle-all" \
      --header "
$base_header
<CR> to EDIT"
  )

  read -r action <"$temp_file"
  trap 'rm -f $temp_file' 0 2 3 15

  if [[ $selection == "" ]]; then
    return
  fi

  if [ -d "$selection" ]; then
    if [[ $action == open ]]; then
      echo -n "open $selection"
    else
      echo -n "cd $selection"
    fi
    return
  fi

  if [[ $action == open ]]; then
    echo -n "open $selection"
  else
    echo -n "nvim $selection"
  fi
}
