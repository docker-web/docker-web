#!/bin/bash

dwebalias() {
  if [ "$(basename "$PWD")" = "docker-web" ]  # if we work/dev from a folder named 'docker-web'
  then
    cp -R ./* /var/docker-web                 # we should copy files to app in /var/docker-web
  fi
  bash /var/docker-web/src/cli.sh $@          # launch app with all params
}

alias docker-web='dwebalias $@'
alias dweb='dwebalias $@'
