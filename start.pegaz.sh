alias pegaz='bash /opt/pegaz/cli.pegaz.sh $1 $2'
alias pegazdev='[ "$(basename "$PWD")" = "pegaz" ] && rsync -avq --exclude=.* ./ /opt/pegaz && bash cli.pegaz.sh $1 $2  || echo "Current directory is not 'pegaz'."'
[[ -f "/opt/pegaz/completion.sh" ]] && source /opt/pegaz/completion.sh
