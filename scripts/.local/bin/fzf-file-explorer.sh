#!/bin/bash

fzf-file-explorer() {
  dir="$1"
  if [[ $dir == "" ]]; then
    dir="."
  fi

  find_base=(find "$dir" -name node_modules -prune -o -name .git -prune -o)
  find_files_cmd="${find_base[*]} -type f -print"
  find_dirs_cmd="${find_base[*]} -type d -print"

  show_preview() {
    if [[ $(tput cols) -ge 100 ]]; then
      echo '50%,border-sharp'
    else
      echo 'hidden'
    fi
  }

  temp_file="$(mktemp)"
  echo "edit" >"$temp_file"

  base_header="
CTRL-D to display directories | CTRL-F to display files
CTRL-A to toggle all
CTRL-O to open | CTRL-E to edit"

  # based on https://thevaluable.dev/practical-guide-fzf-example/
  selection=$(
    eval "$find_files_cmd" | fzf \
      --multi \
      --height=100% \
      --border=sharp \
      --layout=reverse-list \
      --preview-window="$(show_preview)" \
      --preview="bat --style=plain --color=always {}" \
      --prompt='Files > ' \
      --bind="ctrl-o:execute-silent(echo \"open\" > $temp_file)" \
      --bind="ctrl-o:+change-header(
$base_header
<CR> to OPEN)" \
      --bind="ctrl-e:execute-silent(echo \"edit\" > $temp_file)" \
      --bind="ctrl-e:+change-header(
$base_header
<CR> to EDIT)" \
      --bind="ctrl-d:change-prompt(Dirs > )" \
      --bind="ctrl-d:+reload($find_dirs_cmd)" \
      --bind="ctrl-d:+change-preview(tree -C {})" \
      --bind="ctrl-d:+refresh-preview" \
      --bind="ctrl-f:change-prompt(Files > )" \
      --bind="ctrl-f:+reload($find_files_cmd)" \
      --bind="ctrl-f:+change-preview(bat --style=plain --color=always {})" \
      --bind="ctrl-f:+refresh-preview" \
      --bind="ctrl-a:toggle-all" \
      --header "
$base_header
<CR> to EDIT"
  )

  read -r action <"$temp_file"
  trap 'rm -f "$temp_file"' EXIT INT QUIT TERM

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
