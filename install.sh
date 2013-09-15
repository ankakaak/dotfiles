#!/usr/bin/env bash

set -e

cd `dirname $0`
export DOTFILES=`pwd`

source $DOTFILES/install_functions.sh

create_ssh_config
link_with_backup .path
link_with_backup .bashrc
link_with_backup .bash_profile
link_with_backup .gitconfig
link_with_backup .gitignore_global

if [[ "$USER" != "d3andreas" ]]; then
    unset_git_user
fi
