#!/bin/bash
VERSION=0.5

PEGAZ_PATH="/etc/pegaz"
PEGAZ_SERVICES_PATH="/etc/pegaz/src"
COMMANDS=('config' 'up' 'update')
SERVICES=$(find $PEGAZ_SERVICES_PATH -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

SERVICE_INFOS() {
  if test -f $PEGAZ_SERVICES_PATH/$1/config.sh
  then
    source $PEGAZ_PATH/env.sh && source $PEGAZ_SERVICES_PATH/$1/config.sh && echo -e "http://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
  fi
}

EXECUTE() {
  # echo $1 $2
  TEST_NETWORK
  if test -f $PEGAZ_SERVICES_PATH/$2/config.sh
  then
    (cd $PEGAZ_SERVICES_PATH/$2 || return; source $PEGAZ_PATH/env.sh && source config.sh 2> /dev/null && docker-compose $1;)
    if test "$1" == 'up -d' -a "$2" != 'nginx-proxy'
    then
      SERVICE_INFOS $2
    fi
  else
    (cd $PEGAZ_SERVICES_PATH/$2 || return; source $PEGAZ_PATH/env.sh && docker-compose $1;)
  fi
}

TEST_ROOT() {
  if ! whoami | grep -q root
  then
    echo "you need to be root"
    exit
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
  TEST_ROOT
  source $PEGAZ_PATH/env.sh
  echo "Domain (current: $DOMAIN):"
  read DOMAIN
  if test $DOMAIN
  then
    sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" $PEGAZ_PATH/env.sh
  fi

  echo "User (current: $USER):"
  read USER
  if test $USER
  then
    sed -i "s|USER=.*|USER=$USER|g" $PEGAZ_PATH/env.sh
  fi

  echo "Pass:"
  read -s PASS
  if test $PASS
  then
    sed -i "s|PASS=.*|PASS=$PASS|g" $PEGAZ_PATH/env.sh
  fi

  #Email
  source $PEGAZ_PATH/env.sh
  echo "Email (default: $USER@$DOMAIN):"
  read EMAIL
  if test $EMAIL
  then
    sed -i "s|EMAIL=.*|EMAIL=$EMAIL|g" $PEGAZ_PATH/env.sh
  else
    sed -i "s|EMAIL=.*|EMAIL=$USER"@"$DOMAIN|g" $PEGAZ_PATH/env.sh
  fi

  echo -e "Media Path (current: $PATH_MEDIA): \n where all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  read PATH_MEDIA
  if test $PATH_MEDIA
  then
    sed -i "s|PATH_MEDIA=.*|PATH_MEDIA=$PATH_MEDIA|g" $PEGAZ_PATH/env.sh
  fi
}

UPGRADE() {
  UNINSTALL
  curl -L get.pegaz.io | bash
}

UNINSTALL() {
  TEST_ROOT
  BASHRC_PATH="/etc/bash.bashrc"
  sed -i '/pegaz-cli.sh/d' $BASHRC_PATH && source $BASHRC_PATH
  rm -rf $PEGAZ_PATH
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
  config             Assistant to edit configurations stored in env.sh (main configurations or specific configurations if service named is passed)
  up                 Launch a web service with configuration set in env.sh (equivalent to docker-compose up -d)
  update             Update the service with the last config stored in env.sh files
  down               [docker-compose legacy] Stop and remove containers, networks, images, and volumes

Services:
$SERVICES"
}

# DEFAULT
if ! test $1
then
  complete -W $COMMANDS
  HELP
# 1 ARGS
elif ! test $2
then
  complete -W $SERVICES
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
