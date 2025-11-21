UNINSTALL() {
  echo "[?] Are you sure to uninstall docker-web (y/N)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    if [[ -f "~/$BASHFILE" ]]
    then
      sed -i "/docker-web/d" ~/$BASHFILE
    fi
    rm -rf $PATH_DOCKERWEB
    echo "[√] docker-web successfully uninstalled"
  fi
}
