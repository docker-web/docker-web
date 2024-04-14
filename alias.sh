#!/bin/bash
alias docker-web='docker run --rm -v /var/run/docker.sock:/tmp/docker.sock:ro docker-web/docker-web bash src/cli.sh $@'
alias docker-webdev='[ -f "./src/cli.sh" ] && bash ./src/cli.sh $@  || echo "cant find cli.sh"'
source <(curl -s https://raw.githubusercontent.com/docker-web/docker-web/master/completion.sh)
