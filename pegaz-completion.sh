#!/bin/bash
_pegaz_completions() {
  PATH_PEGAZ="/etc/pegaz"
  PATH_PEGAZ_SERVICES="$PATH_PEGAZ/src"
  COMMANDS=('config' 'up' 'update' 'down' 'upgarde' 'uninstall')
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

  if [ -z "$2" ]; then
    COMPREPLY=($(compgen -W "$(echo $SERVICES)" "${COMP_WORDS[1]}"))
  elif [ -z "$1" ]; then
    COMPREPLY=($(compgen -W "$(echo ${COMMANDS[*]})" "${COMP_WORDS[1]}"))
  fi

}

complete -F _pegaz_completions pegaz
