#!/bin/bash
alias docker-web='docker run --rm -v /var/run/docker.sock:/tmp/docker.sock:ro docker-web/docker-web bash docker-web.sh $@'
alias docker-webdev='[ -f "./docker-web.sh" ] && bash docker-web.sh $@  || echo "there is no docker-web.sh here"'
source <(curl -s https://raw.githubusercontent.com/docker-web/docker-web/master/completion.sh)
