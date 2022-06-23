#!/bin/bash

source /etc/pegaz/env.sh
source $PATH_PEGAZ/completion.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
IS_PEGAZDEV=0 && [[ $0 == "cli.pegaz.sh" ]] && IS_PEGAZDEV=1
PATH_PEGAZ_SERVICES_COMPAT="$(dirname $0)/services" # pegazdev compatibility

REMOVE_LINE() {
  sed -i "/.*$1.*/d" $2 &> /dev/null
}

INSERT_LINE_AFTER() {
  sed -i "0,/${1//\//\\/}/s//${1//\//\\/}\n${2//\//\\/}/" $3
}

GET_LAST_PORT() {
  LAST_PORT="0"
  for PATH_SERVICE in `find $PATH_PEGAZ_SERVICES/*/ -type d`
  do
    PORT=`sed -n 's/^export PORT=\(.*\)/\1/p' < "$PATH_SERVICE/$FILENAME_CONFIG"`
    if test $PORT
    then
      PORT=`sed -e 's/^"//' -e 's/"$//' <<<"$PORT"`
      if [ "${PORT}" -gt "${LAST_PORT}" ]
      then
        LAST_PORT=$PORT
      fi
    fi
  done
  echo $LAST_PORT
}

SERVICE_INFOS() {
  if test -f $PATH_PEGAZ_SERVICES/$1/config.sh
  then
    source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "http://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
  fi
}

EXECUTE() {
  CREATE_NETWORK
  if test -f $PATH_PEGAZ_SERVICES/$2/config.sh
  then
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && source config.sh 2> /dev/null && docker-compose $1;)
  else
    echo "exec could not find config for $2"
  fi
}

CREATE_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    echo "create NETWORK"
    docker network create pegaz
  fi
}

SETUP_REDIRECTIONS() {
  if grep -q "REDIRECTIONS=" "$PATH_PEGAZ_SERVICES/$1/$FILENAME_CONFIG" && [[ $REDIRECTIONS != "" ]]
  then
    touch "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX"
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    for REDIRECTION in $REDIRECTIONS
    do
      FROM=${REDIRECTION%->*}
      TO=${REDIRECTION#*->}
      if [[ $FROM == /* ]]; then # same domain
        echo "rewrite ^$FROM$ http://$SUBDOMAIN.$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX"
      elif [[ $TO != "" ]]  # sub-domain
      then
        echo "server {" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "  server_name $FROM.$DOMAIN;" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "  return 301 http://$SUBDOMAIN.$DOMAIN$TO;" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "}" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
      fi
    done
  fi
}

SETUP_NGINX() {
  REMOVE_LINE "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" "$PATH_PROXY_COMPOSE"
  if [[ -f "$PATH_SERVICE/$FILENAME_NGINX" ]]
  then
    NEW_LINE="      - $PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX:/etc/nginx/vhost.d/$SUBDOMAIN.$DOMAIN:ro"
    INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
  fi
}

SETUP_PROXY() {
  if test "$1" == 'up' -o "$1" == 'update'
  then
    source "./$FILENAME_CONFIG"
    PATH_PROXY_COMPOSE="$PATH_PEGAZ_SERVICES/proxy/docker-compose.yml"
    rm -rf "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    for PATH_SERVICE in `find $PATH_PEGAZ_SERVICES/*/ -type d`
    do
      NAME_SERVICE=$(echo $PATH_SERVICE | sed "s%$PATH_PEGAZ_SERVICES%%")
      NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")
      if test -f "$PATH_SERVICE/$FILENAME_CONFIG"
      then
        source "$PATH_SERVICE/$FILENAME_CONFIG"
        SETUP_REDIRECTIONS $NAME_SERVICE
        SETUP_NGINX $NAME_SERVICE
      else
        echo "$NAME_SERVICE should have a $FILENAME_CONFIG file (even empty)"
      fi
    done
    NEW_LINE="      - $PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION:ro"
    INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
    EXECUTE 'up -d' 'proxy'
  fi
}

PRE_INSTALL() {
  source $PATH_PEGAZ_SERVICES/$1/config.sh
  PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_PREINSTALL"
  if test -f $PATH_SCRIPT
  then
    bash $PATH_SCRIPT $1
  fi
}

POST_INSTALL() {
  source $PATH_PEGAZ_SERVICES/$1/config.sh
  PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_POSTINSTALL"
  if test -f $PATH_SCRIPT
  then
    while :
    do
      HTTP_CODE=$(curl -ILs $SUBDOMAIN.$DOMAIN | head -n 1 | cut -d$' ' -f2)
      if [[ $HTTP_CODE == "200" || $HTTP_CODE == "302" || $HTTP_CODE == "308" || $HTTP_CODE == "307" ]]
      then
        bash $PATH_SCRIPT $1 &&\
        SERVICE_INFOS $1
        break
      else
        continue
      fi
    done
  else
    SERVICE_INFOS $1
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

  echo -e "Media Path (current: $DATA_DIR): \nwhere all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  echo -e "this script will set it to www-data as owner & 750 as default file mode"
  read DATA_DIR
  if test $DATA_DIR
  then
    sudo sed -i "s|DATA_DIR=.*|DATA_DIR=$DATA_DIR|g" $PATH_PEGAZ/config.sh
    sudo chown -R www-data:www-data $PATH_PEGAZ $DATA_DIR
    sudo chmod -R 750 $PATH_PEGAZ $DATA_DIR
  fi
  if $IS_PEGAZDEV; then cp $PATH_PEGAZ/config.sh $PATH_PEGAZ; fi
}

CREATE() {
  if test $2
  then
    NAME=$1
    IMAGE=$2
  elif test $1
  then
    NAME=$1
    IMAGE=$(docker search $1 --limit 1 --format "{{.Name}}")
  else
    echo "Name:"
    read NAME
    echo "Docker Image:"
    read IMAGE
  fi

  # ports setup
  PORT=$(GET_LAST_PORT)
  PORT=$(($PORT + 5))
  docker pull $IMAGE
  PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')

  if [[ $PORT_EXPOSED == "" ]]
  then
    PORT_EXPOSED="80"
  fi

  #clean name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  #Setup
  mkdir -p "$PATH_PEGAZ_SERVICES_COMPAT/$NAME"
  cp "$PATH_PEGAZ_SERVICES_COMPAT/test/config.sh" "$PATH_PEGAZ_SERVICES_COMPAT/test/docker-compose.yml" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/"
  sed -i "s/test/$NAME/" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/docker-compose.yml"
  sed -i "s|IMAGE=.*|IMAGE=\"$IMAGE\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|SUBDOMAIN=.*|SUBDOMAIN=\"$NAME\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|REDIRECTIONS=.*|REDIRECTIONS=\"\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  if test $IS_PEGAZDEV
  then
    sudo cp -R "$PATH_PEGAZ_SERVICES_COMPAT/$NAME" $PATH_PEGAZ_SERVICES
  fi
  EXECUTE 'up -d' $NAME
  SERVICE_INFOS $NAME
}

DESTROY() {
  EXECUTE 'down' $1
  sudo rm -rf "$PATH_PEGAZ_SERVICES_COMPAT/$1" "$PATH_PEGAZ_SERVICES/$1"
}

UPGRADE() {
  UNINSTALL
  curl -L get.pegaz.io | sudo bash
}

UNINSTALL() {
  sudo sed -i '/cli.pegaz.sh/d' $PATH_BASHRC && source $PATH_BASHRC
  sudo rm -rf $PATH_PEGAZ "$PATH_COMPLETION/pegaz.sh"
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
  config             Assistant to edit configurations stored in $FILENAME_CONFIG (main configurations or specific configurations if service named is passed)
  up                 Launch a web service with configuration set in $FILENAME_CONFIG and proxy settings set in $FILENAME_NGINX then execute $FILENAME_POSTINSTALL
  update             Update the service with the last config stored in $FILENAME_CONFIG files
  reset              Down the service, prune it and finaly up again (useful for dev & test)
  create             Create a service base on test configuration (pegaz create service_name docker-hub_image_name)
  destroy            down a service and remove its folder
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
  elif test "$1" == 'lastport' -o "$1" == '-l' -o "$1" == '--lastport'
  then
    GET_LAST_PORT
  elif test "$1" == 'version' -o "$1" == '-v' -o "$1" == '--version'
  then
    echo $VERSION
  elif test "$1" == 'config'
  then
    CONFIG
  elif test "$1" == 'create'
  then
    CREATE
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
        [[ "$1" == 'up' ]] && PRE_INSTALL $SERVICE
        EXECUTE $1 $SERVICE # BIND DOCKER-COMPOSE
        [[ "$1" == 'up' ]] && POST_INSTALL $SERVICE
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
  SETUP_PROXY $1 $2
  then
    if test "$1" == 'up'
    then
      PRE_INSTALL $2
      EXECUTE 'build' $2
      EXECUTE 'up -d' $2
      POST_INSTALL $2
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
    elif test "$1" == 'logs'
    then
      EXECUTE 'logs -f' $2
    elif test "$1" == 'create'
    then
      CREATE $2 $3
    elif test "$1" == 'destroy'
    then
      DESTROY $2
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