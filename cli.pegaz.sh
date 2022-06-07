#!/bin/bash

source /etc/pegaz/env.sh
source $PATH_PEGAZ/completion.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

REMOVE_LINE() {
  sed -i "/.*$1.*/d" $2 &> /dev/null
}

INSERT_LINE_AFTER() {
  sed -i "0,/${1//\//\\/}/s//${1//\//\\/}\n${2//\//\\/}/" $3
}

SERVICE_INFOS() {
  if test -f $PATH_PEGAZ_SERVICES/$1/config.sh
  then
    source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "http://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
  fi
}

EXECUTE() {
  CREATE_NETWORK
  SETUP_POSTINSTALL "${1}"
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
  if test "$1" == 'up -d'
  then
    POST_INSTALL "$2"
  fi
}

CREATE_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    echo "create NETWORK"
    docker network create pegaz
  fi
}

SETUP_PROXY() {
  if test "$1" == 'up'
  then
    REGEX_NGINX="$PATH_PEGAZ_SERVICES/*/$FILENAME_NGINX"
    PATH_COMPOSE="$PATH_PEGAZ_SERVICES/proxy/docker-compose.yml"
    INSERT_AFTER="proxy.conf:ro"

    for PATHS in $REGEX_NGINX
    do
      PATHS=$(echo $PATHS | sed "s/$FILENAME_NGINX//g")
      for PATHNAME in $PATHS
      do
        if test -f ${PATHNAME}${FILENAME_CONFIG}
        then
          source ${PATHNAME}${FILENAME_CONFIG}
          source ./${FILENAME_CONFIG}
          OLD_LINE=$PATHNAME$FILENAME_NGINX
          NEW_LINE="      - ${PATHNAME}${FILENAME_NGINX}:/etc/nginx/vhost.d/${SUBDOMAIN}.${DOMAIN}:ro"
          REMOVE_LINE "${OLD_LINE}" "${PATH_COMPOSE}"
          INSERT_LINE_AFTER "${INSERT_AFTER}" "${NEW_LINE}" "${PATH_COMPOSE}"
        else
          echo "${PATHNAME} should have a ${FILENAME_CONFIG} file (even empty)"
        fi
      done
    done
    EXECUTE 'up -d' 'proxy'
  fi
}

SETUP_POSTINSTALL() {
  if test "$1" == 'up -d'
  then
    REGEX_POSTINSTALL="$PATH_PEGAZ_SERVICES/*/$FILENAME_POSTINSTALL"
    INSERT_AFTER="    volumes:"
    INSERT_AFTER_2="restart: unless-stopped"

    for PATHS in $REGEX_POSTINSTALL
    do
      PATHS=$(echo $PATHS | sed "s/$FILENAME_POSTINSTALL//g")
      for PATHNAME in $PATHS
      do
        PATH_COMPOSE="${PATHNAME}docker-compose.yml"
        if test -f ${PATHNAME}${FILENAME_CONFIG}
        then
          source ${PATHNAME}${FILENAME_CONFIG}
          source ./${FILENAME_CONFIG}
          OLD_LINE=$FILENAME_POSTINSTALL
          NEW_LINE="      - ./${FILENAME_POSTINSTALL}:/${FILENAME_POSTINSTALL}:ro"
          REMOVE_LINE "${OLD_LINE}" "${PATH_COMPOSE}"
          if ! grep -q "${INSERT_AFTER}" "${PATH_COMPOSE}"
          then
            INSERT_LINE_AFTER "${INSERT_AFTER_2}" "${INSERT_AFTER}" "${PATH_COMPOSE}"
          fi
          INSERT_LINE_AFTER "${INSERT_AFTER}" "${NEW_LINE}" "${PATH_COMPOSE}"
        else
          echo "${PATHNAME} should have a ${FILENAME_CONFIG} file"
        fi
      done
    done
  fi
}

POST_INSTALL() {
  if $(docker exec $1 test -f ./$FILENAME_POSTINSTALL)
  then
    docker exec $1 sh "./$FILENAME_POSTINSTALL"
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
  reset              Down the service, prune it and finaly up again (useful for dev & test)
  down               [docker-compose legacy] Stop and remove containers, networks, images, and volumes

Services:
$SERVICES"
}

PRUNE() {
  docker system prune && docker volume prune
}

# DEFAULT
if ! test $1
then
  HELP
# 1 ARGS
elif ! test $2
then
  SETUP_PROXY $1
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
    docker ps -a
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
  SETUP_PROXY $1
  then
    if test "$1" == 'up'
    then
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
    elif test "$1" == 'reset'
    then
      EXECUTE 'down' $2
      PRUNE
      EXECUTE 'up -d' $2
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
