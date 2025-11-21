APP_INFOS() {
  local env_file
  env_file=$(HAS_ENV_FILE "$PATH_APPS/$1")
  if [[ -n "$env_file" ]]; then
    if [[ $1 == "proxy" ]]; then
      echo -e "[√] $1 is up"
    else
      SOURCE_APP $1
      echo "[√] $1 is up"
      echo "http://$DOMAIN"
      echo "http://127.0.0.1:$PORT"
    fi
  fi
}
