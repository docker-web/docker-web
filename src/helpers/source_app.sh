SOURCE_APP() {
  local env_file
  env_file=$(HAS_ENV_FILE "$PATH_APPS/$1")
  [[ -n "$env_file" ]] && source "$env_file"
}
