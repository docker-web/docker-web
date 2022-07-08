#!/bin/bash

source /opt/pegaz/env.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
SERVICES_FLAT=$(echo $SERVICES | tr '\n' ' ')
IS_PEGAZ_INSTALLED=0 &&  [[ -d $PATH_PEGAZ ]] && IS_PEGAZ_INSTALLED=1
IS_PEGAZDEV=0 && [[ $0 == "cli.pegaz.sh" ]] && IS_PEGAZDEV=1
PATH_PEGAZ_SERVICES_COMPAT="$(dirname $0)/services" # pegazdev compatibility

# HELPERS

EXECUTE() {
  SETUP_NETWORK
  if test -f $PATH_PEGAZ_SERVICES/$2/config.sh
  then
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && source config.sh 2> /dev/null && docker-compose $1;)
  else
    echo "[x] could not find config for $2"
  fi
}

REMOVE_LINE() {
  sed -i "/.*$1.*/d" $2 &> /dev/null
}

INSERT_LINE_AFTER() {
  sed -i "0,/${1//\//\\/}/s//${1//\//\\/}\n${2//\//\\/}/" $3
}

SERVICE_INFOS() {
  if test -f $PATH_PEGAZ_SERVICES/$1/config.sh
  then
    source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "[√] $1 is up \nhttp://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
  fi
}

SETUP_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    echo "[*] create NETWORK"
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
      echo "[x] $NAME_SERVICE should have a $FILENAME_CONFIG file (even empty)"
    fi
  done
  NEW_LINE="      - $PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION:ro"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
  EXECUTE 'up -d' 'proxy'
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
    echo "[*] wait $1 ready for post-install script"
    if [[ -n $POST_INSTALL_CMD_TEST ]]
    then
      while :
      do
        docker exec $1 $POST_INSTALL_CMD_TEST >> /dev/null
        if [[ $? -eq 0 ]]
        then
          bash $PATH_SCRIPT $1 &&\
          SERVICE_INFOS $1
          break
        else
          continue
        fi
      done
    else
      while :
      do
        HTTP_CODE=$(curl -ILs $SUBDOMAIN.$DOMAIN | head -n 1 | cut -d$' ' -f2)
        if [[ $HTTP_CODE == "200" ]]
        then
          bash $PATH_SCRIPT $1 &&\
          SERVICE_INFOS $1
          break
        else
          continue
        fi
      done
    fi
  else
    SERVICE_INFOS $1
  fi
}

ALIAS() {
  if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
  then
    HELP
  elif [[ $1 == "-v" ]] || [[ $1 == "--version" ]]
  then
    VERSION
  elif [[ $1 == "ps" ]]
  then
    PS
  fi
}

# COMMANDS

PORT() {
  THE_LAST_PORT="0"
  for PATH_SERVICE in `find $PATH_PEGAZ_SERVICES/*/ -type d`
  do
    CURRENT_PORT=`sed -n 's/^export PORT=\(.*\)/\1/p' < "$PATH_SERVICE/$FILENAME_CONFIG"`
    if test $CURRENT_PORT
    then
      CURRENT_PORT=`sed -e 's/^"//' -e 's/"$//' <<<"$CURRENT_PORT"`
      if [ "${CURRENT_PORT}" -gt "${THE_LAST_PORT}" ]
      then
        THE_LAST_PORT=$CURRENT_PORT
      fi
    fi
  done
  echo $THE_LAST_PORT
}

CONFIG() {
  source $PATH_PEGAZ/config.sh
  echo "[?] Domain [$DOMAIN]"
  read DOMAIN
  if test $DOMAIN
  then
    sed -i "s|DOMAIN=.*|DOMAIN=$DOMAIN|g" $PATH_PEGAZ/config.sh
  fi

  echo "[?] Username [$USERNAMENAME]"
  read USERNAMENAME
  if test $USERNAME
  then
    sed -i "s|USERNAME=.*|USERNAME=$USERNAME|g" $PATH_PEGAZ/config.sh
  fi

  echo "[?] Password"
  read -s PASSWORD
  if test $PASSWORD
  then
    sed -i "s|PASSWORD=.*|PASSWORD=$PASSWORD|g" $PATH_PEGAZ/config.sh
  fi

  #Email
  source $PATH_PEGAZ/config.sh
  echo "[?] Email [$USERNAME@$DOMAIN]"
  read EMAIL
  if test $EMAIL
  then
    sed -i "s|EMAIL=.*|EMAIL=$EMAIL|g" $PATH_PEGAZ/config.sh
  else
    sed -i "s|EMAIL=.*|EMAIL=$USERNAME"@"$DOMAIN|g" $PATH_PEGAZ/config.sh
  fi

  echo -e "[?] Media Path [$DATA_DIR] \nwhere all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  echo -e "this script will set it to www-data as owner & 750 as default file mode"
  read DATA_DIR
  if test $DATA_DIR
  then
    sed -i "s|DATA_DIR=.*|DATA_DIR=$DATA_DIR|g" $PATH_PEGAZ/config.sh
    chown -R www-data:www-data $DATA_DIR
    chmod -R 750 $DATA_DIR
  fi

  if test $IS_PEGAZDEV == "1"
  then
    cp ./config.sh $PATH_PEGAZ
  fi
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
    while [[ !" ${SERVICES_FLAT} " =~ " $NAME " || ! $NAME ]]
    do
      echo "[?] Name"
      read NAME
    done
    DELIMITER=") "
    MAX_RESULT=7
    LINE=0
    RESULTS=$(docker search $NAME --limit $MAX_RESULT --format "{{.Name}}" | nl -w2 -s "$DELIMITER")
    while [[ $LINE -lt 1 || $LINE -gt $MAX_RESULT ]]
    do
      printf "$RESULTS\n"
      read LINE
    done
    IMAGE=$(sed -n ${LINE}p <<< "$RESULTS" 2> /dev/null)
    IMAGE=${IMAGE/ $LINE$DELIMITER/}
  fi

  if [[ " ${SERVICES_FLAT} " =~ " $NAME " ]]
  then
    echo "[x] service $NAME already exist"
    exit
  fi

  #ports setup
  PORT=$(PORT)
  PORT=$(($PORT + 5))
  docker pull $IMAGE
  # test $? && exit;
  PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')

  if [[ $PORT_EXPOSED == "" ]]
  then
    PORT_EXPOSED="80"
  fi

  #clean name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  #compose setup
  mkdir -p "$PATH_PEGAZ_SERVICES_COMPAT/$NAME"
  cp "$PATH_PEGAZ_SERVICES_COMPAT/test/config.sh" "$PATH_PEGAZ_SERVICES_COMPAT/test/docker-compose.yml" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/"
  sed -i "s/test/$NAME/" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/docker-compose.yml"
  sed -i "s|IMAGE=.*|IMAGE=\"$IMAGE\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|SUBDOMAIN=.*|SUBDOMAIN=\"$NAME\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  sed -i "s|REDIRECTIONS=.*|REDIRECTIONS=\"\"|g" "$PATH_PEGAZ_SERVICES_COMPAT/$NAME/config.sh"
  if test $IS_PEGAZDEV == "1"
  then
    cp -R "$PATH_PEGAZ_SERVICES_COMPAT/$NAME" $PATH_PEGAZ_SERVICES
  fi
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
  UP $NAME
  test $? && exit;
}

BACKUP() {
  for service_name in $(EXECUTE "config --volumes" $1)
  do
    docker volume inspect "$1_$service_name"
  done
}

DROP() {
  echo "[?] Are you sure to drop $1 (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    EXECUTE 'down' $1
    rm -rf "$PATH_PEGAZ_SERVICES_COMPAT/$1" "$PATH_PEGAZ_SERVICES/$1"
  fi
}

UPGRADE() {
  cd $PATH_PEGAZ
  git stash
  git pull
  git stash pop
  echo "[√] pegaz is now upgraded"
}

UNINSTALL() {
  echo "[?] Are you sure to uninstall pegaz (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    sudo sed -i "\|$PATH_PEGAZ|d" $PATH_BASHRC
    sudo rm -rf $PATH_PEGAZ
    exec bash
    echo "[√] pegaz successfully uninstalled"
  fi
}

HELP() {
  echo "Core Commands:
usage: pegaz <command>

  help      -h       Print help
  version   -v       Print version
  upgrade            Upgrade pegaz
  uninstall          Uninstall pegaz
  config             Assistant to edit configurations stored in $FILENAME_CONFIG (main configurations or specific configurations if service named is passed)

Service Commands:
usage: pegaz <command> <service>

  up                 launch or update a web service with configuration set in $FILENAME_CONFIG and proxy settings set in $FILENAME_NGINX then execute $FILENAME_POSTINSTALL
  reset              down the service, prune it and finaly up again (useful for dev & test)
  create             create a service based on service/test/ (pegaz create <service_name> <dockerhub_image_name>)
  drop               down a service and remove its config folder
  dune               down & prune service (stop and remove containers, networks, images, and volumes)
  *                  down restart stop rm logs pull, any docker-compose commands are compatible

Services:

$SERVICES"
}

PRUNE() {
  docker system prune && docker volume prune
}

VERSION() {
  echo $VERSION
}

UP() {
  SETUP_PROXY
  PRE_INSTALL $1
  EXECUTE 'pull'  $1
  EXECUTE 'build' $1
  EXECUTE 'up -d' $1
  POST_INSTALL $1
}

UPDATE() {
  SETUP_PROXY
  EXECUTE 'pull'  $1
  EXECUTE 'build' $1
  EXECUTE 'up -d' $1
  SERVICE_INFOS $1
}

DUNE() {
  EXECUTE 'down' $1
  PRUNE
}

RESET() {
  DUNE $1
  UP $1
}

PS() {
  docker ps
}

LOGS() {
  EXECUTE 'logs -f'  $1
}

# MAIN

if [[ "$IS_PEGAZ_INSTALLED" -eq "0" ]]
then
  curl -sL get.pegaz.io | sudo bash
fi

source $PATH_PEGAZ/config.sh

# DEFAULT command
if ! test $1
then
  HELP
# ALIAS commands
elif [[ $1 = -* ]] || [[ $1 == "ps" ]]
then
  if ! test $2
  then
    ALIAS $1
  elif [[ $1 == "ps" ]]
  then
    EXECUTE $1 $2
  else
    echo "[x] $1 command doesn't need param, try to run 'pegaz $1'"
  fi
elif [[ " ${COMMANDS[*]} " =~ " $1 " ]]
then
# CORE commands
  if [[ " ${COMMANDS_CORE[*]} " =~ " $1 " ]]
  then
    if ! test $2
    then
      ${1^^}
    elif [[ $1 == "create" ]]
    then
      ${1^^} $2 $3
    else
      echo "[x] $1 command doesn't need param, try to run 'pegaz $1'"
    fi
# SERVICE commands
  elif [[ " ${COMMANDS_SERVICE[*]} " =~ " $1 " ]]
  then
    if test $2
    then
      if [[ " ${SERVICES_FLAT[*]} " =~ " $2 " ]]
      then
        ${1^^} $2
      else
        echo "[x] $2 is not on the list, $1 a service listed below :
$SERVICES"
      fi
    else
      for SERVICE in $SERVICES
      do
        ${1^^} $SERVICE
      done
    fi
# DOCKER-COMPOSE commands
  else
    if test $2
    then
      EXECUTE $1 $2
    else
      for SERVICE in $SERVICES
      do
        EXECUTE $1 $SERVICE
      done
    fi
  fi
else
  echo "[x] No such command: $1"
  HELP
fi
