#!/bin/bash

_pegaz() {
  source "/opt/pegaz/env.sh"
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -exec basename {} \; | sort | sed '/^$/d')

  local cur prev
  CUR="${COMP_WORDS[COMP_CWORD]}"
  PREV="${COMP_WORDS[COMP_CWORD-1]}"
  PREV_PREV="${COMP_WORDS[COMP_CWORD-2]}"

  if test $COMP_CWORD -eq 1
  then
    COMPREPLY=( $(compgen -W "${COMMANDS[*]}" -- ${CUR}) )
  elif test $COMP_CWORD -eq 2
  then
    if [[ " ${COMMANDS_CORE} " =~ " ${PREV} " ]]
    then
      return 0
    elif [[ " ${COMMANDS} " =~ " ${PREV} " ]]
    then
      COMPREPLY=($(compgen -W "$SERVICES" -- ${CUR}))
    fi
  elif test $COMP_CWORD -eq 3
  then
    case "$PREV_PREV" in
      create) IMAGES=$(docker search $PREV --limit 20 --format "{{.Name}}") && COMPREPLY=($(compgen -W "$IMAGES" -- ${CUR}));;
    esac
  fi

  return 0
}

complete -F _pegaz pegaz pegazdev
