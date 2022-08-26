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
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm $1
    command -v yum 1>/dev/null && yum -y update && yum -y install $1
  fi
}

INSTALL_DOCKER() {
  # https://docs.docker.com/engine/install/
  if ! command -v docker 1>/dev/null
  then
    echo "[*] install docker :"
    apt update -y
    curl -fsSL https://get.docker.com | bash
    groupadd docker
    usermod -aG docker $USER
    if [[ -n $SUDO_USER ]]
    then
      usermod -aG docker $SUDO_USER
    fi
    echo "[*] install docker-compose :"
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chgrp docker /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    chmod 750 /usr/local/bin/docker-compose
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
    local ALIAS_PEGAZ="alias pegaz='bash $PATH_PEGAZ/cli.pegaz.sh \$1 \$2'"
    local ALIAS_PEGAZDEV="alias pegazdev='pwd | grep -q pegaz && cp -R ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'"
    local SOURCE_COMPLETION=". $PATH_PEGAZ/completion.sh"
    local PATH_USER_BASHRC=""

    echo "[*] install cli"

    echo $ALIAS_PEGAZ | tee -a $PATH_BASHRC  >/dev/null
    echo $ALIAS_PEGAZDEV | tee -a $PATH_BASHRC  >/dev/null
    echo $SOURCE_COMPLETION | tee -a $PATH_BASHRC  >/dev/null

    if [[ -n $SUDO_USER ]]
    then
      local PATH_SUDO_USER_BASHRC="/home/$SUDO_USER/.bashrc"
      echo $ALIAS_PEGAZ | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
      echo $ALIAS_PEGAZDEV | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
      echo $SOURCE_COMPLETION | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
    fi

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
echo "re-open a shell session to get autocomplete"
echo "[√] pegaz $VERSION successfully installed"
