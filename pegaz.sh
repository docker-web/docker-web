#!/bin/sh
VERSION=0.1

message() {
  CS='\033[1;00;40m'  # color start
  CE='\033[0m'        # color end

  echo $1
}

PEGAZ_PATH="/etc/pegaz"
PEGAZ_SERVICES_PATH="/etc/pegaz/src"
COMMANDS="config add remove update"
SERVICES=$(find $PEGAZ_SERVICES_PATH -maxdepth 1 -not -name '.*' -type d -printf '%f\n  ')

EXECUTE($SERVICE, $CMD) {
  (cd $PEGAZ_SERVICES_PATH/$SERVICE || return; source ../../env.sh && source config.sh && docker-compose $CMD;)
}

TEST_ROOT() {
  if ! whoami | grep -q root
  then
    message "you need to be root"
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
  message "Config:"
  sleep 1
  
  message "Domain (ex: mydomain.com):"
  read DOMAIN
  sed -i s/domain_default/"$DOMAIN"/g $PEGAZ_PATH/env.sh

  message "Username:"
  read USER
  sed -i s/user_default/"$USER"/g $PEGAZ_PATH/env.sh

  unset PASSWORD
  prompt="Password:"
  while IFS= read -p "$prompt" -r -s -n 1 char
  do
      if [[ $char == $'\0' ]]
      then
          break
      fi
      prompt='*'
      PASSWORD+="$char"
  done
  sed -i s/pass_default/"$PASSWORD"/g $PEGAZ_PATH/env.sh
  
  #Email
  message "Email: (default: $user@$domain)"
  read EMAIL
  if $EMAIL
  then
    sed -i s/user@domain_default/"$EMAIL"/g $PEGAZ_PATH/env.sh
  else
    sed -i s/user@domain_default/"$USER"@"$DOMAIN"/g $PEGAZ_PATH/env.sh
  fi

  message "Media Path: \n where all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  read PATH_MEDIA
  sed -i s/PATH_MEDIA/"$PATH_MEDIA"/g $PEGAZ_PATH/env.sh

  message "Data Path: \n where all datas, backup, database are stored by services"
  read PATH_DATA
  sed -i s/PATH_DATA/"$PATH_DATA"/g $PEGAZ_PATH/env.sh
}

HELP() {
  message "
Usage: pegaz <command> <service>\n
\n
Options:\n
  -h, --help         Print information and quit\n
  -v, --version      Print version and quit\n
\n
Commands:\n
  ...                All docker-compose command are compatible/binded (ex: restart logs ...)\n
  config             Assistant to edit configurations stored in env.sh\n
  add                Launch a web service with configuration set in env.sh (equivalent to docker-compose up -d)\n
  remove             Remove all container related to the service\n
  update             Pull the last docker images used by the service\n
\n
Services:\n
$SERVICES
  "
}

if test $1 -o $1 = "help" -o $1 = "-h" -o $1 = "--help"
then
  HELP
elif test $1 = "version" -o $1 = "-v" -o $1 = "--version"
then
  echo $VERSION
elif test $1 = "config"
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
      EXECUTE $2 'up -d'
    elif test $1 = "remove"
    then
      EXECUTE $2 'rm'
    elif test $1 = "update"
    then
      EXECUTE $2 'pull'
    elif ! test echo $COMMANDS | grep -q $1
    then
      # BIND DOCKER-COMPOSE CMD
      EXECUTE $2 $1
    else
      message "command $1 not found"
    fi
  else
    message "pegaz can\'t $1 $2, choose a service above :"
  fi
else
  message "you need to precise witch service you want to $1: "
fi
