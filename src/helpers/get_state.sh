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
        if [[ $STATE == "up" && $1 != "proxy" ]]
        then
          SOURCE_SERVICE $1
          if [[ -n $DOMAIN ]]
          then
            STATE="http://$DOMAIN"
          fi
        elif [[ $1 == "proxy" ]]
        then
          STATE="up"
        fi
        echo $STATE
      fi
    fi
  fi
}
