#!/bin/bash

source /etc/pegaz/env.sh
source $PATH_PEGAZ/completion.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

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
    if test "$1" == 'up -d' -a "$2" != 'proxy'
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
  if ! echo $(docker ps) | grep -q proxy
  then
    EXECUTE 'up -d' 'proxy'
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

  echo -e "Media Path (current: $DATA_DIR): \n where all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  echo -e "CAUTION ! all data will be erased when up for the first time"
  read DATA_DIR
  if test $DATA_DIR
  then
    sudo sed -i "s|DATA_DIR=.*|DATA_DIR=$DATA_DIR|g" $PATH_PEGAZ/config.sh
  fi
}

CREATE_SERVICE() {
  echo "name ? image ? domain ?"
}

UPGRADE() {
  UNINSTALL
  curl -L get.pegaz.io | sudo bash
}

UNINSTALL() {
  BASHRC_PATH="/etc/bash.bashrc"
  sudo sed -i '/cli.pegaz.sh/d' $BASHRC_PATH && source $BASHRC_PATH
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

PRUNE() {
  docker system prune && docker volume prune && docker image prune -a
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
  elif test "$1" == 'create'
  then
    CREATE_SERVICE
  elif test "$1" == 'upgrade' -o "$1" == '--upgrade'
  then
    UPGRADE
  elif test "$1" == 'ps'
  then
    docker ps
  elif test "$1" == 'prune'
  then
    PRUNE
  elif test "$1" == 'uninstall' -o "$1" == '--uninstall'
  then
    UNINSTALL
  else
    for SERVICE in $SERVICES
    do
      if test "$1" == 'update'
      then
        EXECUTE 'down'  $SERVICE
        EXECUTE 'pull'  $SERVICE
        EXECUTE 'build' $SERVICE
        EXECUTE 'up -d' $SERVICE
      elif test "$1" == 'dune'
      then
        EXECUTE 'down'  $SERVICE
      else
        EXECUTE $1 $SERVICE # BIND DOCKER-COMPOSE
      fi
    done
    if test "$1" == 'dune'
    then
      PRUNE
    fi
  fi
# 2 ARGS
elif test $2
then
  if echo $SERVICES | grep -q $2
  then
    if test "$1" == 'up'
    then
      # LAUNCH PROXY IF NOT STARTED YET
      if test "$2" != 'proxy'
      then
        TEST_PROXY
      fi
      EXECUTE 'build' $2
      EXECUTE 'up -d' $2
    elif test "$1" == 'update'
    then
      EXECUTE 'down'  $2
      EXECUTE 'pull'  $2
      EXECUTE 'build' $2
      EXECUTE 'up -d' $2
    elif test "$1" == 'dune'
    then
      EXECUTE 'down'  $2
      PRUNE
    elif test "$1" == 'ps'
    then
      SERVICE_INFOS $2
      EXECUTE 'ps' $2
    elif ! [[ ${COMMANDS[*]} =~ $1 ]]
    then
      EXECUTE $1 $2 # BIND DOCKER-COMPOSE
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
