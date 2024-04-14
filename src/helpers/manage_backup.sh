MANAGE_BACKUP() {
  [[ -z $(GET_STATE $1) ]] && echo "$1 is not initialized" && exit 1
  mkdir -p $PATH_DOCKERWEB_BACKUP
  case $2 in
    storjbackup | storjrestore) SETUP_STORJ;;
  esac
  case $2 in
    backup | storjbackup)   EXECUTE "pause" $1;;
    restore | storjrestore) EXECUTE "stop" $1;;
  esac
  echo "[*] $2 $1"
  for VOLUME in $(EXECUTE "config --volumes" $1)
  do
    local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
    local NAME_VOLUME=${VOLUME[0]}
    if [[ -n $NAME_VOLUME ]]
    then
      local PATH_TARBALL="$PATH_DOCKERWEB_BACKUP/$NAME_VOLUME.tar.gz"
      [[ $2 == "backup" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_DOCKERWEB_BACKUP:/backup busybox tar czvf /backup/$NAME_VOLUME.tar.gz /$NAME_VOLUME
      [[ $2 == "storjbackup" ]] && uplink cp --progress -r $PATH_DOCKERWEB_BACKUP/$NAME_VOLUME.tar.gz sj://$STORJ_BUCKET_NAME
      [[ $2 == "storjrestore" ]] && uplink cp --progress -r sj://$STORJ_BUCKET_NAME/$NAME_VOLUME.tar.gz $PATH_DOCKERWEB_BACKUP
      [[ $2 == "restore" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_DOCKERWEB_BACKUP:/backup busybox sh -c "cd /$NAME_VOLUME && tar xvf /backup/$NAME_VOLUME.tar.gz --strip 1"
    fi
  done
  case $2 in
    backup | storjbackup)   EXECUTE "unpause" $1;;
    restore | storjrestore)  EXECUTE "start" $1;;
  esac
  echo "[√] $1 $2 done"
}
