#!/bin/bash
# shellcheck source=/dev/null

source ~/.dotfiles/helpers.sh

redlib &
REDLIB_PID=$!
h_echo --mode=doing "Redlib running on port: $REDLIB_PID"

cleanup() {
  h_echo --mode=doing "Killing port: $REDLIB_PID"
  kill -9 "$REDLIB_PID"
}

trap cleanup SIGINT

xdg-open "http://localhost:8080/"
wait "$REDLIB_PID"
