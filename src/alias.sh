#!/bin/bash
alias docker-web='bash /var/docker-web/src/cli.sh $@'
alias dweb='docker-web $@'

alias docker-webdev='cp -R ~/docker-web/* /var/docker-web && bash /var/docker-web/src/cli.sh $@'
alias dwebdev='docker-web $@'
