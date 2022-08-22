#!/bin/bash
# curl -sL get.pegaz.io | sudo bash

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

TEST_ROOT() {
  [[ ${EUID} -ne 0 ]] && printf "[x] must be run as root. Try 'curl -sL get.pegaz.io | sudo bash'\n" && exit
}

INSTALL_PKG() {
  if ! command -v $1 1>/dev/null
  then
    echo "[*] install $1"
    command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt -y install $1
    command -v apk 1>/dev/null && apk update && apk add $1
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm $1
    command -v yum 1>/dev/null && yum -y update && yum -y install $1
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
    echo "alias pegazdev='pwd | grep -q pegaz && cp -R ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'" | tee -a $PATH_BASHRC  >/dev/null
    echo ". $PATH_PEGAZ/completion.sh" | tee -a $PATH_BASHRC  >/dev/null
    complete -F _pegaz pegaz pegazdev
  fi
}

TEST_ROOT
INSTALL_PKG "curl"
INSTALL_PKG "sed"
INSTALL_PKG "sudo"
INSTALL_PKG "git"
INSTALL_DOCKER
CLONE_PROJECT
INSTALL_CLI
echo "[√] pegaz $VERSION successfully installed"
