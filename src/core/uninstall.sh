UNINSTALL() {
  echo "[?] Are you sure to uninstall docker-web (Y/n)"
  read ANSWER
  if [[ $ANSWER == "Y" || $ANSWER == "y" ]]
  then
    sudo sed -i "\|$PATH_DOCKERWEB|d" /home/root/.bashrc
    if [[ -n $SUDO_USER ]]
    then
      sudo sed -i "\|$PATH_DOCKERWEB|d" "/home/$SUDO_USER/.bashrc"
    elif [[ -f "/home/$USER/.bashrc" ]]
    then
      sudo sed -i "\|$PATH_DOCKERWEB|d" "/home/$USER/.bashrc"
    fi
    sudo rm -rf $PATH_DOCKERWEB/services $PATH_DOCKERWEB/docs
    sudo rm $PATH_DOCKERWEB/* 2> /dev/null # no -rf to delete only file & keep backup & media folder is exist
    echo "[√] docker-web successfully uninstalled"
  fi
}
