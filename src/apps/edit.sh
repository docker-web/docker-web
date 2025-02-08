EDIT() {
  # edit docker-compose.yml
  EDITOR=$(which nano 2>/dev/null || which vi 2>/dev/null)
  $EDITOR $PATH_DOCKERWEB_APPS/$1/docker-compose.yml
  $IS_DEVMODE && cp $PATH_DOCKERWEB_APPS/$1/docker-compose.yml ./apps/$1/
  if [[ ! -f $PATH_DOCKERWEB_APPS/$1/$FILENAME_CONFIG ]]; then
    $EDITOR $PATH_DOCKERWEB_APPS/$1/FILENAME_ENV
    $IS_DEVMODE && cp $PATH_DOCKERWEB_APPS/$1/FILENAME_ENV ./apps/$1/
  else
    $EDITOR $PATH_DOCKERWEB_APPS/$1/$FILENAME_CONFIG
    $IS_DEVMODE && cp $PATH_DOCKERWEB_APPS/$1/$FILENAME_CONFIG ./apps/$1/
  fi
}
