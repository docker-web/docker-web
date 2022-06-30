#!/bin/bash
# curl -sL get.pegaz.io | bash

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

INSTALL_DEPS() {
  command -v apt 1>/dev/null && apt update && apt install sudo git
  command -v apk 1>/dev/null && apk update && apk add sudo git
  command -v pacman 1>/dev/null && pacman -Sy sudo git
  command -v yum 1>/dev/null && yum update && yum install sudo git
}

INSTALL_DOCKER() {
  if ! type docker 1>/dev/null
  then
    echo "install docker"
    curl -fsSL https://get.docker.com | bash
    usermod -aG docker $USER
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  fi
}

CLONE_PROJECT() {
  if ! test -d $PATH_PEGAZ
  then
    sudo mkdir -p $PATH_PEGAZ $DATA_DIR
    sudo git clone $GITHUB_PEGAZ $PATH_PEGAZ
    sudo chown -R $USER:$USER $PATH_PEGAZ
    sudo chmod -R 750 $PATH_PEGAZ
  fi
}

INSTALL_CLI() {
  if ! echo $(cat $PATH_BASHRC) | grep -q cli.pegaz.sh
  then
    echo "install cli"
    echo "alias pegaz='bash $PATH_PEGAZ/cli.pegaz.sh \$1 \$2'" | sudo tee -a $PATH_BASHRC  >/dev/null
    echo "alias pegazdev='pwd | grep -q pegaz && rm -rf $PATH_PEGAZ/* && cp -ra ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'" | sudo tee -a $PATH_BASHRC  >/dev/null
    echo ". $PATH_PEGAZ/completion.sh" | sudo tee -a $PATH_BASHRC  >/dev/null
    complete -F _pegaz pegaz pegazdev
    exec bash
  fi
}

INSTALL_DEPS
INSTALL_DOCKER
CLONE_PROJECT
INSTALL_CLI
echo "pegaz $VERSION successfully installed"
