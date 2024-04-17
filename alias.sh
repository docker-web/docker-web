#!/bin/bash
alias docker-web='mkdir -p ~/docker-web && docker run --rm -v /var/run/docker.sock:/tmp/docker.sock:ro -v /home/$USER/docker-web/services:/home/services dockerwebcli/dockerweb bash src/cli.sh $@'
alias docker-webdev='[ -f "src/cli.sh" ] && bash src/cli.sh $@  || echo "cant find cli.sh"'
alias dweb='docker-web $@'
alias dwebdev='docker-webdev $@'
source <(curl -s https://raw.githubusercontent.com/docker-web/docker-web/master/completion.sh)
