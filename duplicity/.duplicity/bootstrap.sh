#! /bin/bash

source ~/.dotfiles/helpers.sh

h_validate_num_args --num=1 "$@"
h_validate_package_manager $1

h_install_package $1 duplicity

# TODO: set up cron job
