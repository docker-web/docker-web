DEV_MODE() {
  [ "$(basename "$PWD")" = "docker-web" ] && IS_DEVMODE=true || IS_DEVMODE=false
  export IS_DEVMODE
  if [ "$IS_DEVMODE" = true ]  # if we work/dev from a folder named 'docker-web'
  then
    rsync -avz --quiet --exclude=".*/" --exclude="node_modules/" --exclude="config.sh" "./" "$PATH_DOCKERWEB/"  # we should copy files to app in /var/docker-web
  fi
}
