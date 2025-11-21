SOURCE_APP() {
  [[ -f "$PATH_APPS/$1/$FILENAME_ENV" ]] && source "$PATH_APPS/$1/$FILENAME_ENV"
  local env_file
  env_file=$(HAS_ENV_FILE "$PATH_APPS/$1")
  [[ -n "$env_file" ]] && source "$env_file"
}
