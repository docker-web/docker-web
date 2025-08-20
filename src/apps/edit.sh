EDIT() {
  # edit docker-compose.yml
  EDITOR=$(which nano 2>/dev/null || which vi 2>/dev/null)
  $EDITOR $PATH_DOCKERWEB_APPS/$1/docker-compose.yml
  if [[ ! -f $PATH_DOCKERWEB_APPS/$1/$FILENAME_CONFIG ]]; then
    $EDITOR $PATH_DOCKERWEB_APPS/$1/FILENAME_ENV
  else
    $EDITOR $PATH_DOCKERWEB_APPS/$1/$FILENAME_CONFIG
  fi
}
