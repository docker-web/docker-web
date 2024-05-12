#!/bin/bash
alias docker-web='bash ~/docker-web/src/cli.sh $@'
alias docker-webdev='[ -f src/cli.sh ] && bash src/cli.sh $@  || echo "cant find docker-web"'
alias dweb='docker-web $@'
alias dwebdev='docker-webdev $@'
