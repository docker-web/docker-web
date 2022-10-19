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
  if test -f $PATH_PEGAZ_SERVICES/$2/config.sh
  then
    (cd $PATH_PEGAZ_SERVICES/$2 || return; source $PATH_PEGAZ/config.sh && source config.sh 2> /dev/null && docker-compose $1;)
    UPDATE_DASHBOARD $2
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
  if [[ -f $PATH_PEGAZ_SERVICES/$1/config.sh ]]
  then
    if [[ $1 == "proxy" ]]
    then
      echo -e "[√] $1 is up"
    else
      source $PATH_PEGAZ/config.sh && source $PATH_PEGAZ_SERVICES/$1/config.sh && echo -e "[√] $1 is up (use pegaz logs $1 to know when the service is ready) \nhttp://$DOMAIN"
      if [[ $IS_PEGAZDEV == "true" ]]
      then
        echo "http://127.0.0.1:$PORT"
      fi
    fi
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
      local FROM=${REDIRECTION%->*}
      local TO=${REDIRECTION#*->}
      if [[ $FROM == /* ]]; then # same domain
        echo "rewrite ^$FROM$ http://$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX"
      elif [[ $TO != "" ]]  # sub-domain
      then
        echo "server {" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "  server_name $FROM.$MAIN_DOMAIN;" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "  return 301 http://$DOMAIN$TO;" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
        echo "}" >> "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
      fi
    done
  fi
}

SETUP_NGINX() {
  if [[ -f "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" ]]
  then
    if [[ -s "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" ]]
    then
      local NEW_LINE="      - $PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX:/etc/nginx/vhost.d/${DOMAIN}_location"
      INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
    fi
  fi
}

SETUP_PROXY() {
  source "$PATH_PEGAZ/$FILENAME_CONFIG"
  PATH_PROXY_COMPOSE="$PATH_PEGAZ_SERVICES/proxy/docker-compose.yml"
  rm -rf "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
  sed -i "\|$PATH_PEGAZ_SERVICES|d" "$PATH_PROXY_COMPOSE"
  for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
  do
    local NAME_SERVICE=$(basename $PATH_SERVICE)
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
    echo "[*] pre-install"
    bash $PATH_SCRIPT $1 $IS_PEGAZDEV
  fi
}

POST_INSTALL() {
  local POST_INSTALL_TEST_CMD=""
  source "$PATH_PEGAZ_SERVICES/$1/config.sh"
  local PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_POSTINSTALL"
  if [[ -f $PATH_SCRIPT ]]
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
          break
        else
          continue
        fi
      done
    else
      while :
      do
        HTTP_CODE=$(curl -ILs $DOMAIN | head -n 1 | cut -d$' ' -f2)
        if [[ $HTTP_CODE < "400" ]]
        then
          echo "[*] $DOMAIN http status code is $HTTP_CODE, launch post-install.sh"
          bash $PATH_SCRIPT $1 &&\
          break
        else
          continue
        fi
      done
    fi
  fi
}

ADD_TO_HOSTS() {
  if [[ $IS_PEGAZDEV == "true" ]]
  then
    local PATH_CONFIG="$PATH_PEGAZ_SERVICES/$1/config.sh"
    local PATH_HOSTFILE="/etc/hosts"
    if [[ -f $PATH_CONFIG ]]
    then
      source $PATH_CONFIG
      if [[ -f $PATH_HOSTFILE ]]
      then
        if ! grep -q "$DOMAIN" $PATH_HOSTFILE
        then
          echo "127.0.0.1    $DOMAIN" | sudo tee -a $PATH_HOSTFILE >> /dev/null
        fi
      fi
    fi
  fi
}

SET_ALIAS() {
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

STORJ() {
  if ! command -v "unzip" 1>/dev/null
  then
    sudo apt install unzip
  fi
  if ! command -v "uplink" 1>/dev/null
  then
    echo "[*] install uplink"
    curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip
    unzip -o uplink_linux_amd64.zip
    sudo install uplink /usr/local/bin/uplink
    rm uplink_linux_amd64.zip
    uplink setup
  fi
  echo "what's your bucket name ?"
  read BUCKET_NAME
  if [[ -z $1 ]] || [[ $1 == "backup" ]]
  then
    uplink cp -r --progress /opt/pegaz/backup sj://$BUCKET_NAME
  elif [[ $1 == "restore" ]]
  then
    mkdir -p $PATH_PEGAZ_BACKUP
    uplink cp -r --progress sj://$BUCKET_NAME /opt/pegaz/backup
  fi
}

GET_LAST_PORT() {
  local THE_LAST_PORT="0"
  for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
  do
    [[ $PATH_SERVICE == "$PATH_PEGAZ_SERVICES/deluge" ]] && continue
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
          if [[ -n $DOMAIN ]]
          then
            STATE="http://$DOMAIN"
          fi
        fi
        echo $STATE
      fi
    fi
  fi
}

TEST_CONFIG() {
  source $PATH_PEGAZ/config.sh
  [[ -z $MAIN_DOMAIN || -z $USERNAME || -z $PASSWORD ]] && echo "[!] config pegaz first" && CONFIG
  [[ $MAIN_DOMAIN == "domain.com" && $IS_PEGAZDEV == "false" ]] && echo "[!] please configure pegaz first" && CONFIG
}

# CORE COMMANDS

CONFIG() {
  source $PATH_COMPAT/config.sh
  [[ -n $MAIN_DOMAIN ]] && echo "[?] Domain [$MAIN_DOMAIN]:" || echo "[?] Domain:"
  read NEW_MAIN_DOMAIN
  [[ -n $NEW_MAIN_DOMAIN ]] && sed -i "s|MAIN_DOMAIN=.*|MAIN_DOMAIN=\"$NEW_MAIN_DOMAIN\"|g" $PATH_COMPAT/config.sh;

  [[ -n $USERNAME ]] && echo "[?] Username [$USERNAME]:" || echo "[?] Username:"
  read NEW_USERNAME
  [[ -n $NEW_USERNAME ]] && sed -i "s|USERNAME=.*|USERNAME=\"$NEW_USERNAME\"|g" $PATH_COMPAT/config.sh

  echo "[?] Password:"
  read -s PASSWORD
  [[ -n $PASSWORD ]] && sed -i "s|PASSWORD=.*|PASSWORD=\"$PASSWORD\"|g" $PATH_COMPAT/config.sh

  [[ $EMAIL == "user@domain.com" && -n $NEW_USERNAME && -n $NEW_MAIN_DOMAIN ]] && EMAIL="$NEW_USERNAME@$NEW_MAIN_DOMAIN"
  [[ -n $EMAIL ]] && echo "[?] Email [$EMAIL]:" || echo "[?] Email:"
  read NEW_EMAIL
  if [[ -n $NEW_EMAIL ]]
  then
    sed -i "s|EMAIL=.*|EMAIL=\"$NEW_EMAIL\"|g" $PATH_COMPAT/config.sh
  else
    sed -i "s|EMAIL=.*|EMAIL=\"$EMAIL\"|g" $PATH_COMPAT/config.sh
  fi

  echo -e "[?] Media Path [$MEDIA_DIR]:"
  read MEDIA_DIR
  [[ -n $MEDIA_DIR ]] && {
    [[ -d $MEDIA_DIR ]] && sed -i "s|MEDIA_DIR=.*|MEDIA_DIR=\"$MEDIA_DIR\"|g" $PATH_COMPAT/config.sh || echo "[x] $MEDIA_DIR doesn't exist"
  }

  echo "[?] ZeroSSL API key:"
  read ZEROSSL_API_KEY
  [[ -n $ZEROSSL_API_KEY ]] && sed -i "s|ZEROSSL_API_KEY=.*|ZEROSSL_API_KEY=\"$ZEROSSL_API_KEY\"|g" $PATH_COMPAT/config.sh

  [[ $IS_PEGAZDEV == "true" ]] && cp $PATH_COMPAT/config.sh $PATH_PEGAZ
}


UPGRADE() {
  rm -rf /tmp/pegaz
  git clone $GITHUB_PEGAZ /tmp/pegaz
  chmod -R 750 /tmp/pegaz
  rm $PATH_PEGAZ/env.sh $PATH_PEGAZ/completion.sh $PATH_PEGAZ/cli.pegaz.sh
  rm -rf $PATH_PEGAZ/services/proxy
  rm -rf $PATH_PEGAZ/services/dashboard

  mv /tmp/pegaz/env.sh $PATH_PEGAZ
  mv /tmp/pegaz/completion.sh $PATH_PEGAZ
  mv /tmp/pegaz/cli.pegaz.sh $PATH_PEGAZ
  mv /tmp/pegaz/services/proxy $PATH_PEGAZ/services
  mv /tmp/pegaz/services/dashboard $PATH_PEGAZ/services

  source $PATH_PEGAZ/env.sh
  echo "[√] pegaz is now upgraded (v$PEGAZ_VERSION)"
}

UNINSTALL() {
  echo "[?] Are you sure to uninstall pegaz (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    sudo sed -i "\|$PATH_PEGAZ|d" $PATH_BASHRC
    if [[ -n $SUDO_USER ]]
    then
      sudo sed -i "\|$PATH_PEGAZ|d" "/home/$SUDO_USER/.bashrc"
    elif [[ -f "/home/$USER/.bashrc" ]]
    then
      sudo sed -i "\|$PATH_PEGAZ|d" "/home/$USER/.bashrc"
    fi
    sudo rm -rf $PATH_PEGAZ/services $PATH_PEGAZ/docs
    sudo rm $PATH_PEGAZ/* 2> /dev/null # no -rf to delete only file & keep backup & media folder is exist
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
  create             create a service based on service/test (pegaz create <service_name> <dockerhub_image_name>)
  drop               down a service and remove its config folder
  backup             archive volume(s) mounted on the service in $PATH_PEGAZ_BACKUP
  storj              copy backup to a distant bucket with storj (vice-versa if 'pegaz store restore')
  restore            replace volume(s) mounted on the service by backed up archive in $PATH_PEGAZ_BACKUP
  reset              down a service and prune containers, images and volumes not linked to up & running containers (useful for dev & test)
  *                  down restart stop rm logs pull, any docker-compose commands are compatible

Services:

$SERVICES"
}

VERSION() {
  echo $PEGAZ_VERSION
}

PS() {
  docker ps
}

PORT() {
  echo "the last port used is $(GET_LAST_PORT)"
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
  cp "$PATH_COMPAT/docs/pegaz.svg" "$PATH_COMPAT/services/$NAME/logo.svg"
  cp "$PATH_COMPAT/services/test/config.sh" "$PATH_COMPAT/services/test/docker-compose.yml" "$PATH_COMPAT/services/$NAME/"
  sed -i "s/test/$NAME/" "$PATH_COMPAT/services/$NAME/docker-compose.yml"
  sed -i "s|IMAGE=.*|IMAGE=\"$IMAGE\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.$MAIN_DOMAIN\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
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

UPDATE_DASHBOARD() {
  [[ $1 != "dashboard" && -n $(GET_STATE "dashboard") ]] && bash "$PATH_PEGAZ_SERVICES/dashboard/$FILENAME_POSTINSTALL" "dashboard"
}

UP() {
  SETUP_PROXY
  ADD_TO_HOSTS $1
  PRE_INSTALL $1
  EXECUTE "pull"  $1
  EXECUTE "build" $1
  EXECUTE "up -d" $1
  POST_INSTALL $1
  UPDATE_DASHBOARD $1
  SERVICE_INFOS $1
}

START() {
  [[ -z $(GET_STATE $1) ]] && UP $1 || EXECUTE "start" $1
}

UPDATE() {
  SETUP_PROXY
  EXECUTE "build --pull"  $1
  EXECUTE "up -d" $1
  SERVICE_INFOS $1
}

RESET() {
  EXECUTE "stop" $1
  EXECUTE "rm -f" $1
}

LOGS() {
  [[ -n $(GET_STATE $1) ]] && EXECUTE "logs -f" $1 || echo "$1 is not initialized"
}

# MAIN SCRIPT

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
    SET_ALIAS $1
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
    elif [[ $1 == "create" || $1 == "storj" ]]
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

