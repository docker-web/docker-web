RESTORE() {
  # test
  # restore if backup exist
  if [ -f "$PATH_DOCKERWEB_BACKUP/$1.tar.gz" ]
  then
    local PATH_BACKUP_APP=$PATH_DOCKERWEB_BACKUP/$1
    mkdir -p $PATH_BACKUP_APP
    echo "[*] restore $1"
    # 0. download & untar
    [[ ! -z $STORJ_BUCKET_NAME ]] && uplink cp --progress -r sj://$STORJ_BUCKET_NAME/$1.tar.gz $PATH_DOCKERWEB_BACKUP
    tar xf $PATH_DOCKERWEB_BACKUP/$1.tar.gz -C $PATH_BACKUP_APP

    # 1. app
    [[ -f "$PATH_BACKUP_APP/app.tar.gz" ]] && rm -rf $PATH_BACKUP_APP/$1/* && tar xf $PATH_BACKUP_APP/app.tar.gz -C $PATH_DOCKERWEB_APPS/$1

    # 2. up and down
    [[ -z $(GET_STATE $1) ]] && EXECUTE "up -d" $1
    EXECUTE "stop" $1
    # 3. volume
    for VOLUME in $(EXECUTE "config --volumes" $1)
    do
      local VOLUME=($(docker volume inspect --format "{{.Name}} {{.Mountpoint}}" "$1_$VOLUME" 2> /dev/null))
      local NAME_VOLUME=${VOLUME[0]}
      if [[ -n $NAME_VOLUME ]]
      then
        docker run --rm -v $NAME_VOLUME:/$NAME_VOLUME -v $PATH_BACKUP_APP:/backup busybox sh -c "cd /$NAME_VOLUME && tar xf /backup/$NAME_VOLUME.tar.gz --strip 1"
      fi
    done

    # 4. drop backup if storj is configured
    EXECUTE "start" $1
    rm -rf $PATH_BACKUP_APP
    echo "[√] $1 restore done"
  fi
}
