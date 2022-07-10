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
  EXECUTE "up -d" "proxy"
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
  if [[ $? -eq 0 ]]
  then
    POST_INSTALL_TEST_CMD=""
    POST_INSTALL_TEST_HTTP_CODE=""
    source $PATH_PEGAZ_SERVICES/$1/config.sh
    PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_POSTINSTALL"
    if test -f $PATH_SCRIPT
    then
      echo "[*] post-install: wait for $1"
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
        [[ -z $POST_INSTALL_TEST_HTTP_CODE ]] && POST_INSTALL_TEST_HTTP_CODE="200"
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
  echo "[*] $1 $2"
  case $2 in
    backup)   EXECUTE "pause" $1;;
    restore)  EXECUTE "stop" $1;;
  esac
  for VOLUME in $(EXECUTE "config --volumes" $1)
  do
    NAME_VOLUME=$(docker volume inspect --format "{{.Name}}" "$1_$VOLUME" 2> /dev/null)
    PATH_VOLUME=$(docker volume inspect --format "{{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null)
    if [[ -n $NAME_VOLUME ]]
    then
      PATH_VOLUME_BACKUP="$PATH_PEGAZ_BACKUP/$NAME_VOLUME.tar.gz"
      case $2 in
        backup)
          sudo tar -czf $PATH_VOLUME_BACKUP -C $PATH_VOLUME .
          sudo chown -R $SUDO_USER:$SUDO_USER $PATH_VOLUME_BACKUP
          sudo chmod -R 750 $PATH_VOLUME_BACKUP;;
        restore)
          sudo rm -rf $PATH_VOLUME && sudo mkdir $PATH_VOLUME
          sudo tar -xf $PATH_VOLUME_BACKUP -C $PATH_VOLUME;;
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

GET_STATE() {
  local STATE="$(docker ps -a --format "{{.Names}} {{.State}}" | grep "$1 ")"
  STATE=${STATE/$1/}
  STATE=${STATE/running/up}
  STATE=${STATE/exited/stopped}
  echo $STATE
}

# CORE COMMANDS

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

  echo -e "[?] Media Path [$MEDIA_DIR] \nwhere all media are stored (document for nextcloud, music for radio, video for jellyfin ...))"
  echo -e "this script will set it to www-data as owner & 750 as default file mode"
  read MEDIA_DIR
  if test $MEDIA_DIR
  then
    sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=$MEDIA_DIR|g" $PATH_PEGAZ/config.sh
    chown -R www-data:www-data $MEDIA_DIR
    chmod -R 750 $MEDIA_DIR
  fi

  if test $IS_PEGAZDEV == "1"
  then
    cp ./config.sh $PATH_PEGAZ
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
  docker system prune && docker volume prune
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
    rm -rf "$PATH_PEGAZ_SERVICES_COMPAT/$1" "$PATH_PEGAZ_SERVICES/$1"
  fi
}

UP() {
  SETUP_PROXY
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
