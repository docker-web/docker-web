UNINSTALL() {
  echo "[?] do you want to keep configs & backups ? (Y/n)"
  read ANSWER
  if [[ $ANSWER == "n" ]]
  then
    rm -rf $PATH_DOCKERWEB
  else
    ls $PATH_DOCKERWEB | grep -v -E "^(config\.sh|backup)$" | xargs -I {} rm -rf $PATH_DOCKERWEB/{}
  fi

  if [[ -f "$PATH_BASHFILE" ]]
  then
    sed -i "/docker-web/d" $PATH_BASHFILE
  fi

  echo "[√] docker-web successfully uninstalled"
}
