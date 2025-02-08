DEV_MODE() {
  [ "$(basename "$PWD")" = "docker-web" ] && IS_DEVMODE=true || IS_DEVMODE=false
  export IS_DEVMODE
  if [ $IS_DEVMODE ]  # if we work/dev from a folder named 'docker-web'
  then
    FOLDERS_TO_EXCLUDE=(.git node_modules)
    FILES_TO_EXCLUDE=(config.sh)
    for i in *
    do
      SKIP=""
      for j in "${FOLDERS_TO_EXCLUDE[@]}"
      do
        [ "$i" == "$j" ] && SKIP=1 && break
      done
      for j in "${FILES_TO_EXCLUDE[@]}"
      do
        [ "$i" == "$j" ] && SKIP=1 && break
      done
      [ -z "$SKIP" ] && cp -R "$i" "$PATH_DOCKERWEB/" # we should copy files to app in /var/docker-web
    done
  fi
}
