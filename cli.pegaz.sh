#!/bin/bash

source /opt/pegaz/env.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
SERVICES_FLAT=$(echo $SERVICES | tr '\n' ' ')
IS_PEGAZDEV="false" && [[ $0 == "cli.pegaz.sh" ]] && IS_PEGAZDEV="true"
PATH_COMPAT="$(dirname $0)" # pegazdev compatibility (used for create/drop services)

# HELPERS

EXECUTE() {
  TEST_CONFIG
  SETUP_NETWORK
  local SERVICE_ALONE=""
  if test -f $PATH_PEGAZ_SERVICES/$2/config.sh
  then
    [[ $2 == "proxy" && $1 == "up -d" && $IS_PEGAZDEV == "true" ]] && SERVICE_ALONE="proxy"  # do not mount proxy-acme if dev, dev is http
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && source config.sh 2> /dev/null && docker-compose $1 $SERVICE_ALONE;)
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
    source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "[√] $1 is up (use pegaz logs $1 to know when the service is ready) \nhttp://$SUBDOMAIN.$DOMAIN \nhttp://127.0.0.1:$PORT"
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
  if grep -q "REDIRECTIONS=" "$PATH_SERVICE$FILENAME_CONFIG" && [[ $REDIRECTIONS != "" ]]
  then
    touch "$PATH_SERVICE$FILENAME_NGINX" "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_SERVICE$FILENAME_NGINX"
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    for REDIRECTION in $REDIRECTIONS
    do
      local FROM=${REDIRECTION%->*}
      local TO=${REDIRECTION#*->}
      if [[ $FROM == /* ]]; then # same domain
        echo "rewrite ^$FROM$ http://$SUBDOMAIN.$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_SERVICE$FILENAME_NGINX"
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
  if [[ -f "$PATH_SERVICE/$FILENAME_NGINX" ]]
  then
    local NEW_LINE="      - $PATH_SERVICE$FILENAME_NGINX:/etc/nginx/vhost.d/${SUBDOMAIN}.${DOMAIN}:ro"
    INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
  fi
}

SETUP_PROXY() {
  source "$PATH_PEGAZ/$FILENAME_CONFIG"
  PATH_PROXY_COMPOSE="$PATH_PEGAZ_SERVICES/proxy/docker-compose.yml"
  rm -rf "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
  sed -i "\|$PATH_PEGAZ_SERVICES|d" "$PATH_PROXY_COMPOSE"
  for PATH_SERVICE in `find $PATH_PEGAZ_SERVICES/*/ -type d`
  do
    local NAME_SERVICE=$(echo $PATH_SERVICE | sed "s%$PATH_PEGAZ_SERVICES%%")
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
  local NEW_LINE="      - $PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION:ro"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
  EXECUTE "up -d" "proxy"
}

PRE_INSTALL() {
  source $PATH_PEGAZ_SERVICES/$1/config.sh
  local PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_PREINSTALL"
  if test -f $PATH_SCRIPT
  then
    bash $PATH_SCRIPT $1 $IS_PEGAZDEV
  fi
}

POST_INSTALL() {
  if [[ $? -eq 0 ]]
  then
    local POST_INSTALL_TEST_CMD=""
    local POST_INSTALL_TEST_HTTP_CODE=""
    source $PATH_PEGAZ_SERVICES/$1/config.sh
    local PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_POSTINSTALL"
    if test -f $PATH_SCRIPT
    then
      echo "[*] post-install: wait for $1 up"
      if [[ -n $POST_INSTALL_TEST_CMD ]]
      then
        while :
        do
          $POST_INSTALL_TEST_CMD >> /dev/null
          if [[ $? -eq 0 ]]
          then
            echo "[*] $POST_INSTALL_TEST_CMD is enable, launch post-install.sh"
            bash $PATH_SCRIPT $1 &&\
            SERVICE_INFOS $1
            break
          else
            echo "retry $POST_INSTALL_TEST_CMD"
            continue
          fi
        done
      else
        [[ -z $POST_INSTALL_TEST_HTTP_CODE && $POST_INSTALL_TEST_HTTP_CODE == "200" ]]
        while :
        do
          HTTP_CODE=$(curl -ILs $SUBDOMAIN.$DOMAIN | head -n 1 | cut -d$' ' -f2)
          if [[ $HTTP_CODE == $POST_INSTALL_TEST_HTTP_CODE ]]
          then
            echo "[*] $SUBDOMAIN.$DOMAIN http code is $POST_INSTALL_TEST_HTTP_CODE, launch post-install.sh"
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
  fi
}

ADD_TO_HOSTS() {
  local PATH_CONFIG="$PATH_PEGAZ_SERVICES/$1/config.sh"
  local PATH_HOSTFILE="/etc/hosts"
  if [[ -f $PATH_CONFIG ]]
  then
    source $PATH_CONFIG
    if [[ -f $PATH_HOSTFILE ]]
    then
      if ! grep -q "$SUBDOMAIN.$DOMAIN" $PATH_HOSTFILE
      then
        echo "127.0.0.1    $SUBDOMAIN.$DOMAIN" | sudo tee -a $PATH_HOSTFILE
      fi
    fi
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

MANAGE_BACKUP() {
  mkdir -p $PATH_PEGAZ_BACKUP
  case $2 in
    backup)   EXECUTE "pause" $1;;
    restore)  EXECUTE "stop" $1;;
  esac
  echo "[*] $1 $2"
  for VOLUME in $(EXECUTE "config --volumes" $1)
  do
    local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
    local NAME_VOLUME=${VOLUME[0]}
    local PATH_VOLUME=${VOLUME[1]}
    if [[ -n $NAME_VOLUME ]]
    then
      local PATH_TARBALL="$PATH_PEGAZ_BACKUP/$NAME_VOLUME.tar.gz"
      case $2 in
        backup)
          docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_PEGAZ_BACKUP:/backup busybox tar czvf /backup/$NAME_VOLUME.tar.gz /$NAME_VOLUME;;
        restore)
          docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_PEGAZ_BACKUP:/backup busybox sh -c "cd /$NAME_VOLUME && tar xvf /backup/$NAME_VOLUME.tar.gz --strip 1";;
      esac
    fi
  done
  case $2 in
    backup)   EXECUTE "unpause" $1;;
    restore)  EXECUTE "start" $1;;
  esac
  echo "[√] $1 $2 done"
}

GET_LAST_PORT() {
  local THE_LAST_PORT="0"
  for PATH_SERVICE in `find $PATH_PEGAZ_SERVICES/*/ -type d`
  do
    local CURRENT_PORT=`sed -n 's/^export PORT=\(.*\)/\1/p' < "$PATH_SERVICE/$FILENAME_CONFIG"`
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

GET_STATE() {
  local RESTARTING="$(docker ps -a --format "{{.Names}} {{.State}}" | grep "$1" | grep "restarting")"
  if [[ -n $RESTARTING ]]
  then
    echo "restarting"
  else
    local STARTING="$(docker ps -a --format "{{.Names}} {{.Status}}" | grep "$1" | grep "starting")"
    if [[ -n $STARTING ]]
    then
      echo "starting"
    else
      local STATE="$(docker ps -a --format "{{.Names}} {{.State}}" | grep "$1 ")"
      if [[ -n $STATE ]]
      then
        STATE=${STATE/$1 /}
        STATE=${STATE/running/up}
        STATE=${STATE/exited/stopped}
        if [[ $STATE == "up" ]]
        then
          source "$PATH_PEGAZ_SERVICES/$1/config.sh"
          if [[ -n $SUBDOMAIN ]]
          then
            STATE="http://$SUBDOMAIN.$DOMAIN"
          fi
        fi
        echo $STATE
      fi
    fi
  fi
}

TEST_CONFIG() {
  source $PATH_PEGAZ/config.sh
  [[ -z $DOMAIN || -z $USERNAME || -z $PASSWORD ]] && echo "[!] config pegaz first" && CONFIG
  [[ $DOMAIN == "domain.com" && $IS_PEGAZDEV == "false" ]] && echo "[!] dont use default setting, please configure pegaz first" && CONFIG
}

# CORE COMMANDS

CONFIG() {
  source $PATH_COMPAT/config.sh
  [[ -n $DOMAIN ]] && echo "[?] Domain [$DOMAIN]:" || echo "[?] Domain :"
  read DOMAIN
  [[ -n $DOMAIN ]] && sed -i "s|DOMAIN=.*|DOMAIN=\"$DOMAIN\"|g" $PATH_COMPAT/config.sh;

  [[ -n $USERNAME ]] && echo "[?] Username [$USERNAME]:" || echo "[?] Username :"
  read USERNAME
  [[ -n $USERNAME ]] && sed -i "s|USERNAME=.*|USERNAME=\"$USERNAME\"|g" $PATH_COMPAT/config.sh

  echo "[?] Password"
  read -s PASSWORD
  [[ -n $PASSWORD ]] && sed -i "s|PASSWORD=.*|PASSWORD=\"$PASSWORD\"|g" $PATH_COMPAT/config.sh

  [[ -n $EMAIL ]] && echo "[?] EMAIL [$EMAIL]:" || echo "[?] EMAIL :"
  read EMAIL
  [[ -n $EMAIL ]] && sed -i "s|EMAIL=.*|EMAIL=\"$EMAIL\"|g" $PATH_COMPAT/config.sh

  echo -e "[?] Media Path [$MEDIA_DIR] \nwhere all media are stored (document for nextcloud, music for radio, video for jellyfin ...)) \na chmod 750 will be apply"
  read MEDIA_DIR
  [[ -n $MEDIA_DIR ]] && {
    [[ -d $MEDIA_DIR ]] && sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=\"$MEDIA_DIR\"|g" $PATH_COMPAT/config.sh || echo "[x] $MEDIA_DIR doesn't exist"
  }

  [[ $IS_PEGAZDEV == "true" ]] && cp $PATH_COMPAT/config.sh $PATH_PEGAZ
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
  create             create a service based on service/test (pegaz create <service_name> <dockerhub_image_name>)
  drop               down a service and remove its config folder
  dune               down & prune service (stop and remove containers, networks, images, and volumes)
  backup             archive volume(s) mounted on the service in $PATH_PEGAZ_BACKUP
  restore            replace volume(s) mounted on the service by backed up archive in $PATH_PEGAZ_BACKUP
  *                  down restart stop rm logs pull, any docker-compose commands are compatible

Services:

$SERVICES"
}

PRUNE() {
  docker system prune --all
  docker volume prune
}

VERSION() {
  echo $VERSION
}

PS() {
  docker ps
}

PORT() {
  echo "the next port available is $(GET_LAST_PORT)"
}

# SERVICE COMMANDS

STATE() {
  local STATE_SERVICE=$(GET_STATE $1)
  if [[ -n $STATE_SERVICE ]]
  then
    printf "%-20s %-20s\n" $1 $STATE_SERVICE
  fi
}

CREATE() {
  if test $2
  then
    local NAME=$1
    local IMAGE=$2
  elif test $1
  then
    local NAME=$1
    local IMAGE=$(docker search $1 --limit 1 --format "{{.Name}}")
  else
    while [[ !" ${SERVICES_FLAT} " =~ " $NAME " || ! $NAME ]]
    do
      echo "[?] Name"
      read NAME
    done
    local DELIMITER=") "
    local MAX_RESULT=7
    local LINE=0
    local RESULTS=$(docker search $NAME --limit $MAX_RESULT --format "{{.Name}}" | nl -w2 -s "$DELIMITER")
    while [[ $LINE -lt 1 || $LINE -gt $MAX_RESULT ]]
    do
      printf "$RESULTS\n"
      read LINE
    done
    IMAGE=$(sed -n ${LINE}p <<< "$RESULTS" 2> /dev/null)
    IMAGE=${IMAGE/ $LINE$DELIMITER/}
  fi

  [[ " ${SERVICES_FLAT} " =~ " $NAME " ]] && echo "[x] service $NAME already exist" && exit 1

  #ports setup
  local PORT=$(GET_LAST_PORT)
  PORT=$(($PORT + 5))
  docker pull $IMAGE
  [[ $? != 0 ]] && echo "[x] cant pull $IMAGE" && exit 1
  local PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')

  if [[ $PORT_EXPOSED == "" ]]
  then
    PORT_EXPOSED="80"
  fi

  #clean name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  #compose setup
  mkdir -p "$PATH_COMPAT/services/$NAME"
  cp "$PATH_COMPAT/services/test/config.sh" "$PATH_COMPAT/services/test/docker-compose.yml" "$PATH_COMPAT/services/$NAME/"
  sed -i "s/test/$NAME/" "$PATH_COMPAT/services/$NAME/docker-compose.yml"
  sed -i "s|IMAGE=.*|IMAGE=\"$IMAGE\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|SUBDOMAIN=.*|SUBDOMAIN=\"$NAME\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|REDIRECTIONS=.*|REDIRECTIONS=\"\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  if [[ $IS_PEGAZDEV == "true" ]]
  then
    cp -R "$PATH_COMPAT/services/$NAME" $PATH_PEGAZ_SERVICES
  fi
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d') # update services list
  UP $NAME
  [[ $? != 0 ]] && echo "[x] create fail" && exit 1
}

BACKUP() {
  [[ -n $(GET_STATE $1) ]] && MANAGE_BACKUP $1 "backup" || echo "$1 is not initialized"
}

RESTORE() {
  [[ -n $(GET_STATE $1) ]] && MANAGE_BACKUP $1 "restore" || echo "$1 is not initialized"
}

DROP() {
  echo "[?] Are you sure to drop $1 (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    EXECUTE "down" $1
    rm -rf "$PATH_COMPAT/services/$1" "$PATH_PEGAZ_SERVICES/$1"
  fi
}

UP() {
  SETUP_PROXY
  ADD_TO_HOSTS $1
  PRE_INSTALL $1
  EXECUTE "pull"  $1
  EXECUTE "build" $1
  EXECUTE "up -d" $1
  POST_INSTALL $1
}

START() {
  [[ -z $(GET_STATE $1) ]] && UP $1 || EXECUTE "start" $1
}

UPDATE() {
  SETUP_PROXY
  EXECUTE "pull"  $1
  EXECUTE "build" $1
  EXECUTE "up -d" $1
  SERVICE_INFOS $1
}

DUNE() {
  EXECUTE "down" $1
  PRUNE
}

RESET() {
  DUNE $1
  UP $1
}

LOGS() {
  [[ -n $(GET_STATE $1) ]] && EXECUTE "logs -f" $1 || echo "$1 is not initialized"
}

# MAIN

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
      elif [[ $1 == "backup" && $2 == "ls" ]]
      then
        echo -e "$(ls -lt $PATH_PEGAZ_BACKUP)"
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
