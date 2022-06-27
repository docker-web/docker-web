#!/bin/bash

_pegaz() {
  source "/opt/pegaz/env.sh"
  SERVICES=$(find $PATH_PEGAZ_SERVICES -mindepth 1 -maxdepth 1 -not -name '.*' -type d -printf '  %f\n' | sort | sed '/^$/d')

  local cur prev prev2
  COMPREPLY=()
  FIRST="${COMP_WORDS[COMP_CWORD]}"
  SECOND="${COMP_WORDS[COMP_CWORD+1]}"
  THIRD="${COMP_WORDS[COMP_CWORD+2]}"

  if test $COMP_CWORD -eq 1
  then
    COMPREPLY=( $(compgen -W "${COMMANDS[*]}" -- ${FIRST}) )
  elif test $COMP_CWORD -eq 2
  then
    case "$SECOND" in
      ${COMMANDS_CORE// /|}) return 0;;
      *) COMPREPLY=($(compgen -W "$SERVICES" -- ${SECOND}))
    esac
  elif test $COMP_CWORD -eq 3
  then
    case "$THIRD" in
      create)
        RESULTS=$(docker search $THIRD --limit 1 --format "{{.Name}}")
        echo $RESULTS
        COMPREPLY=($(compgen -W "$RESULTS" -- ${THIRD}))
    esac
  fi

  return 0
}

complete -F _pegaz pegaz pegazdev
