BACKUP() {
  # test
  # if app exist
  APP_STATE=$(GET_STATE $1)
  if [ -n "$APP_STATE" ]
  then
    echo "[*] backup $1"

    local PATH_BACKUP_APP=$PATH_DOCKERWEB_BACKUP/$1
    mkdir -p $PATH_BACKUP_APP
    cd $PATH_DOCKERWEB_APPS/$1 && tar czf $PATH_BACKUP_APP/app.tar.gz *

    # 0. up and down
    [[ -z $(GET_STATE $1) ]] && EXECUTE "up -d" $1
    EXECUTE "pause" $1
    # 1. volume
    for VOLUME in $(EXECUTE "config --volumes" $1)
    do
      local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
      local NAME_VOLUME=${VOLUME[0]}
      if [[ -n $NAME_VOLUME ]]
      then
        docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_BACKUP_APP:/backup busybox tar czf /backup/$NAME_VOLUME.tar.gz /$NAME_VOLUME 2> /dev/null
      fi
    done
    # 2. tar & upload
    cd $PATH_BACKUP_APP && tar czf $PATH_DOCKERWEB_BACKUP/$1.tar.gz *
    [[ ! -z $STORJ_BUCKET_NAME ]] && uplink cp --progress $PATH_DOCKERWEB_BACKUP/$1.tar.gz sj://$STORJ_BUCKET_NAME

    # 3. drop backup if storj is configured
    [[ ! -z $STORJ_BUCKET_NAME ]] && rm -rf $PATH_DOCKERWEB_BACKUP/$1.tar.gz*
    EXECUTE "unpause" $1
    rm -rf $PATH_BACKUP_APP
    echo "[√] backup $1 done"
  fi
}
