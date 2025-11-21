EDIT() {
  # edit docker-compose.yml
  EDITOR=$(which nano 2>/dev/null || which vi 2>/dev/null)
  $EDITOR $PATH_APPS/$1/docker-compose.yml
  if [[ ! -f $PATH_APPS/$1/$FILENAME_ENV ]]; then
    local env_file
    env_file=$(HAS_ENV_FILE "$PATH_APPS/$1")
    [[ -n "$env_file" ]] && $EDITOR "$env_file"
  else
    $EDITOR $PATH_APPS/$1/$FILENAME_ENV
  fi
}
