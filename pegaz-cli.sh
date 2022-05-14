#!/bin/bash

VERSION=0.5
PATH_PEGAZ="/etc/pegaz"
PATH_PEGAZ_SERVICES="$PATH_PEGAZ/src"
COMMANDS=('config' 'up' 'update' 'down' 'upgrade' 'uninstall')
SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

complete -W "$(echo ${COMMANDS[*]})" pegaz pegazdev

SERVICE_INFOS() {
  if test -f $PATH_PEGAZ_SERVICES/$1/config.sh
  then
    source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "http://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
  fi
}

EXECUTE() {
  # echo $1 $2
  TEST_NETWORK
  if test -f $PATH_PEGAZ_SERVICES/$2/config.sh
  then
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && source config.sh 2> /dev/null && docker-compose $1;)
    if test "$1" == 'up -d' -a "$2" != 'nginx-proxy'
    then
      SERVICE_INFOS $2
    fi
  else
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && docker-compose $1;)
  fi
}

TEST_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    echo "create NETWORK"
    docker network create pegaz
  fi
}

TEST_PROXY() {
  if ! echo $(docker ps) | grep -q nginx-proxy
  then
    EXECUTE 'up -d' 'nginx-proxy'
  fi
}

CONFIG() {
  source $PATH_PEGAZ/config.sh
  echo "Domain (current: $DOMAIN):"
  read DOMAIN
  if test $DOMAIN
  then
    sudo sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" $PATH_PEGAZ/config.sh
  fi

  echo "User (current: $USER):"
  read USER
  if test $USER
  then
    sudo sed -i "s|USER=.*|USER=$USER|g" $PATH_PEGAZ/config.sh
  fi

  echo "Pass:"
  read -s PASS
  if test $PASS
  then
    sudo sed -i "s|PASS=.*|PASS=$PASS|g" $PATH_PEGAZ/config.sh
  fi

  #Email
  source $PATH_PEGAZ/config.sh
  echo "Email (default: $USER@$DOMAIN):"
  read EMAIL
  if test $EMAIL
  then
    sudo sed -i "s|EMAIL=.*|EMAIL=$EMAIL|g" $PATH_PEGAZ/config.sh
  else
    sudo sed -i "s|EMAIL=.*|EMAIL=$USER"@"$DOMAIN|g" $PATH_PEGAZ/config.sh
  fi

  echo -e "Media Path (current: $PATH_MEDIA): \n where all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  read PATH_MEDIA
  if test $PATH_MEDIA
  then
    sudo sed -i "s|PATH_MEDIA=.*|PATH_MEDIA=$PATH_MEDIA|g" $PATH_PEGAZ/config.sh
  fi
}

UPGRADE() {
  UNINSTALL
  curl -L get.pegaz.io | sudo bash
}

UNINSTALL() {
  BASHRC_PATH="/etc/bash.bashrc"
  sudo sed -i '/pegaz-cli.sh/d' $BASHRC_PATH && source $BASHRC_PATH
  sudo rm -rf $PATH_PEGAZ
  echo "Pegaz succesfully uninstalled"
}

HELP() {
  echo "Usage: pegaz <command> <service>

Options:
  -h, --help         Print information
  -v, --version      Print version
  --upgrade          Upgrade pegaz
  --uninstall        Uninstall pegaz

Commands:
  ...                All docker-compose command are compatible/binded (ex: restart stop rm logs pull ...)
  config             Assistant to edit configurations stored in config.sh (main configurations or specific configurations if service named is passed)
  up                 Launch a web service with configuration set in config.sh (equivalent to docker-compose up -d)
  update             Update the service with the last config stored in config.sh files
  down               [docker-compose legacy] Stop and remove containers, networks, images, and volumes

Services:
$SERVICES"
}

# DEFAULT
if ! test $1
then
  HELP
# 1 ARGS
elif ! test $2
then
  if test "$1" == 'help' -o "$1" == '-h' -o "$1" == '--help'
  then
    HELP
  elif test "$1" == 'version' -o "$1" == '-v' -o "$1" == '--version'
  then
    echo $VERSION
  elif test "$1" == 'config'
  then
    CONFIG
  elif test "$1" == 'upgrade' -o "$1" == '--upgrade'
  then
    UPGRADE
  elif test "$1" == 'ps'
  then
    docker ps
  elif test "$1" == 'prune'
  then
    docker system prune
  elif test "$1" == 'uninstall' -o "$1" == '--uninstall'
  then
    UNINSTALL
  else
    for SERVICE in $SERVICES
    do
      if test "$1" == 'update'
      then
        EXECUTE 'down' $SERVICE
        EXECUTE 'up -d' $SERVICE
      else
        EXECUTE $1 $SERVICE
      fi
    done
  fi
# 2 ARGS
elif test $2
then
  if echo $SERVICES | grep -q $2
  then
    # LAUNCH PROXY IF NOT STARTED YET
    if test "$2" != 'nginx-proxy'
    then
      TEST_PROXY
    fi
    if test "$1" == 'up'
    then
      EXECUTE 'up -d' $2
    elif test "$1" == 'update'
    then
      EXECUTE 'down' $2
      EXECUTE 'up -d' $2
    elif test "$1" == 'ps'
    then
      SERVICE_INFOS $2
      EXECUTE 'ps' $2
    elif ! [[ ${COMMANDS[*]} =~ $1 ]]
    then
      # BIND DOCKER-COMPOSE
      EXECUTE $1 $2
    else
      echo "command $1 not found"
    fi
  else
    echo "$2 is not on the list, $1 a service listed below :
$SERVICES"
  fi
else
  echo "you need to precise witch service you want to $1:
$SERVICES"
fi
