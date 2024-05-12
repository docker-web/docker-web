UNINSTALL() {
  echo "[?] Are you sure to uninstall docker-web (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    sed -i "\|$PATH_DOCKERWEB|d" /home/root/.bashrc
    if [[ -n $SUDO_USER ]]
    then
      sed -i "\|$PATH_DOCKERWEB|d" "/home/$SUDO_USER/.bashrc"
    elif [[ -f "/home/$USER/.bashrc" ]]
    then
      sed -i "\|$PATH_DOCKERWEB|d" "/home/$USER/.bashrc"
    fi
    rm -rf $PATH_DOCKERWEB/services $PATH_DOCKERWEB/docs
    rm $PATH_DOCKERWEB/* 2> /dev/null # no -rf to delete only file & keep backup & media folder is exist
    echo "[√] docker-web successfully uninstalled"
  fi
}
