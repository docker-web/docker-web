#!/bin/bash
# curl -sL get.pegaz.io | sudo bash

source <(curl -s https://raw.githubusercontent.com/valerebron/pegaz/master/env.sh)

TEST_ROOT() {
  [[ ${EUID} -ne 0 ]] && printf "[x] must be run as root. Try 'curl -sL get.pegaz.io | sudo bash'\n" && exit
}

UPGRADE() {
  echo "[*] upgrade package manager"
  command -v apt 1>/dev/null && apt update --allow-releaseinfo-change -y && apt upgrade -y
  command -v pacman 1>/dev/null && pacman -Syy
  command -v yum 1>/dev/null && yum -y update && yum -y upgrade
}

INSTALL_PKG() {
  if ! command -v $1 1>/dev/null
  then
    echo "[*] install $1"
    command -v apt 1>/dev/null && apt -y install $1
    command -v pacman 1>/dev/null && pacman -Sy --noconfirm $1
    command -v yum 1>/dev/null && yum -y install $1
  fi
}

INSTALL_DOCKER() {
  if ! command -v "docker" 1>/dev/null
  then
    echo "[*] installing Docker..."
    curl -fsSL get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh

    if [[ $EUID -ne 0 ]]; then
      sudo usermod -aG docker "$(whoami)"

      echo "You must log out or restart to apply necessary Docker permissions changes."
      echo "Restart, then continue installing using this script."
      exit 1
    fi
  fi
}

INSTALL_DOCKER_COMPOSE() {
  if ! command -v "docker-compose" 1>/dev/null
  then
    echo "[*] installing Docker Compose..."

    curl -fsSL -o docker-compose https://github.com/docker/compose/releases/download/v2.4.1/docker-compose-linux-$(uname -m)

    ARCHITECTURE=amd64
    if [ "$(uname -m)" = "aarch64" ]; then
      ARCHITECTURE=arm64
    fi
    curl -fsSL -o docker-compose-switch https://github.com/docker/compose-switch/releases/download/v1.0.4/docker-compose-linux-${ARCHITECTURE}

    if [[ $EUID -ne 0 ]]; then
      sudo chmod a+x ./docker-compose
      sudo chmod a+x ./docker-compose-switch

      sudo mv ./docker-compose /usr/libexec/docker/cli-plugins/docker-compose
      sudo mv ./docker-compose-switch /usr/local/bin/docker-compose
    else
      chmod a+x ./docker-compose
      chmod a+x ./docker-compose-switch

      mv ./docker-compose /usr/libexec/docker/cli-plugins/docker-compose
      mv ./docker-compose-switch /usr/local/bin/docker-compose
    fi
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
  local ALIAS_PEGAZ="alias pegaz='bash $PATH_PEGAZ/cli.pegaz.sh \$1 \$2'"
  local ALIAS_PEGAZDEV="alias pegazdev='pwd | grep -q pegaz && cp -R ./* $PATH_PEGAZ && bash cli.pegaz.sh \$1 \$2'"
  local SOURCE_COMPLETION=". $PATH_PEGAZ/completion.sh"
  local PATH_USER_BASHRC=""

  echo "[*] install cli"

  if [[ -n $SUDO_USER ]]
  then
    local PATH_SUDO_USER_BASHRC="/home/$SUDO_USER/.bashrc"
    if ! echo $(cat $PATH_SUDO_USER_BASHRC) | grep -q cli.pegaz.sh
    then
      echo $ALIAS_PEGAZ | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
      echo $ALIAS_PEGAZDEV | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
      echo $SOURCE_COMPLETION | tee -a $PATH_SUDO_USER_BASHRC  >/dev/null
    fi
  fi
  if ! echo $(cat $PATH_BASHRC) | grep -q cli.pegaz.sh
  then
    echo $ALIAS_PEGAZ | tee -a $PATH_BASHRC  >/dev/null
    echo $ALIAS_PEGAZDEV | tee -a $PATH_BASHRC  >/dev/null
    echo $SOURCE_COMPLETION | tee -a $PATH_BASHRC  >/dev/null
    complete -F _pegaz pegaz pegazdev
  fi
}

TEST_ROOT
UPGRADE
INSTALL_PKG "curl"
INSTALL_DOCKER
INSTALL_DOCKER_COMPOSE
INSTALL_PKG "sed"
INSTALL_PKG "sudo"
INSTALL_PKG "git"
CLONE_PROJECT
INSTALL_CLI
echo "re-open a shell session to get autocomplete"
echo "[√] pegaz $VERSION successfully installed"
