#!/bin/bash
source /opt/pegaz/env.sh

SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')
SERVICES_FLAT=$(echo $SERVICES | tr '\n' ' ')
IS_PEGAZDEV="false" && [[ $0 == "cli.pegaz.sh" ]] && IS_PEGAZDEV=true
PATH_COMPAT="$(dirname $0)" # pegazdev compatibility (used for create/drop services)

# HELPERS

EXECUTE() {
  TEST_CONFIG
  SETUP_NETWORK
  if [[ -d $PATH_PEGAZ_SERVICES/$2 ]]
  then
    cd $PATH_PEGAZ_SERVICES/$2
    [[ -f "$PATH_PEGAZ/config.sh" ]] && source "$PATH_PEGAZ/config.sh"
    [[ -f "config.sh" ]] && source "config.sh"
    [[ -f ".env" ]] && source ".env"
    docker-compose $1 2>&1 | grep -v "error while removing network"
  else
    echo "[x] $2 folder doesn't exist"
  fi
  # echo $1 $2
  local ACTION=("stop","down","pause","unpause")
  [[ "${ACTION[*]}" =~ "${1}" ]] && UPDATE_DASHBOARD $2
}

# CHECK_DEPS() {
  # sed >= 4.7
# }

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
      SOURCE_SERVICE $1
      echo "[i] use \`pegaz logs $1\` to know when the service is ready"
      echo "[√] $1 is up"
      echo "http://$DOMAIN"
      echo "http://127.0.0.1:$PORT"
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
  unset REDIRECTIONS
  SOURCE_SERVICE $1
  if [[ $REDIRECTIONS != "" ]]
  then
    PATH_FILE_REDIRECTION="$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"
    touch "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" $PATH_FILE_REDIRECTION
    REMOVE_LINE $AUTO_GENERATED_STAMP "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX"
    REMOVE_LINE $AUTO_GENERATED_STAMP $PATH_FILE_REDIRECTION
    for REDIRECTION in $REDIRECTIONS
    do
      local FROM=${REDIRECTION%->*}
      local TO=${REDIRECTION#*->}
      if [[ $FROM == /* ]]; then # same domain
        echo "rewrite ^$FROM$ http://$DOMAIN$TO permanent; $AUTO_GENERATED_STAMP" >> "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX"
      elif [[ $TO != "" ]]  # sub-domain
      then
        echo "server {" >> $PATH_FILE_REDIRECTION
        echo "  server_name $FROM.$MAIN_DOMAIN;" >> $PATH_FILE_REDIRECTION
        echo "  return 301 http://$DOMAIN$TO;" >> $PATH_FILE_REDIRECTION
        echo "}" >> $PATH_FILE_REDIRECTION
      fi
    done
  fi
}

SETUP_NGINX() {
  if [[ $DOMAIN != *localhost:* ]]
  then
    if [[ -f "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" ]]
    then
      if [[ -s "$PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX" ]]
      then
        local NEW_LINE="      - $PATH_PEGAZ_SERVICES/$1/$FILENAME_NGINX:/etc/nginx/vhost.d/${DOMAIN}_location"
        INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"
      fi
    fi
  fi
}

SETUP_PROXY() {
  [[ -f "$PATH_PEGAZ/$FILENAME_CONFIG" ]] && source "$PATH_PEGAZ/$FILENAME_CONFIG" || echo "[x] no pegaz main config file"
  PATH_PROXY_COMPOSE="$PATH_PEGAZ_SERVICES/proxy/docker-compose.yml"

  rm -rf "$PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION"  # delete old redirections
  sed -i "\|$PATH_PEGAZ_SERVICES|d" "$PATH_PROXY_COMPOSE"    # delete old vhosts
  for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
  do
    local NAME_SERVICE=$(basename $PATH_SERVICE)
    NAME_SERVICE=$(echo $NAME_SERVICE | sed "s%/%%g")
    [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]] && source "$PATH_SERVICE/$FILENAME_CONFIG"
    SETUP_REDIRECTIONS $NAME_SERVICE
    SETUP_NGINX $NAME_SERVICE
  done

  local NEW_LINE="      - $PATH_PEGAZ_SERVICES/proxy/$FILENAME_REDIRECTION:/etc/nginx/conf.d/$FILENAME_REDIRECTION"
  INSERT_LINE_AFTER "docker.sock:ro" "$NEW_LINE" "$PATH_PROXY_COMPOSE"

  EXECUTE "up -d" "proxy"
}

SETUP_STORJ() {
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
  if [[ -z $STORJ_BUCKET_NAME ]]
  then
    echo "[?] what's your storj bucket name ?"
    read STORJ_BUCKET_NAME
    [[ -n $STORJ_BUCKET_NAME ]] && sed -i "s|STORJ_BUCKET_NAME=.*|STORJ_BUCKET_NAME=\"$STORJ_BUCKET_NAME\"|g" $PATH_COMPAT/config.sh
  fi
}

SOURCE_SERVICE() {
  [[ -f "$PATH_PEGAZ_SERVICES/$1/$FILENAME_CONFIG" ]] && source "$PATH_PEGAZ_SERVICES/$1/$FILENAME_CONFIG"
  [[ -f "$PATH_PEGAZ_SERVICES/$1/$FILENAME_ENV" ]] && source "$PATH_PEGAZ_SERVICES/$1/$FILENAME_ENV"
}

PRE_INSTALL() {
  SOURCE_SERVICE $1
  local PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_PREINSTALL"
  if [[ -f $PATH_SCRIPT ]]
  then
    echo "[*] pre-install"
    bash $PATH_SCRIPT $1 $IS_PEGAZDEV
  fi
}

POST_INSTALL() {
  local POST_INSTALL_TEST_CMD=""
  SOURCE_SERVICE $1
  local PATH_SCRIPT="$PATH_PEGAZ_SERVICES/$1/$FILENAME_POST_INSTALL"
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
          bash $PATH_SCRIPT $1
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
  if $IS_PEGAZDEV
  then
    [[ -f "/etc/hosts" ]] && local PATH_HOSTFILE="/etc/hosts"
    [[ -f "/etc/host" ]] && local PATH_HOSTFILE="/etc/host"
    SOURCE_SERVICE $1
    if [[ $DOMAIN == *$MAIN_DOMAIN* && -f $PATH_HOSTFILE ]]
    then
        if ! grep -q "$DOMAIN" $PATH_HOSTFILE
        then
          echo "127.0.0.1    $DOMAIN" | sudo tee -a $PATH_HOSTFILE >> /dev/null
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
  [[ -z $(GET_STATE $1) ]] && echo "$1 is not initialized" && exit 1
  mkdir -p $PATH_PEGAZ_BACKUP
  case $2 in
    storjbackup | storjrestore) SETUP_STORJ;;
  esac
  case $2 in
    backup | storjbackup)   EXECUTE "pause" $1;;
    restore | storjrestore) EXECUTE "stop" $1;;
  esac
  echo "[*] $2 $1"
  for VOLUME in $(EXECUTE "config --volumes" $1)
  do
    local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
    local NAME_VOLUME=${VOLUME[0]}
    if [[ -n $NAME_VOLUME ]]
    then
      local PATH_TARBALL="$PATH_PEGAZ_BACKUP/$NAME_VOLUME.tar.gz"
      [[ $2 == "backup" || $2 == "storjbackup" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_PEGAZ_BACKUP:/backup busybox tar czvf /backup/$NAME_VOLUME.tar.gz /$NAME_VOLUME
      [[ $2 == "storjbackup" ]] && uplink cp --progress -r $PATH_PEGAZ_BACKUP/$NAME_VOLUME.tar.gz sj://$STORJ_BUCKET_NAME
      [[ $2 == "storjrestore" ]] && uplink cp --progress -r sj://$STORJ_BUCKET_NAME/$NAME_VOLUME.tar.gz $PATH_PEGAZ_BACKUP
      [[ $2 == "restore" || $2 == "storjrestore" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_PEGAZ_BACKUP:/backup busybox sh -c "cd /$NAME_VOLUME && tar xvf /backup/$NAME_VOLUME.tar.gz --strip 1"
    fi
  done
  case $2 in
    backup | storjbackup)   EXECUTE "unpause" $1;;
    restore | storjrestore)  EXECUTE "start" $1;;
  esac
  echo "[√] $1 $2 done"
}

GET_LAST_PORT() {
  local THE_LAST_PORT="0"
  for PATH_SERVICE in $PATH_PEGAZ_SERVICES/*
  do
    [[ $PATH_SERVICE == "$PATH_PEGAZ_SERVICES/deluge" ]] && continue
    if [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" || -f "$PATH_SERVICE/$FILENAME_ENV" ]]
    then
      if [[ -f "$PATH_SERVICE/$FILENAME_CONFIG" ]]
      then
        SED_PREFIX="export PORT" && FILENAME=$FILENAME_CONFIG
      else
        SED_PREFIX="PORT" && FILENAME=$FILENAME_ENV
      fi
      local CURRENT_PORT=`sed -n "s/^$SED_PREFIX\(.*\)/\1/p" < "$PATH_SERVICE/$FILENAME"`
      CURRENT_PORT=$(echo $CURRENT_PORT | tr ' ' '\n' | grep -v '_EXPOSED=' | grep -o -E '[0-9]+' | sort -nr | head -n1)
    fi
    if [[ $CURRENT_PORT ]]
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
  local RESTARTING="$(docker ps -a -f "status=restarting" --format "{{.Names}} {{.State}}" | grep "$1")"
  if [[ -n $RESTARTING ]]
  then
    echo "restarting"
  else
    local STARTING="$(docker ps -a -f "status=created" --format "{{.Names}} {{.Status}}" | grep "$1" )"
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
          SOURCE_SERVICE $1
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

UPDATE_DASHBOARD() {
  [[ $1 != "dashboard" && -n $(GET_STATE "dashboard") ]] && source "$PATH_PEGAZ_SERVICES/dashboard/config.sh" && bash "$PATH_PEGAZ_SERVICES/dashboard/$FILENAME_POST_INSTALL" "dashboard"
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

  echo "[?] ZeroSSL API key (optional):"
  read ZEROSSL_API_KEY
  [[ -n $ZEROSSL_API_KEY ]] && sed -i "s|ZEROSSL_API_KEY=.*|ZEROSSL_API_KEY=\"$ZEROSSL_API_KEY\"|g" $PATH_COMPAT/config.sh

  $IS_PEGAZDEV && cp $PATH_COMPAT/config.sh $PATH_PEGAZ
}


UPGRADE() {
  echo "[i] upgrade keep config.sh and custom services"
  echo "[?] Are you sure to upgrade pegaz (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    rm -rf /tmp/pegaz
    git clone $GITHUB_PEGAZ /tmp/pegaz
    chmod -R 750 /tmp/pegaz
    rm $PATH_PEGAZ/env.sh $PATH_PEGAZ/completion.sh $PATH_PEGAZ/cli.pegaz.sh

    mv /tmp/pegaz/env.sh $PATH_PEGAZ
    mv /tmp/pegaz/completion.sh $PATH_PEGAZ
    mv /tmp/pegaz/cli.pegaz.sh $PATH_PEGAZ
    rm -rf $PATH_PEGAZ/template
    mv /tmp/pegaz/template $PATH_PEGAZ

    rsync -raz --ignore-existing /tmp/pegaz/services/* $PATH_PEGAZ_SERVICES
    rsync -raz --exclude "$PATH_PEGAZ_SERVICES/dashboard/web/index.html" --exclude "*config.sh" /tmp/pegaz/services/* $PATH_PEGAZ_SERVICES

    source $PATH_PEGAZ/env.sh
    echo "[√] pegaz is now upgraded (v$PEGAZ_VERSION)"
  fi
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
  echo "pegaz v$PEGAZ_VERSION
Core Commands:
usage: pegaz <command>

  help      -h       Print help
  version   -v       Print version
  upgrade            Upgrade pegaz
  uninstall          Uninstall pegaz
  config             Assistant to edit configurations stored in $FILENAME_CONFIG (specific configurations if service named is passed)

Service Commands:
usage: pegaz <command> <service_name>
       pegaz <command> (command will be apply for all services)

  up                 launch or update a web service with configuration set in $FILENAME_CONFIG and proxy settings set in $FILENAME_NGINX then execute $FILENAME_POST_INSTALL
  create             create a service based on template/ (pegaz create <service_name> <dockerhub_image_name>)
  drop               down a service and remove its config folder
  backup             archive volume(s) mounted on the service in $PATH_PEGAZ_BACKUP
  restore            replace volume(s) mounted on the service by backed up archive in $PATH_PEGAZ_BACKUP
  storjbackup        send volume(s) to a storj bucket
  storjrestore       copy-back volume(s) from a storj bucket
  reset              down a service and prune containers, images and volumes not linked to up & running containers (useful for dev & test)
  init               copy files from template directory to the current directory (useful to init pegaz ci in your repo) 
  *                  restart stop down rm logs pull ... any docker-compose commands are compatible

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

INIT() {
  cp "$PATH_COMPAT/template/.drone.yml" ./
  cp "$PATH_COMPAT/template/docker-compose.yml" ./
  cp "$PATH_COMPAT/template/config.sh" ./
  NAME=${PWD##*/}
  sed -i "s|__SERVICE_NAME__|$NAME|g" .drone.yml
  sed -i "s|__SERVICE_NAME__|$NAME|g" docker-compose.yml
}

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
  PORT=$(($PORT + 3))
  docker pull $IMAGE
  [[ $? != 0 ]] && echo "[x] cant pull $IMAGE" && exit 1
  local PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//')
  [[ $PORT_EXPOSED == "443" ]] && PORT_EXPOSED=$(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE | grep -o -E '[0-9]+' | head -2 | sed -e 's/^0\+//')

  [[ $PORT_EXPOSED == "" ]] && PORT_EXPOSED="80"

  #clean name
  NAME=${NAME//[^a-zA-Z0-9_]/}
  NAME=${NAME,,}

  #compose setup
  mkdir -p "$PATH_COMPAT/services/$NAME"
  cp -r "$PATH_COMPAT/template/"* "$PATH_COMPAT/services/$NAME"
  cp "$PATH_COMPAT/template/.drone.yml" "$PATH_COMPAT/services/$NAME"
  sed -i "s|__SERVICE_NAME__|$NAME|g" "$PATH_COMPAT/services/$NAME/.drone.yml"
  sed -i "s|__SERVICE_NAME__|$NAME|g" "$PATH_COMPAT/services/$NAME/docker-compose.yml"
  sed -i "s|__SERVICE_NAME__|$NAME|g" "$PATH_COMPAT/services/$NAME/README.md"
  sed -i "s|image:.*|image: $IMAGE|g" "$PATH_COMPAT/services/$NAME/docker-compose.yml"
  sed -i "s|version: .*|version: $IMAGE|g" "$PATH_COMPAT/services/$NAME/README.md"
  sed -i "s|DOMAIN=.*|DOMAIN=\"$NAME.\$MAIN_DOMAIN\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|PORT=.*|PORT=\"$PORT\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|PORT_EXPOSED=.*|PORT_EXPOSED=\"$PORT_EXPOSED\"|g" "$PATH_COMPAT/services/$NAME/config.sh"
  sed -i "s|REDIRECTIONS=.*|REDIRECTIONS=\"\"|g" "$PATH_COMPAT/services/$NAME/config.sh"

  if [[ $IMAGE == "ghost" ]]
  then
    sed -i '/    environment:/a\      database__connection__filename: "content/data/ghost.db"' "$PATH_COMPAT/services/$NAME/docker-compose.yml"
    sed -i '/    environment:/a\      database__client: "sqlite3"' "$PATH_COMPAT/services/$NAME/docker-compose.yml"
  fi

  if $IS_PEGAZDEV
  then
    cp -R "$PATH_COMPAT/services/$NAME" $PATH_PEGAZ_SERVICES
  fi
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d') # update services list
  UP $NAME
  [[ $? != 0 ]] && echo "[x] create fail" && exit 1
}

BACKUP() {
  MANAGE_BACKUP $1 "backup"
}

RESTORE() {
  MANAGE_BACKUP $1 "restore"
}

STORJBACKUP() {
  MANAGE_BACKUP $1 "storjbackup"
}

STORJRESTORE() {
  MANAGE_BACKUP $1 "storjrestore"
}

DROP() {
  local LOCAL_PATH=$(pwd)
  echo "[?] Are you sure to drop $1 (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    EXECUTE "down" $1
    $IS_PEGAZDEV && cd $LOCAL_PATH
    rm -rf "$PATH_COMPAT/services/$1" "$PATH_PEGAZ_SERVICES/$1"
  fi
}

UP() {
  ADD_TO_HOSTS $1
  PRE_INSTALL $1
  EXECUTE "pull"  $1
  EXECUTE "build" $1
  EXECUTE "up -d" $1
  POST_INSTALL $1
  SETUP_PROXY
  UPDATE_DASHBOARD $1
  SERVICE_INFOS $1
}

START() {
  [[ -z $(GET_STATE $1) ]] && UP $1 || EXECUTE "start" $1
}

UPDATE() {
  EXECUTE "pull"  $1
  EXECUTE "build --pull" $1
  EXECUTE "up -d" $1
  UPDATE_DASHBOARD $1
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
        echo -e "$(ls -lth $PATH_PEGAZ_BACKUP)"
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
