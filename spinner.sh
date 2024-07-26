#!/bin/bash


# https://willcarh.art/blog/how-to-write-better-bash-spinners
spinner_pid=

# eg: start_spinner "spinning" 
# $1: the message to echo while the spinner runs
function start_spinner {
    set +m
    { 
      while : ; 
      do for char in "⠋" "⠙" "⠹"	"⠸"	"⠼"	"⠴"	"⠦"	"⠧"	"⠇"	"⠏"
        do echo -en "${1//?/\\b}\b\b$char $1" 
          sleep 0.1
        done
      done & 
      } 2>/dev/null
    spinner_pid=$!
}

# eg: stop_spinner
function stop_spinner {
    { kill -9 $spinner_pid && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
    echo -e "$1"
}

trap stop_spinner EXIT
