BACKUP_OR_RESTORE() {
  if ! [[ -z $(GET_STATE $1) ]]
  then
    local PATH_BACKUP_SERVICE=$PATH_DOCKERWEB_BACKUP/$1
    mkdir -p $PATH_BACKUP_SERVICE
    [[ -z $STORJ_BUCKET_NAME ]] && SETUP_STORJ
    case $2 in
      backup)  EXECUTE "pause" $1;;
      restore) EXECUTE "stop" $1;;
    esac
    echo "[*] $2 $1"
    # 0. down & untar
    [[ $2 == "restore" ]] && uplink cp --progress -r sj://$STORJ_BUCKET_NAME/$1.tar.gz $PATH_DOCKERWEB_BACKUP
    [[ $2 == "restore" ]] && tar xf $PATH_DOCKERWEB_BACKUP/$1.tar.gz -C $PATH_BACKUP_SERVICE
    # 1. volume
    for VOLUME in $(EXECUTE "config --volumes" $1)
    do
      local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
      local NAME_VOLUME=${VOLUME[0]}
      if [[ -n $NAME_VOLUME ]]
      then
        [[ $2 == "backup" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_BACKUP_SERVICE:/backup busybox tar czf /backup/$NAME_VOLUME.tar.gz /$NAME_VOLUME 2> /dev/null
        [[ $2 == "restore" ]] && docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_BACKUP_SERVICE:/backup busybox sh -c "cd /$NAME_VOLUME && tar xf /backup/$NAME_VOLUME.tar.gz --strip 1"
      fi
    done
    # 2. service
    [[ $2 == "backup" ]] && cd $PATH_DOCKERWEB_SERVICES/$1 && tar czf $PATH_BACKUP_SERVICE/service.tar.gz *
    [[ $2 == "restore" ]] && rm -rf $PATH_DOCKERWEB_SERVICES/$1/* && tar xf $PATH_BACKUP_SERVICE/service.tar.gz -C $PATH_DOCKERWEB_SERVICES/$1
    # 3. tar & up
    [[ $2 == "backup" ]] && cd $PATH_BACKUP_SERVICE && tar czf $PATH_DOCKERWEB_BACKUP/$1.tar.gz *
    [[ $2 == "backup" ]] && uplink cp --progress $PATH_DOCKERWEB_BACKUP/$1.tar.gz sj://$STORJ_BUCKET_NAME
    case $2 in
      backup)   EXECUTE "unpause" $1;;
      restore)  EXECUTE "start" $1;;
    esac
    rm -rf $PATH_BACKUP_SERVICE
    echo "[√] $1 $2 done"
  fi
}
