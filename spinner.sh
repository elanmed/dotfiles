#!/bin/bash


# https://willcarh.art/blog/how-to-write-better-bash-spinners
spinner_pid=

# eg: start_spinner "spinning" 
# $1: the message to echo while the spinner runs
function start_spinner {
    set +m
    echo -en "$1  "
    { 
      while : ; 
      do for char in "⠋" "⠙" "⠹"	"⠸"	"⠼"	"⠴"	"⠦"	"⠧"	"⠇"	"⠏"
        do echo -en "\b$char"
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
    echo -en "\b \n"
}

trap stop_spinner EXIT
