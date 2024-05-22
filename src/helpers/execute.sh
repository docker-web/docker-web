EXECUTE() {
  TEST_CONFIG
  if [[ -d $PATH_DOCKERWEB_APPS/$2 ]]
  then
    cd $PATH_DOCKERWEB_APPS/$2
    [[ -f "$PATH_DOCKERWEB/config.sh" ]] && source "$PATH_DOCKERWEB/config.sh"
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
