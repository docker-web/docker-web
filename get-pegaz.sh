#!/bin/sh
# v0.1
# sudo curl -fsSL https://raw.githubusercontent.com/valerebron/pegaz/master/get-pegaz.sh -o get-pegaz.sh && sudo sh get-pegaz.sh
# sudo curl get.pegaz.io -o get.pegaz.sh && sudo sh get.pegaz.sh

message() {
  CS='\033[1;00;40m'  # color start
  CE='\033[0m'        # color end

  echo $1
}

PEGAZ_GITHUB="https://github.com/valerebron/pegaz"
PEGAZ_PATH="/etc/pegaz"

TEST_ROOT() {
  if ! echo $(whoami) | grep -q root
  then
    message "you need to be root"
    exit
  fi
}

INSTALL_GIT() {
  if ! type git 1>/dev/null
  then
    if type apt 1>/dev/null
    then
      message "install GIT"
      apt update -y && apt upgrade -y && apt install -y git
    elif type apk 1>/dev/null
    then
      message "install GIT"
      apk update && apk add git
    else
      message "install git first: https://github.com/git-guides/install-git"
      return 3
    fi
  else
    message "skip GIT"
    return 0
  fi
}

INSTALL_DOCKER() {
  if ! type docker 1>/dev/null
  then
    message "install DOCKER"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
    rm get-docker.sh
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  else
    message "skip DOCKER"
  fi
}

CREATE_NETWORK() {
  if ! echo $(docker network ls) | grep -q pegaz
  then
    message "create NETWORK"
    docker network create pegaz
  fi
}

CLONE_PROJECT() {
  if ! test -e $PEGAZ_PATH/pegaz.sh
  then
    message "clone PROJECT"
    git clone $PEGAZ_GITHUB $PEGAZ_PATH
    chmod +x $PEGAZ_PATH/pegaz.sh
  fi
}

CREATE_ALIAS() {
  if ! echo $(cat /etc/bash.bashrc) | grep -q pegaz.sh
  then
    message "create ALIAS"
    echo "alias pegaz='sh $PEGAZ_PATH/pegaz.sh \$1 \$2'" >> /etc/bash.bashrc
    alias pegaz="sh $PEGAZ_PATH/pegaz.sh \$1 \$2;pegaz"
    source /etc/bash.bashrc
  fi
}

TEST_ROOT
INSTALL_GIT
INSTALL_DOCKER
CREATE_NETWORK
CLONE_PROJECT
CREATE_ALIAS

sh $PEGAZ_PATH/pegaz.sh -h
