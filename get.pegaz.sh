#!/bin/bash
# v1
# curl -fsSL get.pegaz.io -o get.pegaz.sh && bash get.pegaz.sh

PEGAZ_GITHUB="https://github.com/valerebron/pegaz"
PEGAZ_PATH="/etc/pegaz"

TEST_ROOT() {
  if ! echo $(whoami) | grep -q root
  then
    echo "you need to be root"
    exit
  fi
}

INSTALL_GIT() {
  if ! type git 1>/dev/null
  then
    if type apt 1>/dev/null
    then
      echo "install GIT"
      apt update -y && apt upgrade -y && apt install -y git
    elif type apk 1>/dev/null
    then
      echo "install GIT"
      apk update && apk add git
    else
      echo "install git first: https://github.com/git-guides/install-git"
      return 3
    fi
  else
    echo "skip GIT"
    return 0
  fi
}

INSTALL_DOCKER() {
  if ! type docker 1>/dev/null
  then
    echo "install DOCKER"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    rm get-docker.sh
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  else
    echo "skip DOCKER"
  fi
}

CREATE_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    echo "create NETWORK"
    docker network create pegaz
  fi
}

CLONE_PROJECT() {
  if ! test -d $PEGAZ_PATH
  then
    echo "clone PROJECT"
    git clone $PEGAZ_GITHUB $PEGAZ_PATH
    chmod +x $PEGAZ_PATH/pegaz-cli.sh
    chmod 700 $PEGAZ_PATH/env.sh
  else
    echo "skip CLONE PROJECT"
  fi
}

CREATE_ALIAS() {
  if ! echo $(cat /etc/bash.bashrc) | grep -q pegaz-cli.sh
  then
    echo "create ALIAS"
    echo "alias pegaz='sh $PEGAZ_PATH/pegaz-cli.sh \$1 \$2'" >> /etc/bash.bashrc
    alias pegaz="sh $PEGAZ_PATH/pegaz-cli.sh \$1 \$2;pegaz"
    source /etc/bash.bashrc
  else
    echo "skip ALIAS"
  fi
}

TEST_ROOT
INSTALL_GIT
INSTALL_DOCKER
CREATE_NETWORK
CLONE_PROJECT
CREATE_ALIAS

bash $PEGAZ_PATH/pegaz-cli.sh -h
