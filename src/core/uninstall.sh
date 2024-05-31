UNINSTALL() {
  echo "[?] Are you sure to uninstall docker-web (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    if [[ -f "~/.bashrc" ]]
    then
      sed -i "/docker-web/d" ~/.bashrc
    fi
    rm -rf $PATH_DOCKERWEB
    echo "[√] docker-web successfully uninstalled"
  fi
}
