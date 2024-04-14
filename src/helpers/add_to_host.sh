ADD_TO_HOSTS() {
  if $IS_DOCKERWEBDEV
  then
    [[ -f "/etc/hosts" ]] && local PATH_HOSTFILE="/etc/hosts"
    [[ -f "/etc/host" ]] && local PATH_HOSTFILE="/etc/host"
    SOURCE_SERVICE $1
    if [[ $DOMAIN == *$MAIN_DOMAIN* && -f $PATH_HOSTFILE ]]
    then
        if ! grep -q "$DOMAIN" $PATH_HOSTFILE
        then
          echo "127.0.0.1    $DOMAIN" | sudo tee -a $PATH_HOSTFILE >> /dev/null
        fi
    fi
  fi
}
