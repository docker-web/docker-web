GET_LAST_PORT() {
  local THE_LAST_PORT="0"
  for PATH_APP in $PATH_DOCKERWEB_APPS/*
  do
    [[ $PATH_APP == "$PATH_DOCKERWEB_APPS/deluge" || $PATH_APP == "$PATH_DOCKERWEB_APPS/transmission" ]] && continue
    if [[ -f "$PATH_APP/$FILENAME_CONFIG" || -f "$PATH_APP/$FILENAME_ENV" ]]
    then
      if [[ -f "$PATH_APP/$FILENAME_CONFIG" ]]
      then
        SED_PREFIX="export PORT" && FILENAME=$FILENAME_CONFIG
      else
        SED_PREFIX="PORT" && FILENAME=$FILENAME_ENV
      fi
      local CURRENT_PORT=`sed -n "s/^$SED_PREFIX\(.*\)/\1/p" < "$PATH_APP/$FILENAME"`
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
