GET_LAST_PORT() {
  local THE_LAST_PORT="0"
  for PATH_SERVICE in $PATH_DOCKERWEB_SERVICES/*
  do
    [[ $PATH_SERVICE == "$PATH_DOCKERWEB_SERVICES/deluge" || $PATH_SERVICE == "$PATH_DOCKERWEB_SERVICES/transmission" ]] && continue
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
