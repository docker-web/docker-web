docker run -d --restart unless-stopped --name docker-web -v /var/run/docker.sock:/tmp/docker.sock:ro docker-web/docker-web
alias pegaz='docker exec docker-web bash docker-web.sh $@'
alias pegazdev='[ -f "./docker-web.sh" ] && bash docker-web.sh $@  || echo "there is no docker-web.sh here"'
[[ -f "/opt/pegaz/completion.sh" ]] && source /opt/pegaz/completion.sh
