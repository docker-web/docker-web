#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/docker-web/docker-web/master/env.sh)

TEST_CMD() {
  if ! command -v $1 1>/dev/null
  then
    echo "install $1 first"
  fi
}

CLONE_PROJECT() {
  echo "[*] download"
  mkdir -p $PATH_DOCKERWEB $MEDIA_DIR
  chmod -R 750 $PATH_DOCKERWEB $MEDIA_DIR
}

INSTALL_CLI() {
  echo "[*] install"
  if [ -e "~/.bashrc" ] && ! grep -q "start.pegaz.sh" "~/.bashrc"; then
    echo "source $PATH_DOCKERWEB/start.pegaz.sh"  | tee -a ~/.bashrc
  elif [ -e "~/.bash_profile" ] && ! grep -q "start.pegaz.sh" "~/.bash_profile"; then
    echo "source $PATH_DOCKERWEB/start.pegaz.sh"  | tee -a ~/.bash_profile
  fi
  echo "[*] init"
  [ -e "$PATH_DOCKERWEB/start.pegaz.sh" ] && source $PATH_DOCKERWEB/start.pegaz.sh
}

TEST_CMD "curl"
TEST_CMD "docker"
CLONE_PROJECT
INSTALL_CLI
echo "[√] docker-web successfully installed"
echo "you need to restart your computer before using docker-web"
