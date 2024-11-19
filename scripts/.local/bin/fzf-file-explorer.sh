#!/bin/bash

temp_file=$(mktemp)
echo 'open' > $temp_file

base_header="
CTRL-D to display directories | CTRL-F to display files
CTRL-A to toggle all
CTRL-O to open | CTRL-E to edit"

# based on https://thevaluable.dev/practical-guide-fzf-example/
selection=$(find -type d | fzf --multi --height=100% --border=sharp --layout=reverse-list \
--preview="tree -C {}" --preview-window="45%,border-sharp" \
--prompt='Dirs > ' \
--bind="ctrl-o:execute-silent(eval 'echo open > "$temp_file"')" \
--bind="ctrl-o:+change-header(
$base_header
ENTER to OPEN
)" \
--bind="ctrl-e:execute-silent(eval 'echo edit > "$temp_file"')" \
--bind="ctrl-e:+change-header(
$base_header
ENTER to EDIT
)" \
--bind="ctrl-d:change-prompt(Dirs > )" \
--bind="ctrl-d:+reload(find -type d)" \
--bind="ctrl-d:+change-preview(tree -C {})" \
--bind="ctrl-d:+refresh-preview" \
--bind="ctrl-f:change-prompt(Files > )" \
--bind="ctrl-f:+reload(find -type f)" \
--bind="ctrl-f:+change-preview(highlight -O ansi --force {})" \
--bind="ctrl-f:+refresh-preview" \
--bind="ctrl-a:toggle-all" \
--header "
$base_header
ENTER to OPEN
"
)

read -r action < "$temp_file"
trap "rm -f $temp_file" 0 2 3 15

if [[ "$selection" == "" ]]
then 
  return
fi

if [ -d "$selection" ]
then
  if [[ $action == open ]]; then open "$selection"; else cd "$selection"; fi
else
  if [[ $action == open ]]; then open "$selection"; else nvim "$selection"; fi
fi
