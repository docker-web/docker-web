#!/bin/bash
# curl -sL get.pegaz.io | sudo bash

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

TEST_ROOT() {
  if [[ $(whoami) != "root" ]]
  then
    echo "[x] you need to be root"
    exit
  fi
}

INSTALL_GIT() {
  if ! command -v git 1>/dev/null
  then
    echo "[*] install git"
    command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt -y install git
    command -v apk 1>/dev/null && apk update && apk add git
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm git
    command -v yum 1>/dev/null && yum -y update && yum -y install git
  fi
}

INSTALL_DOCKER() {
  if ! command -v docker 1>/dev/null
  then
    echo "[*] install docker"
    curl -fsSL https://get.docker.com | bash
    groupadd docker
    usermod -aG docker $USER
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod 750 /usr/local/bin/docker-compose
    [[ $? != 0 ]] && echo "[x] docker install failed, install it first"
  fi
}

CLONE_PROJECT() {
  if ! test -d $PATH_PEGAZ
  then
    mkdir -p $PATH_PEGAZ $MEDIA_DIR
    git clone $GITHUB_PEGAZ $PATH_PEGAZ
    chmod -R 750 $PATH_PEGAZ
    [[ -n $SUDO_USER ]] && chown -R $SUDO_USER:$SUDO_USER $PATH_PEGAZ
  fi
}

INSTALL_CLI() {
  if ! echo $(cat $PATH_BASHRC) | grep -q cli.pegaz.sh
  then
    echo "[*] install cli"
    echo "alias pegaz='bash $PATH_PEGAZ/cli.pegaz.sh \$1 \$2'" | tee -a $PATH_BASHRC  >/dev/null
    echo "alias pegazdev='pwd | grep -q pegaz && cp -pR ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'" | tee -a $PATH_BASHRC  >/dev/null
    echo ". $PATH_PEGAZ/completion.sh" | tee -a $PATH_BASHRC  >/dev/null
    complete -F _pegaz pegaz pegazdev
  fi
}

TEST_ROOT
INSTALL_GIT
INSTALL_DOCKER
CLONE_PROJECT
INSTALL_CLI
echo "[√] pegaz $VERSION successfully installed"
