EXECUTE() {
  TEST_CONFIG
  if [[ -d $PATH_DOCKERWEB_APPS/$2 ]]
  then
    cd $PATH_DOCKERWEB_APPS/$2
    [[ -f "$PATH_DOCKERWEB/$FILENAME_CONFIG" ]] && source "$PATH_DOCKERWEB/$FILENAME_CONFIG"
    [[ -f "$FILENAME_CONFIG" ]] && source "$FILENAME_CONFIG"
    [[ -f "$FILENAME_ENV" ]] && source "$FILENAME_ENV"
    docker-compose $1 2>&1 | grep -v "error while removing network"
  else
    echo "[x] $2 folder doesn't exist"
  fi
  local ACTION=("stop","down","pause","unpause")
  [[ "${ACTION[*]}" =~ "${1}" ]] && UPDATE_DASHBOARD $2
}
