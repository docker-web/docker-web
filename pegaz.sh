#!/bin/sh
VERSION=0.1

PEGAZ_PATH="/etc/pegaz"
PEGAZ_SERVICES_PATH="/etc/pegaz/src"
COMMANDS="config add remove update"
SERVICES=$(find $PEGAZ_SERVICES_PATH -maxdepth 1 -not -name '.*' -type d -printf '%f\n  ')

EXECUTE() {
  (cd $PEGAZ_SERVICES_PATH/$2 || return; source $PEGAZ_PATH/env.sh && source config.sh && docker-compose $1;)
}

TEST_ROOT() {
  if ! whoami | grep -q root
  then
    echo "you need to be root"
    exit
  fi
}

TEST_PROXY() {
  if ! echo $(docker ps) | grep -q reverse-proxy
  then
    EXECUTE add reverse-proxy
  fi    
}

CONFIG() {
  source env.sh
  echo "Domain ($DOMAIN):"
  read DOMAIN
  sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" $PEGAZ_PATH/env.sh

  echo "User ($USER):"
  read USER
  sed -i "s|USER=.*|USER=$USER|g" $PEGAZ_PATH/env.sh

  echo "Pass ($PASS):"
  read -s PASS
  sed -i s/pass_default/"$PASS"/g $PEGAZ_PATH/env.sh
  sed -i "s|PASS=.*|PASS=$PASS|g" $PEGAZ_PATH/env.sh
  
  
  #Email
  echo "Email (default: $EMAIL):"
  read EMAIL
  if $EMAIL
  then
    sed -i "s|EMAIL=.*|EMAIL=$EMAIL|g" $PEGAZ_PATH/env.sh
  else
    sed -i "s|EMAIL=.*|EMAIL=$USER"@"$DOMAIN|g" $PEGAZ_PATH/env.sh
  fi

  echo "Media Path (default: /etc/pegaz/media): \n where all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  read PATH_MEDIA
  sed -i "s|PATH_MEDIA=.*|PATH_MEDIA=$PATH_MEDIA|g" $PEGAZ_PATH/env.sh

  echo "Data Path (default: /etc/pegaz/data): \n where all datas, backup, database are stored by services"
  read PATH_DATA
  sed -i "s|PATH_DATA=.*|PATH_DATA=$PATH_DATA|g" $PEGAZ_PATH/env.sh
}

HELP() {
  echo "
Usage: pegaz <command> <service>

Options:
  -h, --help         Print information and quit
  -v, --version      Print version and quit

Commands:
  ...                All docker-compose command are compatible/binded (ex: restart logs ...)
  config             Assistant to edit configurations stored in env.sh
  add                Launch a web service with configuration set in env.sh (equivalent to docker-compose up -d)
  remove             Remove all container related to the service
  update             Pull the last docker images used by the service

Services:
$SERVICES
  "
}

if ! test $1
then
  HELP
elif test $1 = 'help' -o $1 = '-h' -o $1 = '--help'
then
  HELP
elif test $1 = 'version' -o $1 = '-v' -o $1 = '--version'
then
  echo $VERSION
elif test $1 = 'config'
then
  CONFIG
elif test $2
then
  if test $SERVICES =~ $2
  then
    # LAUNCH PROXY IF NOT STARTED YET
    TEST_PROXY
    # SHORTCUT CMD
    if test $1 = "add"
    then
      EXECUTE 'up -d' $2
    elif test $1 = "remove"
    then
      EXECUTE 'rm' $2
    elif test $1 = "update"
    then
      EXECUTE 'pull' $2
    elif ! test echo $COMMANDS | grep -q $1
    then
      # BIND DOCKER-COMPOSE CMD
      EXECUTE $1 $2
    else
      echo "command $1 not found"
    fi
  else
    echo "pegaz can\'t $1 $2, choose a service above :
    $SERVICES"
  fi
else
  echo "you need to precise witch service you want to $1:
  $SERVICES"
fi
