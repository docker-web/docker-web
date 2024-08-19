#!/bin/bash
source /var/docker-web/config.sh
source /var/docker-web/src/env.sh

for COMMAND in $PATH_DOCKERWEB/src/*/*.sh; do
  [ -f "$COMMAND" ] && source "$COMMAND"
done

# DEFAULT command
if ! test $1
then
  HELP
# ALIAS commands
elif [[ $1 == -* ]] || [[ $1 == "ps" ]]
then
  if ! test $2
  then
    SET_ALIAS $1
  elif [[ $1 == "ps" ]]
  then
    EXECUTE $1 $2
  else
    echo "[x] $1 command doesn't need param, try to run 'docker-web $1'"
  fi
elif [[ " ${COMMANDS[*]} " =~ " $1 " ]]
then
# CORE commands
  if [[ " ${COMMANDS_CORE[*]} " =~ " $1 " ]]
  then
    if ! test $2
    then
      ${1^^}
    elif [[ $1 == "create" ]] || [[ $1 == "init" ]]
    then
      ${1^^} $2 $3
    else
      echo "[x] $1 command doesn't need param, try to run 'docker-web $1'"
    fi
# APP commands
  elif [[ " ${COMMANDS_APP[*]} " =~ " $1 " ]]
  then
    if test $2
    then
      if [[ " ${APPS_FLAT[*]} " =~ " $2 " ]]
      then
        ${1^^} $2
      elif [[ $1 == "backup" && $2 == "ls" ]]
      then
        echo -e "$(ls -lth $PATH_DOCKERWEB_BACKUP)"
      else
        echo "[x] $2 is not on the list, $1 an app listed below :
$APPS"
      fi
    else
      for APP in $APPS
      do
        ${1^^} $APP
      done
    fi
# DOCKER-COMPOSE commands
  else
    if test $2
    then
      EXECUTE $1 $2
    else
      for APP in $APPS
      do
        EXECUTE $1 $APP
      done
    fi
  fi
# DOCKER-WEB CLI FUNCTIONS
elif FUNCTION_EXISTS $1
  then
    "$@"
else
  echo "[x] No such command: $1"
fi
