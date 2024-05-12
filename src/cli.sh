#!/bin/bash
for script in src/*.sh src/*/*.sh; do
  [ -f "$script" ] && [ "${script##*/}" != "${0##*/}" ] && source "$script"
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
        echo -e "$(ls -lth $PATH_DOCKERWEB_BACKUP)"
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
# DOCKER-WEB CLI FUNCTIONS
elif FUNCTION_EXISTS $1
  then
    "$@"
else
  echo "[x] No such command: $1"
fi
