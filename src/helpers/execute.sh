EXECUTE() {
  TEST_CONFIG
  if [[ -d $PATH_APPS/$2 ]]
  then
    cd "$PATH_APPS/$2"
    [[ -f "$PATH_DOCKERWEB/config.sh" ]] && source "$PATH_DOCKERWEB/config.sh"
    local env_file
    env_file=$(HAS_ENV_FILE ".")
    [[ -n "$env_file" ]] && source "$env_file"
    docker compose $1 2>&1 | grep -v "error while removing network"
  else
    echo "[x] $2 folder doesn't exist"
  fi

  local ACTION=("stop" "down" "pause" "unpause" "build")
  [[ " ${ACTION[*]} " =~ " ${1} " ]] && UPDATE_LAUNCHER "$2"
}
