alias pegaz='bash /opt/pegaz/cli.pegaz.sh $1 $2'
alias pegazdev='rsync -avq --exclude=.* ./ /opt/pegaz && bash cli.pegaz.sh $1 $2 '
. /opt/pegaz/completion.sh
